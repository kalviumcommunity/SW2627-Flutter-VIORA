const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    reviewId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true
    },
    appointmentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',
      required: true,
      unique: true, // Only 1 review per appointment
      index: true
    },
    customerId: {
      type: String, // Global customerId reference (e.g. CUST-0001)
      required: true,
      ref: 'Customer',
      index: true
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    stylistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Stylist',
      required: true,
      index: true
    },
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch',
      required: true,
      index: true
    },
    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Service',
      default: null
    },
    rating: {
      type: Number,
      required: [true, 'Please provide a rating between 1 and 5'],
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5']
    },
    lookRating: {
      type: Number,
      required: [true, 'Please provide a look/design rating between 1 and 5'],
      min: [1, 'Look rating must be at least 1'],
      max: [5, 'Look rating cannot exceed 5'],
      default: 5
    },
    serviceRating: {
      type: Number,
      min: [1, 'Service rating must be at least 1'],
      max: [5, 'Service rating cannot exceed 5'],
      default: 5
    },
    reviewText: {
      type: String,
      trim: true,
      maxlength: [1000, 'Review cannot exceed 1000 characters'],
      default: ''
    },
    images: {
      type: [String],
      default: []
    },
    lookCategory: {
      type: String,
      enum: ['Hair', 'Nails', 'Skin', 'Makeup', 'Other', 'General'],
      default: 'Hair'
    },
    moderationStatus: {
      type: String,
      enum: ['approved', 'pending', 'flagged', 'hidden'],
      default: 'approved',
      index: true
    },
    moderationNotes: {
      type: String,
      default: ''
    },
    moderatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null
    },
    moderatedAt: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

reviewSchema.statics.generateReviewId = async function () {
  const count = await this.countDocuments();
  const nextNum = (count + 1).toString().padStart(4, '0');
  const candidate = `REV-${nextNum}`;
  const existing = await this.findOne({ reviewId: candidate });
  if (!existing) {
    return candidate;
  }
  return `REV-${Date.now().toString(36).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;
};

module.exports = mongoose.model('Review', reviewSchema);
