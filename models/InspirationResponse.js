const mongoose = require('mongoose');

const inspirationResponseSchema = new mongoose.Schema(
  {
    responseId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true
    },
    requestId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'InspirationRequest',
      required: true,
      index: true
    },
    stylistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Stylist',
      required: true,
      index: true
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'declined', 'withdrawn'],
      default: 'pending'
    },
    message: {
      type: String,
      required: [true, 'Please provide a message for the customer'],
      trim: true,
      maxlength: [1000, 'Message cannot exceed 1000 characters']
    },
    suggestedServiceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Service',
      default: null
    },
    estimatedPrice: {
      type: Number,
      default: null
    },
    portfolioImageUrls: {
      type: [String],
      default: []
    },
    availableDates: {
      type: [Date],
      default: []
    }
  },
  {
    timestamps: true
  }
);

inspirationResponseSchema.statics.generateResponseId = async function () {
  const count = await this.countDocuments();
  const nextNum = (count + 1).toString().padStart(4, '0');
  const candidate = `RESP-${nextNum}`;
  const existing = await this.findOne({ responseId: candidate });
  if (!existing) {
    return candidate;
  }
  return `RESP-${Date.now().toString(36).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;
};

module.exports = mongoose.model('InspirationResponse', inspirationResponseSchema);
