const express = require('express');
const router = express.Router();
const {
  getProfile,
  updateProfile,
  getPreferences,
  updatePreferences
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

module.exports = router;
