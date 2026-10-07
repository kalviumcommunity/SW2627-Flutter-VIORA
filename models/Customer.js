const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema(
  {
    customerId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
      index: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    email: {
      type: String,
      required: true,
      lowercase: true,
      trim: true
    },
    phone: {
      type: String,
      trim: true,
      default: ''
    },
    dateOfBirth: {
      type: Date,
      default: null
    },
    profilePhoto: {
      type: String,
      default: ''
    },
    preferences: {
      hair: {
        type: [String],
        default: []
      },
      nails: {
        type: [String],
        default: []
      },
      skin: {
        type: [String],
        default: []
      },
      makeup: {
        type: [String],
        default: []
      }
    }
  },
  {
    timestamps: true
  }
);

// Static method to generate unique global customer ID
customerSchema.statics.generateGlobalCustomerId = async function () {
  const count = await this.countDocuments();
  const nextNum = (count + 1).toString().padStart(4, '0');
  let candidate = `CUST-${nextNum}`;
  const existing = await this.findOne({ customerId: candidate });
  if (!existing) {
    return candidate;
  }
  return `CUST-${Date.now().toString(36).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;
};

module.exports = mongoose.model('Customer', customerSchema);
