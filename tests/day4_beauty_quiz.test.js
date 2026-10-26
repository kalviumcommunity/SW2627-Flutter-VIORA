const mongoose = require('mongoose');
const http = require('http');
require('dotenv').config();

const app = require('../server');
const User = require('../models/User');
const Customer = require('../models/Customer');
const Branch = require('../models/Branch');
const Stylist = require('../models/Stylist');
const Service = require('../models/Service');
const QuizResult = require('../models/QuizResult');
const {
  determineArchetypeAndSummary,
  matchProducts,
  matchStylists,
  validateQuizAnswers
} = require('../services/recommendationService');

const PORT = 5004; // Separate test port for Day 4 test suite
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

async function runDay4Tests() {
  console.log('==================================================================');
  console.log('VIORA DAY 4 - BEAUTY QUIZ & PERSONALIZED RECOMMENDATIONS TEST SUITE');
  console.log('==================================================================\n');

  const timestamp = Date.now();
  let customer1Token = '';
  let customer1Id = '';
  let customer1UserId = '';

  let customer2Token = '';
  let customer2Id = '';
  let customer2UserId = '';

  try {
    // 0. Connect DB & Start Server
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/viora_db';
    await mongoose.connect(mongoUri);
    console.log('✓ Connected to MongoDB');

    server = app.listen(PORT);
    console.log(`✓ Test server running on port ${PORT}\n`);

    // --- TEST 1: Frontend Static File Serving & UI Structure ---
    console.log('--- TEST 1: Frontend Static File Serving & Day 4 UI Structure ---');
    const indexRes = await request({ method: 'GET', path: '/' });
    if (
      indexRes.status === 200 &&
      indexRes.rawBody.includes('screenBeautyQuiz') &&
      indexRes.rawBody.includes('screenQuizResults') &&
      indexRes.rawBody.includes('tileBeautyProfile') &&
      indexRes.rawBody.includes('prescribedProductsGrid')
    ) {
      console.log('✓ GET / successfully served index.html containing Beauty Quiz and Results screens');
    } else {
      throw new Error('index.html is missing Day 4 UI screens or containers');
    }

    const cssRes = await request({ method: 'GET', path: '/css/style.css' });
    if (
      cssRes.status === 200 &&
      cssRes.rawBody.includes('quiz-option-card') &&
      cssRes.rawBody.includes('prescribed-products-grid') &&
      cssRes.rawBody.includes('btn-retake-quiz')
    ) {
      console.log('✓ GET /css/style.css successfully served Group 52.png & Group 53.png styling');
    } else {
      throw new Error('style.css is missing Day 4 quiz or recommendation styles');
    }

    const jsApiRes = await request({ method: 'GET', path: '/js/api.js' });
    if (
      jsApiRes.status === 200 &&
      jsApiRes.rawBody.includes('getQuizQuestions') &&
      jsApiRes.rawBody.includes('submitQuiz') &&
      jsApiRes.rawBody.includes('getQuizResult')
    ) {
      console.log('✓ GET /js/api.js successfully served Day 4 API client methods');
    } else {
      throw new Error('api.js is missing Day 4 client methods');
    }

    const jsAppRes = await request({ method: 'GET', path: '/js/app.js' });
    if (
      jsAppRes.status === 200 &&
      jsAppRes.rawBody.includes('function escapeHtml') &&
      jsAppRes.rawBody.includes('window.escapeHtml = escapeHtml')
    ) {
      console.log('✓ GET /js/app.js successfully served safe escapeHtml sanitization helper');

      // Execute actual served app.js in VM sandbox to exercise the real production implementation
      const vm = require('vm');
      const sandbox = { window: {}, document: { addEventListener: () => {} } };
      vm.createContext(sandbox);
      vm.runInContext(jsAppRes.rawBody, sandbox);

      const fn = sandbox.window.escapeHtml;
      if (typeof fn !== 'function') throw new Error('escapeHtml was not exposed on window by served app.js');

      // Test 1: Ampersands, less-than, greater-than, double and single quotes
      if (fn('&') !== '&amp;') throw new Error('escapeHtml failed & escaping');
      if (fn('<') !== '&lt;') throw new Error('escapeHtml failed < escaping');
      if (fn('>') !== '&gt;') throw new Error('escapeHtml failed > escaping');
      if (fn('"') !== '&quot;') throw new Error('escapeHtml failed " escaping');
      if (fn("'") !== '&#039;') throw new Error('escapeHtml failed \' escaping');

      // Test 2: Full XSS-style input containing HTML tags and quotes
      const xssInput = `<script>alert("test & 'xss'")</script>`;
      const expectedOutput = `&lt;script&gt;alert(&quot;test &amp; &#039;xss&#039;&quot;)&lt;/script&gt;`;
      if (fn(xssInput) !== expectedOutput) {
        throw new Error(`escapeHtml failed XSS payload escaping. Got: ${fn(xssInput)}`);
      }

      // Test 3: null and undefined handling
      if (fn(null) !== '') throw new Error('escapeHtml failed null safety check (expected empty string)');
      if (fn(undefined) !== '') throw new Error('escapeHtml failed undefined safety check (expected empty string)');

      // Test 4: Numbers and booleans
      if (fn(0) !== '0') throw new Error('escapeHtml failed numeric 0 conversion');
      if (fn(1500) !== '1500') throw new Error('escapeHtml failed number conversion');
      if (fn(false) !== 'false') throw new Error('escapeHtml failed boolean false conversion');
      if (fn(true) !== 'true') throw new Error('escapeHtml failed boolean true conversion');

      console.log('✓ Production escapeHtml sanitization helper thoroughly verified (XSS characters, null/undefined, numbers, booleans)');
    } else {
      throw new Error('app.js is missing escapeHtml helper definition');
    }

    // --- TEST 2: Security - Unauthenticated Request Rejection ---
    console.log('\n--- TEST 2: Security - Unauthenticated Request Rejection ---');
    const unauthQuizRes = await request({ method: 'GET', path: '/api/customers/quiz' });
    if (unauthQuizRes.status === 401 && !unauthQuizRes.body.success) {
      console.log('✓ Unauthenticated GET /api/customers/quiz rejected with HTTP 401');
    } else {
      throw new Error('Unauthenticated GET quiz was not rejected!');
    }

    const unauthPostRes = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      body: { hairType: 'Straight' }
    });
    if (unauthPostRes.status === 401 && !unauthPostRes.body.success) {
      console.log('✓ Unauthenticated POST /api/customers/quiz rejected with HTTP 401');
    } else {
      throw new Error('Unauthenticated POST quiz was not rejected!');
    }

    // --- SETUP: Provision Customers, Branches, Stylists & Services ---
    console.log('\n--- SETUP: Provisioning Customers & Salon Specialists ---');
    // Customer 1
    const reg1 = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Sarah Sen',
        email: `sarah.quiz.${timestamp}@example.com`,
        password: 'Password@123',
        phone: '+91 98200 12345',
        role: 'customer'
      }
    });
    customer1Token = reg1.body.token;
    customer1Id = reg1.body.user.customerId;
    customer1UserId = reg1.body.user.id;

    // Customer 2
    const reg2 = await request({
      method: 'POST',
      path: '/api/auth/register',
      body: {
        name: 'Elena Gilbert',
        email: `elena.quiz.${timestamp}@example.com`,
        password: 'Password@123',
        phone: '+91 98111 22233',
        role: 'customer'
      }
    });
    customer2Token = reg2.body.token;
    customer2Id = reg2.body.user.customerId;
    customer2UserId = reg2.body.user.id;

    console.log(`✓ Customer 1: ${customer1Id} (${reg1.body.user.email})`);
    console.log(`✓ Customer 2: ${customer2Id} (${reg2.body.user.email})`);

    // Seed Branch
    const testBranch = await Branch.create({
      branchId: `BR-DAY4-${timestamp}`,
      name: 'MAISON — Bandra Flagship',
      address: 'Pali Hill, Bandra West, Mumbai',
      phone: '+91 22 2640 1234'
    });

    // Seed Stylist 1: Specializes in Balayage, Volume & Lift
    const stylistUser1 = await User.create({
      name: 'Christian Dior',
      email: `christian.stylist.${timestamp}@example.com`,
      password: 'Password@123',
      role: 'stylist'
    });
    const stylist1 = await Stylist.create({
      stylistId: `STY-DAY4-1-${timestamp}`,
      userId: stylistUser1._id,
      branchId: testBranch._id,
      specialization: ['Balayage', 'Volume & Lift', 'Frizz Control'],
      experience: 8,
      rating: 4.9
    });

    // Seed Stylist 2: Specializes in Skin Hydration & Glow Facials
    const stylistUser2 = await User.create({
      name: 'Jessica Alba',
      email: `jessica.stylist.${timestamp}@example.com`,
      password: 'Password@123',
      role: 'stylist'
    });
    const stylist2 = await Stylist.create({
      stylistId: `STY-DAY4-2-${timestamp}`,
      userId: stylistUser2._id,
      branchId: testBranch._id,
      specialization: ['Deep Hydration', 'Glow Facial', 'Clean Care'],
      experience: 6,
      rating: 4.8
    });

    // Seed Service
    const service1 = await Service.create({
      serviceId: `SRV-DAY4-1-${timestamp}`,
      branchId: testBranch._id,
      name: 'Signature Volume Haircut & Gloss',
      description: 'Custom contour layering for bounce and lift.',
      duration: 50,
      price: 2200,
      category: 'Hair',
      availability: true
    });

    console.log('✓ Seeded Branch, Stylists & Services for recommendation testing');

    // --- TEST 3: Quiz Questions Schema Endpoint ---
    console.log('\n--- TEST 3: GET /api/customers/quiz/questions ---');
    const questionsRes = await request({
      method: 'GET',
      path: '/api/customers/quiz/questions',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });

    if (questionsRes.status === 200 && questionsRes.body.success && Array.isArray(questionsRes.body.data)) {
      const qList = questionsRes.body.data;
      console.log(`✓ Retrieved ${qList.length} standardized quiz questions`);

      if (qList.length !== 5) {
        throw new Error(`Expected 5 quiz questions, got ${qList.length}`);
      }

      // Check Step 2 matches Group 52.png
      const step2 = qList.find((q) => q.stepNumber === 2);
      if (!step2 || step2.title !== 'What is your primary hair concern?') {
        throw new Error('Step 2 question does not match Group 52.png');
      }

      const optTitles = step2.options.map((o) => o.title);
      if (
        !optTitles.includes('Frizz Control') ||
        !optTitles.includes('Volume & Lift') ||
        !optTitles.includes('Color Maintenance') ||
        !optTitles.includes('Damage Repair') ||
        !optTitles.includes('Scalp Health')
      ) {
        throw new Error('Step 2 options do not match Group 52.png requirements');
      }
      console.log('✓ Step 2 verified matching Group 52.png options:', optTitles.join(', '));
    } else {
      throw new Error(`GET /api/customers/quiz/questions failed: ${JSON.stringify(questionsRes.body)}`);
    }

    // --- TEST 4: Validation of Incomplete and Invalid Submissions ---
    console.log('\n--- TEST 4: Validation of Incomplete Submissions (POST /api/customers/quiz) ---');
    // Missing hairType
    const valRes1 = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        hairConcerns: ['Frizz Control'],
        skinType: 'Combination',
        goals: ['Deep Hydration']
      }
    });
    if (valRes1.status === 400 && !valRes1.body.success) {
      console.log('✓ Rejection of missing hairType verified (HTTP 400):', valRes1.body.errors);
    } else {
      throw new Error('Missing hairType was not rejected!');
    }

    // Empty hairConcerns array
    const valRes2 = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        hairType: '2B Wavy',
        hairConcerns: [],
        skinType: 'Combination',
        goals: ['Deep Hydration']
      }
    });
    if (valRes2.status === 400 && !valRes2.body.success) {
      console.log('✓ Rejection of empty hairConcerns verified (HTTP 400):', valRes2.body.errors);
    } else {
      throw new Error('Empty hairConcerns was not rejected!');
    }

    // Missing skinType
    const valRes3 = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        hairType: '2B Wavy',
        hairConcerns: ['Frizz Control'],
        goals: ['Deep Hydration']
      }
    });
    if (valRes3.status === 400 && !valRes3.body.success) {
      console.log('✓ Rejection of missing skinType verified (HTTP 400):', valRes3.body.errors);
    } else {
      throw new Error('Missing skinType was not rejected!');
    }

    // Empty goals
    const valRes4 = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: {
        hairType: '2B Wavy',
        hairConcerns: ['Frizz Control'],
        skinType: 'Combination',
        goals: []
      }
    });
    if (valRes4.status === 400 && !valRes4.body.success) {
      console.log('✓ Rejection of empty goals verified (HTTP 400):', valRes4.body.errors);
    } else {
      throw new Error('Empty goals was not rejected!');
    }

    // --- TEST 5: Successful Quiz Submission & Deterministic Scoring ---
    console.log('\n--- TEST 5: Successful Quiz Submission & Deterministic Scoring ---');
    // Payload matching Group 52.png & Group 53.png: 2B Wavy + Volume + Frizz + Combination
    const submissionPayload = {
      hairType: '2B Wavy',
      hairConcerns: ['Volume & Lift', 'Frizz Control'],
      skinType: 'Combination',
      goals: ['Deep Hydration', 'Radiant Glow'],
      sensitivities: ['Sulfate & Paraben Free', 'Vegan & Cruelty-Free']
    };

    const submitRes = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: submissionPayload
    });

    if (submitRes.status === 201 && submitRes.body.success && submitRes.body.data) {
      const qResult = submitRes.body.data;
      console.log('✓ Quiz submission succeeded (HTTP 201):', submitRes.body.message);
      console.log('  Customer ID:', qResult.customerId);
      console.log('  Archetype:', qResult.profileArchetype);
      console.log('  Summary:', qResult.summary);
      console.log('  Profile Chips:', qResult.profileChips);

      // Verify profile chips match Group 53.png
      if (
        !qResult.profileChips.includes('Hair: 2B Wavy') ||
        !qResult.profileChips.includes('Skin: Combination') ||
        !qResult.profileChips.some((c) => c.includes('Volume')) ||
        !qResult.profileChips.some((c) => c.includes('Frizz'))
      ) {
        throw new Error('Profile chips do not match expected answers');
      }

      // Check Customer.preferences synchronization
      const updatedCustomerDoc = await Customer.findOne({ customerId: customer1Id });
      if (
        updatedCustomerDoc.preferences.hair.includes('Volume & Lift') &&
        updatedCustomerDoc.preferences.hair.includes('Frizz Control') &&
        updatedCustomerDoc.preferences.skin.includes('Combination')
      ) {
        console.log('✓ Customer.preferences automatically synchronized with quiz concerns');
      } else {
        throw new Error('Customer.preferences was not synchronized with quiz answers');
      }
    } else {
      throw new Error(`POST /api/customers/quiz failed: ${JSON.stringify(submitRes.body)}`);
    }

    // --- TEST 6: Persistence & Retrieval of Quiz Results (GET /api/customers/quiz) ---
    console.log('\n--- TEST 6: GET /api/customers/quiz (Result Persistence) ---');
    const getQuizRes = await request({
      method: 'GET',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });

    if (getQuizRes.status === 200 && getQuizRes.body.success && getQuizRes.body.data) {
      const resData = getQuizRes.body.data;
      console.log('✓ Retrieved persisted QuizResult successfully:');
      console.log('  Profile Archetype:', resData.profileArchetype);
      console.log('  Recommended Products Count:', resData.recommendations.products.length);
      console.log('  Recommended Stylists Count:', resData.recommendations.stylists.length);
      console.log('  Recommended Services Count:', resData.recommendations.services.length);

      if (resData.customerId !== customer1Id) {
        throw new Error('Persisted quiz customerId mismatch');
      }
    } else {
      throw new Error(`GET /api/customers/quiz failed: ${JSON.stringify(getQuizRes.body)}`);
    }

    // --- TEST 7: Suitable Product Recommendations Matching ---
    console.log('\n--- TEST 7: Suitable Product Recommendations Matching ---');
    const products = getQuizRes.body.data.recommendations.products;
    const prodNames = products.map((p) => p.name);
    console.log('  Matched Products:', prodNames.join(' | '));

    // Verify Group 53.png items: "Maison Revital Serum" and "Volumizing Sea Spray"
    if (!prodNames.includes('Maison Revital Serum') || !prodNames.includes('Volumizing Sea Spray')) {
      throw new Error('Prescribed products did not include Maison Revital Serum or Volumizing Sea Spray');
    }

    // Verify match reason is present and meaningful
    products.forEach((p) => {
      if (!p.matchReason || typeof p.matchReason !== 'string' || p.matchReason.length < 10) {
        throw new Error(`Missing or inadequate matchReason for product: ${p.name}`);
      }
    });
    console.log('✓ Product match explanations verified:');
    console.log(`  "${products[0].name}": ${products[0].matchReason}`);

    // Verify sensitivity filtering: customer requested Sulfate & Paraben Free, Vegan & Cruelty-Free
    products.forEach((p) => {
      if (!p.features.includes('Sulfate & Paraben Free') || !p.features.includes('Vegan & Cruelty-Free')) {
        throw new Error(`Product ${p.name} violated customer sensitivities`);
      }
    });
    console.log('✓ Sensitivity filtering verified (all matched products adhere to customer restrictions)');

    // --- TEST 8: Personalized Stylist Recommendations Matching ---
    console.log('\n--- TEST 8: Personalized Stylist Recommendations Matching ---');
    const stylists = getQuizRes.body.data.recommendations.stylists;
    if (stylists.length === 0) {
      throw new Error('Expected at least 1 stylist recommendation');
    }

    console.log(`✓ Stylist recommendations returned ${stylists.length} specialists:`);
    stylists.forEach((st) => {
      console.log(`  - ${st.name} (Rating: ${st.rating}★, Branch: ${st.branchName})`);
      console.log(`    Reason: ${st.matchReason}`);
    });

    // Christian Dior specializes in Balayage, Volume & Lift -> should be top match
    const topStylist = stylists[0];
    if (!topStylist.name.includes('Christian Dior')) {
      console.log('Notice: Top stylist was:', topStylist.name);
    } else {
      console.log('✓ Highest scoring stylist matched correctly based on specialization:', topStylist.name);
    }

    // --- TEST 9: Customer Data Isolation & Authorization Scope ---
    console.log('\n--- TEST 9: Customer Data Isolation & Authorization Scope ---');
    // Customer 2 hasn't taken quiz yet -> should return null
    const c2QuizRes = await request({
      method: 'GET',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer2Token}` }
    });

    if (c2QuizRes.status === 200 && c2QuizRes.body.success && c2QuizRes.body.data === null) {
      console.log('✓ Customer 2 gets null quiz result (cannot access Customer 1 data)');
    } else {
      throw new Error('Customer 2 erroneously received quiz data belonging to Customer 1!');
    }

    // Check GET /api/customers/recommendations for Customer 2 provides baseline fallback
    const c2RecRes = await request({
      method: 'GET',
      path: '/api/customers/recommendations',
      headers: { Authorization: `Bearer ${customer2Token}` }
    });

    if (c2RecRes.status === 200 && c2RecRes.body.success && c2RecRes.body.source === 'preferences_baseline') {
      console.log('✓ Customer 2 recommendations graceful baseline fallback verified');
    } else {
      throw new Error('Customer 2 recommendations baseline failed');
    }

    // --- TEST 10: Retaking Quiz & Score Recalculation ---
    console.log('\n--- TEST 10: Retaking Beauty Quiz & Score Recalculation ---');
    // Retake request
    const retakeInitRes = await request({
      method: 'POST',
      path: '/api/customers/quiz/retake',
      headers: { Authorization: `Bearer ${customer1Token}` }
    });

    if (retakeInitRes.status === 200 && retakeInitRes.body.success) {
      console.log('✓ POST /api/customers/quiz/retake acknowledged');
    } else {
      throw new Error('Retake initialization failed');
    }

    // Customer 1 re-submits with different concerns: Damage Repair & Color Maintenance
    const retakePayload = {
      hairType: 'Curly',
      hairConcerns: ['Damage Repair', 'Color Maintenance'],
      skinType: 'Dry & Dehydrated',
      goals: ['Bond Fortification', 'Deep Hydration'],
      sensitivities: ['Ammonia / Bleach Sensitive', 'Sulfate & Paraben Free']
    };

    const retakeSubmitRes = await request({
      method: 'POST',
      path: '/api/customers/quiz',
      headers: { Authorization: `Bearer ${customer1Token}` },
      body: retakePayload
    });

    if (retakeSubmitRes.status === 201 && retakeSubmitRes.body.success) {
      const updatedResult = retakeSubmitRes.body.data;
      console.log('✓ Retake submission processed successfully');
      console.log('  Updated Archetype:', updatedResult.profileArchetype);
      console.log('  Retake Count:', updatedResult.retakeCount);

      if (updatedResult.retakeCount !== 1) {
        throw new Error(`Expected retakeCount to be 1, got ${updatedResult.retakeCount}`);
      }

      // Products should now prioritize Keratin Bond Fortify Masque
      const updatedProdNames = updatedResult.recommendations.products.map((p) => p.name);
      console.log('  Updated Matched Products:', updatedProdNames.join(' | '));
      if (!updatedProdNames.includes('Keratin Bond Fortify Masque')) {
        throw new Error('Damage & Color retake did not recommend Keratin Bond Fortify Masque');
      }
      console.log('✓ Product recommendations dynamically updated to reflect new answers');
    } else {
      throw new Error('Retake submission failed');
    }

    // --- CLEANUP ---
    console.log('\n--- CLEANUP: Removing Day 4 Test Records ---');
    await QuizResult.deleteMany({ customerId: { $in: [customer1Id, customer2Id] } });
    await Customer.deleteMany({ customerId: { $in: [customer1Id, customer2Id] } });
    await User.deleteMany({ email: { $regex: timestamp.toString() } });
    await Stylist.deleteMany({ stylistId: { $regex: timestamp.toString() } });
    await Service.deleteMany({ serviceId: { $regex: timestamp.toString() } });
    await Branch.deleteMany({ branchId: { $regex: timestamp.toString() } });
    console.log('✓ Day 4 test entities cleaned up successfully.');

    console.log('\n==================================================================');
    console.log('ALL DAY 4 TESTS PASSED SUCCESSFULLY! (10/10)');
    console.log('==================================================================\n');

  } catch (err) {
    console.error('\n❌ DAY 4 TEST SUITE FAILED:', err.message);
    process.exitCode = 1;
  } finally {
    if (server) {
      server.close();
    }
    await mongoose.connection.close();
    process.exit(process.exitCode || 0);
  }
}

runDay4Tests();
