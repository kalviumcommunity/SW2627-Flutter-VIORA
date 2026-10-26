const mongoose = require('mongoose');

const inspirationRequestSchema = new mongoose.Schema(
  {
    requestId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
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
    category: {
      type: String,
      enum: ['Hair', 'Nails', 'Skin', 'Makeup', 'Other'],
      required: [true, 'Please select a service category'],
      default: 'Hair'
    },
    referenceImages: {
      type: [String],
      default: []
    },
    description: {
      type: String,
      required: [true, 'Please provide a description of your desired look'],
      trim: true,
      maxlength: [2000, 'Description cannot exceed 2000 characters']
    },
    preferredBranchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch',
      default: null
    },
    preferredDate: {
      type: Date,
      default: null
    },
    flexibleDate: {
      type: Boolean,
      default: true
    },
    estimatedBudget: {
      type: Number,
      default: null
    },
    status: {
      type: String,
      enum: ['pending', 'responded', 'accepted', 'declined', 'completed', 'cancelled'],
      default: 'pending',
      index: true
    },
    chosenStylistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Stylist',
      default: null
    },
    chosenResponseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'InspirationResponse',
      default: null
    },
    notes: {
      type: String,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

inspirationRequestSchema.statics.generateRequestId = async function () {
  const count = await this.countDocuments();
  const nextNum = (count + 1).toString().padStart(4, '0');
  const candidate = `INSP-${nextNum}`;
  const existing = await this.findOne({ requestId: candidate });
  if (!existing) {
    return candidate;
  }
  return `INSP-${Date.now().toString(36).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;
};

module.exports = mongoose.model('InspirationRequest', inspirationRequestSchema);
