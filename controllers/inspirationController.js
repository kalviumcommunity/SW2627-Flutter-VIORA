const InspirationRequest = require('../models/InspirationRequest');
const InspirationResponse = require('../models/InspirationResponse');
const Customer = require('../models/Customer');
const Stylist = require('../models/Stylist');
const Branch = require('../models/Branch');
const Service = require('../models/Service');
const PortfolioItem = require('../models/PortfolioItem');
const UploadService = require('../services/uploadService');
const NotificationService = require('../services/notificationService');

/**
 * Curated discovery looks for Inspiration Home
 */
const CURATED_LOOKS = [
  {
    id: 'look-1',
    title: 'Sun-Kissed Parisian Balayage',
    category: 'Hair',
    imageUrl: 'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=800&auto=format&fit=crop&q=80',
    description: 'Soft dimensional gradient with hand-painted caramel highlights and face-framing ribbons.',
    stylistName: 'Julian Vance',
    branchName: 'MAISON — Bandra Flagship',
    rating: 4.95,
    estimatedDuration: '120 min',
    tags: ['Balayage', 'Blonde', 'Dimensional']
  },
  {
    id: 'look-2',
    title: 'Architectural Glazed Chrome French',
    category: 'Nails',
    imageUrl: 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=800&auto=format&fit=crop&q=80',
    description: 'High-gloss optical glass finish on almond apex sculpt with iridescent pearl powder.',
    stylistName: 'Elena Rostova',
    branchName: 'MAISON — Khar West',
    rating: 4.9,
    estimatedDuration: '75 min',
    tags: ['Chrome', 'French', 'Gel']
  },
  {
    id: 'look-3',
    title: 'Hydra-Infused Glass Skin Treatment',
    category: 'Skin',
    imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=800&auto=format&fit=crop&q=80',
    description: 'Cellular restoration therapy featuring hyaluronic micro-infusion and cryogenic depuffing.',
    stylistName: 'Aria Mehta',
    branchName: 'MAISON — Bandra Flagship',
    rating: 4.88,
    estimatedDuration: '60 min',
    tags: ['HydraFacial', 'Glow', 'Lymphatic']
  },
  {
    id: 'look-4',
    title: 'Editorial Smoked Bronze & Dewy Glow',
    category: 'Makeup',
    imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800&auto=format&fit=crop&q=80',
    description: 'Velvet contoured sculpting paired with warm bronze wash and satin nude finish.',
    stylistName: 'Mira Thorne',
    branchName: 'MAISON — Juhu Haven',
    rating: 4.92,
    estimatedDuration: '90 min',
    tags: ['Bronze', 'Bridal', 'Editorial']
  },
  {
    id: 'look-5',
    title: 'Silk Press & Japanese Keratin Glaze',
    category: 'Hair',
    imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800&auto=format&fit=crop&q=80',
    description: 'Molecular bond smoothing system delivering ultra-fluid movement and reflective mirror shine.',
    stylistName: 'Julian Vance',
    branchName: 'MAISON — Bandra Flagship',
    rating: 4.96,
    estimatedDuration: '150 min',
    tags: ['SilkPress', 'Keratin', 'MirrorShine']
  }
];

class InspirationController {
  /**
   * Upload an inspiration image (validates file type, magic bytes, size)
   * POST /api/inspiration/upload
   */
  static async uploadImage(req, res, next) {
    try {
      const { image, prefix = 'insp' } = req.body;
      if (!image) {
        return res.status(400).json({
          success: false,
          message: 'No image payload provided'
        });
      }

      const imageUrl = await UploadService.saveImage(image, prefix);
      return res.status(200).json({
        success: true,
        message: 'Image uploaded successfully',
        url: imageUrl
      });
    } catch (err) {
      return res.status(400).json({
        success: false,
        message: err.message || 'Image upload failed'
      });
    }
  }

  /**
   * Get discovery feed: trending looks & category filters
   * GET /api/inspiration/discovery
   */
  static async getDiscoveryFeed(req, res, next) {
    try {
      const { category, search } = req.query;

      // Fetch dynamic active portfolio items
      const query = { isActive: true };
      if (category && category !== 'All') {
        query.category = category;
      }
      if (search) {
        query.$or = [
          { title: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
          { tags: { $in: [new RegExp(search, 'i')] } }
        ];
      }

      const portfolioItems = await PortfolioItem.find(query)
        .populate({
          path: 'stylistId',
          populate: [
            { path: 'userId', select: 'name' },
            { path: 'branchId', select: 'name' }
          ]
        })
        .sort({ createdAt: -1 })
        .limit(20);

      // Map dynamic items to look structure
      const dynamicLooks = portfolioItems.map((item) => ({
        id: item.portfolioId,
        title: item.title,
        category: item.category,
        imageUrl: item.imageUrl,
        description: item.description,
        stylistName: (item.stylistId && item.stylistId.userId && item.stylistId.userId.name) || 'VIORA Master Stylist',
        branchName: (item.stylistId && item.stylistId.branchId && item.stylistId.branchId.name) || 'MAISON Salon',
        rating: (item.stylistId && item.stylistId.rating) || 5.0,
        tags: item.tags || []
      }));

      // Filter curated looks
      let combined = [...CURATED_LOOKS];
      if (category && category !== 'All') {
        combined = combined.filter((l) => l.category.toLowerCase() === category.toLowerCase());
      }
      if (search) {
        const s = search.toLowerCase();
        combined = combined.filter(
          (l) =>
            l.title.toLowerCase().includes(s) ||
            l.description.toLowerCase().includes(s) ||
            l.tags.some((t) => t.toLowerCase().includes(s))
        );
      }

      // Merge dynamic and curated, prioritizing dynamic
      const allLooks = [...dynamicLooks, ...combined];

      return res.status(200).json({
        success: true,
        count: allLooks.length,
        categories: ['All', 'Hair', 'Nails', 'Skin', 'Makeup', 'Other'],
        data: allLooks
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Submit an inspiration request
   * POST /api/inspiration/requests
   */
  static async createRequest(req, res, next) {
    try {
      const {
        category,
        referenceImages = [],
        description,
        preferredBranchId,
        preferredDate,
        flexibleDate = true,
        estimatedBudget,
        notes = ''
      } = req.body;

      if (!description || !description.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Please provide a description of your desired look'
        });
      }

      const validCategories = ['Hair', 'Nails', 'Skin', 'Makeup', 'Other'];
      if (category && !validCategories.includes(category)) {
        return res.status(400).json({
          success: false,
          message: `Category must be one of: ${validCategories.join(', ')}`
        });
      }

      // Find customer document
      const customer = await Customer.findOne({ userId: req.user._id });
      if (!customer) {
        return res.status(404).json({
          success: false,
          message: 'Customer profile not found. Please complete profile registration.'
        });
      }

      // Generate unique requestId
      const requestId = await InspirationRequest.generateRequestId();

      // Create request document
      const requestDoc = await InspirationRequest.create({
        requestId,
        customerId: customer.customerId,
        userId: req.user._id,
        category: category || 'Hair',
        referenceImages: Array.isArray(referenceImages) ? referenceImages : [],
        description: description.trim(),
        preferredBranchId: preferredBranchId || null,
        preferredDate: preferredDate ? new Date(preferredDate) : null,
        flexibleDate: Boolean(flexibleDate),
        estimatedBudget: estimatedBudget ? Number(estimatedBudget) : null,
        status: 'pending',
        notes: notes.trim()
      });

      // Notify customer
      await NotificationService.createNotification({
        recipientId: req.user._id,
        recipientRole: 'customer',
        type: 'INSPIRATION_SUBMITTED',
        title: 'Inspiration Request Submitted',
        message: `Your ${requestDoc.category} look consultation (${requestDoc.requestId}) has been dispatched to our stylists.`,
        entityType: 'InspirationRequest',
        entityId: requestDoc.requestId
      });

      // Notify relevant stylists
      await NotificationService.notifyStylists({
        branchId: preferredBranchId,
        category: requestDoc.category,
        type: 'INSPIRATION_SUBMITTED',
        title: `New ${requestDoc.category} Look Request`,
        message: `A client has requested a bespoke ${requestDoc.category} styling consultation.`,
        entityType: 'InspirationRequest',
        entityId: requestDoc.requestId
      });

      return res.status(201).json({
        success: true,
        message: 'Inspiration request submitted successfully',
        data: requestDoc
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get inspiration requests (scoped to customer, stylist, or admin)
   * GET /api/inspiration/requests
   */
  static async getRequests(req, res, next) {
    try {
      const { status, category } = req.query;
      const filter = {};

      if (status) filter.status = status;
      if (category) filter.category = category;

      if (req.user.role === 'customer') {
        const customer = await Customer.findOne({ userId: req.user._id });
        if (!customer) {
          return res.status(200).json({ success: true, count: 0, data: [] });
        }
        filter.customerId = customer.customerId;
      } else if (req.user.role === 'stylist') {
        const stylist = await Stylist.findOne({ userId: req.user._id });
        if (stylist && stylist.branchId) {
          // Stylist sees requests matching their branch or unassigned
          filter.$or = [
            { preferredBranchId: stylist.branchId },
            { preferredBranchId: null }
          ];
        }
      }

      const requests = await InspirationRequest.find(filter)
        .populate('preferredBranchId', 'name address phone')
        .populate({
          path: 'chosenStylistId',
          populate: { path: 'userId', select: 'name email phone' }
        })
        .sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: requests.length,
        data: requests
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get single inspiration request with stylist responses
   * GET /api/inspiration/requests/:id
   */
  static async getRequestById(req, res, next) {
    try {
      const { id } = req.params;
      const requestDoc = await InspirationRequest.findOne({
        $or: [{ requestId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      }).populate('preferredBranchId', 'name address phone');

      if (!requestDoc) {
        return res.status(404).json({
          success: false,
          message: 'Inspiration request not found'
        });
      }

      // Customer authorization check
      if (req.user.role === 'customer') {
        const customer = await Customer.findOne({ userId: req.user._id });
        if (!customer || customer.customerId !== requestDoc.customerId) {
          return res.status(403).json({
            success: false,
            message: 'You are not authorized to view this inspiration request'
          });
        }
      }

      // Fetch stylist responses
      const responses = await InspirationResponse.find({ requestId: requestDoc._id })
        .populate({
          path: 'stylistId',
          populate: [
            { path: 'userId', select: 'name email phone' },
            { path: 'branchId', select: 'name address' }
          ]
        })
        .populate('suggestedServiceId', 'name duration price category');

      return res.status(200).json({
        success: true,
        data: {
          request: requestDoc,
          responses
        }
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Stylist responds to request
   * POST /api/inspiration/requests/:id/respond
   */
  static async respondToRequest(req, res, next) {
    try {
      const { id } = req.params;
      const {
        message,
        suggestedServiceId,
        estimatedPrice,
        portfolioImageUrls = [],
        availableDates = []
      } = req.body;

      if (!message || !message.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Please provide a response message for the client'
        });
      }

      const requestDoc = await InspirationRequest.findOne({
        $or: [{ requestId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!requestDoc) {
        return res.status(404).json({
          success: false,
          message: 'Inspiration request not found'
        });
      }

      if (['cancelled', 'completed'].includes(requestDoc.status)) {
        return res.status(400).json({
          success: false,
          message: `Cannot respond to request with status '${requestDoc.status}'`
        });
      }

      const stylist = await Stylist.findOne({ userId: req.user._id });
      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist record not found for authenticated account'
        });
      }

      // Check if this stylist already responded
      let existingResponse = await InspirationResponse.findOne({
        requestId: requestDoc._id,
        stylistId: stylist._id
      });

      if (existingResponse) {
        existingResponse.message = message.trim();
        if (suggestedServiceId) existingResponse.suggestedServiceId = suggestedServiceId;
        if (estimatedPrice !== undefined) existingResponse.estimatedPrice = estimatedPrice;
        if (portfolioImageUrls.length) existingResponse.portfolioImageUrls = portfolioImageUrls;
        existingResponse.status = 'pending';
        await existingResponse.save();
      } else {
        const responseId = await InspirationResponse.generateResponseId();
        existingResponse = await InspirationResponse.create({
          responseId,
          requestId: requestDoc._id,
          stylistId: stylist._id,
          status: 'pending',
          message: message.trim(),
          suggestedServiceId: suggestedServiceId || null,
          estimatedPrice: estimatedPrice ? Number(estimatedPrice) : null,
          portfolioImageUrls: Array.isArray(portfolioImageUrls) ? portfolioImageUrls : [],
          availableDates: Array.isArray(availableDates) ? availableDates : []
        });
      }

      // Update request status to 'responded' if it was 'pending'
      if (requestDoc.status === 'pending') {
        requestDoc.status = 'responded';
        await requestDoc.save();
      }

      // Notify customer
      await NotificationService.createNotification({
        recipientId: requestDoc.userId,
        recipientRole: 'customer',
        type: 'INSPIRATION_RESPONSE',
        title: 'New Stylist Response Received',
        message: `A stylist has reviewed and responded to your ${requestDoc.category} look request (${requestDoc.requestId}).`,
        entityType: 'InspirationRequest',
        entityId: requestDoc.requestId
      });

      return res.status(200).json({
        success: true,
        message: 'Response sent to customer successfully',
        data: existingResponse
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Stylist accepts or declines a request
   * PUT /api/inspiration/requests/:id/status
   */
  static async updateStatus(req, res, next) {
    try {
      const { id } = req.params;
      const { status, message = '' } = req.body;

      if (!['accepted', 'declined'].includes(status)) {
        return res.status(400).json({
          success: false,
          message: "Status must be either 'accepted' or 'declined'"
        });
      }

      const requestDoc = await InspirationRequest.findOne({
        $or: [{ requestId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!requestDoc) {
        return res.status(404).json({
          success: false,
          message: 'Inspiration request not found'
        });
      }

      if (['cancelled', 'completed'].includes(requestDoc.status)) {
        return res.status(400).json({
          success: false,
          message: `Cannot update request with status '${requestDoc.status}'`
        });
      }

      const stylist = await Stylist.findOne({ userId: req.user._id });
      if (!stylist) {
        return res.status(404).json({
          success: false,
          message: 'Stylist record not found for authenticated account'
        });
      }

      // Find stylist's response record
      let responseDoc = await InspirationResponse.findOne({
        requestId: requestDoc._id,
        stylistId: stylist._id
      });

      if (!responseDoc) {
        const responseId = await InspirationResponse.generateResponseId();
        responseDoc = await InspirationResponse.create({
          responseId,
          requestId: requestDoc._id,
          stylistId: stylist._id,
          status,
          message: message || (status === 'accepted' ? 'Accepted request' : 'Declined request')
        });
      } else {
        responseDoc.status = status;
        if (message) responseDoc.message = message;
        await responseDoc.save();
      }

      if (status === 'accepted') {
        requestDoc.status = 'responded';
        await requestDoc.save();
      }

      // Notify customer
      await NotificationService.createNotification({
        recipientId: requestDoc.userId,
        recipientRole: 'customer',
        type: status === 'accepted' ? 'INSPIRATION_ACCEPTED' : 'INSPIRATION_DECLINED',
        title: `Stylist ${status === 'accepted' ? 'Accepted' : 'Declined'} Look Request`,
        message: `Your inspiration request (${requestDoc.requestId}) has been ${status} by a stylist.`,
        entityType: 'InspirationRequest',
        entityId: requestDoc.requestId
      });

      return res.status(200).json({
        success: true,
        message: `Request status updated to ${status}`,
        data: responseDoc
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Customer chooses a responding stylist
   * POST /api/inspiration/requests/:id/choose
   */
  static async chooseStylist(req, res, next) {
    try {
      const { id } = req.params;
      const { responseId, stylistId } = req.body;

      const requestDoc = await InspirationRequest.findOne({
        $or: [{ requestId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      });

      if (!requestDoc) {
        return res.status(404).json({
          success: false,
          message: 'Inspiration request not found'
        });
      }

      // Verify customer ownership
      const customer = await Customer.findOne({ userId: req.user._id });
      if (!customer || customer.customerId !== requestDoc.customerId) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to select a stylist for this request'
        });
      }

      if (requestDoc.status === 'cancelled') {
        return res.status(400).json({
          success: false,
          message: 'Cannot choose stylist for a cancelled request'
        });
      }

      // Find the response
      let responseDoc = null;
      if (responseId) {
        responseDoc = await InspirationResponse.findOne({
          $or: [{ responseId }, { _id: responseId.match(/^[0-9a-fA-F]{24}$/) ? responseId : null }],
          requestId: requestDoc._id
        });
      } else if (stylistId) {
        responseDoc = await InspirationResponse.findOne({
          stylistId,
          requestId: requestDoc._id
        });
      }

      if (!responseDoc) {
        return res.status(404).json({
          success: false,
          message: 'Specified stylist response not found for this request'
        });
      }

      // Update chosen stylist and response
      requestDoc.chosenStylistId = responseDoc.stylistId;
      requestDoc.chosenResponseId = responseDoc._id;
      requestDoc.status = 'accepted';
      await requestDoc.save();

      responseDoc.status = 'accepted';
      await responseDoc.save();

      // Notify chosen stylist
      const chosenStylist = await Stylist.findById(responseDoc.stylistId);
      if (chosenStylist && chosenStylist.userId) {
        await NotificationService.createNotification({
          recipientId: chosenStylist.userId,
          recipientRole: 'stylist',
          type: 'INSPIRATION_ACCEPTED',
          title: 'You were Chosen by Client!',
          message: `Client ${customer.name} selected your proposal for ${requestDoc.category} look (${requestDoc.requestId}).`,
          entityType: 'InspirationRequest',
          entityId: requestDoc.requestId
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Stylist selected successfully. Ready for booking handoff.',
        data: {
          requestId: requestDoc.requestId,
          chosenStylistId: requestDoc.chosenStylistId,
          chosenResponseId: requestDoc.chosenResponseId,
          status: requestDoc.status
        }
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Booking handoff context (safe integration contract with booking engine)
   * POST /api/inspiration/requests/:id/handoff
   */
  static async getBookingHandoffContext(req, res, next) {
    try {
      const { id } = req.params;

      const requestDoc = await InspirationRequest.findOne({
        $or: [{ requestId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
      })
        .populate('preferredBranchId')
        .populate({
          path: 'chosenStylistId',
          populate: [
            { path: 'userId', select: 'name email phone' },
            { path: 'branchId', select: 'name address phone' }
          ]
        });

      if (!requestDoc) {
        return res.status(404).json({
          success: false,
          message: 'Inspiration request not found'
        });
      }

      // Check customer ownership
      const customer = await Customer.findOne({ userId: req.user._id });
      if (!customer || customer.customerId !== requestDoc.customerId) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to access booking handoff for this request'
        });
      }

      if (!requestDoc.chosenStylistId) {
        return res.status(400).json({
          success: false,
          message: 'No stylist has been selected for this request yet. Please choose a stylist first.'
        });
      }

      // Load response details
      const responseDoc = await InspirationResponse.findById(requestDoc.chosenResponseId).populate('suggestedServiceId');

      const handoffPayload = {
        integration: 'viora:inspiration-booking-handoff',
        timestamp: new Date().toISOString(),
        customerId: customer.customerId,
        customerName: customer.name,
        inspirationRequestId: requestDoc.requestId,
        inspirationResponseId: responseDoc ? responseDoc.responseId : null,
        category: requestDoc.category,
        description: requestDoc.description,
        referenceImages: requestDoc.referenceImages,
        stylist: {
          id: requestDoc.chosenStylistId._id,
          stylistId: requestDoc.chosenStylistId.stylistId,
          name: (requestDoc.chosenStylistId.userId && requestDoc.chosenStylistId.userId.name) || 'Selected Stylist',
          rating: requestDoc.chosenStylistId.rating
        },
        branch: {
          id: (requestDoc.preferredBranchId && requestDoc.preferredBranchId._id) || (requestDoc.chosenStylistId.branchId && requestDoc.chosenStylistId.branchId._id),
          name: (requestDoc.preferredBranchId && requestDoc.preferredBranchId.name) || (requestDoc.chosenStylistId.branchId && requestDoc.chosenStylistId.branchId.name) || 'Main Flagship'
        },
        suggestedService: responseDoc && responseDoc.suggestedServiceId ? {
          id: responseDoc.suggestedServiceId._id,
          name: responseDoc.suggestedServiceId.name,
          duration: responseDoc.suggestedServiceId.duration,
          price: responseDoc.suggestedServiceId.price
        } : null,
        estimatedPrice: responseDoc ? responseDoc.estimatedPrice : null,
        preferredDate: requestDoc.preferredDate,
        notes: requestDoc.notes
      };

      // Notify customer of handoff ready
      await NotificationService.createNotification({
        recipientId: req.user._id,
        recipientRole: 'customer',
        type: 'BOOKING_HANDOFF',
        title: 'Ready to Book Atelier Appointment',
        message: `Your selection for ${requestDoc.category} look is ready. Proceed to choose date and time.`,
        entityType: 'InspirationRequest',
        entityId: requestDoc.requestId
      });

      return res.status(200).json({
        success: true,
        message: 'Booking handoff payload generated successfully',
        data: handoffPayload
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = InspirationController;
