const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema(
  {
    serviceId: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch'
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    description: {
      type: String,
      default: ''
    },
    duration: {
      type: Number, // in minutes
      required: true
    },
    price: {
      type: Number,
      required: true
    },
    category: {
      type: String,
      enum: ['Hair', 'Nails', 'Skin', 'Makeup', 'Other'],
      default: 'Hair'
    },
    availability: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Service', serviceSchema);
