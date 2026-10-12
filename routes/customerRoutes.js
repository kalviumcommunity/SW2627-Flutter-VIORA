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
  retakeQuiz
} = require('../controllers/customerController');
const { protect } = require('../middleware/authMiddleware');

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

// Customer Beauty Quiz & Recommendations endpoints (Protected - Day 4 Person 2)
router.get('/quiz/questions', protect, getQuizQuestions);

router.route('/quiz')
  .get(protect, getQuizResult)
  .post(protect, submitQuiz);

router.post('/quiz/retake', protect, retakeQuiz);

router.get('/recommendations', protect, getRecommendations);

module.exports = router;

