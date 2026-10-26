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

const PORT = 5006; // Dedicated port for Day 6 Integration & Polish test suite
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
  console.log('VIORA DAY 6 - INTEGRATION, REGRESSION & UI POLISH TEST SUITE');
  console.log('==================================================================\n');

  const testTimestamp = Date.now();
  let adminToken = '';
  let customer1Token = '';
  let customer2Token = '';
  let customer1GlobalId = '';
  let customer2GlobalId = '';
  let completedApptId = '';
  let cancelledApptId = '';

  let branchBandra = null;
  let branchKhar = null;
  let branchJuhu = null;
  let stylistBandra = null;
  let serviceBalayage = null;
  let serviceFacial = null;

  try {
    // 0. Connect to MongoDB and start test server
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db';
    await mongoose.connect(mongoUri);
    console.log('✓ Connected to MongoDB');

    server = app.listen(PORT);
    console.log(`✓ Test server running on port ${PORT}\n`);

    // --- SETUP: Multi-Branch & User Entities Provisioning ---
    console.log('--- SETUP: Provisioning Multi-Branch Integration Entities ---');

    // Admin User
    const adminUser = await User.create({
      name: 'System Admin Day 6',
      email: `admin.${testTimestamp}@viora.com`,
      password: 'AdminPassword123!',
      role: 'admin'
    });

    // Customer 1 User & Profile
    const cust1User = await User.create({
      name: 'Elena Gilbert',
      email: `elena.${testTimestamp}@example.com`,
      password: 'Password123!',
      phone: '+91 98111 22233',
      role: 'customer'
    });
    customer1GlobalId = await Customer.generateGlobalCustomerId();
    const cust1Doc = await Customer.create({
      customerId: customer1GlobalId,
      userId: cust1User._id,
      name: cust1User.name,
      email: cust1User.email,
      phone: cust1User.phone,
      preferences: {
        hair: ['Balayage'],
        nails: ['Gel'],
        skin: ['Hydration'],
        makeup: ['Natural Look']
      }
    });

    // Customer 2 User & Profile (for isolation tests)
    const cust2User = await User.create({
      name: 'Stefan Salvatore',
      email: `stefan.${testTimestamp}@example.com`,
      password: 'Password123!',
      phone: '+91 98333 44455',
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

    // Branches
    branchBandra = await Branch.create({
      branchId: `BR-BAN-${testTimestamp}`,
      name: 'MAISON — Bandra Flagship',
      address: '12 Waterfield Road, Bandra West, Mumbai',
      phone: '+91 22 2640 1111',
      status: 'active'
    });

    branchKhar = await Branch.create({
      branchId: `BR-KHAR-${testTimestamp}`,
      name: 'MAISON — Khar Sanctuary',
      address: '45 Linking Road, Khar West, Mumbai',
      phone: '+91 22 2640 2222',
      status: 'active'
    });

    branchJuhu = await Branch.create({
      branchId: `BR-JUHU-${testTimestamp}`,
      name: 'MAISON — Juhu Haven',
      address: '88 Juhu Tara Road, Juhu, Mumbai',
      phone: '+91 22 2640 3333',
      status: 'active'
    });

    // Stylist
    const stylistUser = await User.create({
      name: 'Julian Vance',
      email: `julian.${testTimestamp}@viora.com`,
      password: 'Password123!',
      role: 'stylist'
    });
    stylistBandra = await Stylist.create({
      stylistId: `STY-${testTimestamp}`,
      userId: stylistUser._id,
      branchId: branchBandra._id,
      specialization: ['Balayage', 'Hair Spa', 'Volume & Lift'],
      experience: 8,
      rating: 4.95
    });

    // Services
    serviceBalayage = await Service.create({
      serviceId: `SRV-BAL-${testTimestamp}`,
      name: 'Artisan French Balayage',
      description: 'Hand-painted sun-kissed dimension with gloss finish',
      duration: 120,
      price: 6500,
      category: 'Hair',
      availability: true
    });

    serviceFacial = await Service.create({
      serviceId: `SRV-FAC-${testTimestamp}`,
      name: 'Hydra-Luxe Radiance Facial',
      description: 'Cellular deep hydration treatment',
      duration: 60,
      price: 4500,
      category: 'Skin',
      availability: true
    });

    // Seed Cross-Branch Appointments for Customer 1
    const apptCompleted1 = await Appointment.create({
      appointmentId: `APT-1-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      serviceId: serviceBalayage._id,
      stylistId: stylistBandra._id,
      date: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000), // 15 days ago
      startTime: '10:00',
      endTime: '12:00',
      status: 'Completed',
      notes: 'Loves cool ash tones'
    });
    completedApptId = apptCompleted1.appointmentId;

    const apptCompleted2 = await Appointment.create({
      appointmentId: `APT-2-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchKhar._id,
      serviceId: serviceFacial._id,
      stylistId: stylistBandra._id,
      date: new Date(Date.now() - 40 * 24 * 60 * 60 * 1000), // 40 days ago
      startTime: '14:00',
      endTime: '15:00',
      status: 'Completed'
    });

    const apptCancelled = await Appointment.create({
      appointmentId: `APT-3-CANC-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchJuhu._id,
      serviceId: serviceBalayage._id,
      stylistId: stylistBandra._id,
      date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      startTime: '11:00',
      endTime: '13:00',
      status: 'Cancelled'
    });
    cancelledApptId = apptCancelled.appointmentId;

    // Login users to acquire tokens
    const adminLoginRes = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: adminUser.email, password: 'AdminPassword123!' }
    });
    adminToken = adminLoginRes.body.token;

    const cust1LoginRes = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: cust1User.email, password: 'Password123!' }
    });
    customer1Token = cust1LoginRes.body.token;

    const cust2LoginRes = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: { email: cust2User.email, password: 'Password123!' }
    });
    customer2Token = cust2LoginRes.body.token;

    console.log('✓ Provisioned admin and multi-branch customer test entities.\n');

    // --- TEST 1: Rebook Integration Contract Endpoint ---
    console.log('--- TEST 1: Rebook Integration Contract (GET /api/customers/history/:id/rebook) ---');
    const rebookRes = await request({
      method: 'GET',
      path: `/api/customers/history/${completedApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });

    if (rebookRes.status !== 200 || !rebookRes.body.success) {
      throw new Error(`Rebook contract fetch failed with status ${rebookRes.status}`);
    }

    const rebookData = rebookRes.body.data;
    // Verify Booking module integration payload contract
    if (!rebookData.service || !rebookData.service.id || !rebookData.service.name || rebookData.service.price === undefined) {
      throw new Error('Rebook payload missing required service fields');
    }
    if (!rebookData.branch || !rebookData.branch.id || !rebookData.branch.name) {
      throw new Error('Rebook payload missing required branch fields');
    }
    if (!rebookData.preferredStylist || !rebookData.preferredStylist.name) {
      throw new Error('Rebook payload missing required preferredStylist fields');
    }
    if (rebookData.sourceAppointmentId !== completedApptId) {
      throw new Error(`Rebook payload sourceAppointmentId mismatch: expected ${completedApptId}, got ${rebookData.sourceAppointmentId}`);
    }

    console.log('✓ Rebook endpoint returned verified contract payload:');
    console.log(`  Service: ${rebookData.service.name} (₹${rebookData.service.price}, ${rebookData.service.duration}m)`);
    console.log(`  Branch: ${rebookData.branch.name}`);
    console.log(`  Stylist: ${rebookData.preferredStylist.name} (${rebookData.preferredStylist.rating}★)`);
    console.log(`  Source Appointment: ${rebookData.sourceAppointmentId}`);

    // --- TEST 2: Rebook Safety (No Unintended Mutation/Creation) ---
    console.log('\n--- TEST 2: Rebook Safety - No Mutation of Appointments ---');
    const appointmentsCount = await Appointment.countDocuments({ customerId: customer1GlobalId });
    if (appointmentsCount !== 3) {
      throw new Error(`Appointment count changed unexpectedly: expected 3, got ${appointmentsCount}`);
    }
    console.log('✓ Rebooking context retrieval is read-only and did not create duplicate appointments');

    // --- TEST 3: Rebook Rejection for Ineligible / Cancelled Appointments ---
    console.log('\n--- TEST 3: Rebook Rejection on Cancelled Appointment ---');
    const rebookCancRes = await request({
      method: 'GET',
      path: `/api/customers/history/${cancelledApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (rebookCancRes.status !== 400 || rebookCancRes.body.success !== false) {
      throw new Error(`Expected HTTP 400 for cancelled appointment rebook, got ${rebookCancRes.status}`);
    }
    console.log(`✓ Cancelled appointment rejected with HTTP 400: "${rebookCancRes.body.message}"`);

    // --- TEST 4: Frontend Rebook Event Dispatch Contract in app.js ---
    console.log('\n--- TEST 4: Frontend viora:rebook-initiated Event Contract ---');
    const appJsContent = fs.readFileSync(path.join(__dirname, '../public/js/app.js'), 'utf8');
    if (!appJsContent.includes("'viora:rebook-initiated'")) {
      throw new Error("app.js missing 'viora:rebook-initiated' CustomEvent dispatch");
    }
    if (!appJsContent.includes('state.selectedRebookData')) {
      throw new Error('app.js missing selectedRebookData state management');
    }
    console.log("✓ Verified app.js dispatches 'viora:rebook-initiated' event with booking detail payload");

    // --- TEST 5: Centralized Cross-Branch Treatment History Retrieval & Filter ---
    console.log('\n--- TEST 5: Cross-Branch Treatment History (GET /api/customers/history) ---');
    const historyRes = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (historyRes.status !== 200 || !historyRes.body.success) {
      throw new Error(`History fetch failed with status ${historyRes.status}`);
    }
    if (historyRes.body.count !== 2) {
      throw new Error(`Expected exactly 2 completed visits across branches, got ${historyRes.body.count}`);
    }
    // Verify branches present
    const branchesVisited = historyRes.body.data.map(h => h.branch.name);
    if (!branchesVisited.includes('MAISON — Bandra Flagship') || !branchesVisited.includes('MAISON — Khar Sanctuary')) {
      throw new Error('Missing expected multi-branch treatments in history');
    }
    console.log(`✓ Retrieved 2 completed treatments across Bandra & Khar branches`);

    // Category filter check: Hair
    const hairHistoryRes = await request({
      method: 'GET',
      path: '/api/customers/history?category=Hair',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (hairHistoryRes.body.count !== 1 || hairHistoryRes.body.data[0].service.category !== 'Hair') {
      throw new Error('Category filter for Hair failed');
    }
    console.log('✓ Category filtering (?category=Hair) returned only hair treatments');

    // --- TEST 6: Customer Identity Scope & Strict Isolation ---
    console.log('\n--- TEST 6: Customer Identity Isolation ---');
    const cust2HistoryRes = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${customer2Token}` }
    });
    if (cust2HistoryRes.body.count !== 0) {
      throw new Error(`Customer 2 should have 0 records, got ${cust2HistoryRes.body.count}`);
    }

    // Attempting to access customer 1's rebook with customer 2's token
    const crossRebookRes = await request({
      method: 'GET',
      path: `/api/customers/history/${completedApptId}/rebook`,
      headers: { Authorization: `Bearer ${customer2Token}` }
    });
    if (crossRebookRes.status !== 404) {
      throw new Error(`Cross-customer rebook access should return 404, got ${crossRebookRes.status}`);
    }
    console.log('✓ Customer 2 cannot access Customer 1 appointments (strict JWT scoping verified)');

    // --- TEST 7: Quiz Result & Profile Preferences Synchronization ---
    console.log('\n--- TEST 7: Quiz Synchronization with Customer Preferences ---');
    const quizSubmissionRes = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        hairType: '2B Wavy',
        hairConcerns: ['Volume & Lift', 'Frizz Control'],
        skinType: 'Combination',
        goals: ['Deep Hydration', 'Radiant Glow'],
        sensitivities: ['Sulfate & Paraben Free']
      }
    });

    if (quizSubmissionRes.status !== 201 || !quizSubmissionRes.body.success) {
      throw new Error(`Quiz submission failed: ${quizSubmissionRes.status}`);
    }

    // Verify Customer profile reflects synchronized preferences
    const profileRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    const prefs = profileRes.body.data.preferences;
    const prefStrings = Object.values(prefs).flat().map(s => String(s));
    const hasVolume = prefStrings.some(s => s.toLowerCase().includes('volume'));
    const hasFrizz = prefStrings.some(s => s.toLowerCase().includes('frizz'));
    if (!hasVolume || !hasFrizz) {
      throw new Error('Preferences were not synchronized with quiz concerns');
    }
    console.log('✓ Quiz submission accurately synchronized customer preferences');

    // --- TEST 8: Admin Customer Management Security & Privacy ---
    console.log('\n--- TEST 8: Role Authorization & Secret Sanitization ---');
    // Customer blocked from admin
    const custAdminBlockRes = await request({
      method: 'GET',
      path: '/api/customers/admin/overview',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (custAdminBlockRes.status !== 403) {
      throw new Error(`Expected HTTP 403 for customer accessing admin overview, got ${custAdminBlockRes.status}`);
    }

    // Admin access allowed
    const adminDetailRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer1GlobalId}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (adminDetailRes.status !== 200 || !adminDetailRes.body.success) {
      throw new Error(`Admin failed to get customer detail: ${adminDetailRes.status}`);
    }

    // Verify no leaked credentials
    const detailJson = JSON.stringify(adminDetailRes.body);
    if (detailJson.includes('password') || detailJson.includes('JWT_SECRET') || detailJson.includes('hash')) {
      throw new Error('Sensitive credentials leaked in admin customer details endpoint!');
    }
    console.log('✓ Customer correctly forbidden (HTTP 403) from admin endpoints');
    console.log('✓ Admin retrieved customer details with zero credentials or secrets leaked');

    // --- TEST 9: Status Badge Alignment Styles & Elements ---
    console.log('\n--- TEST 9: Status Badge CSS Alignment & Layout Rules ---');
    const cssContent = fs.readFileSync(path.join(__dirname, '../public/css/style.css'), 'utf8');
    const requiredCssRules = [
      '.admin-customer-status-field',
      '.admin-retention-badge',
      '.badge-active',
      '.badge-at-risk',
      '.badge-needs-engagement',
      '.badge-new',
      '.badge-novisits'
    ];
    for (const rule of requiredCssRules) {
      if (!cssContent.includes(rule)) {
        throw new Error(`style.css missing required retention badge rule: ${rule}`);
      }
    }
    if (!cssContent.includes('display: inline-flex') || !cssContent.includes('min-width: 60px')) {
      throw new Error('style.css missing inline-flex or min-width alignment constraints on badges');
    }
    console.log('✓ Aligned badge rules verified for ACTIVE, AT-RISK, NEEDS ENGAGEMENT, NEW, and NO VISITS');

    // --- TEST 10: UI Polish - Clean Non-blocking Sign Out ---
    console.log('\n--- TEST 10: Non-blocking Sign Out Handler Verification ---');
    if (appJsContent.includes("confirm('Are you sure you want to sign out")) {
      throw new Error('app.js still contains blocking window.confirm in handleSignOut');
    }
    if (!appJsContent.includes('window.vioraApi.clearSession()')) {
      throw new Error('app.js handleSignOut missing clearSession call');
    }
    console.log('✓ handleSignOut verified: non-blocking, cleans session state, and transitions seamlessly');

    // --- TEST 11: Error Handling for Malformed or Non-existent IDs ---
    console.log('\n--- TEST 11: Resilient Error Handling for Invalid IDs ---');
    const notFoundRebookRes = await request({
      method: 'GET',
      path: '/api/customers/history/NON-EXISTENT-ID/rebook',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (notFoundRebookRes.status !== 404) {
      throw new Error(`Expected 404 for non-existent appointment rebook, got ${notFoundRebookRes.status}`);
    }

    const notFoundAdminCustRes = await request({
      method: 'GET',
      path: '/api/customers/admin/CUST-INVALID-999',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (notFoundAdminCustRes.status !== 404) {
      throw new Error(`Expected 404 for non-existent admin customer, got ${notFoundAdminCustRes.status}`);
    }
    console.log('✓ Invalid appointment and customer IDs rejected gracefully with HTTP 404');

    // --- CLEANUP ---
    console.log('\n--- CLEANUP: Removing Day 6 Test Records ---');
    await Appointment.deleteMany({ customerId: { $in: [customer1GlobalId, customer2GlobalId] } });
    await QuizResult.deleteMany({ customerId: customer1GlobalId });
    await Customer.deleteMany({ customerId: { $in: [customer1GlobalId, customer2GlobalId] } });
    await User.deleteMany({ _id: { $in: [adminUser._id, cust1User._id, cust2User._id, stylistUser._id] } });
    await Stylist.deleteOne({ _id: stylistBandra._id });
    await Service.deleteMany({ _id: { $in: [serviceBalayage._id, serviceFacial._id] } });
    await Branch.deleteMany({ _id: { $in: [branchBandra._id, branchKhar._id, branchJuhu._id] } });
    console.log('✓ Cleaned up test records.');

    console.log('\n==================================================================');
    console.log('ALL DAY 6 INTEGRATION & POLISH TESTS PASSED SUCCESSFULLY! (11/11)');
    console.log('==================================================================\n');

  } catch (err) {
    console.error('\n❌ DAY 6 TEST SUITE FAILED:', err.message);
    process.exitCode = 1;
  } finally {
    if (server) {
      await new Promise(r => server.close(r));
    }
    await mongoose.disconnect();
  }
}

runTests();
