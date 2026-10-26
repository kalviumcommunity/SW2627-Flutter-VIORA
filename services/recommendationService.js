/**
 * VIORA Customer Intelligence - Recommendation & Quiz Scoring Service
 * Module: Person 2 - Customer Intelligence
 * 
 * Provides deterministic, testable scoring and matching mechanisms:
 * 1. Standardized Quiz Questions Schema (matches Group 52.png)
 * 2. Beauty Archetype & Persona Generation
 * 3. Suitable Product Recommendations Matching
 * 4. Personalized Stylist Recommendations Matching
 * 5. Matched Salon Services Recommendation
 */

const QUIZ_QUESTIONS = [
  {
    id: 'hairType',
    stepNumber: 1,
    category: 'Hair Texture',
    title: 'What is your hair texture & type?',
    subtitle: 'Helps us tailor styling techniques and product weight.',
    isMultiSelect: false,
    required: true,
    options: [
      {
        id: 'Straight',
        title: 'Straight',
        description: 'Fine to medium density with sleek, reflective finish',
        icon: 'straight'
      },
      {
        id: '2B Wavy',
        title: '2B Wavy',
        description: 'Defined S-waves with natural body and loose movement',
        icon: 'wavy'
      },
      {
        id: 'Curly',
        title: 'Curly',
        description: 'Bouncy spirals and loops that crave weightless hydration',
        icon: 'curly'
      },
      {
        id: 'Coily',
        title: 'Coily / Textured',
        description: 'Delicate tight coils requiring nourishing moisture locks',
        icon: 'coily'
      }
    ]
  },
  {
    id: 'hairConcerns',
    stepNumber: 2,
    category: 'Hair Profile',
    title: 'What is your primary hair concern?',
    subtitle: 'Select one or more concerns for personalized treatment.',
    isMultiSelect: true,
    required: true,
    options: [
      {
        id: 'Frizz Control',
        title: 'Frizz Control',
        description: 'Smoothing and hydration locks',
        icon: 'frizz'
      },
      {
        id: 'Volume & Lift',
        title: 'Volume & Lift',
        description: 'Adding body to flat layers',
        icon: 'volume'
      },
      {
        id: 'Color Maintenance',
        title: 'Color Maintenance',
        description: 'Preventing fade & brassy tones',
        icon: 'color'
      },
      {
        id: 'Damage Repair',
        title: 'Damage Repair',
        description: 'Treating heat and chemical wear',
        icon: 'damage'
      },
      {
        id: 'Scalp Health',
        title: 'Scalp Health',
        description: 'Deep cleansing and exfoliation',
        icon: 'scalp'
      }
    ]
  },
  {
    id: 'skinType',
    stepNumber: 3,
    category: 'Skin Profile',
    title: 'How would you describe your skin profile?',
    subtitle: 'Enables tailored facials and biocompatible formulations.',
    isMultiSelect: false,
    required: true,
    options: [
      {
        id: 'Combination',
        title: 'Combination',
        description: 'Oily T-zone with normal to dry cheeks',
        icon: 'combination'
      },
      {
        id: 'Dry & Dehydrated',
        title: 'Dry & Dehydrated',
        description: 'Tightness, dullness, or compromised moisture barrier',
        icon: 'dry'
      },
      {
        id: 'Balanced / Normal',
        title: 'Balanced / Normal',
        description: 'Even texture with calm, comfortable barrier',
        icon: 'normal'
      },
      {
        id: 'Sensitive / Reactive',
        title: 'Sensitive / Reactive',
        description: 'Easily irritated, prone to redness or reactivity',
        icon: 'sensitive'
      },
      {
        id: 'Oily / Congested',
        title: 'Oily / Congested',
        description: 'Persistent shine and prone to clogged pores',
        icon: 'oily'
      }
    ]
  },
  {
    id: 'goals',
    stepNumber: 4,
    category: 'Beauty Goals',
    title: 'What are your main beauty & treatment goals?',
    subtitle: 'Your immediate priorities for in-salon and at-home rituals.',
    isMultiSelect: true,
    required: true,
    options: [
      {
        id: 'Deep Hydration',
        title: 'Deep Hydration',
        description: 'Restoring long-lasting moisture, bounce, and suppleness',
        icon: 'hydration'
      },
      {
        id: 'Radiant Glow',
        title: 'Radiant Glow',
        description: 'Luminous complexion and polished, light-reflective shine',
        icon: 'glow'
      },
      {
        id: 'Bond Fortification',
        title: 'Bond Fortification',
        description: 'Strengthening cuticles, bond repair, and thermal defense',
        icon: 'fortify'
      },
      {
        id: 'Precision Style & Definition',
        title: 'Precision Style & Definition',
        description: 'Customized contour cuts, layer bounce, and sharp finish',
        icon: 'style'
      }
    ]
  },
  {
    id: 'sensitivities',
    stepNumber: 5,
    category: 'Care Preferences',
    title: 'Do you have any ingredient or service preferences?',
    subtitle: 'We filter all recommended products and formulas accordingly.',
    isMultiSelect: true,
    required: false,
    options: [
      {
        id: 'Sulfate & Paraben Free',
        title: 'Sulfate & Paraben Free',
        description: 'Gentle, clean salon formulations without harsh surfactants',
        icon: 'sulfate_free'
      },
      {
        id: 'Fragrance Sensitive',
        title: 'Fragrance Sensitive',
        description: 'Hypoallergenic, fragrance-neutral formulations',
        icon: 'fragrance_free'
      },
      {
        id: 'Vegan & Cruelty-Free',
        title: 'Vegan & Cruelty-Free',
        description: '100% plant-derived ethically certified care',
        icon: 'vegan'
      },
      {
        id: 'Ammonia / Bleach Sensitive',
        title: 'Ammonia / Bleach Sensitive',
        description: 'Zero-ammonia toning and gentle lift pigments',
        icon: 'ammonia_free'
      },
      {
        id: 'No Sensitivities',
        title: 'No Sensitivities',
        description: 'Open to all professional salon treatment lines',
        icon: 'all_clear'
      }
    ]
  }
];

// Curated VIORA Salon Product Recommendations Foundation
// Visual match to Group 53.png: "Maison Revital Serum" and "Volumizing Sea Spray"
const CURATED_PRODUCT_CATALOG = [
  {
    productId: 'PROD-H-01',
    name: 'Maison Revital Serum',
    category: 'Hair',
    price: 1200,
    formattedPrice: '₹1,200',
    imageUrl: 'https://images.unsplash.com/photo-1608248597359-2ff99479b188?w=400&auto=format&fit=crop&q=80',
    targetedHairTypes: ['2B Wavy', 'Curly', 'Coily', 'Straight'],
    targetedConcerns: ['Frizz Control', 'Damage Repair', 'Scalp Health'],
    targetedGoals: ['Deep Hydration', 'Bond Fortification'],
    features: ['Sulfate & Paraben Free', 'Vegan & Cruelty-Free'],
    keyIngredients: ['Cold-Pressed Argan', 'Hyaluronic Spheres', 'Camellia Oil'],
    baseReason: 'Restores weightless hydration and smooths cuticle frizz without weighing down wave patterns.'
  },
  {
    productId: 'PROD-H-02',
    name: 'Volumizing Sea Spray',
    category: 'Hair',
    price: 950,
    formattedPrice: '₹950',
    imageUrl: 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=400&auto=format&fit=crop&q=80',
    targetedHairTypes: ['Straight', '2B Wavy'],
    targetedConcerns: ['Volume & Lift', 'Frizz Control'],
    targetedGoals: ['Precision Style & Definition', 'Radiant Glow'],
    features: ['Sulfate & Paraben Free', 'Vegan & Cruelty-Free'],
    keyIngredients: ['Mediterranean Sea Salt', 'Bamboo Extract', 'Kelp Bio-ferment'],
    baseReason: 'Adds textured grip, instant root lift, and effortless airy bounce to layered sections.'
  },
  {
    productId: 'PROD-H-03',
    name: 'Keratin Bond Fortify Masque',
    category: 'Hair',
    price: 1450,
    formattedPrice: '₹1,450',
    imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&auto=format&fit=crop&q=80',
    targetedHairTypes: ['Straight', '2B Wavy', 'Curly', 'Coily'],
    targetedConcerns: ['Damage Repair', 'Color Maintenance'],
    targetedGoals: ['Bond Fortification', 'Deep Hydration'],
    features: ['Sulfate & Paraben Free', 'Ammonia / Bleach Sensitive'],
    keyIngredients: ['Hydrolyzed Keratin', 'Quinoa Protein', 'Marula Butter'],
    baseReason: 'Reconstructs heat-compromised bonds and locks in tone brilliance against wash-out fade.'
  },
  {
    productId: 'PROD-S-01',
    name: 'Hydra-Luxe Botanical Elixir',
    category: 'Skin',
    price: 1650,
    formattedPrice: '₹1,650',
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&auto=format&fit=crop&q=80',
    targetedSkinTypes: ['Combination', 'Dry & Dehydrated', 'Sensitive / Reactive'],
    targetedConcerns: ['Scalp Health', 'Frizz Control'],
    targetedGoals: ['Deep Hydration', 'Radiant Glow'],
    features: ['Sulfate & Paraben Free', 'Fragrance Sensitive', 'Vegan & Cruelty-Free'],
    keyIngredients: ['Snow Mushroom Tremella', 'Niacinamide', 'Ceramide NP'],
    baseReason: 'Replenishes cellular moisture barriers for a lasting dewy glow without congesting the T-zone.'
  },
  {
    productId: 'PROD-S-02',
    name: 'Purifying Enzyme Polish',
    category: 'Skin',
    price: 1100,
    formattedPrice: '₹1,100',
    imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&auto=format&fit=crop&q=80',
    targetedSkinTypes: ['Oily / Congested', 'Combination', 'Balanced / Normal'],
    targetedConcerns: ['Scalp Health'],
    targetedGoals: ['Radiant Glow', 'Precision Style & Definition'],
    features: ['Sulfate & Paraben Free', 'Vegan & Cruelty-Free'],
    keyIngredients: ['Papaya Enzymes', 'Green Tea Polyphenols', 'Rice Micro-Beads'],
    baseReason: 'Gentle fruit enzyme exfoliation eliminates surface dullness and refines pore texture.'
  },
  {
    productId: 'PROD-N-01',
    name: 'Rose Quartz Cuticle Nectar',
    category: 'Nails',
    price: 750,
    formattedPrice: '₹750',
    imageUrl: 'https://images.unsplash.com/photo-1607602132700-068258431c6c?w=400&auto=format&fit=crop&q=80',
    targetedHairTypes: [],
    targetedConcerns: ['Damage Repair', 'Frizz Control'],
    targetedGoals: ['Deep Hydration', 'Bond Fortification'],
    features: ['Vegan & Cruelty-Free', 'Fragrance Sensitive'],
    keyIngredients: ['Sweet Almond Oil', 'Vitamin E', 'Jojoba Ester'],
    baseReason: 'Nourishes nail plate keratin and soothes dry nail margins for long-wearing manicure flexibility.'
  }
];

/**
 * Determine Beauty Archetype and Personalized Summary from Quiz Answers
 */
function determineArchetypeAndSummary(answers) {
  const { hairType, hairConcerns = [], skinType, goals = [] } = answers;

  const hasVolume = hairConcerns.includes('Volume & Lift');
  const hasFrizz = hairConcerns.includes('Frizz Control');
  const hasDamage = hairConcerns.includes('Damage Repair');
  const hasColor = hairConcerns.includes('Color Maintenance');
  const hasHydration = goals.includes('Deep Hydration');
  const hasGlow = goals.includes('Radiant Glow');
  const hasFortify = goals.includes('Bond Fortification');

  let archetype = 'Luminous Glow & Hydration';
  let summary = '';

  if (hasDamage || hasFortify) {
    archetype = 'Restorative Bond & Texture Revival';
    summary = `Your profile centers on rebuilding cuticle integrity, strengthening internal keratin bonds, and shielding your ${hairType || 'hair'} texture from heat and environmental stress.`;
  } else if (hasVolume && hasFrizz) {
    archetype = 'Airy Volume & Sleek Defiance';
    summary = `Tailored for ${hairType || 'wavy/layered'} textures that need customized root lift and bounce without sacrificing smooth, frizz-resistant moisture locks.`;
  } else if (hasColor) {
    archetype = 'Luminous Color Longevity & Shine';
    summary = `Focused on locking in tonal vibrancy, preventing brassy oxidation, and enhancing mirror-like radiance across your ${skinType} complexion and styled lengths.`;
  } else if (hasGlow || hasHydration) {
    archetype = 'Luminous Glow & Hydration';
    summary = `Prioritizing deep humectant replenishment, cellular hydration for ${skinType} skin, and effortless bounce for ${hairType || 'your'} hair.`;
  } else {
    archetype = 'Bespoke Salon Ritualist';
    summary = `A balanced, harmonious beauty regimen uniting customized hair architecture with gentle, barrier-supporting skincare.`;
  }

  // Profile Chips matching Group 53.png: Hair, Skin, Concerns
  const chips = [];
  if (hairType) chips.push(`Hair: ${hairType}`);
  if (skinType) chips.push(`Skin: ${skinType}`);
  hairConcerns.forEach((concern) => {
    chips.push(`Concern: ${concern.replace(' Control', '').replace(' Repair', '').replace(' Health', '')}`);
  });

  return { archetype, summary, chips };
}

/**
 * Match Suitable Products based on answers, sensitivities, and customer preferences
 */
function matchProducts(answers, savedPreferences = {}) {
  const { hairType, hairConcerns = [], skinType, goals = [], sensitivities = [] } = answers;

  const results = CURATED_PRODUCT_CATALOG.map((product) => {
    let score = 0;
    const reasons = [];

    // Hair Type Match
    if (product.targetedHairTypes && product.targetedHairTypes.includes(hairType)) {
      score += 3;
      reasons.push(`ideal for your ${hairType} texture`);
    }

    // Skin Type Match
    if (product.targetedSkinTypes && product.targetedSkinTypes.includes(skinType)) {
      score += 3;
      reasons.push(`biocompatible with ${skinType} skin`);
    }

    // Concern Overlap
    const matchedConcerns = (product.targetedConcerns || []).filter((c) => hairConcerns.includes(c));
    if (matchedConcerns.length > 0) {
      score += matchedConcerns.length * 4;
      reasons.push(`targets ${matchedConcerns.join(' & ')}`);
    }

    // Goal Overlap
    const matchedGoals = (product.targetedGoals || []).filter((g) => goals.includes(g));
    if (matchedGoals.length > 0) {
      score += matchedGoals.length * 3;
      reasons.push(`supports ${matchedGoals.join(' & ')}`);
    }

    // Sensitivity Compatibility
    const violatesSensitivity = sensitivities.some((s) => {
      if (s === 'Sulfate & Paraben Free' && !product.features.includes('Sulfate & Paraben Free')) return true;
      if (s === 'Fragrance Sensitive' && !product.features.includes('Fragrance Sensitive')) return true;
      if (s === 'Vegan & Cruelty-Free' && !product.features.includes('Vegan & Cruelty-Free')) return true;
      return false;
    });

    if (violatesSensitivity) {
      score = -100; // Filter out incompatible products
    } else {
      // Bonus if directly caters to requested sensitivity
      const matchedFeatures = (product.features || []).filter((f) => sensitivities.includes(f));
      if (matchedFeatures.length > 0) {
        score += 2;
      }
    }

    // Customer Saved Preferences Alignment (Hair, Skin, Nails, Makeup)
    const prefHair = Array.isArray(savedPreferences.hair) ? savedPreferences.hair : [];
    if (prefHair.some((p) => product.name.toLowerCase().includes(p.toLowerCase()))) {
      score += 2;
    }

    let matchReason = product.baseReason;
    if (reasons.length > 0) {
      matchReason = `Specifically curated because it is ${reasons.join(', ')}. ${product.baseReason}`;
    }

    return {
      productId: product.productId,
      name: product.name,
      category: product.category,
      price: product.price,
      formattedPrice: product.formattedPrice,
      imageUrl: product.imageUrl,
      matchReason,
      features: product.features,
      keyIngredients: product.keyIngredients,
      score
    };
  });

  // Filter positive scores and sort descending
  const matched = results
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score);

  // Return top 2 to 4 products (as seen in Group 53.png grid)
  return matched.slice(0, 4);
}

/**
 * Match Stylists using existing Stylist & User records from database
 * Isolated and fully testable matching mechanism
 */
async function matchStylists(answers, savedPreferences = {}, StylistModel) {
  if (!StylistModel) {
    return [];
  }

  try {
    const stylists = await StylistModel.find()
      .populate('userId', 'name email role')
      .populate('branchId', 'name address');

    if (!stylists || stylists.length === 0) {
      return [];
    }

    const { hairConcerns = [], goals = [], hairType } = answers;
    const searchTerms = [
      ...hairConcerns.map((c) => c.toLowerCase()),
      ...goals.map((g) => g.toLowerCase()),
      (hairType || '').toLowerCase()
    ];

    const scoredStylists = stylists.map((stylist) => {
      const stylistUser = stylist.userId || {};
      const branch = stylist.branchId || {};
      const specializations = Array.isArray(stylist.specialization) ? stylist.specialization : [];

      let score = stylist.rating || 5.0; // Base score from rating
      let matchedSpecialties = [];

      specializations.forEach((spec) => {
        const specLower = spec.toLowerCase();
        searchTerms.forEach((term) => {
          if (term && (specLower.includes(term) || term.includes(specLower))) {
            score += 5;
            if (!matchedSpecialties.includes(spec)) {
              matchedSpecialties.push(spec);
            }
          }
        });

        // Check saved customer preferences
        const prefHair = Array.isArray(savedPreferences.hair) ? savedPreferences.hair : [];
        if (prefHair.some((p) => p.toLowerCase().includes(specLower))) {
          score += 3;
          if (!matchedSpecialties.includes(spec)) {
            matchedSpecialties.push(spec);
          }
        }
      });

      let matchReason = 'Senior Salon Stylist specializing in bespoke care.';
      if (matchedSpecialties.length > 0) {
        matchReason = `Specializes in ${matchedSpecialties.join(' & ')} with ${stylist.rating}★ rating. Perfectly aligned with your treatment goals.`;
      } else if (specializations.length > 0) {
        matchReason = `Specializes in ${specializations.join(', ')} with ${stylist.rating}★ rating.`;
      }

      return {
        stylistId: stylist.stylistId,
        name: stylistUser.name || 'Senior Salon Stylist',
        rating: stylist.rating || 5.0,
        experience: stylist.experience || 0,
        specialization: specializations,
        branchName: branch.name || 'VIORA Salon',
        matchReason,
        score
      };
    });

    // Sort descending by score
    scoredStylists.sort((a, b) => b.score - a.score);

    return scoredStylists.slice(0, 3);
  } catch (err) {
    console.error('Error matching stylists:', err);
    return [];
  }
}

/**
 * Match Recommended Services from Service database records
 * Fallback to default luxury services matching Group 53.png if DB empty
 */
async function matchServices(answers, ServiceModel) {
  const { hairConcerns = [], goals = [], hairType = '2B Wavy' } = answers;

  // Defaults matching Group 53.png
  const defaultServices = [
    {
      serviceId: 'SRV-REC-01',
      name: 'Premium Hair Spa',
      category: 'Hair',
      duration: 60,
      price: 1500,
      formattedPrice: 'From ₹1,500',
      description: `Specifically curated to restore hydration and reduce frizz for your ${hairType} hair texture.`,
      matchReason: 'Targets deep hydration and cuticle smoothing'
    },
    {
      serviceId: 'SRV-REC-02',
      name: 'Couture Haircut & Style',
      category: 'Hair',
      duration: 45,
      price: 1800,
      formattedPrice: 'From ₹1,800',
      description: 'Ideal for adding customized body, layers, and bounce to flat crown sections.',
      matchReason: 'Customized contour layering to address volume and bounce'
    }
  ];

  if (!ServiceModel) {
    return defaultServices;
  }

  try {
    const dbServices = await ServiceModel.find({ availability: true });
    if (!dbServices || dbServices.length === 0) {
      return defaultServices;
    }

    const scored = dbServices.map((srv) => {
      let score = 0;
      const nameLower = (srv.name || '').toLowerCase();
      const descLower = (srv.description || '').toLowerCase();

      hairConcerns.forEach((c) => {
        const cLower = c.toLowerCase();
        if (nameLower.includes(cLower) || descLower.includes(cLower)) score += 4;
      });

      goals.forEach((g) => {
        const gLower = g.toLowerCase();
        if (nameLower.includes(gLower) || descLower.includes(gLower)) score += 3;
      });

      if (srv.category === 'Hair') score += 2;

      return {
        serviceId: srv.serviceId,
        name: srv.name,
        category: srv.category,
        duration: srv.duration,
        price: srv.price,
        formattedPrice: `From ₹${srv.price.toLocaleString('en-IN')}`,
        description: srv.description || `Tailored ${srv.category} treatment for your beauty profile.`,
        matchReason: `Curated for your ${hairType} texture and ${hairConcerns[0] || 'beauty goals'}.`,
        score
      };
    });

    scored.sort((a, b) => b.score - a.score);
    const topServices = scored.filter((s) => s.score > 0).slice(0, 3);

    return topServices.length > 0 ? topServices : defaultServices;
  } catch (err) {
    console.error('Error querying services for recommendations:', err);
    return defaultServices;
  }
}

/**
 * Validate incoming Quiz Answers Payload
 */
function validateQuizAnswers(answers) {
  const errors = [];

  if (!answers || typeof answers !== 'object') {
    return { isValid: false, errors: ['Invalid request payload. Quiz answers object required.'] };
  }

  if (!answers.hairType || typeof answers.hairType !== 'string' || !answers.hairType.trim()) {
    errors.push('Hair type is required.');
  }

  if (!Array.isArray(answers.hairConcerns) || answers.hairConcerns.length === 0) {
    errors.push('At least one hair concern must be selected.');
  }

  if (!answers.skinType || typeof answers.skinType !== 'string' || !answers.skinType.trim()) {
    errors.push('Skin type is required.');
  }

  if (!Array.isArray(answers.goals) || answers.goals.length === 0) {
    errors.push('At least one beauty or treatment goal must be selected.');
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

module.exports = {
  QUIZ_QUESTIONS,
  CURATED_PRODUCT_CATALOG,
  determineArchetypeAndSummary,
  matchProducts,
  matchStylists,
  matchServices,
  validateQuizAnswers
};
