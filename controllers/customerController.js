const Customer = require('../models/Customer');
const User = require('../models/User');

// @desc    Get current authenticated customer profile
// @route   GET /api/customers/profile
// @access  Private (Customer)
exports.getProfile = async (req, res) => {
  try {
    // Identify logged-in user from auth middleware
    const userId = req.user._id;

    let customer = await Customer.findOne({ userId });

    // Self-healing: if customer profile doesn't exist yet for a customer user
    if (!customer) {
      if (req.user.role === 'customer') {
        const globalCustomerId = await Customer.generateGlobalCustomerId();
        customer = await Customer.create({
          customerId: globalCustomerId,
          userId: req.user._id,
          name: req.user.name,
          email: req.user.email,
          phone: req.user.phone || '',
          preferences: {
            hair: [],
            nails: [],
            skin: [],
            makeup: []
          }
        });
      } else {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found for this account'
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: {
        customerId: customer.customerId,
        userId: customer.userId,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        dateOfBirth: customer.dateOfBirth,
        profilePhoto: customer.profilePhoto,
        preferences: customer.preferences,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching customer profile'
    });
  }
};

// @desc    Update current authenticated customer profile
// @route   PUT /api/customers/profile
// @access  Private (Customer)
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user._id;

    let customer = await Customer.findOne({ userId });

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer profile not found'
      });
    }

    const {
      name,
      phone,
      dateOfBirth,
      profilePhoto,
      preferences,
      // Restricted fields:
      customerId: attemptedCustomerId,
      userId: attemptedUserId,
      role: attemptedRole,
      password: attemptedPassword
    } = req.body;

    // Explicit security check: Prevent tampering with immutable identifiers
    if (
      attemptedCustomerId !== undefined &&
      attemptedCustomerId !== customer.customerId
    ) {
      return res.status(400).json({
        success: false,
        message: 'Modification of global customerId is not permitted'
      });
    }

    if (
      attemptedUserId !== undefined &&
      attemptedUserId.toString() !== customer.userId.toString()
    ) {
      return res.status(400).json({
        success: false,
        message: 'Modification of userId is not permitted'
      });
    }

    // Apply allowed updates
    if (name !== undefined) customer.name = name.trim();
    if (phone !== undefined) customer.phone = phone.trim();
    if (dateOfBirth !== undefined) customer.dateOfBirth = dateOfBirth;
    if (profilePhoto !== undefined) customer.profilePhoto = profilePhoto.trim();

    // Optionally update preferences if provided in profile payload
    if (preferences && typeof preferences === 'object') {
      if (Array.isArray(preferences.hair)) customer.preferences.hair = preferences.hair;
      if (Array.isArray(preferences.nails)) customer.preferences.nails = preferences.nails;
      if (Array.isArray(preferences.skin)) customer.preferences.skin = preferences.skin;
      if (Array.isArray(preferences.makeup)) customer.preferences.makeup = preferences.makeup;
    }

    await customer.save();

    // Keep corresponding User record in sync for common attributes
    if (name !== undefined || phone !== undefined) {
      const userUpdate = {};
      if (name !== undefined) userUpdate.name = customer.name;
      if (phone !== undefined) userUpdate.phone = customer.phone;
      await User.findByIdAndUpdate(userId, userUpdate);
    }

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        customerId: customer.customerId,
        userId: customer.userId,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        dateOfBirth: customer.dateOfBirth,
        profilePhoto: customer.profilePhoto,
        preferences: customer.preferences,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while updating customer profile'
    });
  }
};

// @desc    Get customer preferences
// @route   GET /api/customers/preferences
// @access  Private (Customer)
exports.getPreferences = async (req, res) => {
  try {
    const customer = await Customer.findOne({ userId: req.user._id });
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    return res.status(200).json({
      success: true,
      data: customer.preferences
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while fetching preferences'
    });
  }
};

// @desc    Update customer preferences
// @route   PUT /api/customers/preferences
// @access  Private (Customer)
exports.updatePreferences = async (req, res) => {
  try {
    const customer = await Customer.findOne({ userId: req.user._id });
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    const { hair, nails, skin, makeup } = req.body;

    if (hair && Array.isArray(hair)) customer.preferences.hair = hair;
    if (nails && Array.isArray(nails)) customer.preferences.nails = nails;
    if (skin && Array.isArray(skin)) customer.preferences.skin = skin;
    if (makeup && Array.isArray(makeup)) customer.preferences.makeup = makeup;

    await customer.save();

    return res.status(200).json({
      success: true,
      message: 'Preferences updated successfully',
      data: customer.preferences
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while updating preferences'
    });
  }
};
