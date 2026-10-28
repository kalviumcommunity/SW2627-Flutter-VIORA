const express = require('express');
const router = express.Router();
const {
  getProfile,
  updateProfile,
  getPreferences,
  updatePreferences,
  getTreatmentHistory,
  getRebookContext,
  getQuizQuestions,
  submitQuiz,
  getQuizResult,
  getRecommendations,
  retakeQuiz,
  getAdminOverview,
  getAdminCustomerList,
  getAdminCustomerDetails,
  getAdminCustomerHistory
} = require('../controllers/customerController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Customer Profile endpoints (Protected)
router.route('/profile')
  .get(protect, getProfile)
  .put(protect, updateProfile);

// Customer Preferences foundation endpoints (Protected)
router.route('/preferences')
  .get(protect, getPreferences)
  .put(protect, updatePreferences);

// Customer Treatment History endpoints (Protected - Centralized Multi-Branch Identity)
router.route('/history')
  .get(protect, getTreatmentHistory);

router.route('/history/:appointmentId/rebook')
  .get(protect, getRebookContext);

// Customer Beauty Quiz & Recommendations endpoints (Day 4 Person 2)
router.get('/quiz/questions', getQuizQuestions);

router.route('/quiz')
  .get(protect, getQuizResult)
  .post(protect, submitQuiz);

router.post('/quiz/retake', protect, retakeQuiz);

router.get('/recommendations', protect, getRecommendations);

// ========================================================
// Day 5: Admin Customer Management Endpoints
// Role-based authorization: admin or branch_manager
// ========================================================
router.get('/admin/overview', protect, authorize('admin', 'branch_manager'), getAdminOverview);
router.get('/admin/list', protect, authorize('admin', 'branch_manager'), getAdminCustomerList);
router.get('/admin/:customerId', protect, authorize('admin', 'branch_manager'), getAdminCustomerDetails);
router.get('/admin/:customerId/history', protect, authorize('admin', 'branch_manager'), getAdminCustomerHistory);

module.exports = router;

