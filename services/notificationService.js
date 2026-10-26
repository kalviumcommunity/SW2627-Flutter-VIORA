const Notification = require('../models/Notification');
const Stylist = require('../models/Stylist');
const User = require('../models/User');

class NotificationService {
  /**
   * Create a single persistent notification
   */
  static async createNotification({
    recipientId,
    recipientRole = 'customer',
    type,
    title,
    message,
    entityType = 'General',
    entityId = ''
  }) {
    try {
      if (!recipientId || !type || !title || !message) {
        return null;
      }
      const notificationId = await Notification.generateNotificationId();
      const notification = await Notification.create({
        notificationId,
        recipientId,
        recipientRole,
        type,
        title,
        message,
        entityType,
        entityId: String(entityId || ''),
        read: false
      });
      return notification;
    } catch (err) {
      console.error('Error creating notification:', err.message);
      return null;
    }
  }

  /**
   * Notify stylists matching branch or category
   */
  static async notifyStylists({ branchId, category, type, title, message, entityType, entityId }) {
    try {
      const query = {};
      if (branchId) query.branchId = branchId;
      if (category) query.specialization = category;

      const stylists = await Stylist.find(query).select('userId');
      const notifications = [];
      for (const st of stylists) {
        if (st.userId) {
          const notif = await this.createNotification({
            recipientId: st.userId,
            recipientRole: 'stylist',
            type,
            title,
            message,
            entityType,
            entityId
          });
          if (notif) notifications.push(notif);
        }
      }
      return notifications;
    } catch (err) {
      console.error('Error notifying stylists:', err.message);
      return [];
    }
  }

  /**
   * Notify admins or branch managers
   */
  static async notifyAdmins({ type, title, message, entityType, entityId }) {
    try {
      const admins = await User.find({ role: { $in: ['admin', 'branch_manager'] } }).select('_id role');
      const notifications = [];
      for (const adm of admins) {
        const notif = await this.createNotification({
          recipientId: adm._id,
          recipientRole: adm.role,
          type,
          title,
          message,
          entityType,
          entityId
        });
        if (notif) notifications.push(notif);
      }
      return notifications;
    } catch (err) {
      console.error('Error notifying admins:', err.message);
      return [];
    }
  }
}

module.exports = NotificationService;
