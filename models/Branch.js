const mongoose = require('mongoose');

const branchSchema = new mongoose.Schema(
  {
    branchId: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    address: {
      type: String,
      required: true
    },
    phone: {
      type: String,
      required: true
    },
    openingTime: {
      type: String,
      default: '09:00'
    },
    closingTime: {
      type: String,
      default: '20:00'
    },
    status: {
      type: String,
      enum: ['active', 'inactive'],
      default: 'active'
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Branch', branchSchema);
