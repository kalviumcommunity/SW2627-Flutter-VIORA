const mongoose = require('mongoose');
const http = require('http');
require('dotenv').config();

const app = require('../server');
const User = require('../models/User');
const Customer = require('../models/Customer');

const PORT = 5001; // separate test port
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

async function runTests() {
  console.log('====================================================');
  console.log('VIORA DAY 1 - CUSTOMER INTELLIGENCE TEST SUITE');
  console.log('====================================================\n');

  try {
    // 0. Connect DB & Start Server
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db';
    await mongoose.connect(mongoUri);
    console.log('✓ Connected to MongoDB');

    server = app.listen(PORT);
    console.log(`✓ Test server running on port ${PORT}\n`);

    const testEmail = `test.customer.${Date.now()}@example.com`;
    let authToken = '';
    let customerId = '';
    let userId = '';

    // Step 1: Register customer using authentication
    console.log('--- TEST 1: Register Customer ---');
    const registerRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Sarah Thomas',
        email: testEmail,
        password: 'Password@123',
        phone: '+91 9876543210',
        role: 'customer'
      }
    });

    if (registerRes.status === 201 && registerRes.body.success) {
      console.log('✓ Registration succeeded:', registerRes.body.message);
      authToken = registerRes.body.token;
      userId = registerRes.body.user.id;
      customerId = registerRes.body.user.customerId;
      console.log('✓ Generated global customerId:', customerId);
    } else {
      throw new Error(`Registration failed: ${JSON.stringify(registerRes.body)}`);
    }

    // Step 2: Login with registered customer
    console.log('\n--- TEST 2: Customer Login ---');
    const loginRes = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: {
        email: testEmail,
        password: 'Password@123'
      }
    });

    if (loginRes.status === 200 && loginRes.body.success && loginRes.body.token) {
      console.log('✓ Login succeeded. Token received.');
      authToken = loginRes.body.token;
    } else {
      throw new Error(`Login failed: ${JSON.stringify(loginRes.body)}`);
    }

    // Step 3: Verify User -> Customer relationship in database
    console.log('\n--- TEST 3: Verify User -> Customer Linkage ---');
    const customerDoc = await Customer.findOne({ userId });
    if (customerDoc && customerDoc.customerId === customerId) {
      console.log('✓ User -> Customer relationship verified in database.');
      console.log('  Customer Name:', customerDoc.name);
      console.log('  Customer Email:', customerDoc.email);
      console.log('  Customer ID:', customerDoc.customerId);
    } else {
      throw new Error('User -> Customer relationship not found in database');
    }

    // Step 4: GET /api/customers/profile
    console.log('\n--- TEST 4: GET /api/customers/profile ---');
    const getProfileRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    if (getProfileRes.status === 200 && getProfileRes.body.success) {
      const data = getProfileRes.body.data;
      console.log('✓ Retrieved profile successfully:');
      console.log('  customerId:', data.customerId);
      console.log('  name:', data.name);
      console.log('  email:', data.email);
      console.log('  phone:', data.phone);
      console.log('  preferences structure:', data.preferences);

      if (!data.preferences || typeof data.preferences !== 'object') {
        throw new Error('Preferences structure missing in profile response');
      }
    } else {
      throw new Error(`GET profile failed: ${JSON.stringify(getProfileRes.body)}`);
    }

    // Step 5: PUT /api/customers/profile (Update profile)
    console.log('\n--- TEST 5: PUT /api/customers/profile ---');
    const updateRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` },
      body: {
        name: 'Sarah Thomas Updated',
        phone: '+91 9999988888',
        dateOfBirth: '1996-08-25',
        profilePhoto: 'https://example.com/photos/sarah.jpg',
        preferences: {
          hair: ['Layered Cuts', 'Colour'],
          nails: ['Gel', 'French Tip'],
          skin: ['Hydration'],
          makeup: ['Natural Look']
        }
      }
    });

    if (updateRes.status === 200 && updateRes.body.success) {
      console.log('✓ Update request succeeded:', updateRes.body.message);
    } else {
      throw new Error(`PUT profile failed: ${JSON.stringify(updateRes.body)}`);
    }

    // Step 6: GET profile again to verify persistence
    console.log('\n--- TEST 6: Verify Persistence of Profile Updates ---');
    const verifyGetRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    const updatedData = verifyGetRes.body.data;
    if (
      updatedData.name === 'Sarah Thomas Updated' &&
      updatedData.phone === '+91 9999988888' &&
      updatedData.preferences.hair.includes('Layered Cuts') &&
      updatedData.preferences.nails.includes('Gel')
    ) {
      console.log('✓ Changes verified persisted in profile:');
      console.log('  Updated Name:', updatedData.name);
      console.log('  Updated Phone:', updatedData.phone);
      console.log('  Updated Preferences:', updatedData.preferences);
    } else {
      throw new Error('Profile updates were not properly persisted');
    }

    // Step 7: Preferences Foundation endpoints GET & PUT /api/customers/preferences
    console.log('\n--- TEST 7: Customer Preferences Foundation Endpoints ---');
    const getPrefRes = await request({
      method: 'GET',
      path: '/api/customers/preferences',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    if (getPrefRes.status === 200 && getPrefRes.body.success) {
      console.log('✓ GET /api/customers/preferences returned:', getPrefRes.body.data);
    } else {
      throw new Error(`GET preferences failed: ${JSON.stringify(getPrefRes.body)}`);
    }

    const updatePrefRes = await request({
      method: 'PUT',
      path: '/api/customers/preferences',
      headers: { Authorization: `Bearer ${authToken}` },
      body: {
        hair: ['Balayage', 'Keratin'],
        nails: ['Acrylic'],
        skin: ['Glow Facial'],
        makeup: ['Bridal']
      }
    });

    if (updatePrefRes.status === 200 && updatePrefRes.body.data.hair.includes('Balayage')) {
      console.log('✓ PUT /api/customers/preferences updated:', updatePrefRes.body.data);
    } else {
      throw new Error(`PUT preferences failed: ${JSON.stringify(updatePrefRes.body)}`);
    }

    // Step 8: Security - Unauthenticated access rejection
    console.log('\n--- TEST 8: Security - Unauthenticated Request Rejection ---');
    const unauthRes = await request({
      method: 'GET',
      path: '/api/customers/profile'
    });

    if (unauthRes.status === 401 && !unauthRes.body.success) {
      console.log('✓ Unauthenticated access correctly rejected with HTTP 401:', unauthRes.body.message);
    } else {
      throw new Error('Unauthenticated access was NOT rejected!');
    }

    // Step 9: Security - Tampering with customerId or userId rejection
    console.log('\n--- TEST 9: Security - Prevent customerId Tampering ---');
    const tamperRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` },
      body: {
        customerId: 'CUST-HACKED'
      }
    });

    if (tamperRes.status === 400 && !tamperRes.body.success) {
      console.log('✓ Tampering with customerId correctly rejected with HTTP 400:', tamperRes.body.message);
    } else {
      throw new Error('Tampering with customerId was NOT prevented!');
    }

    // Step 10: Duplicate registration prevention
    console.log('\n--- TEST 10: Duplicate Email Prevention ---');
    const duplicateRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Another User',
        email: testEmail,
        password: 'Password@123'
      }
    });

    if (duplicateRes.status === 400 && !duplicateRes.body.success) {
      console.log('✓ Duplicate registration correctly rejected with HTTP 400:', duplicateRes.body.message);
    } else {
      throw new Error('Duplicate registration was NOT rejected!');
    }

    // Cleanup test data
    console.log('\n--- CLEANUP: Removing Test Records ---');
    await Customer.deleteMany({ email: testEmail });
    await User.deleteMany({ email: testEmail });
    console.log('✓ Test user and customer records cleaned up successfully.');

    console.log('\n====================================================');
    console.log('ALL TESTS PASSED SUCCESSFULLY! (10/10)');
    console.log('====================================================\n');

  } catch (err) {
    console.error('\n❌ TEST SUITE FAILED:', err.message);
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
