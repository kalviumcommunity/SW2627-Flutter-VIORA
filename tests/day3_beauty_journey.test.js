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

const PORT = 5003; // Separate port for Day 3 test suite
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

async function runDay3Tests() {
  console.log('==================================================================');
  console.log('VIORA DAY 3 - MY BEAUTY JOURNEY & TREATMENT HISTORY TEST SUITE');
  console.log('==================================================================\n');

  try {
    // 1. Connect DB if not connected
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db');
      console.log('✓ Connected to MongoDB');
    }

    // 2. Start Test Server on port 5003
    await new Promise((resolve) => {
      server = app.listen(PORT, () => {
        console.log(`✓ Test server running on port ${PORT}\n`);
        resolve();
      });
    });

    // -------------------------------------------------------------------------
    // TEST 1: Frontend Static File Serving & UI Structure (Group 51.png)
    // -------------------------------------------------------------------------
    console.log('--- TEST 1: Frontend Static File Serving & UI Structure ---');
    const indexRes = await request({ method: 'GET', path: '/' });
    if (
      indexRes.status === 200 &&
      indexRes.rawBody &&
      indexRes.rawBody.includes('screenBeautyJourney') &&
      indexRes.rawBody.includes('My Beauty Journey') &&
      indexRes.rawBody.includes('pillFilterAll') &&
      indexRes.rawBody.includes('rebookModal')
    ) {
      console.log('✓ GET / successfully served index.html containing My Beauty Journey & Rebook UI');
    } else {
      throw new Error(`Failed to verify index.html UI markup: status ${indexRes.status}`);
    }

    const cssRes = await request({ method: 'GET', path: '/css/style.css' });
    if (
      cssRes.status === 200 &&
      cssRes.rawBody &&
      cssRes.rawBody.includes('treatment-card') &&
      cssRes.rawBody.includes('btn-rebook')
    ) {
      console.log('✓ GET /css/style.css successfully served Group 51.png treatment card styles');
    } else {
      throw new Error(`Failed to verify style.css: status ${cssRes.status}`);
    }

    const apiJsRes = await request({ method: 'GET', path: '/js/api.js' });
    if (
      apiJsRes.status === 200 &&
      apiJsRes.rawBody &&
      apiJsRes.rawBody.includes('getHistory') &&
      apiJsRes.rawBody.includes('getRebookContext')
    ) {
      console.log('✓ GET /js/api.js successfully served treatment history & rebook API client methods');
    } else {
      throw new Error(`Failed to verify api.js: status ${apiJsRes.status}`);
    }

    // -------------------------------------------------------------------------
    // TEST 2: Security - Unauthenticated Request Rejection
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 2: Security - Unauthenticated Request Rejection ---');
    const unauthRes = await request({ method: 'GET', path: '/api/customers/history' });
    if (unauthRes.status === 401 && !unauthRes.body.success) {
      console.log('✓ Unauthenticated GET /api/customers/history rejected with HTTP 401');
    } else {
      throw new Error(`Unauthenticated request was not rejected with 401: status ${unauthRes.status}`);
    }

    // -------------------------------------------------------------------------
    // SETUP TEST ENTITIES: Branches, Stylists, Services, Customers & Appointments
    // -------------------------------------------------------------------------
    console.log('\n--- SETUP: Provisioning Multi-Branch Test Data ---');
    const timestamp = Date.now();

    // Branch 1: MAISON — Bandra
    const branchBandra = await Branch.create({
      branchId: `BR-BANDRA-${timestamp}`,
      name: 'MAISON — Bandra',
      address: '14th Road, Bandra West, Mumbai',
      phone: '+91 22 2640 1001'
    });

    // Branch 2: MAISON — Khar West (Cross-branch location!)
    const branchKhar = await Branch.create({
      branchId: `BR-KHAR-${timestamp}`,
      name: 'MAISON — Khar West',
      address: 'Linking Road, Khar West, Mumbai',
      phone: '+91 22 2648 2002'
    });

    // Stylist 1 (User + Stylist Doc)
    const stylistUser1 = await User.create({
      name: 'Christian Dior',
      email: `christian.${timestamp}@viora.com`,
      phone: '+91 98201 11111',
      password: 'Password123!',
      role: 'stylist'
    });
    const stylist1 = await Stylist.create({
      stylistId: `STY-1-${timestamp}`,
      userId: stylistUser1._id,
      branchId: branchBandra._id,
      specialization: ['Hair', 'Balayage'],
      rating: 4.9
    });

    // Stylist 2 (User + Stylist Doc)
    const stylistUser2 = await User.create({
      name: 'Avani Sen',
      email: `avani.${timestamp}@viora.com`,
      phone: '+91 98202 22222',
      password: 'Password123!',
      role: 'stylist'
    });
    const stylist2 = await Stylist.create({
      stylistId: `STY-2-${timestamp}`,
      userId: stylistUser2._id,
      branchId: branchKhar._id,
      specialization: ['Nails', 'Gel Art'],
      rating: 4.8
    });

    // Services
    const serviceBalayage = await Service.create({
      serviceId: `SRV-BAL-${timestamp}`,
      branchId: branchBandra._id,
      name: 'Signature Balayage',
      price: 6500,
      duration: 120,
      category: 'Hair',
      availability: true
    });

    const serviceManicure = await Service.create({
      serviceId: `SRV-MAN-${timestamp}`,
      branchId: branchKhar._id,
      name: 'Chrome Gel Manicure',
      price: 1500,
      duration: 45,
      category: 'Nails',
      availability: true
    });

    const serviceFacial = await Service.create({
      serviceId: `SRV-FAC-${timestamp}`,
      branchId: branchBandra._id,
      name: 'Glow Hydrafacial',
      price: 3500,
      duration: 60,
      category: 'Skin',
      availability: true
    });

    // Customer 1: Registered Customer
    const regRes1 = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Sarah Sen',
        email: `sarah.journey.${timestamp}@maison.com`,
        phone: '+91 98200 12345',
        password: 'Password123!',
        role: 'customer'
      }
    });
    const tokenCustomer1 = regRes1.body.token;
    const customer1GlobalId = regRes1.body.user.customerId;
    const customer1UserId = regRes1.body.user.id;

    // Customer 2: Another Customer (for cross-customer isolation tests)
    const regRes2 = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Elena Rostova',
        email: `elena.${timestamp}@maison.com`,
        phone: '+91 98200 99999',
        password: 'Password123!',
        role: 'customer'
      }
    });
    const tokenCustomer2 = regRes2.body.token;
    const customer2GlobalId = regRes2.body.user.customerId;

    console.log(`✓ Provisioned Branches: ${branchBandra.name}, ${branchKhar.name}`);
    console.log(`✓ Customer 1 Global ID: ${customer1GlobalId}`);
    console.log(`✓ Customer 2 Global ID: ${customer2GlobalId}`);

    // -------------------------------------------------------------------------
    // TEST 3: Empty History Handling
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 3: Empty Treatment History Handling ---');
    const emptyRes = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${tokenCustomer1}` }
    });
    if (emptyRes.status === 200 && emptyRes.body.success && Array.isArray(emptyRes.body.data) && emptyRes.body.data.length === 0) {
      console.log('✓ New customer with no completed appointments returns HTTP 200 and empty data array');
    } else {
      throw new Error(`Empty history test failed: ${JSON.stringify(emptyRes.body)}`);
    }

    // -------------------------------------------------------------------------
    // SEED APPOINTMENTS FOR CUSTOMER 1 (Cross-Branch + Various Statuses)
    // -------------------------------------------------------------------------
    console.log('\n--- SEED: Inserting Cross-Branch Appointments ---');
    // Appt 1: Completed at Branch Bandra (Hair)
    const apptCompleted1 = await Appointment.create({
      appointmentId: `APPT-1-${timestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      stylistId: stylist1._id,
      serviceId: serviceBalayage._id,
      date: new Date('2023-10-14T11:00:00Z'),
      startTime: '11:00',
      endTime: '13:00',
      status: 'Completed'
    });

    // Appt 2: Completed at Branch Khar West (Nails) -> DIFFERENT BRANCH!
    const apptCompleted2 = await Appointment.create({
      appointmentId: `APPT-2-${timestamp}`,
      customerId: customer1GlobalId,
      branchId: branchKhar._id,
      stylistId: stylist2._id,
      serviceId: serviceManicure._id,
      date: new Date('2023-10-02T15:30:00Z'),
      startTime: '15:30',
      endTime: '16:15',
      status: 'Completed'
    });

    // Appt 3: Completed at Branch Bandra (Skin)
    const apptCompleted3 = await Appointment.create({
      appointmentId: `APPT-3-${timestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      stylistId: stylist1._id,
      serviceId: serviceFacial._id,
      date: new Date('2023-09-15T10:00:00Z'),
      startTime: '10:00',
      endTime: '11:00',
      status: 'Completed'
    });

    // Appt 4: CANCELLED appointment (Must NOT appear in treatment history!)
    const apptCancelled = await Appointment.create({
      appointmentId: `APPT-CANCEL-${timestamp}`,
      customerId: customer1GlobalId,
      branchId: branchBandra._id,
      stylistId: stylist1._id,
      serviceId: serviceBalayage._id,
      date: new Date('2023-09-20T14:00:00Z'),
      startTime: '14:00',
      endTime: '16:00',
      status: 'Cancelled'
    });

    // Appt 5: UPCOMING / CONFIRMED appointment (Must NOT appear in treatment history!)
    const apptUpcoming = await Appointment.create({
      appointmentId: `APPT-UPCOMING-${timestamp}`,
      customerId: customer1GlobalId,
      branchId: branchKhar._id,
      stylistId: stylist2._id,
      serviceId: serviceManicure._id,
      date: new Date('2023-11-05T16:00:00Z'),
      startTime: '16:00',
      endTime: '16:45',
      status: 'Confirmed'
    });

    // Appt for Customer 2: Completed at Branch Bandra (Must NOT appear in Customer 1 history!)
    await Appointment.create({
      appointmentId: `APPT-CUST2-${timestamp}`,
      customerId: customer2GlobalId,
      branchId: branchBandra._id,
      stylistId: stylist1._id,
      serviceId: serviceBalayage._id,
      date: new Date('2023-10-18T12:00:00Z'),
      startTime: '12:00',
      endTime: '14:00',
      status: 'Completed'
    });

    console.log('✓ Seeded 3 completed appointments across 2 branches, 1 cancelled, 1 confirmed, and 1 for Customer 2');

    // -------------------------------------------------------------------------
    // TEST 4: Cross-Branch Retrieval & Completed Only
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 4: Cross-Branch Retrieval & Distinction from Non-Completed ---');
    const historyRes = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${tokenCustomer1}` }
    });

    if (historyRes.status !== 200 || !historyRes.body.success) {
      throw new Error(`Failed to retrieve history: ${JSON.stringify(historyRes.body)}`);
    }

    const items = historyRes.body.data;
    console.log(`✓ Retrieved ${items.length} completed treatment records`);

    // Verify exactly 3 completed records returned
    if (items.length !== 3) {
      throw new Error(`Expected 3 completed records, got ${items.length}`);
    }

    // Verify cancelled appointment is NOT present
    const hasCancelled = items.some(i => i.appointmentId === apptCancelled.appointmentId || i.status === 'Cancelled');
    if (hasCancelled) {
      throw new Error('Cancelled appointment was found in treatment history!');
    }
    console.log('✓ Cancelled appointment correctly excluded from treatment history');

    // Verify confirmed/upcoming appointment is NOT present
    const hasUpcoming = items.some(i => i.appointmentId === apptUpcoming.appointmentId || i.status === 'Confirmed');
    if (hasUpcoming) {
      throw new Error('Upcoming appointment was found in treatment history!');
    }
    console.log('✓ Upcoming appointment correctly excluded from treatment history');

    // Verify cross-branch records exist
    const branchNames = new Set(items.map(i => i.branch.name));
    if (!branchNames.has('MAISON — Bandra') || !branchNames.has('MAISON — Khar West')) {
      throw new Error(`Expected records from both MAISON — Bandra and MAISON — Khar West, got: ${Array.from(branchNames).join(', ')}`);
    }
    console.log(`✓ Verified cross-branch treatments present across: ${Array.from(branchNames).join(' and ')}`);

    // -------------------------------------------------------------------------
    // TEST 5: Customer Isolation & Protection Against Tampering
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 5: Customer Identity Scope & Isolation ---');
    // Customer 2 requests history
    const cust2Res = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${tokenCustomer2}` }
    });
    if (cust2Res.status === 200 && cust2Res.body.data.length === 1 && cust2Res.body.data[0].appointmentId === `APPT-CUST2-${timestamp}`) {
      console.log('✓ Customer 2 retrieves only their own records (1 record)');
    } else {
      throw new Error(`Customer isolation failed: ${JSON.stringify(cust2Res.body)}`);
    }

    // Tampering test: Customer 2 tries to supply customerId of Customer 1 in query string
    const tamperRes = await request({
      method: 'GET',
      path: `/api/customers/history?customerId=${customer1GlobalId}`,
      headers: { Authorization: `Bearer ${tokenCustomer2}` }
    });
    if (tamperRes.body.data.length === 1 && tamperRes.body.customerId === customer2GlobalId) {
      console.log('✓ Security verified: customerId query param cannot bypass JWT identity derivation');
    } else {
      throw new Error('Tampering check failed: unauthorized records exposed!');
    }

    // -------------------------------------------------------------------------
    // TEST 6: Category Filtering (Hair, Nails, Skin)
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 6: Category Filtering (GET /api/customers/history?category=...) ---');
    const hairRes = await request({
      method: 'GET',
      path: '/api/customers/history?category=Hair',
      headers: { Authorization: `Bearer ${tokenCustomer1}` }
    });
    if (hairRes.body.count === 1 && hairRes.body.data[0].service.category === 'Hair') {
      console.log('✓ Filter ?category=Hair returned 1 record: ' + hairRes.body.data[0].service.name);
    } else {
      throw new Error(`Hair filter failed: ${JSON.stringify(hairRes.body)}`);
    }

    const nailsRes = await request({
      method: 'GET',
      path: '/api/customers/history?category=Nails',
      headers: { Authorization: `Bearer ${tokenCustomer1}` }
    });
    if (nailsRes.body.count === 1 && nailsRes.body.data[0].service.category === 'Nails') {
      console.log('✓ Filter ?category=Nails returned 1 record: ' + nailsRes.body.data[0].service.name);
    } else {
      throw new Error(`Nails filter failed: ${JSON.stringify(nailsRes.body)}`);
    }

    // -------------------------------------------------------------------------
    // TEST 7: Graceful Handling of Missing Optional References
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 7: Graceful Handling of Missing Optional Data ---');
    const fakeObjectId = new mongoose.Types.ObjectId();
    const apptWithMissingRefs = await Appointment.create({
      appointmentId: `APPT-ORPHAN-${timestamp}`,
      customerId: customer1GlobalId,
      branchId: fakeObjectId, // Non-existent branch
      stylistId: fakeObjectId, // Non-existent stylist
      serviceId: fakeObjectId, // Non-existent service
      date: new Date('2023-08-01T10:00:00Z'),
      startTime: '10:00',
      endTime: '11:00',
      status: 'Completed'
    });

    const robustRes = await request({
      method: 'GET',
      path: '/api/customers/history',
      headers: { Authorization: `Bearer ${tokenCustomer1}` }
    });
    if (robustRes.status === 200 && robustRes.body.success) {
      const orphanItem = robustRes.body.data.find(i => i.appointmentId === apptWithMissingRefs.appointmentId);
      if (orphanItem && orphanItem.branch.name && orphanItem.service.name && orphanItem.stylist.name) {
        console.log('✓ Orphaned/missing relations handled safely with default fallback values');
      } else {
        throw new Error('Fallback values not populated for orphan record');
      }
    } else {
      throw new Error(`Query crashed on missing relations: status ${robustRes.status}`);
    }

    // Clean up orphan appt
    await Appointment.deleteOne({ _id: apptWithMissingRefs._id });

    // -------------------------------------------------------------------------
    // TEST 8: Rebook Context API Integration
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 8: Rebook Context & Prefill Data (GET /api/customers/history/:id/rebook) ---');
    const countBeforeRebook = await Appointment.countDocuments();

    const rebookRes = await request({
      method: 'GET',
      path: `/api/customers/history/${apptCompleted1.appointmentId}/rebook`,
      headers: { Authorization: `Bearer ${tokenCustomer1}` }
    });

    if (rebookRes.status === 200 && rebookRes.body.success && rebookRes.body.data) {
      const rData = rebookRes.body.data;
      if (
        rData.service.name === 'Signature Balayage' &&
        rData.branch.name === 'MAISON — Bandra' &&
        rData.preferredStylist.name === 'Christian Dior' &&
        rData.service.available === true
      ) {
        console.log('✓ Rebook context correctly retrieved with service, branch, and stylist prefill');
      } else {
        throw new Error(`Rebook context data mismatch: ${JSON.stringify(rData)}`);
      }
    } else {
      throw new Error(`Rebook context failed: ${JSON.stringify(rebookRes.body)}`);
    }

    // -------------------------------------------------------------------------
    // TEST 9: Rebooking Does NOT Auto-Create/Confirm an Appointment
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 9: Rebook Safety - No Automatic Booking Creation ---');
    const countAfterRebook = await Appointment.countDocuments();
    if (countBeforeRebook === countAfterRebook) {
      console.log('✓ Verified: Rebook context retrieval did not create or mutate any appointment documents');
    } else {
      throw new Error(`Appointment count changed from ${countBeforeRebook} to ${countAfterRebook}!`);
    }

    // -------------------------------------------------------------------------
    // TEST 10: Rebooking Rejected for Non-Completed Appointments
    // -------------------------------------------------------------------------
    console.log('\n--- TEST 10: Rebook Rejection for Ineligible/Cancelled Appointments ---');
    const invalidRebookRes = await request({
      method: 'GET',
      path: `/api/customers/history/${apptCancelled.appointmentId}/rebook`,
      headers: { Authorization: `Bearer ${tokenCustomer1}` }
    });
    if (invalidRebookRes.status === 400 && !invalidRebookRes.body.success) {
      console.log('✓ Rebook request on cancelled appointment properly rejected with HTTP 400');
    } else {
      throw new Error(`Cancelled appointment rebook was not rejected: status ${invalidRebookRes.status}`);
    }

    // -------------------------------------------------------------------------
    // CLEANUP TEST RECORDS
    // -------------------------------------------------------------------------
    console.log('\n--- CLEANUP: Removing Day 3 Test Records ---');
    await Appointment.deleteMany({ appointmentId: { $regex: timestamp.toString() } });
    await Service.deleteMany({ serviceId: { $regex: timestamp.toString() } });
    await Stylist.deleteMany({ stylistId: { $regex: timestamp.toString() } });
    await Branch.deleteMany({ branchId: { $regex: timestamp.toString() } });
    await User.deleteMany({ email: { $regex: timestamp.toString() } });
    await Customer.deleteMany({ customerId: { $in: [customer1GlobalId, customer2GlobalId] } });
    console.log('✓ Day 3 test entities cleaned up successfully.');

    console.log('\n==================================================================');
    console.log('ALL DAY 3 TESTS PASSED SUCCESSFULLY! (10/10)');
    console.log('==================================================================\n');

  } catch (error) {
    console.error('\n❌ DAY 3 TEST FAILURE:', error);
    process.exitCode = 1;
  } finally {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }
  }
}

if (require.main === module) {
  runDay3Tests().then(() => {
    if (process.exitCode === 1) {
      process.exit(1);
    }
    process.exit(0);
  });
}

module.exports = runDay3Tests;
