const express = require('express');
const router = express.Router();
const NotificationController = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, NotificationController.getNotifications);
router.put('/read-all', protect, NotificationController.markAllAsRead);
router.put('/:id/read', protect, NotificationController.markAsRead);
router.delete('/:id', protect, NotificationController.deleteNotification);

module.exports = router;
