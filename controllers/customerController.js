const mongoose = require('mongoose');
const Customer = require('../models/Customer');
const User = require('../models/User');
const Appointment = require('../models/Appointment');
const Branch = require('../models/Branch');
const Service = require('../models/Service');
const Stylist = require('../models/Stylist');
const QuizResult = require('../models/QuizResult');
const {
  QUIZ_QUESTIONS,
  determineArchetypeAndSummary,
  matchProducts,
  matchStylists,
  matchServices,
  validateQuizAnswers
} = require('../services/recommendationService');


// @desc    Get current authenticated customer profile
// @route   GET /api/customers/profile
// @access  Private (Customer)
exports.getProfile = async (req, res) => {
  try {
    // Identify logged-in user from auth middleware
    const userId = req.user._id;

    let customer = await Customer.findOne({ userId });

    // Self-healing: if customer profile doesn't exist yet for a customer user
    if (!customer) {
      if (req.user.role === 'customer') {
        const globalCustomerId = await Customer.generateGlobalCustomerId();
        customer = await Customer.create({
          customerId: globalCustomerId,
          userId: req.user._id,
          name: req.user.name,
          email: req.user.email,
          phone: req.user.phone || '',
          preferences: {
            hair: [],
            nails: [],
            skin: [],
            makeup: []
          }
        });
      } else {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found for this account'
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: {
        customerId: customer.customerId,
        userId: customer.userId,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        dateOfBirth: customer.dateOfBirth,
        profilePhoto: customer.profilePhoto,
        preferences: customer.preferences,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching customer profile'
    });
  }
};

// @desc    Update current authenticated customer profile
// @route   PUT /api/customers/profile
// @access  Private (Customer)
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user._id;

    let customer = await Customer.findOne({ userId });

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer profile not found'
      });
    }

    const {
      name,
      phone,
      dateOfBirth,
      profilePhoto,
      preferences,
      // Restricted fields:
      customerId: attemptedCustomerId,
      userId: attemptedUserId,
      role: attemptedRole,
      password: attemptedPassword
    } = req.body;

    // Explicit security check: Prevent tampering with immutable identifiers
    if (
      attemptedCustomerId !== undefined &&
      attemptedCustomerId !== customer.customerId
    ) {
      return res.status(400).json({
        success: false,
        message: 'Modification of global customerId is not permitted'
      });
    }

    if (
      attemptedUserId !== undefined &&
      attemptedUserId.toString() !== customer.userId.toString()
    ) {
      return res.status(400).json({
        success: false,
        message: 'Modification of userId is not permitted'
      });
    }

    // Apply allowed updates
    if (name !== undefined) customer.name = name.trim();
    if (phone !== undefined) customer.phone = phone.trim();
    if (dateOfBirth !== undefined) customer.dateOfBirth = dateOfBirth;
    if (profilePhoto !== undefined) customer.profilePhoto = profilePhoto.trim();

    // Optionally update preferences if provided in profile payload
    if (preferences && typeof preferences === 'object') {
      if (Array.isArray(preferences.hair)) customer.preferences.hair = preferences.hair;
      if (Array.isArray(preferences.nails)) customer.preferences.nails = preferences.nails;
      if (Array.isArray(preferences.skin)) customer.preferences.skin = preferences.skin;
      if (Array.isArray(preferences.makeup)) customer.preferences.makeup = preferences.makeup;
    }

    await customer.save();

    // Keep corresponding User record in sync for common attributes
    if (name !== undefined || phone !== undefined) {
      const userUpdate = {};
      if (name !== undefined) userUpdate.name = customer.name;
      if (phone !== undefined) userUpdate.phone = customer.phone;
      await User.findByIdAndUpdate(userId, userUpdate);
    }

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        customerId: customer.customerId,
        userId: customer.userId,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        dateOfBirth: customer.dateOfBirth,
        profilePhoto: customer.profilePhoto,
        preferences: customer.preferences,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while updating customer profile'
    });
  }
};

// @desc    Get customer preferences
// @route   GET /api/customers/preferences
// @access  Private (Customer)
exports.getPreferences = async (req, res) => {
  try {
    const customer = await Customer.findOne({ userId: req.user._id });
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    return res.status(200).json({
      success: true,
      data: customer.preferences
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching preferences'
    });
  }
};

// @desc    Update customer preferences
// @route   PUT /api/customers/preferences
// @access  Private (Customer)
exports.updatePreferences = async (req, res) => {
  try {
    const customer = await Customer.findOne({ userId: req.user._id });
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    const { hair, nails, skin, makeup } = req.body;

    if (hair && Array.isArray(hair)) customer.preferences.hair = hair;
    if (nails && Array.isArray(nails)) customer.preferences.nails = nails;
    if (skin && Array.isArray(skin)) customer.preferences.skin = skin;
    if (makeup && Array.isArray(makeup)) customer.preferences.makeup = makeup;

    await customer.save();

    return res.status(200).json({
      success: true,
      message: 'Preferences updated successfully',
      data: customer.preferences
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while updating preferences'
    });
  }
};

// @desc    Get customer treatment history across all salon branches (Centralized Identity)
// @route   GET /api/customers/history
// @access  Private (Customer)
exports.getTreatmentHistory = async (req, res) => {
  try {
    const userId = req.user._id;

    // Resolve authenticated customer from JWT session
    let customer = await Customer.findOne({ userId });

    // Self-healing: if customer profile doesn't exist yet for a customer user
    if (!customer) {
      if (req.user.role === 'customer') {
        const globalCustomerId = await Customer.generateGlobalCustomerId();
        customer = await Customer.create({
          customerId: globalCustomerId,
          userId: req.user._id,
          name: req.user.name,
          email: req.user.email,
          phone: req.user.phone || '',
          preferences: { hair: [], nails: [], skin: [], makeup: [] }
        });
      } else {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found for this account'
        });
      }
    }

    // Query completed appointments strictly scoped to the authenticated customer's global customerId
    // Centralized customer identity: retrieves eligible records across ALL branches
    const query = {
      customerId: customer.customerId,
      status: 'Completed'
    };

    if (req.query.branchId) {
      query.branchId = req.query.branchId;
    }

    const appointments = await Appointment.find(query)
      .sort({ date: -1, createdAt: -1 })
      .populate('branchId', 'branchId name address phone openingTime closingTime status')
      .populate('serviceId', 'serviceId name description duration price category availability')
      .populate({
        path: 'stylistId',
        select: 'stylistId specialization experience rating userId',
        populate: {
          path: 'userId',
          select: 'name email'
        }
      });

    // Format records safely, handling missing optional references gracefully
    let formattedRecords = appointments.map((appt) => {
      const service = appt.serviceId || null;
      const branch = appt.branchId || null;
      const stylist = appt.stylistId || null;
      const stylistUser = stylist && stylist.userId ? stylist.userId : null;

      return {
        id: appt._id,
        appointmentId: appt.appointmentId,
        date: appt.date,
        startTime: appt.startTime,
        endTime: appt.endTime,
        status: appt.status,
        service: {
          id: service ? service._id : null,
          serviceId: service ? service.serviceId : 'N/A',
          name: service ? service.name : 'Bespoke Salon Treatment',
          description: service ? service.description : '',
          duration: service ? service.duration : 60,
          price: service ? service.price : 0,
          category: service ? service.category : 'Other',
          availability: service ? (service.availability !== false) : true
        },
        branch: {
          id: branch ? branch._id : null,
          branchId: branch ? branch.branchId : 'N/A',
          name: branch ? branch.name : 'VIORA Salon',
          address: branch ? branch.address : 'Salon Branch',
          phone: branch ? branch.phone : ''
        },
        stylist: {
          id: stylist ? stylist._id : null,
          stylistId: stylist ? stylist.stylistId : null,
          name: stylistUser ? stylistUser.name : 'Assigned Stylist',
          rating: stylist ? stylist.rating : 5.0
        }
      };
    });

    // Optional category filtering
    if (req.query.category && req.query.category.toLowerCase() !== 'all') {
      const targetCategory = req.query.category.toLowerCase();
      formattedRecords = formattedRecords.filter(item =>
        item.service.category.toLowerCase() === targetCategory
      );
    }

    return res.status(200).json({
      success: true,
      customerId: customer.customerId,
      count: formattedRecords.length,
      data: formattedRecords
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching treatment history'
    });
  }
};

// @desc    Retrieve rebook context and prefill data for an eligible past service
// @route   GET /api/customers/history/:appointmentId/rebook
// @access  Private (Customer)
exports.getRebookContext = async (req, res) => {
  try {
    const userId = req.user._id;
    const { appointmentId } = req.params;

    const customer = await Customer.findOne({ userId });
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    // Find the appointment by appointmentId or mongo _id
    let appointment;
    if (mongoose.Types.ObjectId.isValid(appointmentId)) {
      appointment = await Appointment.findOne({
        _id: appointmentId,
        customerId: customer.customerId
      });
    }
    if (!appointment) {
      appointment = await Appointment.findOne({
        appointmentId,
        customerId: customer.customerId
      });
    }

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment record not found in customer history'
      });
    }

    // Only completed appointments can be rebooked from treatment history
    if (appointment.status !== 'Completed') {
      return res.status(400).json({
        success: false,
        message: `Only completed treatments can be rebooked. Current status: ${appointment.status}`
      });
    }

    // Populate service, branch, stylist
    await appointment.populate([
      { path: 'branchId', select: 'branchId name address phone status' },
      { path: 'serviceId', select: 'serviceId name description duration price category availability' },
      {
        path: 'stylistId',
        select: 'stylistId specialization rating userId',
        populate: { path: 'userId', select: 'name email' }
      }
    ]);

    const service = appointment.serviceId;
    const branch = appointment.branchId;
    const stylist = appointment.stylistId;
    const stylistUser = stylist && stylist.userId ? stylist.userId : null;

    if (!service) {
      return res.status(404).json({
        success: false,
        message: 'Original service record is no longer available'
      });
    }

    // Check service availability and branch status
    const isServiceAvailable = service.availability !== false;
    const isBranchActive = !branch || branch.status !== 'inactive';

    const rebookData = {
      service: {
        id: service._id,
        serviceId: service.serviceId,
        name: service.name,
        price: service.price,
        duration: service.duration,
        category: service.category,
        available: isServiceAvailable
      },
      branch: {
        id: branch ? branch._id : null,
        branchId: branch ? branch.branchId : null,
        name: branch ? branch.name : 'VIORA Salon',
        address: branch ? branch.address : '',
        active: isBranchActive
      },
      preferredStylist: stylist ? {
        id: stylist._id,
        stylistId: stylist.stylistId,
        name: stylistUser ? stylistUser.name : 'Preferred Stylist',
        rating: stylist.rating
      } : null,
      sourceAppointmentId: appointment.appointmentId
    };

    return res.status(200).json({
      success: true,
      eligible: isServiceAvailable && isBranchActive,
      data: rebookData,
      bookingModuleAvailable: false,
      integrationStatus: 'Ready for integration with Booking Module flow (availability scheduling and stylist selection)'
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while preparing rebook context'
    });
  }
};

// =========================================================================
// DAY 4: BEAUTY QUIZ, RESULTS & PERSONALIZED RECOMMENDATIONS (PERSON 2)
// =========================================================================

// @desc    Get standardized Beauty Quiz questions schema
// @route   GET /api/customers/quiz/questions
// @access  Private (Customer)
exports.getQuizQuestions = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      count: QUIZ_QUESTIONS.length,
      data: QUIZ_QUESTIONS
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while retrieving quiz questions'
    });
  }
};

// @desc    Submit Beauty Quiz answers and calculate deterministic recommendations
// @route   POST /api/customers/quiz
// @access  Private (Customer)
exports.submitQuiz = async (req, res) => {
  try {
    const userId = req.user._id;

    let customer = await Customer.findOne({ userId });
    if (!customer) {
      if (req.user.role === 'customer') {
        const globalCustomerId = await Customer.generateGlobalCustomerId();
        customer = await Customer.create({
          customerId: globalCustomerId,
          userId: req.user._id,
          name: req.user.name,
          email: req.user.email,
          phone: req.user.phone || '',
          preferences: { hair: [], nails: [], skin: [], makeup: [] }
        });
      } else {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found for this account'
        });
      }
    }

    // Validate answers payload
    const validation = validateQuizAnswers(req.body);
    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Quiz validation failed',
        errors: validation.errors
      });
    }

    const { hairType, hairConcerns = [], skinType, goals = [], sensitivities = [] } = req.body;

    // 1. Synthesize archetype, summary, and profile chips
    const { archetype, summary, chips } = determineArchetypeAndSummary(req.body);

    // 2. Compute suitable products matching answers & sensitivities
    const recommendedProducts = matchProducts(req.body, customer.preferences);

    // 3. Compute matching stylists from Stylist database records
    const recommendedStylists = await matchStylists(req.body, customer.preferences, Stylist);

    // 4. Compute recommended services from Service database records
    const recommendedServices = await matchServices(req.body, Service);

    const recommendations = {
      products: recommendedProducts,
      stylists: recommendedStylists,
      services: recommendedServices
    };

    // 5. Persist or update QuizResult document strictly linked to customerId
    let quizResult = await QuizResult.findOne({ customerId: customer.customerId });

    if (quizResult) {
      quizResult.answers = {
        hairType,
        hairConcerns,
        skinType,
        goals,
        sensitivities
      };
      quizResult.profileArchetype = archetype;
      quizResult.summary = summary;
      quizResult.profileChips = chips;
      quizResult.recommendations = recommendations;
      quizResult.retakeCount = (quizResult.retakeCount || 0) + 1;
      await quizResult.save();
    } else {
      quizResult = await QuizResult.create({
        customerId: customer.customerId,
        userId: customer.userId,
        answers: {
          hairType,
          hairConcerns,
          skinType,
          goals,
          sensitivities
        },
        profileArchetype: archetype,
        summary,
        profileChips: chips,
        recommendations,
        retakeCount: 0
      });
    }

    // 6. Seamless synchronization with Customer.preferences
    let preferencesUpdated = false;
    hairConcerns.forEach((c) => {
      if (!customer.preferences.hair.includes(c)) {
        customer.preferences.hair.push(c);
        preferencesUpdated = true;
      }
    });
    if (skinType && !customer.preferences.skin.includes(skinType)) {
      customer.preferences.skin.push(skinType);
      preferencesUpdated = true;
    }
    goals.forEach((g) => {
      if (!customer.preferences.hair.includes(g) && !customer.preferences.skin.includes(g)) {
        customer.preferences.hair.push(g);
        preferencesUpdated = true;
      }
    });

    if (preferencesUpdated) {
      await customer.save();
    }

    return res.status(201).json({
      success: true,
      message: 'Beauty Quiz submitted and personalized recommendations generated successfully',
      data: quizResult
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while submitting quiz'
    });
  }
};

// @desc    Get customer latest Beauty Quiz result & recommendations
// @route   GET /api/customers/quiz
// @access  Private (Customer)
exports.getQuizResult = async (req, res) => {
  try {
    const userId = req.user._id;
    const customer = await Customer.findOne({ userId });

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    const quizResult = await QuizResult.findOne({ customerId: customer.customerId })
      .sort({ createdAt: -1 });

    if (!quizResult) {
      return res.status(200).json({
        success: true,
        data: null,
        message: 'No quiz taken yet'
      });
    }

    return res.status(200).json({
      success: true,
      data: quizResult
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching quiz result'
    });
  }
};

// @desc    Get personalized product and stylist recommendations
// @route   GET /api/customers/recommendations
// @access  Private (Customer)
exports.getRecommendations = async (req, res) => {
  try {
    const userId = req.user._id;
    const customer = await Customer.findOne({ userId });

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    // Try finding latest quiz result first
    const quizResult = await QuizResult.findOne({ customerId: customer.customerId })
      .sort({ createdAt: -1 });

    if (quizResult) {
      return res.status(200).json({
        success: true,
        source: 'quiz_results',
        archetype: quizResult.profileArchetype,
        summary: quizResult.summary,
        profileChips: quizResult.profileChips,
        data: quizResult.recommendations
      });
    }

    // If quiz hasn't been taken yet, generate baseline recommendations using saved preferences
    const defaultAnswers = {
      hairType: '2B Wavy',
      hairConcerns: customer.preferences.hair.length > 0 ? customer.preferences.hair : ['Frizz Control'],
      skinType: customer.preferences.skin.length > 0 ? customer.preferences.skin[0] : 'Combination',
      goals: ['Deep Hydration', 'Radiant Glow'],
      sensitivities: []
    };

    const { archetype, summary, chips } = determineArchetypeAndSummary(defaultAnswers);
    const products = matchProducts(defaultAnswers, customer.preferences);
    const stylists = await matchStylists(defaultAnswers, customer.preferences, Stylist);
    const services = await matchServices(defaultAnswers, Service);

    return res.status(200).json({
      success: true,
      source: 'preferences_baseline',
      archetype,
      summary,
      profileChips: chips,
      data: {
        products,
        stylists,
        services
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching recommendations'
    });
  }
};

// @desc    Retake or reset Beauty Quiz
// @route   POST /api/customers/quiz/retake
// @access  Private (Customer)
exports.retakeQuiz = async (req, res) => {
  try {
    const userId = req.user._id;
    const customer = await Customer.findOne({ userId });

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Ready to retake beauty quiz',
      data: {
        questions: QUIZ_QUESTIONS
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while preparing quiz retake'
    });
  }
};

// ========================================================
// DAY 5: ADMIN CUSTOMER MANAGEMENT CONTROLLER METHODS
// Role-based authorization: admin or branch_manager
// ========================================================

// @desc    Get salon-wide customer management overview & analytics
// @route   GET /api/customers/admin/overview
// @access  Private (Admin / Branch Manager)
exports.getAdminOverview = async (req, res) => {
  try {
    const totalCustomers = await Customer.countDocuments();

    // Query all completed appointments across all branches
    const completedAppointments = await Appointment.find({ status: 'Completed' })
      .populate('branchId', 'name')
      .populate('serviceId', 'price category');

    // Aggregate by customerId
    const customerStats = new Map();
    const branchVisits = new Map();

    completedAppointments.forEach((appt) => {
      const cId = appt.customerId;
      if (!customerStats.has(cId)) {
        customerStats.set(cId, {
          visitCount: 0,
          lastVisitDate: null,
          branches: new Set(),
          totalSpend: 0
        });
      }
      const stat = customerStats.get(cId);
      stat.visitCount += 1;
      stat.totalSpend += (appt.serviceId && appt.serviceId.price) ? appt.serviceId.price : 0;
      if (appt.branchId) {
        stat.branches.add(appt.branchId.name || appt.branchId.toString());
        const bName = appt.branchId.name || 'Other';
        branchVisits.set(bName, (branchVisits.get(bName) || 0) + 1);
      }
      const apptDate = new Date(appt.date);
      if (!stat.lastVisitDate || apptDate > new Date(stat.lastVisitDate)) {
        stat.lastVisitDate = apptDate;
      }
    });

    let repeatCustomersCount = 0;
    let activeCustomersCount = 0;
    let atRiskCustomersCount = 0;
    let multiBranchCustomersCount = 0;
    let needsEngagementCount = 0;

    const now = Date.now();
    customerStats.forEach((stat) => {
      if (stat.visitCount >= 2) repeatCustomersCount++;
      if (stat.branches.size >= 2) multiBranchCustomersCount++;

      if (stat.lastVisitDate) {
        const days = Math.floor((now - new Date(stat.lastVisitDate).getTime()) / (1000 * 60 * 60 * 24));
        if (days <= 30) {
          activeCustomersCount++;
        } else if (days <= 90) {
          needsEngagementCount++;
        } else {
          atRiskCustomersCount++;
        }
      }
    });

    const customersWithVisitsCount = customerStats.size;
    const zeroVisitsCustomersCount = Math.max(0, totalCustomers - customersWithVisitsCount);
    const newCustomersCount = totalCustomers - repeatCustomersCount;
    const repeatCustomerRate = totalCustomers > 0 ? Number(((repeatCustomersCount / totalCustomers) * 100).toFixed(1)) : 0;

    const branchBreakdown = Array.from(branchVisits.entries()).map(([branchName, visitCount]) => ({
      branchName,
      visitCount
    }));

    return res.status(200).json({
      success: true,
      data: {
        totalCustomers,
        totalCompletedVisits: completedAppointments.length,
        repeatCustomerRate,
        segments: {
          new: newCustomersCount,
          returning: repeatCustomersCount,
          active: activeCustomersCount,
          needsEngagement: needsEngagementCount,
          atRisk: atRiskCustomersCount,
          multiBranch: multiBranchCustomersCount,
          zeroVisits: zeroVisitsCustomersCount
        },
        branchBreakdown
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching admin overview'
    });
  }
};

// @desc    Get customer management list with retention indicators and filtering
// @route   GET /api/customers/admin/list
// @access  Private (Admin / Branch Manager)
exports.getAdminCustomerList = async (req, res) => {
  try {
    const { search, segment, page = 1, limit = 50 } = req.query;

    // Fetch customers
    let customerQuery = {};
    if (search && search.trim()) {
      const s = search.trim();
      const regex = new RegExp(s, 'i');
      customerQuery.$or = [
        { name: regex },
        { email: regex },
        { phone: regex },
        { customerId: regex }
      ];
    }

    const customers = await Customer.find(customerQuery).sort({ createdAt: -1 });

    // Fetch all completed appointments to aggregate metrics per customer
    const completedAppointments = await Appointment.find({ status: 'Completed' })
      .populate('branchId', 'name address')
      .populate('serviceId', 'name category price');

    const appointmentMap = new Map();
    completedAppointments.forEach((appt) => {
      const cId = appt.customerId;
      if (!appointmentMap.has(cId)) {
        appointmentMap.set(cId, []);
      }
      appointmentMap.get(cId).push(appt);
    });

    const now = Date.now();

    // Map customer enriched data
    let enrichedList = customers.map((c) => {
      const appts = appointmentMap.get(c.customerId) || [];
      const totalCompletedVisits = appts.length;

      // Sort appointments descending to find latest
      appts.sort((a, b) => new Date(b.date) - new Date(a.date));
      const latestAppt = appts[0] || null;

      let lastCompletedVisit = null;
      let daysSinceLastVisit = null;
      let retentionStatus = 'No Visits';

      if (latestAppt) {
        lastCompletedVisit = {
          date: latestAppt.date,
          serviceName: latestAppt.serviceId ? latestAppt.serviceId.name : 'Salon Service',
          branchName: latestAppt.branchId ? latestAppt.branchId.name : 'VIORA Salon',
          price: latestAppt.serviceId ? latestAppt.serviceId.price : 0
        };
        daysSinceLastVisit = Math.floor((now - new Date(latestAppt.date).getTime()) / (1000 * 60 * 60 * 24));
        if (daysSinceLastVisit <= 30) {
          retentionStatus = 'Active';
        } else if (daysSinceLastVisit <= 90) {
          retentionStatus = 'Needs Engagement';
        } else {
          retentionStatus = 'At-Risk';
        }
      }

      // Unique branches visited
      const branchesVisited = Array.from(new Set(appts.map(a => a.branchId ? a.branchId.name : '').filter(Boolean)));

      // Segments
      const customerSegments = [];
      if (totalCompletedVisits <= 1) customerSegments.push('new');
      if (totalCompletedVisits >= 2) customerSegments.push('returning');
      if (totalCompletedVisits >= 1 && daysSinceLastVisit !== null && daysSinceLastVisit > 90) customerSegments.push('at_risk');
      if (branchesVisited.length >= 2) customerSegments.push('multi_branch');
      if (daysSinceLastVisit !== null && daysSinceLastVisit <= 30) customerSegments.push('active');

      const totalSpend = appts.reduce((sum, a) => sum + ((a.serviceId && a.serviceId.price) || 0), 0);

      return {
        id: c._id,
        customerId: c.customerId,
        name: c.name,
        email: c.email,
        phone: c.phone || '',
        dateOfBirth: c.dateOfBirth,
        profilePhoto: c.profilePhoto || '',
        createdAt: c.createdAt,
        totalCompletedVisits,
        totalSpend,
        lastCompletedVisit,
        daysSinceLastVisit,
        retentionStatus,
        segments: customerSegments,
        branchesVisited
      };
    });

    // Apply segment filter if specified
    if (segment && segment.toLowerCase() !== 'all') {
      const segKey = segment.toLowerCase();
      enrichedList = enrichedList.filter(c => c.segments.includes(segKey));
    }

    const totalCount = enrichedList.length;
    const pageNum = parseInt(page, 10) || 1;
    const limitNum = parseInt(limit, 10) || 50;
    const startIndex = (pageNum - 1) * limitNum;
    const paginated = enrichedList.slice(startIndex, startIndex + limitNum);

    return res.status(200).json({
      success: true,
      count: paginated.length,
      totalCount,
      page: pageNum,
      totalPages: Math.ceil(totalCount / limitNum) || 1,
      data: paginated
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching customer list'
    });
  }
};

// @desc    Get detailed customer profile, retention analytics, and authorized preferences
// @route   GET /api/customers/admin/:customerId
// @access  Private (Admin / Branch Manager)
exports.getAdminCustomerDetails = async (req, res) => {
  try {
    const { customerId } = req.params;

    if (!customerId) {
      return res.status(400).json({
        success: false,
        message: 'Customer identifier is required'
      });
    }

    const customer = await Customer.findOne({ customerId });
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    // Completed appointments for retention metrics
    const completedAppts = await Appointment.find({ customerId, status: 'Completed' })
      .populate('branchId', 'name address')
      .populate('serviceId', 'name category price');

    completedAppts.sort((a, b) => new Date(b.date) - new Date(a.date));

    const totalCompletedVisits = completedAppts.length;
    const totalSpend = completedAppts.reduce((sum, a) => sum + ((a.serviceId && a.serviceId.price) || 0), 0);
    const branchesVisited = Array.from(new Set(completedAppts.map(a => a.branchId ? a.branchId.name : '').filter(Boolean)));

    const now = Date.now();
    let lastCompletedVisit = null;
    let daysSinceLastVisit = null;
    let retentionStatus = 'No Visits';

    if (completedAppts.length > 0) {
      const latest = completedAppts[0];
      lastCompletedVisit = {
        date: latest.date,
        serviceName: latest.serviceId ? latest.serviceId.name : 'Salon Service',
        branchName: latest.branchId ? latest.branchId.name : 'VIORA Salon',
        price: latest.serviceId ? latest.serviceId.price : 0
      };
      daysSinceLastVisit = Math.floor((now - new Date(latest.date).getTime()) / (1000 * 60 * 60 * 24));
      if (daysSinceLastVisit <= 30) {
        retentionStatus = 'Active';
      } else if (daysSinceLastVisit <= 90) {
        retentionStatus = 'Needs Engagement';
      } else {
        retentionStatus = 'At-Risk';
      }
    }

    const segmentTags = [];
    if (totalCompletedVisits <= 1) segmentTags.push('New Customer');
    if (totalCompletedVisits >= 2) segmentTags.push('Returning Client');
    if (totalCompletedVisits >= 5) segmentTags.push('Loyal / VIP');
    if (branchesVisited.length >= 2) segmentTags.push('Multi-Branch');
    if (retentionStatus === 'At-Risk') segmentTags.push('At-Risk');

    // Retrieve quiz results if available
    const quizResult = await QuizResult.findOne({ customerId });

    return res.status(200).json({
      success: true,
      data: {
        profile: {
          id: customer._id,
          customerId: customer.customerId,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          dateOfBirth: customer.dateOfBirth,
          profilePhoto: customer.profilePhoto,
          createdAt: customer.createdAt,
          updatedAt: customer.updatedAt
        },
        preferences: customer.preferences || { hair: [], nails: [], skin: [], makeup: [] },
        retention: {
          totalCompletedVisits,
          totalSpend,
          lastCompletedVisit,
          daysSinceLastVisit,
          retentionStatus,
          branchesVisited,
          segmentTags
        },
        beautyQuiz: quizResult ? {
          archetype: quizResult.profileArchetype || quizResult.archetype || 'Personalized Care',
          summary: quizResult.summary,
          profileChips: quizResult.profileChips || [],
          takenAt: quizResult.createdAt,
          retakeCount: quizResult.retakeCount || 0
        } : null
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching customer details'
    });
  }
};

// @desc    Get customer's cross-branch appointment & treatment history for authorized admin
// @route   GET /api/customers/admin/:customerId/history
// @access  Private (Admin / Branch Manager)
exports.getAdminCustomerHistory = async (req, res) => {
  try {
    const { customerId } = req.params;
    const { status } = req.query;

    if (!customerId) {
      return res.status(400).json({
        success: false,
        message: 'Customer identifier is required'
      });
    }

    const customer = await Customer.findOne({ customerId });
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    const filter = { customerId };
    if (status && status !== 'all') {
      filter.status = status;
    }

    const appointments = await Appointment.find(filter)
      .sort({ date: -1, createdAt: -1 })
      .populate('branchId', 'name address phone')
      .populate('serviceId', 'name category price duration')
      .populate({
        path: 'stylistId',
        select: 'specialization experience rating userId',
        populate: {
          path: 'userId',
          select: 'name email'
        }
      });

    // Count summary
    const allCustomerAppts = await Appointment.find({ customerId });
    const completedCount = allCustomerAppts.filter(a => a.status === 'Completed').length;
    const upcomingCount = allCustomerAppts.filter(a => a.status === 'Pending' || a.status === 'Confirmed').length;
    const cancelledCount = allCustomerAppts.filter(a => a.status === 'Cancelled' || a.status === 'No-show').length;

    const formattedHistory = appointments.map((appt) => {
      const stylist = appt.stylistId;
      const stylistUser = stylist && stylist.userId ? stylist.userId : null;

      return {
        id: appt._id,
        appointmentId: appt.appointmentId,
        date: appt.date,
        startTime: appt.startTime,
        endTime: appt.endTime,
        status: appt.status,
        service: appt.serviceId ? {
          id: appt.serviceId._id,
          name: appt.serviceId.name,
          category: appt.serviceId.category,
          price: appt.serviceId.price,
          duration: appt.serviceId.duration
        } : null,
        branch: appt.branchId ? {
          id: appt.branchId._id,
          name: appt.branchId.name,
          address: appt.branchId.address,
          phone: appt.branchId.phone
        } : null,
        stylist: stylist ? {
          id: stylist._id,
          name: stylistUser ? stylistUser.name : 'VIORA Stylist',
          rating: stylist.rating,
          specialization: stylist.specialization
        } : null
      };
    });

    return res.status(200).json({
      success: true,
      customerId,
      customerName: customer.name,
      counts: {
        total: allCustomerAppts.length,
        completed: completedCount,
        upcoming: upcomingCount,
        cancelled: cancelledCount
      },
      data: formattedHistory
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching customer history'
    });
  }
};


