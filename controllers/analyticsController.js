const Appointment = require('../models/Appointment');
const Customer = require('../models/Customer');
const Branch = require('../models/Branch');
const Stylist = require('../models/Stylist');
const Service = require('../models/Service');
const Review = require('../models/Review');
const InspirationRequest = require('../models/InspirationRequest');
const PortfolioItem = require('../models/PortfolioItem');

class AnalyticsController {
  /**
   * Helper to build base appointment match filter based on query
   */
  static buildAppointmentFilter(query) {
    const filter = {};
    if (query.branchId) {
      filter.branchId = query.branchId.match(/^[0-9a-fA-F]{24}$/)
        ? query.branchId
        : null;
    }
    if (query.stylistId) {
      filter.stylistId = query.stylistId.match(/^[0-9a-fA-F]{24}$/)
        ? query.stylistId
        : null;
    }
    if (query.startDate || query.endDate) {
      filter.date = {};
      if (query.startDate) filter.date.$gte = new Date(query.startDate);
      if (query.endDate) filter.date.$lte = new Date(query.endDate);
    }
    return filter;
  }

  /**
   * GET /api/admin/analytics/overview
   * Executive KPI cards, revenue, customer metrics, trend
   */
  static async getOverview(req, res, next) {
    try {
      const filter = AnalyticsController.buildAppointmentFilter(req.query);

      // Fetch appointments matching filter, populate serviceId
      const allAppts = await Appointment.find(filter)
        .populate('serviceId', 'name price category')
        .populate('branchId', 'name')
        .sort({ date: 1 });

      const totalBookings = allAppts.length;
      const completedAppts = allAppts.filter((a) => a.status === 'Completed');
      const cancelledAppts = allAppts.filter((a) => a.status === 'Cancelled');
      const pendingAppts = allAppts.filter((a) => a.status === 'Pending' || a.status === 'Confirmed');

      // Calculate authoritative revenue strictly from completed appointments
      const totalRevenue = completedAppts.reduce((sum, a) => {
        const price = (a.serviceId && typeof a.serviceId.price === 'number') ? a.serviceId.price : 0;
        return sum + price;
      }, 0);

      // Customer stats
      const totalCustomers = await Customer.countDocuments();

      // Find unique customers in completed appointments
      const completedCustomerIds = new Set(completedAppts.map((a) => a.customerId));
      const activeCustomers = completedCustomerIds.size;

      // Group appointments by customer to count returning customers (>= 2 completed visits)
      const customerVisits = {};
      completedAppts.forEach((a) => {
        customerVisits[a.customerId] = (customerVisits[a.customerId] || 0) + 1;
      });

      const returningCustomers = Object.values(customerVisits).filter((v) => v > 1).length;
      const singleVisitCustomers = Object.values(customerVisits).filter((v) => v === 1).length;
      const returningRate = activeCustomers > 0 ? Number(((returningCustomers / activeCustomers) * 100).toFixed(1)) : 0;

      // New customers in period
      const newCustomerFilter = {};
      if (req.query.startDate || req.query.endDate) {
        newCustomerFilter.createdAt = {};
        if (req.query.startDate) newCustomerFilter.createdAt.$gte = new Date(req.query.startDate);
        if (req.query.endDate) newCustomerFilter.createdAt.$lte = new Date(req.query.endDate);
      }
      const newCustomersInPeriod = await Customer.countDocuments(newCustomerFilter);

      // Booking trends over time (by date)
      const dateMap = {};
      allAppts.forEach((a) => {
        const dStr = a.date ? a.date.toISOString().split('T')[0] : 'Unknown';
        if (!dateMap[dStr]) {
          dateMap[dStr] = { date: dStr, bookings: 0, completed: 0, revenue: 0 };
        }
        dateMap[dStr].bookings++;
        if (a.status === 'Completed') {
          dateMap[dStr].completed++;
          dateMap[dStr].revenue += (a.serviceId && a.serviceId.price) || 0;
        }
      });
      const trends = Object.values(dateMap).sort((a, b) => a.date.localeCompare(b.date));

      // Popular services in this selection
      const serviceCounts = {};
      completedAppts.forEach((a) => {
        if (a.serviceId) {
          const sName = a.serviceId.name;
          if (!serviceCounts[sName]) {
            serviceCounts[sName] = {
              name: sName,
              category: a.serviceId.category || 'Hair',
              bookings: 0,
              revenue: 0
            };
          }
          serviceCounts[sName].bookings++;
          serviceCounts[sName].revenue += a.serviceId.price || 0;
        }
      });
      const popularServices = Object.values(serviceCounts)
        .sort((a, b) => b.bookings - a.bookings)
        .slice(0, 5);

      return res.status(200).json({
        success: true,
        data: {
          overview: {
            totalBookings,
            completedBookings: completedAppts.length,
            cancelledBookings: cancelledAppts.length,
            pendingBookings: pendingAppts.length,
            totalRevenue,
            totalCustomers,
            activeCustomers,
            returningCustomers,
            singleVisitCustomers,
            newCustomersInPeriod,
            returningRate
          },
          trends,
          popularServices
        }
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * GET /api/admin/analytics/branches
   * Comprehensive branch comparison
   */
  static async getBranchPerformance(req, res, next) {
    try {
      const branches = await Branch.find();
      const apptFilter = AnalyticsController.buildAppointmentFilter(req.query);

      const appointments = await Appointment.find(apptFilter).populate('serviceId', 'price');
      const reviews = await Review.find({ moderationStatus: 'approved' });

      const branchMetrics = branches.map((branch) => {
        const bIdStr = branch._id.toString();
        const branchAppts = appointments.filter((a) => a.branchId && a.branchId.toString() === bIdStr);
        const completed = branchAppts.filter((a) => a.status === 'Completed');

        const revenue = completed.reduce((sum, a) => sum + ((a.serviceId && a.serviceId.price) || 0), 0);
        const uniqueCustomers = new Set(completed.map((a) => a.customerId)).size;

        // Count returning clients in this branch
        const clientVisits = {};
        completed.forEach((a) => {
          clientVisits[a.customerId] = (clientVisits[a.customerId] || 0) + 1;
        });
        const returningClients = Object.values(clientVisits).filter((v) => v > 1).length;

        // Average rating
        const branchReviews = reviews.filter((r) => r.branchId && r.branchId.toString() === bIdStr);
        const avgRating = branchReviews.length > 0
          ? Number((branchReviews.reduce((sum, r) => sum + r.rating, 0) / branchReviews.length).toFixed(2))
          : 5.0;

        return {
          branchId: branch.branchId,
          id: branch._id,
          name: branch.name,
          address: branch.address,
          status: branch.status,
          totalBookings: branchAppts.length,
          completedBookings: completed.length,
          revenue,
          uniqueCustomers,
          returningClients,
          reviewCount: branchReviews.length,
          avgRating
        };
      });

      return res.status(200).json({
        success: true,
        count: branchMetrics.length,
        data: branchMetrics
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * GET /api/admin/analytics/stylists
   * Stylist ranking & performance
   */
  static async getStylistPerformance(req, res, next) {
    try {
      const stylists = await Stylist.find()
        .populate('userId', 'name email phone')
        .populate('branchId', 'name');

      const apptFilter = AnalyticsController.buildAppointmentFilter(req.query);
      const appointments = await Appointment.find(apptFilter).populate('serviceId', 'name price category');
      const reviews = await Review.find({ moderationStatus: 'approved' });

      const stylistMetrics = stylists.map((stylist) => {
        const sIdStr = stylist._id.toString();
        const stylistAppts = appointments.filter((a) => a.stylistId && a.stylistId.toString() === sIdStr);
        const completed = stylistAppts.filter((a) => a.status === 'Completed');

        const revenue = completed.reduce((sum, a) => sum + ((a.serviceId && a.serviceId.price) || 0), 0);
        const uniqueClients = new Set(completed.map((a) => a.customerId)).size;

        const stylistReviews = reviews.filter((r) => r.stylistId && r.stylistId.toString() === sIdStr);
        const avgRating = stylistReviews.length > 0
          ? Number((stylistReviews.reduce((sum, r) => sum + r.rating, 0) / stylistReviews.length).toFixed(2))
          : stylist.rating || 5.0;
        const avgLookRating = stylistReviews.length > 0
          ? Number((stylistReviews.reduce((sum, r) => sum + r.lookRating, 0) / stylistReviews.length).toFixed(2))
          : 5.0;

        return {
          stylistId: stylist.stylistId,
          id: stylist._id,
          name: (stylist.userId && stylist.userId.name) || 'Stylist',
          branchName: (stylist.branchId && stylist.branchId.name) || 'Atelier',
          specialization: stylist.specialization || [],
          experience: stylist.experience || 0,
          totalBookings: stylistAppts.length,
          completedBookings: completed.length,
          revenue,
          uniqueClients,
          reviewCount: stylistReviews.length,
          avgRating,
          avgLookRating
        };
      });

      // Sort by completed bookings and revenue
      stylistMetrics.sort((a, b) => b.completedBookings - a.completedBookings || b.revenue - a.revenue);

      return res.status(200).json({
        success: true,
        count: stylistMetrics.length,
        data: stylistMetrics
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * GET /api/admin/analytics/services
   * Most popular services by booking volume & revenue
   */
  static async getPopularServices(req, res, next) {
    try {
      const apptFilter = AnalyticsController.buildAppointmentFilter(req.query);
      apptFilter.status = 'Completed';

      const completedAppts = await Appointment.find(apptFilter)
        .populate('serviceId', 'serviceId name category price duration')
        .populate('branchId', 'name');

      const serviceAgg = {};
      completedAppts.forEach((a) => {
        if (a.serviceId) {
          const sId = a.serviceId._id.toString();
          if (!serviceAgg[sId]) {
            serviceAgg[sId] = {
              id: a.serviceId._id,
              serviceId: a.serviceId.serviceId,
              name: a.serviceId.name,
              category: a.serviceId.category,
              price: a.serviceId.price,
              duration: a.serviceId.duration,
              totalBookings: 0,
              totalRevenue: 0,
              branches: new Set()
            };
          }
          serviceAgg[sId].totalBookings++;
          serviceAgg[sId].totalRevenue += a.serviceId.price || 0;
          if (a.branchId && a.branchId.name) {
            serviceAgg[sId].branches.add(a.branchId.name);
          }
        }
      });

      const results = Object.values(serviceAgg)
        .map((s) => ({
          ...s,
          branches: Array.from(s.branches)
        }))
        .sort((a, b) => b.totalBookings - a.totalBookings || b.totalRevenue - a.totalRevenue);

      return res.status(200).json({
        success: true,
        count: results.length,
        data: results
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * GET /api/admin/analytics/looks
   * Popular looks based on requests, look ratings, categories
   */
  static async getPopularLooks(req, res, next) {
    try {
      const requests = await InspirationRequest.find();
      const reviews = await Review.find({ moderationStatus: 'approved' });
      const portfolioItems = await PortfolioItem.find({ isActive: true });

      const categoryStats = {
        Hair: { category: 'Hair', requestCount: 0, lookRatingSum: 0, reviewCount: 0, portfolioCount: 0 },
        Nails: { category: 'Nails', requestCount: 0, lookRatingSum: 0, reviewCount: 0, portfolioCount: 0 },
        Skin: { category: 'Skin', requestCount: 0, lookRatingSum: 0, reviewCount: 0, portfolioCount: 0 },
        Makeup: { category: 'Makeup', requestCount: 0, lookRatingSum: 0, reviewCount: 0, portfolioCount: 0 },
        Other: { category: 'Other', requestCount: 0, lookRatingSum: 0, reviewCount: 0, portfolioCount: 0 }
      };

      requests.forEach((r) => {
        if (categoryStats[r.category]) {
          categoryStats[r.category].requestCount++;
        }
      });

      reviews.forEach((rev) => {
        const cat = rev.lookCategory || 'Hair';
        if (categoryStats[cat]) {
          categoryStats[cat].lookRatingSum += rev.lookRating;
          categoryStats[cat].reviewCount++;
        }
      });

      portfolioItems.forEach((p) => {
        if (categoryStats[p.category]) {
          categoryStats[p.category].portfolioCount++;
        }
      });

      const looksAnalytics = Object.values(categoryStats).map((stat) => ({
        category: stat.category,
        requestCount: stat.requestCount,
        portfolioCount: stat.portfolioCount,
        reviewCount: stat.reviewCount,
        avgLookRating: stat.reviewCount > 0 ? Number((stat.lookRatingSum / stat.reviewCount).toFixed(2)) : 5.0,
        sampleImages: portfolioItems.filter((p) => p.category === stat.category).slice(0, 3).map((p) => p.imageUrl)
      }));

      looksAnalytics.sort((a, b) => b.requestCount - a.requestCount || b.avgLookRating - a.avgLookRating);

      return res.status(200).json({
        success: true,
        data: looksAnalytics
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * GET /api/admin/analytics/reviews
   * Review intelligence, distribution, and branch/stylist rating breakdown
   */
  static async getReviewAnalytics(req, res, next) {
    try {
      const reviews = await Review.find()
        .populate('stylistId', 'stylistId rating')
        .populate('branchId', 'name')
        .sort({ createdAt: -1 });

      const approvedReviews = reviews.filter((r) => r.moderationStatus === 'approved');
      const totalApproved = approvedReviews.length;

      const avgStylistRating = totalApproved > 0
        ? Number((approvedReviews.reduce((sum, r) => sum + r.rating, 0) / totalApproved).toFixed(2))
        : 5.0;

      const avgLookRating = totalApproved > 0
        ? Number((approvedReviews.reduce((sum, r) => sum + r.lookRating, 0) / totalApproved).toFixed(2))
        : 5.0;

      const ratingDistribution = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
      approvedReviews.forEach((r) => {
        const star = Math.round(r.rating);
        if (ratingDistribution[star] !== undefined) {
          ratingDistribution[star]++;
        }
      });

      const moderationBreakdown = {
        approved: reviews.filter((r) => r.moderationStatus === 'approved').length,
        pending: reviews.filter((r) => r.moderationStatus === 'pending').length,
        flagged: reviews.filter((r) => r.moderationStatus === 'flagged').length,
        hidden: reviews.filter((r) => r.moderationStatus === 'hidden').length
      };

      // Flag low-rated reviews (< 3.0)
      const attentionRequired = reviews.filter((r) => r.rating <= 2);

      return res.status(200).json({
        success: true,
        data: {
          totalReviews: reviews.length,
          totalApproved,
          avgStylistRating,
          avgLookRating,
          ratingDistribution,
          moderationBreakdown,
          attentionRequiredCount: attentionRequired.length,
          recentReviews: reviews.slice(0, 10)
        }
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * GET /api/admin/analytics/retention
   * Customer retention, new vs returning, and cross-branch visitors
   */
  static async getRetentionAnalytics(req, res, next) {
    try {
      const completedAppointments = await Appointment.find({ status: 'Completed' })
        .populate('branchId', 'name');

      // Group appointments by customerId
      const customerMap = {};
      completedAppointments.forEach((a) => {
        if (!customerMap[a.customerId]) {
          customerMap[a.customerId] = {
            customerId: a.customerId,
            visits: 0,
            branches: new Set()
          };
        }
        customerMap[a.customerId].visits++;
        if (a.branchId && a.branchId.name) {
          customerMap[a.customerId].branches.add(a.branchId.name);
        }
      });

      const totalActiveClients = Object.keys(customerMap).length;
      let singleVisitCount = 0;
      let returningCount = 0;
      let crossBranchCount = 0;

      Object.values(customerMap).forEach((c) => {
        if (c.visits === 1) {
          singleVisitCount++;
        } else if (c.visits > 1) {
          returningCount++;
        }
        if (c.branches.size > 1) {
          crossBranchCount++;
        }
      });

      const retentionRate = totalActiveClients > 0
        ? Number(((returningCount / totalActiveClients) * 100).toFixed(1))
        : 0;

      const crossBranchRate = totalActiveClients > 0
        ? Number(((crossBranchCount / totalActiveClients) * 100).toFixed(1))
        : 0;

      return res.status(200).json({
        success: true,
        data: {
          totalActiveClients,
          singleVisitCount,
          returningCount,
          crossBranchCount,
          retentionRate,
          crossBranchRate
        }
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = AnalyticsController;
