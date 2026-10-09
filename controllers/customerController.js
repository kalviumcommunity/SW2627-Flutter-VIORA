const mongoose = require('mongoose');
const Customer = require('../models/Customer');
const User = require('../models/User');
const Appointment = require('../models/Appointment');
const Branch = require('../models/Branch');
const Service = require('../models/Service');
const Stylist = require('../models/Stylist');

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

