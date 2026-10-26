const express = require('express');
const router = express.Router();
const AnalyticsController = require('../controllers/analyticsController');
const { protect, authorize } = require('../middleware/authMiddleware');

// All analytics endpoints require admin or branch_manager role
router.use(protect);
router.use(authorize('admin', 'branch_manager'));

router.get('/overview', AnalyticsController.getOverview);
router.get('/branches', AnalyticsController.getBranchPerformance);
router.get('/stylists', AnalyticsController.getStylistPerformance);
router.get('/services', AnalyticsController.getPopularServices);
router.get('/looks', AnalyticsController.getPopularLooks);
router.get('/reviews', AnalyticsController.getReviewAnalytics);
router.get('/retention', AnalyticsController.getRetentionAnalytics);

module.exports = router;
