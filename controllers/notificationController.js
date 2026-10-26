const Notification = require('../models/Notification');

class NotificationController {
  /**
   * Get authenticated user's notifications & unread count
   * GET /api/notifications
   */
  static async getNotifications(req, res, next) {
    try {
      const { unreadOnly, limit = 50 } = req.query;
      const query = { recipientId: req.user._id };

      if (unreadOnly === 'true') {
        query.read = false;
      }

      const notifications = await Notification.find(query)
        .sort({ createdAt: -1 })
        .limit(parseInt(limit, 10));

      const unreadCount = await Notification.countDocuments({
        recipientId: req.user._id,
        read: false
      });

      return res.status(200).json({
        success: true,
        unreadCount,
        count: notifications.length,
        data: notifications
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Mark single notification as read
   * PUT /api/notifications/:id/read
   */
  static async markAsRead(req, res, next) {
    try {
      const { id } = req.params;

      const notification = await Notification.findOne({
        $or: [{ notificationId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!notification) {
        return res.status(404).json({
          success: false,
          message: 'Notification not found'
        });
      }

      // Enforce recipient ownership
      if (notification.recipientId.toString() !== req.user._id.toString()) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to modify another user’s notification'
        });
      }

      notification.read = true;
      await notification.save();

      return res.status(200).json({
        success: true,
        message: 'Notification marked as read',
        data: notification
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Mark all notifications as read for current user
   * PUT /api/notifications/read-all
   */
  static async markAllAsRead(req, res, next) {
    try {
      await Notification.updateMany(
        { recipientId: req.user._id, read: false },
        { $set: { read: true } }
      );

      return res.status(200).json({
        success: true,
        message: 'All notifications marked as read'
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Delete a notification
   * DELETE /api/notifications/:id
   */
  static async deleteNotification(req, res, next) {
    try {
      const { id } = req.params;

      const notification = await Notification.findOne({
        $or: [{ notificationId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!notification) {
        return res.status(404).json({
          success: false,
          message: 'Notification not found'
        });
      }

      // Enforce recipient ownership
      if (notification.recipientId.toString() !== req.user._id.toString()) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to delete another user’s notification'
        });
      }

      await Notification.deleteOne({ _id: notification._id });

      return res.status(200).json({
        success: true,
        message: 'Notification removed successfully'
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = NotificationController;
