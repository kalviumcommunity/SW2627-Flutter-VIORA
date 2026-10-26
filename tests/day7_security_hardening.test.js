const mongoose = require('mongoose');
const http = require('http');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const app = require('../server');
const User = require('../models/User');
const Customer = require('../models/Customer');
const Branch = require('../models/Branch');
const Stylist = require('../models/Stylist');
const Service = require('../models/Service');
const Appointment = require('../models/Appointment');
const QuizResult = require('../models/QuizResult');

const PORT = 5007; // Dedicated port for Day 7 Security Hardening & Final QA test suite
let server;

// Helper to make HTTP requests
const request = ({ method, path: reqPath, headers = {}, body = null }) => {
  return new Promise((resolve, reject) => {
    const dataString = body ? JSON.stringify(body) : null;
    const options = {
      hostname: '127.0.0.1',
      port: PORT,
      path: reqPath,
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
          resolve({ status: res.statusCode, headers: res.headers, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, headers: res.headers, rawBody: responseBody });
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

async function runTests() {
  console.log('==================================================================');
  console.log('VIORA DAY 7 - SECURITY HARDENING, REBOOK CONTRACT & FINAL QA');
  console.log('==================================================================\n');

  const testTimestamp = Date.now();
  let adminToken = '';
  let managerToken = '';
  let customer1Token = '';
  let customer2Token = '';
  let customer1GlobalId = '';
  let customer2GlobalId = '';

  let branchBandra = null;
  let branchInactive = null;
  let stylist1 = null;
  let serviceActive = null;
  let serviceUnavailable = null;
  let completedApptId = '';
  let inactiveBranchApptId = '';
  let cancelledApptId = '';

  try {
    // 0. Connect to MongoDB and start test server
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db';
    await mongoose.connect(mongoUri);
    console.log('✓ Connected to MongoDB');

    server = app.listen(PORT);
    console.log(`✓ Test server running on port ${PORT}\n`);

    // --- SETUP: Multi-Branch & User Entities Provisioning ---
    console.log('--- SETUP: Provisioning Multi-Branch Entities & User Roles ---');

    // Admin User
    const adminUser = await User.create({
      name: 'System Admin Day 7',
      email: `admin.${testTimestamp}@viora.com`,
      password: 'AdminPassword123!',
      role: 'admin'
    });

    // Branch Manager User
    const managerUser = await User.create({
      name: 'Branch Manager Day 7',
      email: `manager.${testTimestamp}@viora.com`,
      password: 'ManagerPassword123!',
      role: 'branch_manager'
    });

    // Customer 1 User & Profile
    const cust1User = await User.create({
      name: 'Priya Sen',
      email: `priya.${testTimestamp}@example.com`,
      password: 'Password123!',
      phone: '+91 98111 99901',
      role: 'customer'
    });
    customer1GlobalId = await Customer.generateGlobalCustomerId();
    await Customer.create({
      customerId: customer1GlobalId,
      userId: cust1User._id,
      name: cust1User.name,
      email: cust1User.email,
      phone: cust1User.phone,
      preferences: {
        hair: ['Balayage'],
        nails: ['Gel'],
        skin: ['Hydration'],
        makeup: ['Natural']
      }
    });

    // Customer 2 User & Profile (for isolation tests)
    const cust2User = await User.create({
      name: 'Aarav Mehta',
      email: `aarav.${testTimestamp}@example.com`,
      password: 'Password123!',
      phone: '+91 98222 99902',
      role: 'customer'
    });
    customer2GlobalId = await Customer.generateGlobalCustomerId();
    await Customer.create({
      customerId: customer2GlobalId,
      userId: cust2User._id,
      name: cust2User.name,
      email: cust2User.email,
      phone: cust2User.phone,
      preferences: { hair: [], nails: [], skin: [], makeup: [] }
    });

    // Active Branch
    branchBandra = await Branch.create({
      branchId: `BR-BAN-${testTimestamp}`,
      name: 'MAISON — Bandra Flagship',
      address: '12 Waterfield Road, Bandra West, Mumbai',
      phone: '+91 22 2640 1111',
      status: 'active'
    });

    // Inactive Branch (for edge-case testing)
    branchInactive = await Branch.create({
      branchId: `BR-INACT-${testTimestamp}`,
      name: 'MAISON — Colaba Sanctuary (Renovating)',
      address: '44 Colaba Causeway, Mumbai',
      phone: '+91 22 2280 2222',
      status: 'inactive'
    });

    // Stylist User & Profile
    const stylistUser = await User.create({
      name: 'Julian Vance Day 7',
      email: `julian.${testTimestamp}@viora.com`,
      password: 'StylistPassword123!',
      role: 'stylist'
    });
    stylist1 = await Stylist.create({
      stylistId: `STY-1-${testTimestamp}`,
      userId: stylistUser._id,
      branchId: branchBandra._id,
      specialization: ['Hair Architecture', 'Balayage Specialist'],
      rating: 4.95,
      experience: 8
    });

    // Active Service
    serviceActive = await Service.create({
      serviceId: `SRV-ACT-${testTimestamp}`,
      branchId: branchBandra._id,
      name: 'Artisan French Balayage',
      category: 'Hair',
      duration: 120,
      price: 6500,
      availability: true
    });

    // Unavailable Service (for edge-case testing)
    serviceUnavailable = await Service.create({
      serviceId: `SRV-UNAV-${testTimestamp}`,
      branchId: branchBandra._id,
      name: 'Seasonal Botanical Scalp Detox',
      category: 'Hair',
      duration: 60,
      price: 3200,
      availability: false
    });

    // Appointment 1: Completed treatment for Customer 1 (Active Service & Active Branch)
    const appt1 = await Appointment.create({
      appointmentId: `APT-CUST1-1-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      stylistId: stylist1._id,
      serviceId: serviceActive._id,
      date: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000), // 10 days ago (Active)
      startTime: '11:00',
      endTime: '13:00',
      status: 'Completed'
    });
    completedApptId = appt1.appointmentId;

    // Appointment 2: Completed treatment for Customer 1 with Inactive Branch
    const appt2 = await Appointment.create({
      appointmentId: `APT-CUST1-2-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchInactive._id,
      stylistId: stylist1._id,
      serviceId: serviceActive._id,
      date: new Date(Date.now() - 40 * 24 * 60 * 60 * 1000), // 40 days ago
      startTime: '14:00',
      endTime: '16:00',
      status: 'Completed'
    });
    inactiveBranchApptId = appt2.appointmentId;

    // Appointment 3: Cancelled treatment for Customer 1
    const appt3 = await Appointment.create({
      appointmentId: `APT-CUST1-3-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      stylistId: stylist1._id,
      serviceId: serviceActive._id,
      date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      startTime: '10:00',
      endTime: '12:00',
      status: 'Cancelled'
    });
    cancelledApptId = appt3.appointmentId;

    // Login users to acquire JWT tokens
    const loginAdmin = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: adminUser.email, password: 'AdminPassword123!' }
    });
    adminToken = loginAdmin.body.token;

    const loginManager = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: managerUser.email, password: 'ManagerPassword123!' }
    });
    managerToken = loginManager.body.token;

    const loginCust1 = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: cust1User.email, password: 'Password123!' }
    });
    customer1Token = loginCust1.body.token;

    const loginCust2 = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: cust2User.email, password: 'Password123!' }
    });
    customer2Token = loginCust2.body.token;

    console.log('✓ Multi-branch entities, user roles, and authentication tokens provisioned.\n');

    // =========================================================================
    // TEST 1: Strict Customer Data Isolation & Scoping
    // =========================================================================
    console.log('--- TEST 1: Customer Data Isolation & Cross-Account Scoping ---');
    
    // Customer 1 gets profile
    const c1ProfileRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (c1ProfileRes.body.data.customerId !== customer1GlobalId) {
      throw new Error(`Profile data leak: expected ${customer1GlobalId}, got ${c1ProfileRes.body.data.customerId}`);
    }

    // Customer 2 gets profile
    const c2ProfileRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer2Token}` }
    });
    if (c2ProfileRes.body.data.customerId !== customer2GlobalId) {
      throw new Error(`Profile data leak: expected ${customer2GlobalId}, got ${c2ProfileRes.body.data.customerId}`);
    }

    // Customer 2 treatment history should be empty (Customer 1's appointments NOT visible)
    const c2HistRes = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${customer2Token}` }
    });
    if (c2HistRes.body.count !== 0 || c2HistRes.body.data.length !== 0) {
      throw new Error(`Customer 2 should have 0 history records, got ${c2HistRes.body.count}`);
    }

    // Customer 2 attempting to access Customer 1's rebook context must return 404
    const c2RebookCross = await request({
      method: 'GET',
      path: `/api/customers/history/${completedApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer2Token}` }
    });
    if (c2RebookCross.status !== 404) {
      throw new Error(`Cross-customer rebook access must return 404, got ${c2RebookCross.status}`);
    }
    console.log('✓ Strict customer data isolation verified: profiles, history, and rebook contexts strictly scoped');

    // =========================================================================
    // TEST 2: Tampering Prevention on Immutable Identifiers
    // =========================================================================
    console.log('\n--- TEST 2: Tampering Prevention on Immutable Identifiers ---');

    // Attempting to modify customerId
    const tamperCIdRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { customerId: 'CUST-FORGED-9999' }
    });
    if (tamperCIdRes.status !== 400 || !tamperCIdRes.body.message.includes('Modification of global customerId')) {
      throw new Error(`Expected HTTP 400 on customerId tampering, got ${tamperCIdRes.status}`);
    }

    // Attempting to modify userId
    const tamperUIdRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { userId: new mongoose.Types.ObjectId() }
    });
    if (tamperUIdRes.status !== 400 || !tamperUIdRes.body.message.includes('Modification of userId')) {
      throw new Error(`Expected HTTP 400 on userId tampering, got ${tamperUIdRes.status}`);
    }

    // Blank name rejected with HTTP 400
    const blankNameRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { name: '   ' }
    });
    if (blankNameRes.status !== 400 || !blankNameRes.body.message.includes('Name cannot be empty')) {
      throw new Error(`Expected HTTP 400 on empty name update, got ${blankNameRes.status}`);
    }

    // Attempting to elevate role via profile payload is safely ignored
    const tamperRoleRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: { name: 'Priya Sen Verified', role: 'admin' }
    });
    if (tamperRoleRes.status !== 200) {
      throw new Error(`Profile update with extra fields failed with ${tamperRoleRes.status}`);
    }
    const freshCustUser = await User.findById(cust1User._id);
    if (freshCustUser.role !== 'customer') {
      throw new Error(`Security breach: User role modified from 'customer' to '${freshCustUser.role}'`);
    }
    console.log('✓ Tampering prevention verified: customerId, userId, empty name, and role privilege escalation safely blocked');

    // =========================================================================
    // TEST 3: Regex Search Sanitization & ReDoS Resilience
    // =========================================================================
    console.log('\n--- TEST 3: Regex Search Sanitization & ReDoS Resilience ---');

    // Searching with special regex characters that would trigger SyntaxError if unescaped
    const dangerousPatterns = ['[', '*', '+', '?', '\\', '(', ')'];
    for (const pat of dangerousPatterns) {
      const searchRes = await request({
        method: 'GET',
        path: `/api/customers/admin/list?search=${encodeURIComponent(pat)}`,
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      if (searchRes.status !== 200) {
        throw new Error(`Admin search for pattern "${pat}" caused HTTP ${searchRes.status} instead of HTTP 200`);
      }
    }
    console.log('✓ Admin customer search successfully sanitizes regex meta-characters without 500 SyntaxError');

    // =========================================================================
    // TEST 4: Role Authorization Boundaries (Admin & Branch Manager)
    // =========================================================================
    console.log('\n--- TEST 4: Role Authorization Boundaries ---');

    // Customer role is forbidden (HTTP 403) from all admin routes
    const adminRoutes = [
      '/api/customers/admin/overview',
      '/api/customers/admin/list',
      `/api/customers/admin/${customer1GlobalId}`,
      `/api/customers/admin/${customer1GlobalId}/history`
    ];

    for (const route of adminRoutes) {
      const forbidRes = await request({
        method: 'GET',
        path: route,
        headers: { Authorization: `Bearer ${customer1Token}` }
      });
      if (forbidRes.status !== 403) {
        throw new Error(`Customer role should be forbidden (403) from ${route}, got ${forbidRes.status}`);
      }
    }

    // Branch manager role has authorized access (HTTP 200)
    for (const route of adminRoutes) {
      const managerRes = await request({
        method: 'GET',
        path: route,
        headers: { Authorization: `Bearer ${managerToken}` }
      });
      if (managerRes.status !== 200) {
        throw new Error(`Branch Manager should have authorized access (200) to ${route}, got ${managerRes.status}`);
      }
    }

    // Unauthenticated request is rejected (HTTP 401)
    const unauthRes = await request({
      method: 'GET',
      path: '/api/customers/admin/overview'
    });
    if (unauthRes.status !== 401) {
      throw new Error(`Unauthenticated request should return 401, got ${unauthRes.status}`);
    }
    console.log('✓ Role authorization rules verified: Customer forbidden (403), Manager authorized (200), Unauthenticated rejected (401)');

    // =========================================================================
    // TEST 5: Secret Sanitization Across All Customer Intelligence Endpoints
    // =========================================================================
    console.log('\n--- TEST 5: Secret Sanitization Across Customer Intelligence APIs ---');

    const profilePayload = c1ProfileRes.body;
    const adminDetailsRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer1GlobalId}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    const payloadsToCheck = [
      { name: 'Customer Profile', data: profilePayload },
      { name: 'Admin Customer Details', data: adminDetailsRes.body }
    ];

    for (const item of payloadsToCheck) {
      const str = JSON.stringify(item.data).toLowerCase();
      if (str.includes('password') && (str.includes('$2a$') || str.includes('adminpassword') || str.includes('password123'))) {
        throw new Error(`Credential leaked in ${item.name}`);
      }
      if (str.includes('jwt_secret') || str.includes('super_secret')) {
        throw new Error(`Secret leaked in ${item.name}`);
      }
    }
    console.log('✓ Verified: Zero passwords, password hashes, or secret keys leaked in API responses');

    // =========================================================================
    // TEST 6: Rebook Integration Contract & Handoff Payload
    // =========================================================================
    console.log('\n--- TEST 6: Rebook Integration Contract & Handoff Payload ---');

    const rebookRes = await request({
      method: 'GET',
      path: `/api/customers/history/${completedApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });

    if (rebookRes.status !== 200 || !rebookRes.body.success) {
      throw new Error(`Rebook contract fetch failed with status ${rebookRes.status}`);
    }

    const rebookData = rebookRes.body.data;
    if (!rebookData.service || !rebookData.service.id || !rebookData.service.name || rebookData.service.price === undefined) {
      throw new Error('Rebook payload missing required service structure');
    }
    if (!rebookData.branch || !rebookData.branch.id || !rebookData.branch.name) {
      throw new Error('Rebook payload missing required branch structure');
    }
    if (!rebookData.preferredStylist || !rebookData.preferredStylist.name || rebookData.preferredStylist.rating === undefined) {
      throw new Error('Rebook payload missing required preferredStylist structure');
    }
    if (rebookData.sourceAppointmentId !== completedApptId) {
      throw new Error(`sourceAppointmentId mismatch: expected ${completedApptId}, got ${rebookData.sourceAppointmentId}`);
    }
    if (rebookRes.body.bookingModuleAvailable !== false) {
      throw new Error('bookingModuleAvailable flag must accurately reflect false until Booking module integration');
    }
    console.log('✓ Rebook contract payload verified:');
    console.log(`  Service: ${rebookData.service.name} (₹${rebookData.service.price}, Available: ${rebookData.service.available})`);
    console.log(`  Branch: ${rebookData.branch.name} (Active: ${rebookData.branch.active})`);
    console.log(`  Preferred Stylist: ${rebookData.preferredStylist.name} (${rebookData.preferredStylist.rating}★)`);
    console.log(`  Source Appointment: ${rebookData.sourceAppointmentId}`);

    // =========================================================================
    // TEST 7: Rebooking Safety - Non-Mutation of Appointments
    // =========================================================================
    console.log('\n--- TEST 7: Rebooking Safety - Appointment Count Non-Mutation ---');

    const apptCountBefore = await Appointment.countDocuments();
    await request({
      method: 'GET',
      path: `/api/customers/history/${completedApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    const apptCountAfter = await Appointment.countDocuments();
    if (apptCountBefore !== apptCountAfter) {
      throw new Error(`Rebooking context call mutated appointments: before=${apptCountBefore}, after=${apptCountAfter}`);
    }
    console.log('✓ Rebooking context retrieval is strictly read-only and did not mutate or duplicate appointments');

    // =========================================================================
    // TEST 8: Rebooking Edge Cases - Inactive Branch & Cancelled Appointments
    // =========================================================================
    console.log('\n--- TEST 8: Rebooking Edge Cases (Inactive Branch & Cancelled Appointment) ---');

    // Cancelled appointment rebook must be rejected with HTTP 400
    const rebookCancRes = await request({
      method: 'GET',
      path: `/api/customers/history/${cancelledApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (rebookCancRes.status !== 400) {
      throw new Error(`Cancelled appointment rebook must return 400, got ${rebookCancRes.status}`);
    }

    // Inactive branch rebook context must mark eligible: false and branch.active: false
    const rebookInactRes = await request({
      method: 'GET',
      path: `/api/customers/history/${inactiveBranchApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (rebookInactRes.status !== 200) {
      throw new Error(`Inactive branch appointment rebook context failed with ${rebookInactRes.status}`);
    }
    if (rebookInactRes.body.eligible !== false) {
      throw new Error('Rebook context for inactive branch must have eligible: false');
    }
    if (rebookInactRes.body.data.branch.active !== false) {
      throw new Error('Rebook context for inactive branch must have branch.active: false');
    }
    console.log('✓ Cancelled appointment rejected with 400; Inactive branch context accurately marked eligible: false and branch.active: false');

    // =========================================================================
    // TEST 9: Malformed Request & Invalid ID Resilience
    // =========================================================================
    console.log('\n--- TEST 9: Malformed Request & Invalid Identifier Resilience ---');

    // Invalid branchId format on treatment history returns HTTP 400 (not 500 CastError)
    const malformedBranchRes = await request({
      method: 'GET',
      path: '/api/customers/history?branchId=NOT-A-MONGO-OBJECT-ID',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (malformedBranchRes.status !== 400) {
      throw new Error(`Expected HTTP 400 for malformed branchId format, got ${malformedBranchRes.status}`);
    }

    // Non-existent appointment ID on rebook returns HTTP 404
    const notFoundRebook = await request({
      method: 'GET',
      path: '/api/customers/history/NON-EXISTENT-APPT-ID/rebook',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (notFoundRebook.status !== 404) {
      throw new Error(`Expected HTTP 404 for non-existent appointment rebook, got ${notFoundRebook.status}`);
    }

    // Non-existent customerId on admin details returns HTTP 404
    const notFoundCust = await request({
      method: 'GET',
      path: '/api/customers/admin/CUST-NON-EXISTENT-999',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (notFoundCust.status !== 404) {
      throw new Error(`Expected HTTP 404 for non-existent customer details, got ${notFoundCust.status}`);
    }
    console.log('✓ Malformed identifiers and non-existent entity lookups safely handled with clean 400/404 responses');

    // =========================================================================
    // TEST 10: Zero-Visit Customer Graceful Handling
    // =========================================================================
    console.log('\n--- TEST 10: Zero-Visit Customer Handling ---');

    const zeroCustDetails = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer2GlobalId}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (zeroCustDetails.status !== 200) {
      throw new Error(`Zero-visit customer details retrieval failed with ${zeroCustDetails.status}`);
    }

    const retMetrics = zeroCustDetails.body.data.retention;
    if (retMetrics.totalCompletedVisits !== 0) {
      throw new Error(`Zero visit customer totalCompletedVisits should be 0, got ${retMetrics.totalCompletedVisits}`);
    }
    if (retMetrics.retentionStatus !== 'No Visits') {
      throw new Error(`Zero visit customer retentionStatus should be 'No Visits', got ${retMetrics.retentionStatus}`);
    }
    if (retMetrics.lastCompletedVisit !== null) {
      throw new Error('Zero visit customer lastCompletedVisit must be null');
    }
    console.log('✓ Zero-visit customer handled smoothly with zeroed metrics and "No Visits" retention status');

    // =========================================================================
    // TEST 11: Cross-Branch Retention Aggregation & Segment Calculation
    // =========================================================================
    console.log('\n--- TEST 11: Cross-Branch Retention Aggregation & Segmentation ---');

    // Customer 1 has 2 completed visits across Bandra and Colaba
    const c1DetailsRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer1GlobalId}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    const c1Ret = c1DetailsRes.body.data.retention;
    if (c1Ret.totalCompletedVisits !== 2) {
      throw new Error(`Expected 2 completed visits for Customer 1, got ${c1Ret.totalCompletedVisits}`);
    }
    if (!c1Ret.segmentTags.includes('Multi-Branch')) {
      throw new Error('Customer 1 visiting multiple branches must be tagged "Multi-Branch"');
    }
    if (!c1Ret.segmentTags.includes('Returning Client')) {
      throw new Error('Customer 1 with 2 completed visits must be tagged "Returning Client"');
    }
    console.log(`✓ Customer 1 cross-branch retention metrics verified: ${c1Ret.totalCompletedVisits} visits, segments: [${c1Ret.segmentTags.join(', ')}]`);

    // =========================================================================
    // TEST 12: Beauty Quiz Submission & Preference Synchronization
    // =========================================================================
    console.log('\n--- TEST 12: Beauty Quiz Submission & Preference Synchronization ---');

    const quizPayload = {
      hairType: '2B Wavy',
      hairConcerns: ['Frizz Control', 'Volume & Lift'],
      skinType: 'Combination',
      goals: ['Deep Hydration', 'Radiant Glow'],
      sensitivities: ['Sulfate & Paraben Free']
    };

    const submitQuizRes = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: quizPayload
    });
    if (submitQuizRes.status !== 201 || !submitQuizRes.body.success) {
      throw new Error(`Beauty Quiz submission failed with status ${submitQuizRes.status}`);
    }

    // Verify preferences were synchronized
    const syncPrefRes = await request({
      method: 'GET',
      path: '/api/customers/preferences',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    const syncedPrefs = syncPrefRes.body.data;
    if (!syncedPrefs.hair.includes('Frizz Control') || !syncedPrefs.skin.includes('Combination')) {
      throw new Error('Customer preferences failed to synchronize from Beauty Quiz submission');
    }
    console.log('✓ Beauty Quiz submitted and customer preferences synchronized successfully');

    // =========================================================================
    // TEST 13: Beauty Quiz Retake Idempotency (Single Document Maintenance)
    // =========================================================================
    console.log('\n--- TEST 13: Beauty Quiz Retake Idempotency ---');

    // Retake the quiz with altered goals
    const retakePayload = {
      hairType: 'Curly',
      hairConcerns: ['Damage Repair'],
      skinType: 'Dry & Dehydrated',
      goals: ['Bond Fortification'],
      sensitivities: ['Vegan & Cruelty-Free']
    };

    const retakeRes = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: retakePayload
    });
    if (retakeRes.status !== 201) {
      throw new Error(`Quiz retake submission failed with status ${retakeRes.status}`);
    }

    // Ensure customer has exactly ONE QuizResult document (no duplicate records)
    const quizDocsCount = await QuizResult.countDocuments({ customerId: customer1GlobalId });
    if (quizDocsCount !== 1) {
      throw new Error(`Expected exactly 1 QuizResult document after retake, found ${quizDocsCount}`);
    }
    if (retakeRes.body.data.retakeCount !== 1) {
      throw new Error(`Expected retakeCount to be 1, got ${retakeRes.body.data.retakeCount}`);
    }
    console.log('✓ Quiz retake updated existing document cleanly without duplicate database records (retakeCount: 1)');

    // =========================================================================
    // TEST 14: Frontend viora:rebook-initiated Event Contract Verification
    // =========================================================================
    console.log('\n--- TEST 14: Frontend Rebook Event Contract in app.js ---');

    const appJsPath = path.join(__dirname, '../public/js/app.js');
    const appJsContent = fs.readFileSync(appJsPath, 'utf8');

    if (!appJsContent.includes("'viora:rebook-initiated'")) {
      throw new Error("app.js missing 'viora:rebook-initiated' CustomEvent dispatch");
    }
    if (!appJsContent.includes('isEligible')) {
      throw new Error('app.js missing isEligible check for rebooking availability');
    }
    console.log("✓ Verified app.js rebook workflow dispatches 'viora:rebook-initiated' and enforces eligibility rules");

    // =========================================================================
    // TEST 15: UI Layout Polish & Text Truncation CSS Rules
    // =========================================================================
    console.log('\n--- TEST 15: UI Layout Polish & CSS Rules Verification ---');

    const cssPath = path.join(__dirname, '../public/css/style.css');
    const cssContent = fs.readFileSync(cssPath, 'utf8');

    if (!cssContent.includes('.admin-retention-badge')) {
      throw new Error('style.css missing .admin-retention-badge definition');
    }
    if (!cssContent.includes('overflow-wrap: anywhere;') && !cssContent.includes('word-break: break-word;')) {
      throw new Error('style.css missing word-break/overflow-wrap rules for long customer text');
    }
    console.log('✓ Verified status badge consistency and text wrapping rules in style.css');

    // --- CLEANUP ---
    console.log('\n--- CLEANUP: Removing Day 7 Test Records ---');
    await User.deleteMany({ _id: { $in: [adminUser._id, managerUser._id, cust1User._id, cust2User._id, stylistUser._id] } });
    await Customer.deleteMany({ customerId: { $in: [customer1GlobalId, customer2GlobalId] } });
    await Branch.deleteMany({ _id: { $in: [branchBandra._id, branchInactive._id] } });
    await Stylist.deleteMany({ _id: stylist1._id });
    await Service.deleteMany({ _id: { $in: [serviceActive._id, serviceUnavailable._id] } });
    await Appointment.deleteMany({ _id: { $in: [appt1._id, appt2._id, appt3._id] } });
    await QuizResult.deleteMany({ customerId: { $in: [customer1GlobalId, customer2GlobalId] } });
    console.log('✓ Cleaned up test records.');

    console.log('\n==================================================================');
    console.log('ALL DAY 7 SECURITY HARDENING & QA TESTS PASSED SUCCESSFULLY! (15/15)');
    console.log('==================================================================\n');

  } catch (err) {
    console.error('\n❌ DAY 7 TEST FAILED:', err.message);
    console.error(err.stack);
    process.exitCode = 1;
  } finally {
    if (server) {
      server.close();
    }
    await mongoose.disconnect();
  }
}

runTests();
