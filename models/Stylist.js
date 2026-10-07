const mongoose = require('mongoose');

const stylistSchema = new mongoose.Schema(
  {
    stylistId: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch'
    },
    specialization: {
      type: [String],
      default: []
    },
    experience: {
      type: Number,
      default: 0
    },
    rating: {
      type: Number,
      default: 5.0
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Stylist', stylistSchema);
