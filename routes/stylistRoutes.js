const express = require('express');
const router = express.Router();
const StylistController = require('../controllers/stylistController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Public endpoints
router.get('/', StylistController.getAllStylists);
router.get('/:id', StylistController.getStylistById);
router.get('/:id/portfolio', StylistController.getStylistPortfolio);

// Stylist authenticated portfolio & reviews
router.get('/me/portfolio', protect, authorize('stylist'), StylistController.getMyPortfolio);
router.post('/me/portfolio', protect, authorize('stylist'), StylistController.createPortfolioItem);
router.put('/me/portfolio/:itemId', protect, authorize('stylist'), StylistController.updatePortfolioItem);
router.delete('/me/portfolio/:itemId', protect, authorize('stylist'), StylistController.deletePortfolioItem);
router.get('/me/reviews', protect, authorize('stylist'), StylistController.getMyReviews);

module.exports = router;
