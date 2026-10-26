const Review = require('../models/Review');
const Appointment = require('../models/Appointment');
const Customer = require('../models/Customer');
const Stylist = require('../models/Stylist');
const Branch = require('../models/Branch');
const Service = require('../models/Service');
const UploadService = require('../services/uploadService');
const NotificationService = require('../services/notificationService');

class ReviewController {
  /**
   * Helper to recalculate and update stylist's average rating
   */
  static async recalculateStylistRating(stylistId) {
    try {
      const stats = await Review.aggregate([
        { $match: { stylistId, moderationStatus: 'approved' } },
        {
          $group: {
            _id: '$stylistId',
            avgRating: { $avg: '$rating' },
            count: { $sum: 1 }
          }
        }
      ]);

      if (stats.length > 0) {
        const rounded = Number(stats[0].avgRating.toFixed(2));
        await Stylist.findByIdAndUpdate(stylistId, { rating: rounded });
      }
    } catch (err) {
      console.error('Error recalculating stylist rating:', err.message);
    }
  }

  /**
   * Get eligible completed appointments that have not yet been reviewed
   * GET /api/reviews/eligible-appointments
   */
  static async getEligibleAppointments(req, res, next) {
    try {
      const customer = await Customer.findOne({ userId: req.user._id });
      if (!customer) {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found'
        });
      }

      // Find all completed appointments for this customer
      const completedAppointments = await Appointment.find({
        customerId: customer.customerId,
        status: 'Completed'
      })
        .populate('branchId', 'name address')
        .populate({
          path: 'stylistId',
          populate: { path: 'userId', select: 'name' }
        })
        .populate('serviceId', 'name category price duration')
        .sort({ date: -1 });

      // Find all appointmentIds already reviewed
      const existingReviews = await Review.find({ customerId: customer.customerId }).select('appointmentId');
      const reviewedAppointmentIdSet = new Set(existingReviews.map((r) => r.appointmentId.toString()));

      // Filter to only unreviewed
      const eligible = completedAppointments.filter((apt) => !reviewedAppointmentIdSet.has(apt._id.toString()));

      return res.status(200).json({
        success: true,
        count: eligible.length,
        data: eligible
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Submit a review for a completed appointment
   * POST /api/reviews
   */
  static async submitReview(req, res, next) {
    try {
      const {
        appointmentId,
        rating,
        lookRating = 5,
        serviceRating = 5,
        reviewText = '',
        images = [],
        lookCategory
      } = req.body;

      if (!appointmentId) {
        return res.status(400).json({
          success: false,
          message: 'Appointment ID is required'
        });
      }

      const numRating = Number(rating);
      if (isNaN(numRating) || numRating < 1 || numRating > 5) {
        return res.status(400).json({
          success: false,
          message: 'Rating must be an integer or decimal between 1 and 5'
        });
      }

      const numLookRating = Number(lookRating);
      if (isNaN(numLookRating) || numLookRating < 1 || numLookRating > 5) {
        return res.status(400).json({
          success: false,
          message: 'Look rating must be between 1 and 5'
        });
      }

      const numServiceRating = Number(serviceRating);
      if (isNaN(numServiceRating) || numServiceRating < 1 || numServiceRating > 5) {
        return res.status(400).json({
          success: false,
          message: 'Service rating must be between 1 and 5'
        });
      }

      // Verify customer identity
      const customer = await Customer.findOne({ userId: req.user._id });
      if (!customer) {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found'
        });
      }

      // Verify appointment exists
      const appointment = await Appointment.findOne({
        $or: [
          { _id: appointmentId.match(/^[0-9a-fA-F]{24}$/) ? appointmentId : null },
          { appointmentId }
        ]
      });

      if (!appointment) {
        return res.status(404).json({
          success: false,
          message: 'Appointment not found'
        });
      }

      // Enforce ownership: appointment must belong to customer
      if (appointment.customerId !== customer.customerId) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to review an appointment belonging to another customer'
        });
      }

      // Enforce eligibility: must be 'Completed'
      if (appointment.status !== 'Completed') {
        return res.status(400).json({
          success: false,
          message: `Only completed appointments can be reviewed. Current status: ${appointment.status}`
        });
      }

      // Check duplicate review
      const existingReview = await Review.findOne({ appointmentId: appointment._id });
      if (existingReview) {
        return res.status(400).json({
          success: false,
          message: 'A review has already been submitted for this appointment'
        });
      }

      // Optional image processing if base64 passed
      const processedImages = [];
      if (Array.isArray(images)) {
        for (const img of images) {
          if (img.startsWith('data:image')) {
            const url = await UploadService.saveImage(img, 'rev');
            processedImages.push(url);
          } else {
            processedImages.push(img);
          }
        }
      }

      // Detect look category from service if not provided
      let finalCategory = lookCategory;
      if (!finalCategory && appointment.serviceId) {
        const service = await Service.findById(appointment.serviceId);
        if (service && service.category) {
          finalCategory = service.category;
        }
      }

      const reviewId = await Review.generateReviewId();
      const review = await Review.create({
        reviewId,
        appointmentId: appointment._id,
        customerId: customer.customerId,
        userId: req.user._id,
        stylistId: appointment.stylistId,
        branchId: appointment.branchId,
        serviceId: appointment.serviceId || null,
        rating: numRating,
        lookRating: numLookRating,
        serviceRating: numServiceRating,
        reviewText: reviewText.trim(),
        images: processedImages,
        lookCategory: finalCategory || 'Hair',
        moderationStatus: 'approved'
      });

      // Recalculate stylist average rating
      await ReviewController.recalculateStylistRating(appointment.stylistId);

      // Notify stylist
      const stylist = await Stylist.findById(appointment.stylistId);
      if (stylist && stylist.userId) {
        await NotificationService.createNotification({
          recipientId: stylist.userId,
          recipientRole: 'stylist',
          type: 'REVIEW_SUBMITTED',
          title: 'New Client Review Received',
          message: `Client ${customer.name} rated their styling experience ${numRating}★ (Look: ${numLookRating}★).`,
          entityType: 'Review',
          entityId: review.reviewId
        });
      }

      // Notify customer
      await NotificationService.createNotification({
        recipientId: req.user._id,
        recipientRole: 'customer',
        type: 'REVIEW_SUBMITTED',
        title: 'Thank You for Your Review',
        message: 'Your review and atelier rating have been published.',
        entityType: 'Review',
        entityId: review.reviewId
      });

      return res.status(201).json({
        success: true,
        message: 'Review submitted successfully',
        data: review
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get reviews for a specific stylist with rating breakdown
   * GET /api/reviews/stylist/:stylistId
   */
  static async getStylistReviews(req, res, next) {
    try {
      const { stylistId } = req.params;

      const stylist = await Stylist.findOne({
        $or: [{ stylistId }, { _id: stylistId.match(/^[0-9a-fA-F]{24}$/) ? stylistId : null }]
      });

      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist not found'
        });
      }

      const reviews = await Review.find({ stylistId: stylist._id, moderationStatus: 'approved' })
        .populate('serviceId', 'name category price')
        .populate('branchId', 'name')
        .sort({ createdAt: -1 });

      const total = reviews.length;
      const avgStylist = total > 0 ? Number((reviews.reduce((s, r) => s + r.rating, 0) / total).toFixed(2)) : 5.0;
      const avgLook = total > 0 ? Number((reviews.reduce((s, r) => s + r.lookRating, 0) / total).toFixed(2)) : 5.0;

      // Distribution
      const distribution = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
      reviews.forEach((r) => {
        const rounded = Math.round(r.rating);
        if (distribution[rounded] !== undefined) {
          distribution[rounded]++;
        }
      });

      return res.status(200).json({
        success: true,
        stats: {
          totalReviews: total,
          avgStylistRating: avgStylist,
          avgLookRating: avgLook,
          distribution
        },
        data: reviews
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get customer's own submitted reviews
   * GET /api/reviews/my-reviews
   */
  static async getMyReviews(req, res, next) {
    try {
      const customer = await Customer.findOne({ userId: req.user._id });
      if (!customer) {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found'
        });
      }

      const reviews = await Review.find({ customerId: customer.customerId })
        .populate({
          path: 'stylistId',
          populate: { path: 'userId', select: 'name' }
        })
        .populate('branchId', 'name')
        .populate('serviceId', 'name category')
        .sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: reviews.length,
        data: reviews
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: List all reviews with filters
   * GET /api/reviews/admin
   */
  static async getAdminReviews(req, res, next) {
    try {
      const { rating, stylistId, branchId, status, startDate, endDate } = req.query;
      const filter = {};

      if (rating) {
        filter.rating = Number(rating);
      }
      if (status) {
        filter.moderationStatus = status;
      }
      if (stylistId) {
        filter.stylistId = stylistId;
      }
      if (branchId) {
        filter.branchId = branchId;
      }
      if (startDate || endDate) {
        filter.createdAt = {};
        if (startDate) filter.createdAt.$gte = new Date(startDate);
        if (endDate) filter.createdAt.$lte = new Date(endDate);
      }

      const reviews = await Review.find(filter)
        .populate({
          path: 'stylistId',
          populate: { path: 'userId', select: 'name' }
        })
        .populate('branchId', 'name address')
        .populate('serviceId', 'name category price')
        .populate('moderatedBy', 'name email')
        .sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: reviews.length,
        data: reviews
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Moderate review (approve, flag, hide)
   * PUT /api/reviews/admin/:id/moderate
   */
  static async moderateReview(req, res, next) {
    try {
      const { id } = req.params;
      const { status, notes = '' } = req.body;

      const validStatuses = ['approved', 'pending', 'flagged', 'hidden'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: `Status must be one of: ${validStatuses.join(', ')}`
        });
      }

      const review = await Review.findOne({
        $or: [{ reviewId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!review) {
        return res.status(404).json({
          success: false,
          message: 'Review not found'
        });
      }

      review.moderationStatus = status;
      review.moderationNotes = notes;
      review.moderatedBy = req.user._id;
      review.moderatedAt = new Date();
      await review.save();

      // Recalculate stylist rating
      await ReviewController.recalculateStylistRating(review.stylistId);

      // Audit notification to customer if hidden/flagged
      if (status === 'hidden' || status === 'flagged') {
        await NotificationService.createNotification({
          recipientId: review.userId,
          recipientRole: 'customer',
          type: 'REVIEW_MODERATED',
          title: 'Review Moderation Notice',
          message: `Your review (${review.reviewId}) status was updated to '${status}'.`,
          entityType: 'Review',
          entityId: review.reviewId
        });
      }

      return res.status(200).json({
        success: true,
        message: `Review moderation status updated to '${status}'`,
        data: review
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = ReviewController;
