const mongoose = require('mongoose');

const portfolioItemSchema = new mongoose.Schema(
  {
    portfolioId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true
    },
    stylistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Stylist',
      required: true,
      index: true
    },
    title: {
      type: String,
      required: [true, 'Please provide a title for the portfolio item'],
      trim: true,
      maxlength: [120, 'Title cannot exceed 120 characters']
    },
    description: {
      type: String,
      default: '',
      trim: true,
      maxlength: [500, 'Description cannot exceed 500 characters']
    },
    category: {
      type: String,
      enum: ['Hair', 'Nails', 'Skin', 'Makeup', 'Other'],
      required: [true, 'Please select a category'],
      default: 'Hair'
    },
    imageUrl: {
      type: String,
      required: [true, 'Please provide an image URL for the portfolio item']
    },
    tags: {
      type: [String],
      default: []
    },
    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

portfolioItemSchema.statics.generatePortfolioId = async function () {
  const count = await this.countDocuments();
  const nextNum = (count + 1).toString().padStart(4, '0');
  const candidate = `PORT-${nextNum}`;
  const existing = await this.findOne({ portfolioId: candidate });
  if (!existing) {
    return candidate;
  }
  return `PORT-${Date.now().toString(36).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;
};

module.exports = mongoose.model('PortfolioItem', portfolioItemSchema);
