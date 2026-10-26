const mongoose = require('mongoose');
const http = require('http');
require('dotenv').config();

const app = require('../server');
const User = require('../models/User');
const Customer = require('../models/Customer');
const Branch = require('../models/Branch');
const Stylist = require('../models/Stylist');
const Service = require('../models/Service');
const Appointment = require('../models/Appointment');
const QuizResult = require('../models/QuizResult');

const PORT = 5005; // Dedicated test port for Day 5 test suite
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
  console.log('VIORA DAY 5 - ADMIN CUSTOMER MANAGEMENT & RETENTION TEST SUITE');
  console.log('==================================================================\n');

  const testTimestamp = Date.now();
  let adminToken = '';
  let branchManagerToken = '';
  let customer1Token = '';
  let customer1GlobalId = '';
  let customer2GlobalId = '';
  let customer3GlobalId = '';

  let branchBandra = null;
  let branchKhar = null;
  let branchJuhu = null;
  let stylistBandra = null;
  let stylistKhar = null;
  let serviceHair = null;
  let serviceFacial = null;

  try {
    // 0. Connect DB & Start Server
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db';
    await mongoose.connect(mongoUri);
    console.log('✓ Connected to MongoDB');

    server = app.listen(PORT);
    console.log(`✓ Test server running on port ${PORT}\n`);

    // --- TEST 1: Frontend Static File Serving & Day 5 UI Structure ---
    console.log('--- TEST 1: Frontend Static File Serving & Day 5 UI Structure ---');
    const indexRes = await request({ method: 'GET', path: '/' });
    if (indexRes.status === 200 && indexRes.rawBody) {
      const html = indexRes.rawBody;
      if (!html.includes('id="screenAdminCustomers"')) {
        throw new Error('index.html missing Screen 8 screenAdminCustomers');
      }
      if (!html.includes('id="screenAdminCustomerDetail"')) {
        throw new Error('index.html missing Screen 9 screenAdminCustomerDetail');
      }
      if (!html.includes('id="btnDemoAdminLogin"')) {
        throw new Error('index.html missing btnDemoAdminLogin quick demo button');
      }
      if (!html.includes('id="tileAdminCustomers"')) {
        throw new Error('index.html missing tileAdminCustomers in Profile screen');
      }
      console.log('✓ GET / successfully served index.html containing Day 5 Admin screens');
    } else {
      throw new Error(`Failed to serve index.html (status: ${indexRes.status})`);
    }

    const cssRes = await request({ method: 'GET', path: '/css/style.css' });
    if (cssRes.status === 200 && cssRes.rawBody && cssRes.rawBody.includes('.admin-customer-card')) {
      const css = cssRes.rawBody;
      if (!css.includes('.admin-customer-status-field')) {
        throw new Error('style.css missing .admin-customer-status-field rule');
      }
      if (!css.includes('.admin-retention-badge') || !css.includes('display: inline-flex')) {
        throw new Error('style.css missing aligned .admin-retention-badge rule');
      }
      if (!css.includes('badge-active') || !css.includes('badge-at-risk') || !css.includes('badge-needs-engagement') || !css.includes('badge-new') || !css.includes('badge-novisits')) {
        throw new Error('style.css missing retention status badge color classes');
      }
      console.log('✓ GET /css/style.css successfully served Day 5 luxury admin styles & aligned status badge rules');
    } else {
      throw new Error('Failed to serve Day 5 styles in style.css');
    }

    const apiJsRes = await request({ method: 'GET', path: '/js/api.js' });
    if (apiJsRes.status === 200 && apiJsRes.rawBody && apiJsRes.rawBody.includes('getAdminOverview')) {
      console.log('✓ GET /js/api.js successfully served Day 5 admin API client methods');
    } else {
      throw new Error('Failed to serve Day 5 admin methods in api.js');
    }

    // --- SETUP: Provision Admin, Branch Manager, Customers, Branches, Appointments ---
    console.log('\n--- SETUP: Provisioning Multi-Branch Test Infrastructure ---');

    // Provision Admin user
    const adminEmail = `admin.${testTimestamp}@viora.com`;
    const adminRegRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Sarah Executive Admin',
        email: adminEmail,
        password: 'AdminPassword@123',
        phone: '+91 98000 11111',
        role: 'admin'
      }
    });
    if (adminRegRes.status !== 201 || !adminRegRes.body.token) {
      throw new Error(`Admin registration failed: ${JSON.stringify(adminRegRes.body)}`);
    }
    adminToken = adminRegRes.body.token;
    console.log('✓ Provisioned Administrator:', adminEmail);

    // Provision Branch Manager user
    const bmEmail = `manager.${testTimestamp}@viora.com`;
    const bmRegRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Michael Branch Manager',
        email: bmEmail,
        password: 'ManagerPassword@123',
        phone: '+91 98000 22222',
        role: 'branch_manager'
      }
    });
    if (bmRegRes.status !== 201 || !bmRegRes.body.token) {
      throw new Error(`Branch Manager registration failed: ${JSON.stringify(bmRegRes.body)}`);
    }
    branchManagerToken = bmRegRes.body.token;
    console.log('✓ Provisioned Branch Manager:', bmEmail);

    // Provision Customer 1 (Returning & Multi-Branch patron)
    const cust1Email = `sarah.cust1.${testTimestamp}@example.com`;
    const cust1RegRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Sarah Sen',
        email: cust1Email,
        password: 'CustPassword@123',
        phone: '+91 98200 12345',
        role: 'customer'
      }
    });
    customer1Token = cust1RegRes.body.token;
    customer1GlobalId = cust1RegRes.body.user.customerId;
    console.log(`✓ Provisioned Customer 1: ${customer1GlobalId} (${cust1Email})`);

    // Provision Customer 2 (At-Risk / Inactive patron)
    const cust2Email = `elena.cust2.${testTimestamp}@example.com`;
    const cust2RegRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Elena Gilbert',
        email: cust2Email,
        password: 'CustPassword@123',
        phone: '+91 98300 54321',
        role: 'customer'
      }
    });
    customer2GlobalId = cust2RegRes.body.user.customerId;
    console.log(`✓ Provisioned Customer 2: ${customer2GlobalId} (${cust2Email})`);

    // Provision Customer 3 (Brand new customer with 0 visits)
    const cust3Email = `priya.cust3.${testTimestamp}@example.com`;
    const cust3RegRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Priya Sharma',
        email: cust3Email,
        password: 'CustPassword@123',
        phone: '+91 98400 99999',
        role: 'customer'
      }
    });
    customer3GlobalId = cust3RegRes.body.user.customerId;
    console.log(`✓ Provisioned Customer 3 (Zero Visits): ${customer3GlobalId} (${cust3Email})`);

    // Update Customer 1 with preferences & quiz results
    await Customer.findOneAndUpdate(
      { customerId: customer1GlobalId },
      {
        preferences: {
          hair: ['Balayage', 'Keratin'],
          nails: ['Gel', 'French Tip'],
          skin: ['Glow Facial'],
          makeup: ['Natural Look']
        },
        dateOfBirth: new Date('1995-05-15')
      }
    );

    await QuizResult.create({
      customerId: customer1GlobalId,
      userId: cust1RegRes.body.user.id,
      answers: {
        hairType: '2B Wavy',
        hairConcerns: ['Volume & Lift', 'Frizz'],
        skinType: 'Combination',
        goals: ['Hydration'],
        sensitivities: []
      },
      profileArchetype: 'Airy Volume & Sleek Defiance',
      summary: 'Tailored for 2B Wavy textures that need customized root lift and bounce.',
      profileChips: ['Hair: 2B Wavy', 'Skin: Combination', 'Concern: Volume & Lift'],
      recommendations: {
        products: [],
        stylists: [],
        services: []
      }
    });

    // Provision Branches
    branchBandra = await Branch.create({
      branchId: `BR-BANDRA-${testTimestamp}`,
      name: 'MAISON — Bandra Flagship',
      address: 'Waterfield Road, Bandra West',
      phone: '+91 22 2640 1111'
    });

    branchKhar = await Branch.create({
      branchId: `BR-KHAR-${testTimestamp}`,
      name: 'MAISON — Khar West',
      address: '14th Road, Khar West',
      phone: '+91 22 2640 2222'
    });

    branchJuhu = await Branch.create({
      branchId: `BR-JUHU-${testTimestamp}`,
      name: 'MAISON — Juhu',
      address: 'Juhu Tara Road',
      phone: '+91 22 2640 3333'
    });

    // Provision Stylists
    const stylistUser1 = await User.create({
      name: 'Christian Dior',
      email: `christian.${testTimestamp}@viora.com`,
      password: 'StylistPassword@123',
      role: 'stylist'
    });

    stylistBandra = await Stylist.create({
      stylistId: `STY-1-${testTimestamp}`,
      userId: stylistUser1._id,
      branchId: branchBandra._id,
      specialization: ['Balayage', 'Color Specialist'],
      rating: 4.9
    });

    const stylistUser2 = await User.create({
      name: 'Jessica Alba',
      email: `jessica.${testTimestamp}@viora.com`,
      password: 'StylistPassword@123',
      role: 'stylist'
    });

    stylistKhar = await Stylist.create({
      stylistId: `STY-2-${testTimestamp}`,
      userId: stylistUser2._id,
      branchId: branchKhar._id,
      specialization: ['Hydration', 'Glow Facial'],
      rating: 4.8
    });

    // Provision Services
    serviceHair = await Service.create({
      serviceId: `SRV-HAIR-${testTimestamp}`,
      name: 'Signature Balayage & Gloss',
      duration: 120,
      price: 6500,
      category: 'Hair'
    });

    serviceFacial = await Service.create({
      serviceId: `SRV-SKIN-${testTimestamp}`,
      name: 'Hydra-Luxe Glow Facial',
      duration: 60,
      price: 4500,
      category: 'Skin'
    });

    // Seed Appointments:
    // Customer 1:
    // 1) Completed at Bandra (10 days ago) -> Active (<30d)
    const tenDaysAgo = new Date(Date.now() - 10 * 24 * 60 * 60 * 1000);
    await Appointment.create({
      appointmentId: `APPT-1-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      stylistId: stylistBandra._id,
      serviceId: serviceHair._id,
      date: tenDaysAgo,
      startTime: '10:00',
      endTime: '12:00',
      status: 'Completed'
    });

    // 2) Completed at Khar West (40 days ago) -> Cross-branch!
    const fortyDaysAgo = new Date(Date.now() - 40 * 24 * 60 * 60 * 1000);
    await Appointment.create({
      appointmentId: `APPT-2-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchKhar._id,
      stylistId: stylistKhar._id,
      serviceId: serviceFacial._id,
      date: fortyDaysAgo,
      startTime: '14:00',
      endTime: '15:00',
      status: 'Completed'
    });

    // 3) Confirmed Upcoming appointment at Juhu (tomorrow) - MUST NOT BE COUNTED AS COMPLETED VISIT
    const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000);
    await Appointment.create({
      appointmentId: `APPT-3-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchJuhu._id,
      stylistId: stylistBandra._id,
      serviceId: serviceHair._id,
      date: tomorrow,
      startTime: '11:00',
      endTime: '13:00',
      status: 'Confirmed'
    });

    // 4) Cancelled appointment at Bandra - MUST NOT BE COUNTED AS COMPLETED VISIT
    const pastCancelled = new Date(Date.now() - 60 * 24 * 60 * 60 * 1000);
    await Appointment.create({
      appointmentId: `APPT-4-${testTimestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      stylistId: stylistBandra._id,
      serviceId: serviceHair._id,
      date: pastCancelled,
      startTime: '16:00',
      endTime: '18:00',
      status: 'Cancelled'
    });

    // Customer 2:
    // Completed appointment 120 days ago (>90 days) -> Inactive / At-Risk
    const fourMonthsAgo = new Date(Date.now() - 120 * 24 * 60 * 60 * 1000);
    await Appointment.create({
      appointmentId: `APPT-5-${testTimestamp}`,
      customerId: customer2GlobalId,
      branchId: branchKhar._id,
      stylistId: stylistKhar._id,
      serviceId: serviceFacial._id,
      date: fourMonthsAgo,
      startTime: '11:00',
      endTime: '12:00',
      status: 'Completed'
    });

    console.log('✓ Multi-branch appointments seeded successfully across 3 branches.\n');

    // --- TEST 2: Security - Unauthenticated Request Rejection ---
    console.log('--- TEST 2: Security - Unauthenticated Request Rejection ---');
    const unauthRes = await request({ method: 'GET', path: '/api/customers/admin/overview' });
    if (unauthRes.status === 401 && !unauthRes.body.success) {
      console.log('✓ Unauthenticated request to /api/customers/admin/overview rejected with HTTP 401');
    } else {
      throw new Error(`Unauthenticated request was NOT rejected: status ${unauthRes.status}`);
    }

    const unauthListRes = await request({ method: 'GET', path: '/api/customers/admin/list' });
    if (unauthListRes.status === 401 && !unauthListRes.body.success) {
      console.log('✓ Unauthenticated request to /api/customers/admin/list rejected with HTTP 401');
    } else {
      throw new Error(`Unauthenticated list request was NOT rejected: status ${unauthListRes.status}`);
    }

    // --- TEST 3: Security - Ordinary Customers Cannot Access Admin Endpoints ---
    console.log('\n--- TEST 3: Security - Ordinary Customers Rejection (HTTP 403 Forbidden) ---');
    const custForbiddenRes = await request({
      method: 'GET',
      path: '/api/customers/admin/overview',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (custForbiddenRes.status === 403 && !custForbiddenRes.body.success) {
      console.log('✓ Ordinary customer blocked from admin overview with HTTP 403 Forbidden:', custForbiddenRes.body.message);
    } else {
      throw new Error(`Ordinary customer was NOT rejected with 403: status ${custForbiddenRes.status}`);
    }

    const custForbiddenListRes = await request({
      method: 'GET',
      path: '/api/customers/admin/list',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (custForbiddenListRes.status === 403 && !custForbiddenListRes.body.success) {
      console.log('✓ Ordinary customer blocked from customer list with HTTP 403 Forbidden');
    } else {
      throw new Error(`Ordinary customer was NOT rejected with 403 on list: status ${custForbiddenListRes.status}`);
    }

    const custForbiddenDetailRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer2GlobalId}`,
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (custForbiddenDetailRes.status === 403 && !custForbiddenDetailRes.body.success) {
      console.log('✓ Ordinary customer blocked from accessing another customer profile with HTTP 403 Forbidden');
    } else {
      throw new Error(`Ordinary customer was NOT rejected with 403 on detail: status ${custForbiddenDetailRes.status}`);
    }

    // --- TEST 4: Authorized Administrator & Branch Manager Access ---
    console.log('\n--- TEST 4: Authorized Access for Admin & Branch Manager ---');
    const adminOverviewRes = await request({
      method: 'GET',
      path: '/api/customers/admin/overview',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (adminOverviewRes.status === 200 && adminOverviewRes.body.success) {
      const data = adminOverviewRes.body.data;
      console.log('✓ Administrator retrieved overview successfully:');
      console.log('  Total Customers:', data.totalCustomers);
      console.log('  Total Completed Visits:', data.totalCompletedVisits);
      console.log('  Repeat Retention Rate:', data.repeatCustomerRate + '%');
      console.log('  Segments Breakdown:', data.segments);
      console.log('  Branch Breakdown:', data.branchBreakdown);
    } else {
      throw new Error(`Admin overview failed: ${JSON.stringify(adminOverviewRes.body)}`);
    }

    const bmOverviewRes = await request({
      method: 'GET',
      path: '/api/customers/admin/overview',
      headers: { Authorization: `Bearer ${branchManagerToken}` }
    });
    if (bmOverviewRes.status === 200 && bmOverviewRes.body.success) {
      console.log('✓ Branch Manager authorized access verified (HTTP 200)');
    } else {
      throw new Error(`Branch Manager access failed: ${JSON.stringify(bmOverviewRes.body)}`);
    }

    // --- TEST 5: Customer Management List & Pagination ---
    console.log('\n--- TEST 5: Customer Management List (GET /api/customers/admin/list) ---');
    const listRes = await request({
      method: 'GET',
      path: '/api/customers/admin/list',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (listRes.status === 200 && listRes.body.success) {
      const list = listRes.body.data;
      console.log(`✓ Retrieved ${list.length} customer records (Total: ${listRes.body.totalCount})`);

      const c1 = list.find(c => c.customerId === customer1GlobalId);
      if (!c1) throw new Error(`Customer 1 (${customer1GlobalId}) missing in customer list`);

      console.log('✓ Customer 1 verified:');
      console.log('  Name:', c1.name);
      console.log('  Global ID:', c1.customerId);
      console.log('  Total Completed Visits:', c1.totalCompletedVisits);
      console.log('  Retention Status:', c1.retentionStatus);
      console.log('  Segments:', c1.segments);
      console.log('  Branches Visited:', c1.branchesVisited);

      // Verify distinction from non-completed: Customer 1 has 2 completed, 1 confirmed, 1 cancelled.
      if (c1.totalCompletedVisits !== 2) {
        throw new Error(`Expected Customer 1 to have exactly 2 completed visits, got: ${c1.totalCompletedVisits}`);
      }
      console.log('✓ Confirmed & Cancelled appointments correctly EXCLUDED from completed visit count');
    } else {
      throw new Error(`Admin customer list failed: ${JSON.stringify(listRes.body)}`);
    }

    // --- TEST 6: Search Functionality ---
    console.log('\n--- TEST 6: Search Functionality ---');
    // Search by Name
    const searchNameRes = await request({
      method: 'GET',
      path: '/api/customers/admin/list?search=Elena',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (searchNameRes.status === 200 && searchNameRes.body.data.some(c => c.customerId === customer2GlobalId)) {
      console.log('✓ Search by name ("Elena") returned matching record');
    } else {
      throw new Error('Search by name failed');
    }

    // Search by Global Customer ID
    const searchIdRes = await request({
      method: 'GET',
      path: `/api/customers/admin/list?search=${customer1GlobalId}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (searchIdRes.status === 200 && searchIdRes.body.data.length === 1 && searchIdRes.body.data[0].customerId === customer1GlobalId) {
      console.log(`✓ Search by global ID ("${customer1GlobalId}") returned exact matching customer`);
    } else {
      throw new Error('Search by customerId failed');
    }

    // Search by Email
    const searchEmailRes = await request({
      method: 'GET',
      path: `/api/customers/admin/list?search=${cust3Email}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (searchEmailRes.status === 200 && searchEmailRes.body.data.some(c => c.customerId === customer3GlobalId)) {
      console.log(`✓ Search by email ("${cust3Email}") returned matching record`);
    } else {
      throw new Error('Search by email failed');
    }

    // --- TEST 7: Segmentation Rules Produce Consistent Results ---
    console.log('\n--- TEST 7: Segmentation Rules & Filtering ---');
    // Returning segment (>= 2 completed visits)
    const segReturningRes = await request({
      method: 'GET',
      path: '/api/customers/admin/list?segment=returning',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    const returningIds = segReturningRes.body.data.map(c => c.customerId);
    if (returningIds.includes(customer1GlobalId) && !returningIds.includes(customer2GlobalId) && !returningIds.includes(customer3GlobalId)) {
      console.log('✓ Segment "returning" correctly returned Customer 1 (>= 2 visits) and excluded single/zero visit clients');
    } else {
      throw new Error(`Segment returning rule inconsistent: ${JSON.stringify(returningIds)}`);
    }

    // At-Risk segment (completed visit > 90 days ago)
    const segAtRiskRes = await request({
      method: 'GET',
      path: '/api/customers/admin/list?segment=at_risk',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    const atRiskIds = segAtRiskRes.body.data.map(c => c.customerId);
    if (atRiskIds.includes(customer2GlobalId) && !atRiskIds.includes(customer1GlobalId)) {
      console.log('✓ Segment "at_risk" correctly identified Customer 2 (> 90 days since last visit)');
    } else {
      throw new Error(`Segment at_risk rule inconsistent: ${JSON.stringify(atRiskIds)}`);
    }

    // Multi-Branch segment (visited >= 2 distinct branches)
    const segMultiBranchRes = await request({
      method: 'GET',
      path: '/api/customers/admin/list?segment=multi_branch',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    const multiBranchIds = segMultiBranchRes.body.data.map(c => c.customerId);
    if (multiBranchIds.includes(customer1GlobalId) && !multiBranchIds.includes(customer2GlobalId)) {
      console.log('✓ Segment "multi_branch" correctly identified Customer 1 (Bandra & Khar West)');
    } else {
      throw new Error(`Segment multi_branch rule inconsistent: ${JSON.stringify(multiBranchIds)}`);
    }

    // --- TEST 8: Centralized Customer Identity (No Duplication) ---
    console.log('\n--- TEST 8: Centralized Identity & Cross-Branch Integrity ---');
    const allCustomersInDb = await Customer.countDocuments();
    const overviewTotal = adminOverviewRes.body.data.totalCustomers;
    if (overviewTotal === allCustomersInDb) {
      console.log(`✓ Total customers count (${overviewTotal}) matches unique customer identity documents`);
      console.log('✓ Verified: Customer visiting multiple branches is NOT duplicated in directory');
    } else {
      throw new Error(`Customer count mismatch: DB has ${allCustomersInDb}, overview reported ${overviewTotal}`);
    }

    // --- TEST 9: Customer Details & No Leaked Secrets ---
    console.log('\n--- TEST 9: Customer Details Contain Authorized Info & No Leaked Secrets ---');
    const detailRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer1GlobalId}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (detailRes.status === 200 && detailRes.body.success) {
      const d = detailRes.body.data;
      console.log('✓ Customer Details retrieved:');
      console.log('  Customer Name:', d.profile.name);
      console.log('  Customer ID:', d.profile.customerId);
      console.log('  Email:', d.profile.email);
      console.log('  Phone:', d.profile.phone);
      console.log('  Total Completed Visits:', d.retention.totalCompletedVisits);
      console.log('  Total Spend:', '₹' + d.retention.totalSpend);
      console.log('  Branches Visited:', d.retention.branchesVisited);
      console.log('  Retention Status:', d.retention.retentionStatus);

      // Verify no password, token, or secret is returned
      if (d.profile.password || d.password || d.token) {
        throw new Error('SECURITY VIOLATION: Customer detail response leaked password or token!');
      }
      console.log('✓ Security verified: No passwords, tokens, or private secrets leaked in payload');
    } else {
      throw new Error(`Customer details retrieval failed: ${JSON.stringify(detailRes.body)}`);
    }

    // --- TEST 10: Authorized Preference & Quiz Visibility ---
    console.log('\n--- TEST 10: Authorized Personal Preferences & Quiz Visibility ---');
    const d1 = detailRes.body.data;
    if (
      d1.preferences &&
      Array.isArray(d1.preferences.hair) &&
      d1.preferences.hair.includes('Balayage') &&
      d1.preferences.nails.includes('Gel')
    ) {
      console.log('✓ Customer preferences accurately accessible to authorized staff:');
      console.log('  Hair:', d1.preferences.hair);
      console.log('  Nails:', d1.preferences.nails);
      console.log('  Skin:', d1.preferences.skin);
    } else {
      throw new Error('Authorized customer preferences missing or inaccurate');
    }

    if (d1.beautyQuiz && d1.beautyQuiz.archetype === 'Airy Volume & Sleek Defiance') {
      console.log('✓ Beauty consultation quiz archetype verified:', d1.beautyQuiz.archetype);
    } else {
      throw new Error('Beauty quiz details missing in customer detail payload');
    }

    // --- TEST 11: Cross-Branch Treatment History & Status Categorization ---
    console.log('\n--- TEST 11: Cross-Branch Treatment History & Status Categorization ---');
    const histRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer1GlobalId}/history`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (histRes.status === 200 && histRes.body.success) {
      console.log('✓ Customer History retrieved:');
      console.log('  Total Records:', histRes.body.counts.total);
      console.log('  Completed:', histRes.body.counts.completed);
      console.log('  Upcoming:', histRes.body.counts.upcoming);
      console.log('  Cancelled:', histRes.body.counts.cancelled);

      if (histRes.body.counts.completed !== 2 || histRes.body.counts.upcoming !== 1 || histRes.body.counts.cancelled !== 1) {
        throw new Error(`History status categorization incorrect: ${JSON.stringify(histRes.body.counts)}`);
      }

      const branchesInHist = histRes.body.data.map(h => h.branch ? h.branch.name : '').filter(Boolean);
      if (!branchesInHist.includes('MAISON — Bandra Flagship') || !branchesInHist.includes('MAISON — Khar West')) {
        throw new Error(`Cross-branch appointments not present in history: ${JSON.stringify(branchesInHist)}`);
      }
      console.log('✓ Cross-branch history verified across Bandra Flagship and Khar West');

      // Test Status Filter (?status=Completed)
      const completedHistRes = await request({
        method: 'GET',
        path: `/api/customers/admin/${customer1GlobalId}/history?status=Completed`,
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      if (completedHistRes.status === 200 && completedHistRes.body.data.length === 2) {
        console.log('✓ Filter ?status=Completed returned only the 2 completed treatments');
      } else {
        throw new Error('Filter ?status=Completed failed');
      }
    } else {
      throw new Error(`History retrieval failed: ${JSON.stringify(histRes.body)}`);
    }

    // --- TEST 12: Customers with Zero Visits Handled Safely ---
    console.log('\n--- TEST 12: Customers with Zero Visits Handled Gracefully ---');
    const zeroCustRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer3GlobalId}`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (zeroCustRes.status === 200 && zeroCustRes.body.success) {
      const zData = zeroCustRes.body.data;
      if (
        zData.retention.totalCompletedVisits === 0 &&
        zData.retention.lastCompletedVisit === null &&
        zData.retention.retentionStatus === 'No Visits' &&
        zData.retention.totalSpend === 0
      ) {
        console.log('✓ Zero-visit customer handled smoothly with default zero metrics and "No Visits" status');
      } else {
        throw new Error(`Zero-visit customer metrics incorrect: ${JSON.stringify(zData.retention)}`);
      }
    } else {
      throw new Error(`Zero-visit customer fetch failed: ${JSON.stringify(zeroCustRes.body)}`);
    }

    const zeroHistRes = await request({
      method: 'GET',
      path: `/api/customers/admin/${customer3GlobalId}/history`,
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (zeroHistRes.status === 200 && zeroHistRes.body.data.length === 0 && zeroHistRes.body.counts.total === 0) {
      console.log('✓ Zero-visit customer history returns empty array with 0 counts (HTTP 200)');
    } else {
      throw new Error(`Zero-visit customer history failed: ${JSON.stringify(zeroHistRes.body)}`);
    }

    // --- TEST 13: Invalid Customer Identifiers Handled Safely (HTTP 404) ---
    console.log('\n--- TEST 13: Invalid Customer Identifiers Handled Safely ---');
    const invalidDetailRes = await request({
      method: 'GET',
      path: '/api/customers/admin/CUST-NONEXISTENT-99999',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (invalidDetailRes.status === 404 && !invalidDetailRes.body.success) {
      console.log('✓ Invalid customerId rejected safely with HTTP 404:', invalidDetailRes.body.message);
    } else {
      throw new Error(`Invalid customerId was NOT rejected with 404: status ${invalidDetailRes.status}`);
    }

    const invalidHistRes = await request({
      method: 'GET',
      path: '/api/customers/admin/CUST-NONEXISTENT-99999/history',
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    if (invalidHistRes.status === 404 && !invalidHistRes.body.success) {
      console.log('✓ Invalid customerId on history rejected safely with HTTP 404');
    } else {
      throw new Error(`Invalid customerId on history was NOT rejected with 404: status ${invalidHistRes.status}`);
    }

    // --- TEST 14: Existing Customer Profile, Preferences, Journey & Quiz Unaffected ---
    console.log('\n--- TEST 14: Regression Check - Day 1-4 Endpoints Unaffected ---');
    const profileRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (profileRes.status === 200 && profileRes.body.data.customerId === customer1GlobalId) {
      console.log('✓ Day 1/2: GET /api/customers/profile operational');
    } else {
      throw new Error('Regression: Customer profile endpoint broken');
    }

    const prefsRes = await request({
      method: 'GET',
      path: '/api/customers/preferences',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (prefsRes.status === 200 && Array.isArray(prefsRes.body.data.hair)) {
      console.log('✓ Day 2: GET /api/customers/preferences operational');
    } else {
      throw new Error('Regression: Customer preferences endpoint broken');
    }

    const journeyRes = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (journeyRes.status === 200 && Array.isArray(journeyRes.body.data) && journeyRes.body.data.length === 2) {
      console.log('✓ Day 3: GET /api/customers/history operational (2 completed treatments)');
    } else {
      throw new Error('Regression: Customer beauty journey endpoint broken');
    }

    const quizRes = await request({
      method: 'GET',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });
    if (quizRes.status === 200 && (quizRes.body.data.profileArchetype === 'Airy Volume & Sleek Defiance' || quizRes.body.data.archetype === 'Airy Volume & Sleek Defiance')) {
      console.log('✓ Day 4: GET /api/customers/quiz operational');
    } else {
      throw new Error(`Regression: Customer beauty quiz endpoint broken: ${JSON.stringify(quizRes.body)}`);
    }

    // --- CLEANUP ---
    console.log('\n--- CLEANUP: Removing Day 5 Test Entities ---');
    await Appointment.deleteMany({ customerId: { $in: [customer1GlobalId, customer2GlobalId, customer3GlobalId] } });
    await QuizResult.deleteMany({ customerId: customer1GlobalId });
    await Customer.deleteMany({ customerId: { $in: [customer1GlobalId, customer2GlobalId, customer3GlobalId] } });
    await User.deleteMany({
      email: {
        $in: [
          adminEmail,
          bmEmail,
          cust1Email,
          cust2Email,
          cust3Email,
          `christian.${testTimestamp}@viora.com`,
          `jessica.${testTimestamp}@viora.com`
        ]
      }
    });
    await Stylist.deleteMany({ _id: { $in: [stylistBandra._id, stylistKhar._id] } });
    await Service.deleteMany({ _id: { $in: [serviceHair._id, serviceFacial._id] } });
    await Branch.deleteMany({ _id: { $in: [branchBandra._id, branchKhar._id, branchJuhu._id] } });
    console.log('✓ Day 5 test entities cleaned up successfully.');

    console.log('\n==================================================================');
    console.log('ALL DAY 5 TESTS PASSED SUCCESSFULLY! (14/14)');
    console.log('==================================================================\n');

  } catch (err) {
    console.error('\n❌ DAY 5 TEST SUITE FAILED:', err.message);
    process.exitCode = 1;
  } finally {
    if (server) {
      server.close();
    }
    await mongoose.connection.close();
    process.exit(process.exitCode || 0);
  }
}

runTests();
