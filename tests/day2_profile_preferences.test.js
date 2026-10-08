const mongoose = require('mongoose');
const http = require('http');
require('dotenv').config();

const app = require('../server');
const User = require('../models/User');
const Customer = require('../models/Customer');

const PORT = 5002; // Separate port for Day 2 test suite
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

async function runDay2Tests() {
  console.log('==================================================================');
  console.log('VIORA DAY 2 - CUSTOMER PROFILE & PREFERENCES TEST SUITE');
  console.log('==================================================================\n');

  try {
    // 1. Connect DB if not connected
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db');
      console.log('✓ Connected to MongoDB');
    }

    // 2. Start Test Server
    await new Promise((resolve) => {
      server = app.listen(PORT, () => {
        console.log(`✓ Test server running on port ${PORT}\n`);
        resolve();
      });
    });

    let authToken = '';
    let testCustomerId = '';
    const testEmail = `sarah.day2.${Date.now()}@maison.com`;

    // -------------------------------------------------------------------------
    // TEST 1: Frontend Static File Serving
    // -------------------------------------------------------------------------
    console.log('--- TEST 1: Frontend Static File Serving (public/) ---');
    const indexRes = await request({ method: 'GET', path: '/' });
    if (indexRes.status === 200 && indexRes.rawBody && indexRes.rawBody.includes('VIORA')) {
      console.log('✓ GET / successfully served index.html with VIORA container');
    } else {
      throw new Error(`Failed to serve index.html: status ${indexRes.status}`);
    }

    const cssRes = await request({ method: 'GET', path: '/css/style.css' });
    if (cssRes.status === 200 && cssRes.rawBody && cssRes.rawBody.includes('--color-bronze')) {
      console.log('✓ GET /css/style.css successfully served luxury design tokens');
    } else {
      throw new Error(`Failed to serve style.css: status ${cssRes.status}`);
    }

    const apiJsRes = await request({ method: 'GET', path: '/js/api.js' });
    if (apiJsRes.status === 200 && apiJsRes.rawBody && apiJsRes.rawBody.includes('VioraApiService')) {
      console.log('✓ GET /js/api.js successfully served API service layer');
    } else {
      throw new Error(`Failed to serve api.js: status ${apiJsRes.status}`);
    }

    const appJsRes = await request({ method: 'GET', path: '/js/app.js' });
    if (appJsRes.status === 200 && appJsRes.rawBody && appJsRes.rawBody.includes('screenPreferences')) {
      console.log('✓ GET /js/app.js successfully served frontend application controller\n');
    } else {
      throw new Error(`Failed to serve app.js: status ${appJsRes.status}`);
    }

    // -------------------------------------------------------------------------
    // TEST 2: Customer Registration & Token Generation
    // -------------------------------------------------------------------------
    console.log('--- TEST 2: Customer Registration & Authentication ---');
    const regRes = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Sarah Sen',
        email: testEmail,
        phone: '+91 98200 12345',
        password: 'Password123!',
        role: 'customer'
      }
    });

    if (regRes.status !== 201 || !regRes.body.token) {
      throw new Error(`Registration failed: ${JSON.stringify(regRes.body)}`);
    }
    authToken = regRes.body.token;
    testCustomerId = regRes.body.user.customerId;
    console.log(`✓ Registration succeeded. Token issued. Global customerId: ${testCustomerId}`);

    // Verify Login endpoint
    const loginRes = await request({
      method: 'POST',
      path: '/api/auth/login',
      body: {
        email: testEmail,
        password: 'Password123!'
      }
    });

    if (loginRes.status !== 200 || !loginRes.body.token) {
      throw new Error(`Login failed: ${JSON.stringify(loginRes.body)}`);
    }
    console.log('✓ Customer login verified. Token authentication operational.\n');

    // -------------------------------------------------------------------------
    // TEST 3: Customer Profile Loading (GET /api/customers/profile)
    // -------------------------------------------------------------------------
    console.log('--- TEST 3: Customer Profile Loading (GET /api/customers/profile) ---');
    const profileRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    if (profileRes.status !== 200 || !profileRes.body.success) {
      throw new Error(`Profile fetch failed: ${JSON.stringify(profileRes.body)}`);
    }

    const profileData = profileRes.body.data;
    if (
      profileData.name !== 'Sarah Sen' ||
      profileData.email !== testEmail ||
      profileData.customerId !== testCustomerId
    ) {
      throw new Error(`Profile data mismatch: ${JSON.stringify(profileData)}`);
    }
    console.log('✓ Profile loaded successfully:');
    console.log(`  Name: ${profileData.name}`);
    console.log(`  Email: ${profileData.email}`);
    console.log(`  Phone: ${profileData.phone}`);
    console.log(`  Customer ID: ${profileData.customerId}\n`);

    // -------------------------------------------------------------------------
    // TEST 4: Customer Profile Editing & Saving (PUT /api/customers/profile)
    // -------------------------------------------------------------------------
    console.log('--- TEST 4: Profile Editing & Updating (PUT /api/customers/profile) ---');
    const updateRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` },
      body: {
        name: 'Sarah Sen Luxury',
        phone: '+91 99887 76655',
        dateOfBirth: '1996-05-18T00:00:00.000Z',
        profilePhoto: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300'
      }
    });

    if (updateRes.status !== 200 || !updateRes.body.success) {
      throw new Error(`Profile update failed: ${JSON.stringify(updateRes.body)}`);
    }
    console.log('✓ Profile updated successfully with permitted fields.');

    // Verify persistence
    const recheckProfile = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    const updated = recheckProfile.body.data;
    if (
      updated.name !== 'Sarah Sen Luxury' ||
      updated.phone !== '+91 99887 76655' ||
      !updated.dateOfBirth.startsWith('1996-05-18') ||
      !updated.profilePhoto.includes('photo-1517841905240')
    ) {
      throw new Error(`Updated values did not persist: ${JSON.stringify(updated)}`);
    }
    console.log('✓ Verified updated fields persisted in database.\n');

    // -------------------------------------------------------------------------
    // TEST 5: Security Protection - Immutable customerId Tampering Prevention
    // -------------------------------------------------------------------------
    console.log('--- TEST 5: Security Protection - Immutable customerId Tampering ---');
    const tamperRes = await request({
      method: 'PUT',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` },
      body: {
        customerId: 'CUST-HACKED-9999',
        name: 'Malicious Edit'
      }
    });

    if (tamperRes.status === 400 && tamperRes.body.message.includes('not permitted')) {
      console.log('✓ Security check passed: customerId tampering rejected with HTTP 400.\n');
    } else {
      throw new Error(`Security vulnerability: customerId modification was not rejected! Status: ${tamperRes.status}`);
    }

    // -------------------------------------------------------------------------
    // TEST 6: Personal Preferences Loading (GET /api/customers/preferences)
    // -------------------------------------------------------------------------
    console.log('--- TEST 6: Personal Preferences Loading (GET /api/customers/preferences) ---');
    const getPrefsRes = await request({
      method: 'GET',
      path: '/api/customers/preferences',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    if (getPrefsRes.status !== 200 || !getPrefsRes.body.success) {
      throw new Error(`Preferences fetch failed: ${JSON.stringify(getPrefsRes.body)}`);
    }
    console.log('✓ Initial preferences retrieved successfully:');
    console.log(`  Categories present: ${Object.keys(getPrefsRes.body.data).join(', ')}\n`);

    // -------------------------------------------------------------------------
    // TEST 7: Personal Preferences Updating & Persistence (PUT /api/customers/preferences)
    // -------------------------------------------------------------------------
    console.log('--- TEST 7: Personal Preferences Updating & Persistence ---');
    const updatedPreferencesPayload = {
      hair: ['Layered Cuts', 'Balayage', 'Keratin'],
      nails: ['Gel', 'French Tip', 'Chrome'],
      skin: ['Hydration', 'Glow Facial'],
      makeup: ['Natural Look', 'HD Airbrush']
    };

    const updatePrefsRes = await request({
      method: 'PUT',
      path: '/api/customers/preferences',
      headers: { Authorization: `Bearer ${authToken}` },
      body: updatedPreferencesPayload
    });

    if (updatePrefsRes.status !== 200 || !updatePrefsRes.body.success) {
      throw new Error(`Preferences update failed: ${JSON.stringify(updatePrefsRes.body)}`);
    }
    console.log('✓ Preferences updated via PUT /api/customers/preferences');

    // Verify persistence via GET /api/customers/preferences
    const verifyPrefsRes = await request({
      method: 'GET',
      path: '/api/customers/preferences',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    const savedPrefs = verifyPrefsRes.body.data;
    if (
      savedPrefs.hair.length !== 3 ||
      savedPrefs.nails.length !== 3 ||
      savedPrefs.skin.length !== 2 ||
      savedPrefs.makeup.length !== 2
    ) {
      throw new Error(`Preferences persistence mismatch: ${JSON.stringify(savedPrefs)}`);
    }
    console.log('✓ Verified 4 categories persisted accurately:');
    console.log(`  Hair: [${savedPrefs.hair.join(', ')}]`);
    console.log(`  Nails: [${savedPrefs.nails.join(', ')}]`);
    console.log(`  Skin: [${savedPrefs.skin.join(', ')}]`);
    console.log(`  Makeup: [${savedPrefs.makeup.join(', ')}]\n`);

    // -------------------------------------------------------------------------
    // TEST 8: Customer Profile Reflection of Preferences
    // -------------------------------------------------------------------------
    console.log('--- TEST 8: Customer Profile Reflects Preferences ---');
    const syncProfileRes = await request({
      method: 'GET',
      path: '/api/customers/profile',
      headers: { Authorization: `Bearer ${authToken}` }
    });

    if (
      syncProfileRes.body.data.preferences.hair.length === 3 &&
      syncProfileRes.body.data.preferences.nails.length === 3
    ) {
      console.log('✓ GET /api/customers/profile returns synchronized preferences object\n');
    } else {
      throw new Error('Profile did not reflect updated preferences!');
    }

    // -------------------------------------------------------------------------
    // TEST 9: Security - Unauthenticated Request Rejections
    // -------------------------------------------------------------------------
    console.log('--- TEST 9: Security - Unauthenticated Request Rejection ---');
    const unauthProfileRes = await request({
      method: 'GET',
      path: '/api/customers/profile'
    });
    if (unauthProfileRes.status !== 401) {
      throw new Error(`Expected 401, got ${unauthProfileRes.status}`);
    }

    const unauthPrefsRes = await request({
      method: 'GET',
      path: '/api/customers/preferences'
    });
    if (unauthPrefsRes.status !== 401) {
      throw new Error(`Expected 401, got ${unauthPrefsRes.status}`);
    }
    console.log('✓ Unauthenticated requests properly rejected with HTTP 401\n');

    // -------------------------------------------------------------------------
    // CLEANUP
    // -------------------------------------------------------------------------
    console.log('--- CLEANUP: Removing Day 2 Test Records ---');
    await Customer.deleteOne({ email: testEmail });
    await User.deleteOne({ email: testEmail });
    console.log('✓ Test records cleaned up.\n');

    console.log('==================================================================');
    console.log('ALL DAY 2 TESTS PASSED SUCCESSFULLY! (9/9)');
    console.log('==================================================================');
  } catch (error) {
    console.error('\n❌ DAY 2 TEST SUITE FAILED:', error);
    process.exitCode = 1;
  } finally {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
    }
  }
}

runDay2Tests();
