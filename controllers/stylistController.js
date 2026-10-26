const Stylist = require('../models/Stylist');
const PortfolioItem = require('../models/PortfolioItem');
const Review = require('../models/Review');
const UploadService = require('../services/uploadService');

class StylistController {
  /**
   * Get all active stylists
   * GET /api/stylists
   */
  static async getAllStylists(req, res, next) {
    try {
      const { branchId, specialization } = req.query;
      const filter = {};
      if (branchId) filter.branchId = branchId;
      if (specialization) filter.specialization = specialization;

      const stylists = await Stylist.find(filter)
        .populate('userId', 'name email phone')
        .populate('branchId', 'name address phone openingTime closingTime')
        .sort({ rating: -1 });

      return res.status(200).json({
        success: true,
        count: stylists.length,
        data: stylists
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get stylist profile by ID
   * GET /api/stylists/:id
   */
  static async getStylistById(req, res, next) {
    try {
      const { id } = req.params;
      const stylist = await Stylist.findOne({
        $or: [{ stylistId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      })
        .populate('userId', 'name email phone')
        .populate('branchId', 'name address phone openingTime closingTime');

      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist not found'
        });
      }

      // Fetch public portfolio
      const portfolio = await PortfolioItem.find({ stylistId: stylist._id, isActive: true }).sort({ createdAt: -1 });

      // Fetch approved reviews
      const reviews = await Review.find({ stylistId: stylist._id, moderationStatus: 'approved' })
        .populate('serviceId', 'name')
        .sort({ createdAt: -1 })
        .limit(10);

      return res.status(200).json({
        success: true,
        data: {
          stylist,
          portfolio,
          reviews
        }
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get public portfolio of a stylist
   * GET /api/stylists/:id/portfolio
   */
  static async getStylistPortfolio(req, res, next) {
    try {
      const { id } = req.params;
      const { category } = req.query;

      const stylist = await Stylist.findOne({
        $or: [{ stylistId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist not found'
        });
      }

      const query = { stylistId: stylist._id, isActive: true };
      if (category && category !== 'All') {
        query.category = category;
      }

      const items = await PortfolioItem.find(query).sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: items.length,
        data: items
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get authenticated stylist's own portfolio
   * GET /api/stylists/me/portfolio
   */
  static async getMyPortfolio(req, res, next) {
    try {
      const stylist = await Stylist.findOne({ userId: req.user._id });
      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist profile not found for authenticated account'
        });
      }

      const items = await PortfolioItem.find({ stylistId: stylist._id }).sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: items.length,
        data: items
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Add portfolio item (authenticated stylist)
   * POST /api/stylists/me/portfolio
   */
  static async createPortfolioItem(req, res, next) {
    try {
      const { title, description = '', category = 'Hair', image, imageUrl, tags = [] } = req.body;

      if (!title || !title.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Title is required for the portfolio item'
        });
      }

      const stylist = await Stylist.findOne({ userId: req.user._id });
      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist profile not found for authenticated account'
        });
      }

      let finalImageUrl = imageUrl;
      if (image) {
        finalImageUrl = await UploadService.saveImage(image, 'port');
      }

      if (!finalImageUrl) {
        return res.status(400).json({
          success: false,
          message: 'Please provide an image for the portfolio item'
        });
      }

      const portfolioId = await PortfolioItem.generatePortfolioId();
      const item = await PortfolioItem.create({
        portfolioId,
        stylistId: stylist._id,
        title: title.trim(),
        description: description.trim(),
        category,
        imageUrl: finalImageUrl,
        tags: Array.isArray(tags) ? tags : [],
        isActive: true
      });

      return res.status(201).json({
        success: true,
        message: 'Portfolio item added successfully',
        data: item
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Update portfolio item (ensures ownership)
   * PUT /api/stylists/me/portfolio/:itemId
   */
  static async updatePortfolioItem(req, res, next) {
    try {
      const { itemId } = req.params;
      const { title, description, category, image, imageUrl, tags, isActive } = req.body;

      const stylist = await Stylist.findOne({ userId: req.user._id });
      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist profile not found'
        });
      }

      const item = await PortfolioItem.findOne({
        $or: [{ portfolioId: itemId }, { _id: itemId.match(/^[0-9a-fA-F]{24}$/) ? itemId : null }]
      });

      if (!item) {
        return res.status(404).json({
          success: false,
          message: 'Portfolio item not found'
        });
      }

      // Strict ownership check
      if (item.stylistId.toString() !== stylist._id.toString()) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to update another stylist’s portfolio item'
        });
      }

      if (title !== undefined) item.title = title.trim();
      if (description !== undefined) item.description = description.trim();
      if (category !== undefined) item.category = category;
      if (tags !== undefined) item.tags = Array.isArray(tags) ? tags : [];
      if (isActive !== undefined) item.isActive = Boolean(isActive);

      if (image) {
        item.imageUrl = await UploadService.saveImage(image, 'port');
      } else if (imageUrl) {
        item.imageUrl = imageUrl;
      }

      await item.save();

      return res.status(200).json({
        success: true,
        message: 'Portfolio item updated successfully',
        data: item
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Delete or deactivate portfolio item (ensures ownership)
   * DELETE /api/stylists/me/portfolio/:itemId
   */
  static async deletePortfolioItem(req, res, next) {
    try {
      const { itemId } = req.params;

      const stylist = await Stylist.findOne({ userId: req.user._id });
      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist profile not found'
        });
      }

      const item = await PortfolioItem.findOne({
        $or: [{ portfolioId: itemId }, { _id: itemId.match(/^[0-9a-fA-F]{24}$/) ? itemId : null }]
      });

      if (!item) {
        return res.status(404).json({
          success: false,
          message: 'Portfolio item not found'
        });
      }

      // Strict ownership check
      if (item.stylistId.toString() !== stylist._id.toString()) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to delete another stylist’s portfolio item'
        });
      }

      await PortfolioItem.deleteOne({ _id: item._id });

      return res.status(200).json({
        success: true,
        message: 'Portfolio item deleted successfully'
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get reviews received by the authenticated stylist
   * GET /api/stylists/me/reviews
   */
  static async getMyReviews(req, res, next) {
    try {
      const stylist = await Stylist.findOne({ userId: req.user._id });
      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist profile not found'
        });
      }

      const reviews = await Review.find({ stylistId: stylist._id, moderationStatus: 'approved' })
        .populate('serviceId', 'name category price')
        .populate('branchId', 'name')
        .sort({ createdAt: -1 });

      const totalReviews = reviews.length;
      const avgStylistRating = totalReviews > 0
        ? Number((reviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews).toFixed(2))
        : 5.0;
      const avgLookRating = totalReviews > 0
        ? Number((reviews.reduce((sum, r) => sum + r.lookRating, 0) / totalReviews).toFixed(2))
        : 5.0;

      return res.status(200).json({
        success: true,
        stats: {
          totalReviews,
          avgStylistRating,
          avgLookRating
        },
        data: reviews
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = StylistController;
