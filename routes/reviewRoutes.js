const express = require('express');
const router = express.Router();
const ReviewController = require('../controllers/reviewController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Customer review submission & eligibility
router.get('/eligible-appointments', protect, authorize('customer'), ReviewController.getEligibleAppointments);
router.post('/', protect, authorize('customer'), ReviewController.submitReview);
router.get('/my-reviews', protect, authorize('customer'), ReviewController.getMyReviews);

// Stylist reviews (public / protected)
router.get('/stylist/:stylistId', ReviewController.getStylistReviews);

// Admin review moderation
router.get('/admin', protect, authorize('admin', 'branch_manager'), ReviewController.getAdminReviews);
router.put('/admin/:id/moderate', protect, authorize('admin', 'branch_manager'), ReviewController.moderateReview);

module.exports = router;
