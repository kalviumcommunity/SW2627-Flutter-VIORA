const express = require('express');
const router = express.Router();
const InspirationController = require('../controllers/inspirationController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Public or protected discovery feed
router.get('/discovery', InspirationController.getDiscoveryFeed);

// Image upload (authenticated)
router.post('/upload', protect, InspirationController.uploadImage);

// Inspiration Requests
router.post('/requests', protect, authorize('customer'), InspirationController.createRequest);
router.get('/requests', protect, InspirationController.getRequests);
router.get('/requests/:id', protect, InspirationController.getRequestById);

// Stylist interactions
router.post('/requests/:id/respond', protect, authorize('stylist', 'admin'), InspirationController.respondToRequest);
router.put('/requests/:id/status', protect, authorize('stylist', 'admin'), InspirationController.updateStatus);

// Customer decision & booking handoff
router.post('/requests/:id/choose', protect, authorize('customer'), InspirationController.chooseStylist);
router.post('/requests/:id/handoff', protect, authorize('customer'), InspirationController.getBookingHandoffContext);

module.exports = router;
