const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    notificationId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true
    },
    recipientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    recipientRole: {
      type: String,
      enum: ['customer', 'stylist', 'branch_manager', 'admin'],
      default: 'customer'
    },
    type: {
      type: String,
      enum: [
        'INSPIRATION_SUBMITTED',
        'INSPIRATION_RESPONSE',
        'INSPIRATION_ACCEPTED',
        'INSPIRATION_DECLINED',
        'BOOKING_HANDOFF',
        'BOOKING_CONFIRMED',
        'REVIEW_SUBMITTED',
        'REVIEW_MODERATED',
        'SYSTEM'
      ],
      required: true
    },
    title: {
      type: String,
      required: true,
      trim: true
    },
    message: {
      type: String,
      required: true,
      trim: true
    },
    entityType: {
      type: String,
      enum: ['InspirationRequest', 'InspirationResponse', 'Appointment', 'Review', 'General'],
      default: 'General'
    },
    entityId: {
      type: String,
      default: ''
    },
    read: {
      type: Boolean,
      default: false,
      index: true
    }
  },
  {
    timestamps: true
  }
);

notificationSchema.statics.generateNotificationId = async function () {
  const count = await this.countDocuments();
  const nextNum = (count + 1).toString().padStart(4, '0');
  const candidate = `NOTIF-${nextNum}`;
  const existing = await this.findOne({ notificationId: candidate });
  if (!existing) {
    return candidate;
  }
  return `NOTIF-${Date.now().toString(36).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;
};

module.exports = mongoose.model('Notification', notificationSchema);
