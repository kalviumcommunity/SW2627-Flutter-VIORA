const mongoose = require('mongoose');

const quizResultSchema = new mongoose.Schema(
  {
    customerId: {
      type: String, // Global customerId reference (e.g. CUST-0001)
      required: true,
      index: true
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    answers: {
      hairType: {
        type: String,
        required: true,
        trim: true
      },
      hairConcerns: {
        type: [String],
        default: []
      },
      skinType: {
        type: String,
        required: true,
        trim: true
      },
      goals: {
        type: [String],
        default: []
      },
      sensitivities: {
        type: [String],
        default: []
      }
    },
    profileArchetype: {
      type: String,
      default: 'Luminous Glow & Hydration'
    },
    summary: {
      type: String,
      default: ''
    },
    profileChips: {
      type: [String],
      default: []
    },
    recommendations: {
      products: [
        {
          productId: { type: String, required: true },
          name: { type: String, required: true },
          category: { type: String, default: 'Hair' },
          price: { type: Number, default: 0 },
          formattedPrice: { type: String, default: '' },
          imageUrl: { type: String, default: '' },
          matchReason: { type: String, default: '' },
          features: { type: [String], default: [] },
          keyIngredients: { type: [String], default: [] }
        }
      ],
      stylists: [
        {
          stylistId: { type: String, default: '' },
          name: { type: String, required: true },
          rating: { type: Number, default: 5.0 },
          experience: { type: Number, default: 0 },
          specialization: { type: [String], default: [] },
          branchName: { type: String, default: 'VIORA Salon' },
          matchReason: { type: String, default: '' }
        }
      ],
      services: [
        {
          serviceId: { type: String, default: '' },
          name: { type: String, required: true },
          category: { type: String, default: 'Hair' },
          duration: { type: Number, default: 60 },
          price: { type: Number, default: 0 },
          formattedPrice: { type: String, default: '' },
          description: { type: String, default: '' },
          matchReason: { type: String, default: '' }
        }
      ]
    },
    retakeCount: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);

// Compound index to quickly find latest quiz for a customer
quizResultSchema.index({ customerId: 1, createdAt: -1 });

module.exports = mongoose.model('QuizResult', quizResultSchema);
