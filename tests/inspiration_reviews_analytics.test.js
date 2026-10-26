const mongoose = require('mongoose');
const http = require('http');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const app = require('../server');
const User = require('../models/User');
const Customer = require('../models/Customer');
const Branch = require('../models/Branch');
const Stylist = require('../models/Stylist');
const Service = require('../models/Service');
const Appointment = require('../models/Appointment');
const InspirationRequest = require('../models/InspirationRequest');
const InspirationResponse = require('../models/InspirationResponse');
const PortfolioItem = require('../models/PortfolioItem');
const Review = require('../models/Review');
const Notification = require('../models/Notification');
const UploadService = require('../services/uploadService');

const PORT = 5008; // isolated port for Person 3 test suite
let server;

// Helper to make HTTP requests
const request = ({ method, path, headers = {}, body = null }) => {
  return new Promise((resolve, reject) => {
    const dataString = body ? JSON.stringify(body) : null;
    const options = {
      hostname: '127.0.0.1',
      port: PORT,
      path,
      method,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };

    if (dataString) {
      options.headers['Content-Length'] = Buffer.byteLength(dataString);
    }

    const req = http.request(options, (res) => {
      let responseBody = '';
      res.on('data', (chunk) => {
        responseBody += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseBody);
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, rawBody: responseBody });
        }
      });
    });

    req.on('error', reject);

    if (dataString) {
      req.write(dataString);
    }
    req.end();
  });
};

async function runPerson3Tests() {
  console.log('==================================================================');
  console.log('VIORA PERSON 3 - INSPIRATION, REVIEWS, NOTIFICATIONS & ANALYTICS');
  console.log('==================================================================\n');

  const testTs = Date.now();
  let adminToken, customer1Token, customer2Token, stylist1Token, stylist2Token;
  let adminUser, customer1User, customer2User, stylist1User, stylist2User;
  let customer1Doc, customer2Doc, branchDoc, stylist1Doc, stylist2Doc, service1Doc, service2Doc;
  let completedApptDoc, cancelledApptDoc;
  let createdRequestId, createdResponseId, createdPortfolioId, createdReviewId;

  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db';
    await mongoose.connect(mongoUri);
    console.log('✓ Connected to MongoDB');

    server = app.listen(PORT);
    console.log(`✓ Test server running on port ${PORT}\n`);

    // =========================================================================
    // SETUP: Provision Test Entities & Tokens
    // =========================================================================
    console.log('--- SETUP: Provisioning Person 3 Test Entities ---');

    // 1. Admin User
    adminUser = await User.create({
      name: 'Person 3 Admin',
      email: `admin.p3.${testTs}@viora.com`,
      password: 'Password@123',
      role: 'admin'
    });

    // 2. Branch
    branchDoc = await Branch.create({
      branchId: `BR-P3-${testTs}`,
      name: 'MAISON — Bandra Flagship P3',
      address: 'Turner Road, Bandra West',
      phone: '+91 22 2640 1111',
      status: 'active'
    });

    // 3. Stylist 1 (Hair Master)
    stylist1User = await User.create({
      name: 'Julian Vance P3',
      email: `julian.p3.${testTs}@viora.com`,
      password: 'Password@123',
      role: 'stylist'
    });
    stylist1Doc = await Stylist.create({
      stylistId: `STY-1-${testTs}`,
      userId: stylist1User._id,
      branchId: branchDoc._id,
      specialization: ['Hair', 'Balayage'],
      experience: 8,
      rating: 5.0
    });

    // 4. Stylist 2 (Colorist)
    stylist2User = await User.create({
      name: 'Elena Rostova P3',
      email: `elena.p3.${testTs}@viora.com`,
      password: 'Password@123',
      role: 'stylist'
    });
    stylist2Doc = await Stylist.create({
      stylistId: `STY-2-${testTs}`,
      userId: stylist2User._id,
      branchId: branchDoc._id,
      specialization: ['Nails', 'Hair'],
      experience: 6,
      rating: 4.8
    });

    // 5. Services
    service1Doc = await Service.create({
      serviceId: `SRV-1-${testTs}`,
      branchId: branchDoc._id,
      name: 'French Balayage & Glaze',
      category: 'Hair',
      duration: 120,
      price: 6500,
      availability: true
    });
    service2Doc = await Service.create({
      serviceId: `SRV-2-${testTs}`,
      branchId: branchDoc._id,
      name: 'Couture Glazed Nails',
      category: 'Nails',
      duration: 60,
      price: 3500,
      availability: true
    });

    // 6. Customer 1
    customer1User = await User.create({
      name: 'Sarah Sen P3',
      email: `sarah.p3.${testTs}@example.com`,
      password: 'Password@123',
      role: 'customer'
    });
    customer1Doc = await Customer.create({
      customerId: `CUST-P3-1-${testTs}`,
      userId: customer1User._id,
      name: 'Sarah Sen P3',
      email: customer1User.email,
      phone: '+91 98200 11111'
    });

    // 7. Customer 2
    customer2User = await User.create({
      name: 'Mira Nair P3',
      email: `mira.p3.${testTs}@example.com`,
      password: 'Password@123',
      role: 'customer'
    });
    customer2Doc = await Customer.create({
      customerId: `CUST-P3-2-${testTs}`,
      userId: customer2User._id,
      name: 'Mira Nair P3',
      email: customer2User.email,
      phone: '+91 98200 22222'
    });

    // 8. Appointments for Customer 1 (Completed & Cancelled)
    completedApptDoc = await Appointment.create({
      appointmentId: `APT-P3-1-${testTs}`,
      customerId: customer1Doc.customerId,
      branchId: branchDoc._id,
      stylistId: stylist1Doc._id,
      serviceId: service1Doc._id,
      date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      startTime: '10:00',
      endTime: '12:00',
      status: 'Completed'
    });

    cancelledApptDoc = await Appointment.create({
      appointmentId: `APT-P3-2-${testTs}`,
      customerId: customer1Doc.customerId,
      branchId: branchDoc._id,
      stylistId: stylist1Doc._id,
      serviceId: service2Doc._id,
      date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      startTime: '14:00',
      endTime: '15:00',
      status: 'Cancelled'
    });

    // Login users to acquire tokens
    const loginResAdmin = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: adminUser.email, password: 'Password@123' }
    });
    adminToken = loginResAdmin.body.token;

    const loginResC1 = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: customer1User.email, password: 'Password@123' }
    });
    customer1Token = loginResC1.body.token;

    const loginResC2 = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: customer2User.email, password: 'Password@123' }
    });
    customer2Token = loginResC2.body.token;

    const loginResS1 = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: stylist1User.email, password: 'Password@123' }
    });
    stylist1Token = loginResS1.body.token;

    const loginResS2 = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: stylist2User.email, password: 'Password@123' }
    });
    stylist2Token = loginResS2.body.token;

    console.log('✓ Provisioned test users, tokens, branch, stylists, and appointments.\n');

    // =========================================================================
    // TEST 1: Server-Side Image Upload & Magic Byte Validation
    // =========================================================================
    console.log('--- TEST 1: Image Upload & Security Type Validation ---');

    // 1a. Valid 1x1 PNG base64
    const validPngBase64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
    const uploadRes = await request({
      method: 'POST',
      path: '/api/inspiration/upload',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { image: validPngBase64, prefix: 'test_insp' }
    });
    if (uploadRes.status !== 200 || !uploadRes.body.url.includes('/uploads/test_insp_')) {
      throw new Error(`Expected image upload success, got status ${uploadRes.status}`);
    }
    console.log(`✓ Valid PNG accepted and stored at: ${uploadRes.body.url}`);

    // 1b. Invalid executable payload spoofed as image
    const fakeImageBuffer = Buffer.from('MZ\x90\x00\x03\x00\x00\x00DOS executable script');
    const fakeBase64 = `data:image/png;base64,${fakeImageBuffer.toString('base64')}`;
    const rejectUploadRes = await request({
      method: 'POST',
      path: '/api/inspiration/upload',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { image: fakeBase64 }
    });
    if (rejectUploadRes.status !== 400) {
      throw new Error(`Expected 400 rejection for spoofed binary image, got ${rejectUploadRes.status}`);
    }
    console.log('✓ Malicious executable spoofed as PNG safely blocked by magic byte validation');

    // =========================================================================
    // TEST 2: Inspiration Request Creation & Validation
    // =========================================================================
    console.log('\n--- TEST 2: Inspiration Request Creation & Validation ---');

    // 2a. Reject empty description
    const emptyDescRes = await request({
      method: 'POST',
      path: '/api/inspiration/requests',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { category: 'Hair', description: '' }
    });
    if (emptyDescRes.status !== 400) {
      throw new Error(`Expected 400 for empty description, got ${emptyDescRes.status}`);
    }
    console.log('✓ Missing description correctly rejected with HTTP 400');

    // 2b. Valid inspiration request submission
    const initialApptCount = await Appointment.countDocuments();
    const createReqRes = await request({
      method: 'POST',
      path: '/api/inspiration/requests',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        category: 'Hair',
        referenceImages: [uploadRes.body.url],
        description: 'Honey caramel dimension with soft curtain fringe and face-framing ribbons.',
        preferredBranchId: branchDoc._id,
        flexibleDate: true,
        estimatedBudget: 7000
      }
    });
    if (createReqRes.status !== 201 || !createReqRes.body.data.requestId) {
      throw new Error(`Inspiration request creation failed with status ${createReqRes.status}`);
    }
    createdRequestId = createReqRes.body.data.requestId;
    console.log(`✓ Inspiration request created successfully (requestId: ${createdRequestId}, status: pending)`);

    // 2c. Verify Inspiration submission does NOT automatically create an appointment
    const afterReqApptCount = await Appointment.countDocuments();
    if (afterReqApptCount !== initialApptCount) {
      throw new Error(`Appointment count mutated from ${initialApptCount} to ${afterReqApptCount} upon inspiration request creation!`);
    }
    console.log('✓ Confirmed: Submitting inspiration request strictly does NOT create an appointment');

    // =========================================================================
    // TEST 3: Customer Data Isolation on Inspiration Requests
    // =========================================================================
    console.log('\n--- TEST 3: Customer Identity Isolation ---');

    // Customer 2 attempts to access Customer 1's request
    const unauthorizedAccessRes = await request({
      method: 'GET',
      path: `/api/inspiration/requests/${createdRequestId}`,
      headers: { Authorization: `Bearer ${customer2Token}` }
    });
    if (unauthorizedAccessRes.status !== 403) {
      throw new Error(`Expected HTTP 403 Forbidden for cross-account request access, got ${unauthorizedAccessRes.status}`);
    }
    console.log('✓ Strict customer isolation verified: Customer 2 forbidden (403) from accessing Customer 1 request');

    // =========================================================================
    // TEST 4: Stylist Responds to Inspiration Request
    // =========================================================================
    console.log('\n--- TEST 4: Stylist Response Creation & Status Transitions ---');

    const stylistRespondRes = await request({
      method: 'POST',
      path: `/api/inspiration/requests/${createdRequestId}/respond`,
      headers: { Authorization: `Bearer ${stylist1Token}` },
      body: {
        message: 'I can achieve this dimensional honey caramel look using hand-painted clay balayage and an acidic gloss glaze.',
        suggestedServiceId: service1Doc._id,
        estimatedPrice: 6500,
        portfolioImageUrls: [uploadRes.body.url]
      }
    });
    if (stylistRespondRes.status !== 200 || !stylistRespondRes.body.data.responseId) {
      throw new Error(`Stylist response creation failed with status ${stylistRespondRes.status}`);
    }
    createdResponseId = stylistRespondRes.body.data.responseId;
    console.log(`✓ Stylist 1 response created successfully (responseId: ${createdResponseId})`);

    // Verify request status transitioned to 'responded'
    const updatedReqDoc = await InspirationRequest.findOne({ requestId: createdRequestId });
    if (updatedReqDoc.status !== 'responded') {
      throw new Error(`Expected request status 'responded', found '${updatedReqDoc.status}'`);
    }
    console.log("✓ Request status successfully transitioned from 'pending' to 'responded'");

    // =========================================================================
    // TEST 5: Stylist Comparison & Choosing Stylist
    // =========================================================================
    console.log('\n--- TEST 5: Stylist Comparison & Selection ---');

    // Stylist 2 also responds
    await request({
      method: 'POST',
      path: `/api/inspiration/requests/${createdRequestId}/respond`,
      headers: { Authorization: `Bearer ${stylist2Token}` },
      body: {
        message: 'Alternative approach using foilayage and molecular bonding for extra brightness.',
        suggestedServiceId: service1Doc._id,
        estimatedPrice: 6800
      }
    });

    // Customer views request with both responses
    const viewResponsesRes = await request({
      method: 'GET',
      path: `/api/inspiration/requests/${createdRequestId}`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (viewResponsesRes.body.data.responses.length !== 2) {
      throw new Error(`Expected 2 stylist responses, got ${viewResponsesRes.body.data.responses.length}`);
    }
    console.log('✓ Customer retrieved 2 competing stylist proposals for side-by-side comparison');

    // Customer chooses Stylist 1
    const chooseRes = await request({
      method: 'POST',
      path: `/api/inspiration/requests/${createdRequestId}/choose`,
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { responseId: createdResponseId }
    });
    if (chooseRes.status !== 200 || chooseRes.body.data.status !== 'accepted') {
      throw new Error(`Choosing stylist failed with status ${chooseRes.status}`);
    }
    console.log('✓ Customer successfully chose Stylist 1; request status updated to accepted');

    // =========================================================================
    // TEST 6: Booking Handoff Integration Contract
    // =========================================================================
    console.log('\n--- TEST 6: Booking Handoff Integration Contract ---');

    const handoffRes = await request({
      method: 'POST',
      path: `/api/inspiration/requests/${createdRequestId}/handoff`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (handoffRes.status !== 200 || !handoffRes.body.data) {
      throw new Error(`Booking handoff failed with status ${handoffRes.status}`);
    }

    const handoff = handoffRes.body.data;
    if (
      handoff.customerId !== customer1Doc.customerId ||
      !handoff.stylist.id ||
      !handoff.branch.id ||
      !handoff.suggestedService.id
    ) {
      throw new Error('Booking handoff payload missing required integration identifiers');
    }
    console.log('✓ Booking handoff payload verified with customerId, stylistId, branchId, and serviceId');

    // 6b. Verify frontend event listener and storage contract in app.js
    const appJsContent = fs.readFileSync(path.join(__dirname, '..', 'public', 'js', 'app.js'), 'utf8');
    if (!appJsContent.includes("viora:inspiration-booking-handoff") || !appJsContent.includes("viora:activeInspirationHandoff")) {
      throw new Error('app.js does not register resilient listener or session persistence for viora:inspiration-booking-handoff');
    }
    console.log('✓ Frontend viora:inspiration-booking-handoff resilient listener and storage verified in app.js');

    // =========================================================================
    // TEST 7: Stylist Portfolio Management & Ownership Security
    // =========================================================================
    console.log('\n--- TEST 7: Stylist Portfolio Management & Ownership ---');

    // 7a. Stylist 1 creates a portfolio look
    const createPortRes = await request({
      method: 'POST',
      path: '/api/stylists/me/portfolio',
      headers: { Authorization: `Bearer ${stylist1Token}` },
      body: {
        title: 'Bespoke Caramel Balayage',
        category: 'Hair',
        description: 'Dimensional blonde ribbons on warm chestnut base.',
        imageUrl: uploadRes.body.url,
        tags: ['Balayage', 'Blonde', 'Warm']
      }
    });
    if (createPortRes.status !== 201 || !createPortRes.body.data.portfolioId) {
      throw new Error(`Portfolio creation failed with status ${createPortRes.status}`);
    }
    createdPortfolioId = createPortRes.body.data.portfolioId;
    console.log(`✓ Stylist 1 added portfolio item: ${createdPortfolioId}`);

    // 7b. Stylist 2 tries to modify Stylist 1's portfolio item -> Forbidden
    const unauthPortUpdate = await request({
      method: 'PUT',
      path: `/api/stylists/me/portfolio/${createdPortfolioId}`,
      headers: { Authorization: `Bearer ${stylist2Token}` },
      body: { title: 'Hacked Title' }
    });
    if (unauthPortUpdate.status !== 403) {
      throw new Error(`Expected HTTP 403 Forbidden for cross-stylist portfolio mutation, got ${unauthPortUpdate.status}`);
    }
    console.log('✓ Server-side ownership enforced: Stylist 2 blocked (403) from modifying Stylist 1 portfolio');

    // =========================================================================
    // TEST 8: Customer Reviews & Ratings Submission
    // =========================================================================
    console.log('\n--- TEST 8: Review Submission & Eligibility Rules ---');

    // 8a. Reject review for Cancelled appointment
    const rejectCancelledReview = await request({
      method: 'POST',
      path: '/api/reviews',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        appointmentId: cancelledApptDoc._id.toString(),
        rating: 5,
        lookRating: 5
      }
    });
    if (rejectCancelledReview.status !== 400) {
      throw new Error(`Expected 400 for cancelled appointment review, got ${rejectCancelledReview.status}`);
    }
    console.log('✓ Ineligible cancelled appointment rejected for review with HTTP 400');

    // 8b. Reject out-of-range rating (> 5)
    const rejectRangeReview = await request({
      method: 'POST',
      path: '/api/reviews',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        appointmentId: completedApptDoc._id.toString(),
        rating: 6,
        lookRating: 5
      }
    });
    if (rejectRangeReview.status !== 400) {
      throw new Error(`Expected 400 for rating > 5, got ${rejectRangeReview.status}`);
    }
    console.log('✓ Invalid rating range (> 5) rejected with HTTP 400');

    // 8c. Customer 2 tries to review Customer 1 appointment -> Forbidden
    const unauthReview = await request({
      method: 'POST',
      path: '/api/reviews',
      headers: { Authorization: `Bearer ${customer2Token}` },
      body: {
        appointmentId: completedApptDoc._id.toString(),
        rating: 5,
        lookRating: 5
      }
    });
    if (unauthReview.status !== 403) {
      throw new Error(`Expected 403 for unauthorized review, got ${unauthReview.status}`);
    }
    console.log('✓ Unauthorized appointment review safely rejected with HTTP 403');

    // 8d. Successful review submission for completed appointment
    const submitReviewRes = await request({
      method: 'POST',
      path: '/api/reviews',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        appointmentId: completedApptDoc._id.toString(),
        rating: 5,
        lookRating: 5,
        serviceRating: 5,
        reviewText: 'Flawless execution! Julian captured the exact caramel tone and dimension from my consultation.',
        lookCategory: 'Hair'
      }
    });
    if (submitReviewRes.status !== 201 || !submitReviewRes.body.data.reviewId) {
      throw new Error(`Review submission failed with status ${submitReviewRes.status}`);
    }
    createdReviewId = submitReviewRes.body.data.reviewId;
    console.log(`✓ Review submitted successfully (reviewId: ${createdReviewId}, rating: 5★, look: 5★)`);

    // 8e. Reject duplicate review for same appointment
    const dupReviewRes = await request({
      method: 'POST',
      path: '/api/reviews',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        appointmentId: completedApptDoc._id.toString(),
        rating: 4,
        lookRating: 4
      }
    });
    if (dupReviewRes.status !== 400) {
      throw new Error(`Expected 400 for duplicate review on same appointment, got ${dupReviewRes.status}`);
    }
    console.log('✓ Duplicate review on same appointment safely rejected with HTTP 400');

    // =========================================================================
    // TEST 9: Persistent Notifications Scoping & Read Status
    // =========================================================================
    console.log('\n--- TEST 9: In-App Notifications Persistence & Scoping ---');

    // Customer 1 checks notifications
    const notifsRes = await request({
      method: 'GET',
      path: '/api/notifications',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (notifsRes.status !== 200 || notifsRes.body.count === 0) {
      throw new Error('Expected notifications for Customer 1');
    }
    const notifItem = notifsRes.body.data[0];
    console.log(`✓ Customer 1 retrieved ${notifsRes.body.count} notifications (Unread: ${notifsRes.body.unreadCount})`);

    // Mark single notification as read
    const markReadRes = await request({
      method: 'PUT',
      path: `/api/notifications/${notifItem.notificationId}/read`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (markReadRes.status !== 200 || !markReadRes.body.data.read) {
      throw new Error('Failed to mark notification as read');
    }
    console.log('✓ Notification marked as read successfully');

    // Customer 2 cannot modify Customer 1's notification -> Forbidden
    const unauthNotifRes = await request({
      method: 'PUT',
      path: `/api/notifications/${notifItem.notificationId}/read`,
      headers: { Authorization: `Bearer ${customer2Token}` }
    });
    if (unauthNotifRes.status !== 403) {
      throw new Error(`Expected 403 for cross-user notification update, got ${unauthNotifRes.status}`);
    }
    console.log('✓ Recipient ownership enforced: Customer 2 forbidden (403) from modifying Customer 1 alerts');

    // =========================================================================
    // TEST 10: Admin Intelligence & Analytics Aggregations
    // =========================================================================
    console.log('\n--- TEST 10: Admin Business Intelligence & Real Database Analytics ---');

    // 10a. Customer forbidden from admin analytics
    const unauthAdminRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/overview',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (unauthAdminRes.status !== 403) {
      throw new Error(`Expected 403 for non-admin on analytics, got ${unauthAdminRes.status}`);
    }
    console.log('✓ Role authorization enforced: Non-admin rejected with HTTP 403');

    // 10b. Admin fetches overview analytics
    const overviewRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/overview',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (overviewRes.status !== 200 || !overviewRes.body.data.overview) {
      throw new Error(`Admin analytics overview failed with status ${overviewRes.status}`);
    }

    const ov = overviewRes.body.data.overview;
    if (ov.completedBookings < 1 || ov.totalRevenue < 6500) {
      throw new Error(`Calculated analytics revenue mismatch: ${ov.totalRevenue}`);
    }
    console.log(`✓ Real Analytics Overview verified: Bookings=${ov.totalBookings}, Completed=${ov.completedBookings}, Revenue=₹${ov.totalRevenue}`);

    // 10c. Branch Performance
    const branchPerfRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/branches',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (branchPerfRes.status !== 200 || branchPerfRes.body.data.length === 0) {
      throw new Error('Branch performance benchmark retrieval failed');
    }
    console.log(`✓ Branch Performance verified across ${branchPerfRes.body.data.length} branches`);

    // 10c-1. Reject invalid branchId with HTTP 400
    const invalidBranchRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/branches?branchId=invalid-format-id',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (invalidBranchRes.status !== 400 || !invalidBranchRes.body.message.includes('Invalid branch identifier')) {
      throw new Error(`Expected HTTP 400 for invalid branchId, got ${invalidBranchRes.status}`);
    }
    console.log('✓ Invalid branchId filter safely rejected with HTTP 400 Bad Request');

    // 10d. Stylist Performance
    const stylistPerfRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/stylists',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (stylistPerfRes.status !== 200 || stylistPerfRes.body.data.length === 0) {
      throw new Error('Stylist performance ranking retrieval failed');
    }
    console.log(`✓ Stylist Performance verified: Top stylist ${stylistPerfRes.body.data[0].name}`);

    // 10d-1. Reject invalid stylistId with HTTP 400
    const invalidStylistRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/stylists?stylistId=invalid-format-id',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (invalidStylistRes.status !== 400 || !invalidStylistRes.body.message.includes('Invalid stylist identifier')) {
      throw new Error(`Expected HTTP 400 for invalid stylistId, got ${invalidStylistRes.status}`);
    }
    console.log('✓ Invalid stylistId filter safely rejected with HTTP 400 Bad Request');

    // 10e. Popular Services & Looks
    const popularServRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/services',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (popularServRes.status !== 200) {
      throw new Error('Popular services endpoint failed');
    }
    console.log('✓ Popular Services ranked from real appointment records');

    const popularLooksRes = await request({
      method: 'GET',
      path: '/api/admin/analytics/looks',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (popularLooksRes.status !== 200) {
      throw new Error('Popular looks endpoint failed');
    }
    console.log('✓ Popular Looks ranked from inspiration requests and look ratings');

    // 10f. Admin Review Moderation
    const moderateRes = await request({
      method: 'PUT',
      path: `/api/reviews/admin/${createdReviewId}/moderate`,
      headers: { Authorization: `Bearer ${adminToken}` },
      body: { status: 'approved', notes: 'Verified luxury salon client experience' }
    });
    if (moderateRes.status !== 200 || moderateRes.body.data.moderationStatus !== 'approved') {
      throw new Error(`Review moderation failed with status ${moderateRes.status}`);
    }
    console.log("✓ Admin review moderation verified: status updated to 'approved'");

    // =========================================================================
    // CLEANUP: Removing Person 3 Test Records
    // =========================================================================
    console.log('\n--- CLEANUP: Removing Person 3 Test Entities ---');
    const reqDocs = await InspirationRequest.find({ $or: [{ requestId: createdRequestId }, { customerId: customer1Doc.customerId }] });
    const reqObjectIds = reqDocs.map(r => r._id);
    await InspirationResponse.deleteMany({ requestId: { $in: reqObjectIds } });
    await InspirationRequest.deleteMany({ _id: { $in: reqObjectIds } });
    await PortfolioItem.deleteMany({ stylistId: { $in: [stylist1Doc._id, stylist2Doc._id] } });
    await Review.deleteMany({ customerId: { $in: [customer1Doc.customerId, customer2Doc.customerId] } });
    await Notification.deleteMany({ recipientId: { $in: [customer1User._id, customer2User._id, stylist1User._id, stylist2User._id, adminUser._id] } });
    await Appointment.deleteMany({ _id: { $in: [completedApptDoc._id, cancelledApptDoc._id] } });
    await Service.deleteMany({ _id: { $in: [service1Doc._id, service2Doc._id] } });
    await Stylist.deleteMany({ _id: { $in: [stylist1Doc._id, stylist2Doc._id] } });
    await Customer.deleteMany({ _id: { $in: [customer1Doc._id, customer2Doc._id] } });
    await Branch.deleteMany({ _id: branchDoc._id });
    await User.deleteMany({ _id: { $in: [adminUser._id, customer1User._id, customer2User._id, stylist1User._id, stylist2User._id] } });

    // Clean up any test uploaded image files
    try {
      const uploadsDir = path.join(__dirname, '..', 'public', 'uploads');
      if (fs.existsSync(uploadsDir)) {
        const files = fs.readdirSync(uploadsDir);
        for (const file of files) {
          if (file.startsWith('test_insp_')) {
            fs.unlinkSync(path.join(uploadsDir, file));
          }
        }
      }
    } catch (err) {
      // ignore upload cleanup error
    }

    console.log('✓ Cleaned up test records successfully.');

    console.log('\n==================================================================');
    console.log('ALL PERSON 3 AUTOMATED TESTS PASSED SUCCESSFULLY! (10/10 TEST SUITES)');
    console.log('==================================================================\n');

  } catch (error) {
    console.error('\n❌ TEST FAILURE:', error);
    process.exit(1);
  } finally {
    if (server) {
      server.close();
    }
    await mongoose.connection.close();
    process.exit(0);
  }
}

runPerson3Tests();
