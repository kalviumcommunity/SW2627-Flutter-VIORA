/**
 * VIORA Customer Profile & Personal Preferences Application Controller
 * Manages State, UI Views, Validations, and Day 1 API Integrations.
 */

// ==========================================
// HTML ESCAPING SANITIZATION HELPER
// ==========================================
function escapeHtml(value) {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// Expose on window for global accessibility in browsers
window.escapeHtml = escapeHtml;

document.addEventListener('DOMContentLoaded', () => {
  // ==========================================
  // STATE MANAGEMENT
  // ==========================================
  const state = {
    currentScreen: 'screenAuth',
    customerProfile: null,
    preferences: {
      hair: new Set(),
      nails: new Set(),
      skin: new Set(),
      makeup: new Set()
    },
    savedPreferences: {
      hair: [],
      nails: [],
      skin: [],
      makeup: []
    },
    journeyHistory: [],
    journeyFilter: 'all',
    selectedRebookData: null,
    quizQuestions: [],
    currentQuizStepIndex: 0,
    quizAnswers: {
      hairType: '',
      hairConcerns: [],
      skinType: '',
      goals: [],
      sensitivities: []
    },
    quizResult: null,
    isSubmittingQuiz: false,
    isLoading: false,
    // Day 5 Admin state
    adminOverview: null,
    adminCustomers: [],
    adminSearch: '',
    adminSegment: 'all',
    selectedAdminCustomer: null,
    selectedAdminCustomerHistory: [],
    adminHistoryFilter: 'all'
  };

  // Predefined salon preference options from Viora UI/UX design catalog
  const defaultPreferenceOptions = {
    hair: [
      'Layered Cuts', 'Colour', 'Balayage', 'Keratin',
      'Haircut & Styling', 'Hair Spa & Care', 'Smoothening & Texture',
      'Hair Extensions', 'Classic Cuts', 'Bob Cuts', 'Frizz Control', 'Volume & Lift'
    ],
    nails: [
      'Gel', 'French Tip', 'Acrylic', 'Nail Art',
      'Manicure', 'Pedicure', 'Nail Care & Maintenance',
      'Ombre & Gradients', 'Chrome', 'Velvet', 'Matte Finish'
    ],
    skin: [
      'Hydration', 'Glow Facial', 'Facials', 'Skin Cleanse & Detox',
      'Skin Concerns & Corrective Care', 'Peels & Exfoliation',
      'Advanced Technology', 'Body Care', 'Anti-Aging', 'Sensitive Skin Care'
    ],
    makeup: [
      'Natural Look', 'Bridal', 'Basic Party', 'Evening Engagement',
      'HD Airbrush', 'Eye Makeup', 'Touch-Up', 'Saree Draping',
      'Event Hairstyling', 'Minimalist Glow'
    ]
  };

  // ==========================================
  // DOM ELEMENT SELECTORS
  // ==========================================
  const screens = {
    screenAuth: document.getElementById('screenAuth'),
    screenProfile: document.getElementById('screenProfile'),
    screenEditProfile: document.getElementById('screenEditProfile'),
    screenPreferences: document.getElementById('screenPreferences'),
    screenBeautyJourney: document.getElementById('screenBeautyJourney'),
    screenBeautyQuiz: document.getElementById('screenBeautyQuiz'),
    screenQuizResults: document.getElementById('screenQuizResults'),
    screenAdminCustomers: document.getElementById('screenAdminCustomers'),
    screenAdminCustomerDetail: document.getElementById('screenAdminCustomerDetail'),
    screenInspiration: document.getElementById('screenInspiration'),
    screenInspirationRequest: document.getElementById('screenInspirationRequest'),
    screenInspirationResponses: document.getElementById('screenInspirationResponses'),
    screenReviews: document.getElementById('screenReviews'),
    screenNotifications: document.getElementById('screenNotifications'),
    screenStylistPortal: document.getElementById('screenStylistPortal'),
    screenAdminAnalytics: document.getElementById('screenAdminAnalytics')
  };

  // Auth elements
  const tabSignIn = document.getElementById('tabSignIn');
  const tabSignUp = document.getElementById('tabSignUp');
  const signInForm = document.getElementById('signInForm');
  const signUpForm = document.getElementById('signUpForm');
  const btnDemoLogin = document.getElementById('btnDemoLogin');
  const btnDemoAdminLogin = document.getElementById('btnDemoAdminLogin');

  // Day 5 Admin Management Selectors
  const tileAdminCustomers = document.getElementById('tileAdminCustomers');
  const btnAdminBackToClient = document.getElementById('btnAdminBackToClient');
  const btnAdminSignOut = document.getElementById('btnAdminSignOut');

  const kpiTotalCustomers = document.getElementById('kpiTotalCustomers');
  const kpiVisitsCount = document.getElementById('kpiVisitsCount');
  const kpiRepeatRate = document.getElementById('kpiRepeatRate');
  const kpiReturningCount = document.getElementById('kpiReturningCount');
  const kpiActiveClients = document.getElementById('kpiActiveClients');
  const kpiMultiBranch = document.getElementById('kpiMultiBranch');

  const adminSearchInput = document.getElementById('adminSearchInput');
  const btnClearAdminSearch = document.getElementById('btnClearAdminSearch');
  const adminSegmentFilterBar = document.getElementById('adminSegmentFilterBar');
  const adminCustomerCountLabel = document.getElementById('adminCustomerCountLabel');
  const btnRefreshAdminList = document.getElementById('btnRefreshAdminList');

  const adminLoadingBox = document.getElementById('adminLoadingBox');
  const adminErrorBox = document.getElementById('adminErrorBox');
  const adminErrorMessage = document.getElementById('adminErrorMessage');
  const btnRetryAdminCustomers = document.getElementById('btnRetryAdminCustomers');
  const adminEmptyBox = document.getElementById('adminEmptyBox');
  const adminCustomersList = document.getElementById('adminCustomersList');

  // Day 5 Customer Detail Selectors
  const btnAdminCustomerDetailBack = document.getElementById('btnAdminCustomerDetailBack');
  const adminDetailCustomerIdBadge = document.getElementById('adminDetailCustomerIdBadge');
  const adminDetailLoadingBox = document.getElementById('adminDetailLoadingBox');
  const adminDetailErrorBox = document.getElementById('adminDetailErrorBox');
  const adminDetailErrorMessage = document.getElementById('adminDetailErrorMessage');
  const btnRetryAdminDetail = document.getElementById('btnRetryAdminDetail');
  const adminDetailContent = document.getElementById('adminDetailContent');

  const adminDetailAvatarImg = document.getElementById('adminDetailAvatarImg');
  const adminDetailName = document.getElementById('adminDetailName');
  const adminDetailContact = document.getElementById('adminDetailContact');
  const adminDetailIdPill = document.getElementById('adminDetailIdPill');
  const adminDetailMemberSince = document.getElementById('adminDetailMemberSince');
  const adminDetailDobPill = document.getElementById('adminDetailDobPill');

  const adminDetailCompletedVisits = document.getElementById('adminDetailCompletedVisits');
  const adminDetailTotalSpend = document.getElementById('adminDetailTotalSpend');
  const adminDetailRetentionStatusPill = document.getElementById('adminDetailRetentionStatusPill');
  const adminDetailLastVisitText = document.getElementById('adminDetailLastVisitText');
  const adminDetailBranchesText = document.getElementById('adminDetailBranchesText');
  const adminDetailSegmentTags = document.getElementById('adminDetailSegmentTags');

  const adminDetailPreferencesContainer = document.getElementById('adminDetailPreferencesContainer');
  const adminDetailQuizCard = document.getElementById('adminDetailQuizCard');
  const adminDetailArchetypeTitle = document.getElementById('adminDetailArchetypeTitle');
  const adminDetailArchetypeSummary = document.getElementById('adminDetailArchetypeSummary');
  const adminDetailQuizChipsContainer = document.getElementById('adminDetailQuizChipsContainer');

  const adminHistoryTotalBadge = document.getElementById('adminHistoryTotalBadge');
  const countHistAll = document.getElementById('countHistAll');
  const countHistCompleted = document.getElementById('countHistCompleted');
  const countHistUpcoming = document.getElementById('countHistUpcoming');
  const countHistCancelled = document.getElementById('countHistCancelled');
  const adminHistoryFilterBar = document.getElementById('adminHistoryFilterBar');
  const adminHistoryTimelineContent = document.getElementById('adminHistoryTimelineContent');
  const adminHistoryEmptyBox = document.getElementById('adminHistoryEmptyBox');

  // Profile elements
  const profileAvatarImg = document.getElementById('profileAvatarImg');
  const profileNameDisplay = document.getElementById('profileNameDisplay');
  const profileContactDisplay = document.getElementById('profileContactDisplay');
  const profileCustomerIdBadge = document.getElementById('profileCustomerIdBadge');
  const profilePreferencesSummary = document.getElementById('profilePreferencesSummary');
  const btnEditProfile = document.getElementById('btnEditProfile');
  const tilePreferences = document.getElementById('tilePreferences');
  const tileSignOut = document.getElementById('tileSignOut');
  const btnChangeAvatar = document.getElementById('btnChangeAvatar');

  // Edit Profile elements
  const editProfileForm = document.getElementById('editProfileForm');
  const editCustomerId = document.getElementById('editCustomerId');
  const editEmail = document.getElementById('editEmail');
  const editName = document.getElementById('editName');
  const editPhone = document.getElementById('editPhone');
  const editDob = document.getElementById('editDob');
  const editPhotoUrl = document.getElementById('editPhotoUrl');
  const btnEditProfileBack = document.getElementById('btnEditProfileBack');
  const btnCancelEditProfile = document.getElementById('btnCancelEditProfile');
  const btnSaveProfileHeader = document.getElementById('btnSaveProfileHeader');
  const avatarOptionBtns = document.querySelectorAll('.avatar-option-btn');

  // Preferences elements
  const btnPreferencesBack = document.getElementById('btnPreferencesBack');
  const btnSavePreferences = document.getElementById('btnSavePreferences');
  const btnSavePreferencesHeader = document.getElementById('btnSavePreferencesHeader');
  const btnResetPreferences = document.getElementById('btnResetPreferences');

  // Beauty Journey elements (Day 3 - Group 51.png)
  const tileBeautyJourney = document.getElementById('tileBeautyJourney');
  const tileBeautyProfile = document.getElementById('tileBeautyProfile');
  const profileJourneySummary = document.getElementById('profileJourneySummary');
  const btnJourneyBack = document.getElementById('btnJourneyBack');
  const journeyFilterPills = document.querySelectorAll('.journey-filter-pill');
  const journeyLoadingBox = document.getElementById('journeyLoadingBox');
  const journeyErrorBox = document.getElementById('journeyErrorBox');
  const journeyErrorMessage = document.getElementById('journeyErrorMessage');
  const journeyEmptyBox = document.getElementById('journeyEmptyBox');
  const journeyTimelineContent = document.getElementById('journeyTimelineContent');
  const btnRetryJourney = document.getElementById('btnRetryJourney');

  // Rebook Modal elements (Day 3 Safe Integration)
  const rebookModal = document.getElementById('rebookModal');
  const rebookModalBody = document.getElementById('rebookModalBody');
  const btnCloseRebookModal = document.getElementById('btnCloseRebookModal');
  const btnProceedRebook = document.getElementById('btnProceedRebook');
  const btnCancelRebook = document.getElementById('btnCancelRebook');

  // Day 4 Beauty Quiz & Recommendations elements (Group 52.png & Group 53.png)
  const profileQuizSummary = document.getElementById('profileQuizSummary');
  const btnQuizBack = document.getElementById('btnQuizBack');
  const quizStepNumberTag = document.getElementById('quizStepNumberTag');
  const quizStepCategoryTag = document.getElementById('quizStepCategoryTag');
  const quizProgressFill = document.getElementById('quizProgressFill');
  const quizQuestionTitle = document.getElementById('quizQuestionTitle');
  const quizQuestionSubtitle = document.getElementById('quizQuestionSubtitle');
  const quizOptionsList = document.getElementById('quizOptionsList');
  const btnQuizPrev = document.getElementById('btnQuizPrev');
  const btnQuizNext = document.getElementById('btnQuizNext');
  const btnQuizNextText = document.getElementById('btnQuizNextText');

  const btnResultsBack = document.getElementById('btnResultsBack');
  const resultsLoadingBox = document.getElementById('resultsLoadingBox');
  const resultsErrorBox = document.getElementById('resultsErrorBox');
  const resultsErrorMessage = document.getElementById('resultsErrorMessage');
  const btnRetryResults = document.getElementById('btnRetryResults');
  const resultsScrollContainer = document.getElementById('resultsScrollContainer');
  const profileChipsContainer = document.getElementById('profileChipsContainer');
  const archetypeTitle = document.getElementById('archetypeTitle');
  const archetypeSummaryText = document.getElementById('archetypeSummaryText');
  const recommendedServicesList = document.getElementById('recommendedServicesList');
  const prescribedProductsGrid = document.getElementById('prescribedProductsGrid');
  const recommendedStylistsList = document.getElementById('recommendedStylistsList');
  const btnRetakeQuiz = document.getElementById('btnRetakeQuiz');

  // Loading & Feedback
  const loadingOverlay = document.getElementById('loadingOverlay');
  const loadingText = document.getElementById('loadingText');
  const toastContainer = document.getElementById('toastContainer');

  // ==========================================
  // FEEDBACK & NOTIFICATION HELPERS
  // ==========================================
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;

    let iconSvg = '';
    if (type === 'success') {
      iconSvg = `<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"></path></svg>`;
    } else if (type === 'error') {
      iconSvg = `<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>`;
    } else {
      iconSvg = `<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>`;
    }

    toast.innerHTML = `${iconSvg}<span>${message}</span>`;
    toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.remove();
    }, 4000);
  }

  function setGlobalLoading(isLoading, message = 'Connecting to VIORA...') {
    state.isLoading = isLoading;
    if (isLoading) {
      loadingText.textContent = message;
      loadingOverlay.style.display = 'flex';
      loadingOverlay.setAttribute('aria-hidden', 'false');
    } else {
      loadingOverlay.style.display = 'none';
      loadingOverlay.setAttribute('aria-hidden', 'true');
    }
  }

  function setButtonLoading(btn, isLoading) {
    if (!btn) return;
    if (isLoading) {
      btn.classList.add('loading');
      btn.setAttribute('disabled', 'true');
    } else {
      btn.classList.remove('loading');
      btn.removeAttribute('disabled');
    }
  }

  // ==========================================
  // ROUTING & SCREEN NAVIGATION
  // ==========================================
  function navigateTo(screenId) {
    state.currentScreen = screenId;
    Object.keys(screens).forEach((key) => {
      if (screens[key]) {
        screens[key].style.display = (key === screenId) ? 'flex' : 'none';
      }
    });

    // Handle universal bottom nav bar visibility and active tab state
    const bottomNav = document.getElementById('mainBottomNav');
    if (bottomNav) {
      if (screenId === 'screenAuth' || !window.vioraApi.isAuthenticated()) {
        bottomNav.style.display = 'none';
      } else {
        bottomNav.style.display = 'flex';
        updateBottomNavActiveTab(screenId);
      }
    }

    // Scroll container to top
    const container = document.getElementById('appContainer');
    if (container) container.scrollTop = 0;
  }

  function updateBottomNavActiveTab(screenId) {
    const tabs = {
      navTabProfile: ['screenProfile', 'screenEditProfile', 'screenPreferences', 'screenBeautyJourney', 'screenBeautyQuiz', 'screenQuizResults'],
      navTabInspiration: ['screenInspiration', 'screenInspirationRequest', 'screenInspirationResponses'],
      navTabReviews: ['screenReviews'],
      navTabNotifications: ['screenNotifications'],
      navTabDashboard: ['screenStylistPortal', 'screenAdminAnalytics', 'screenAdminCustomers', 'screenAdminCustomerDetail']
    };

    Object.keys(tabs).forEach((tabId) => {
      const btn = document.getElementById(tabId);
      if (btn) {
        if (tabs[tabId].includes(screenId)) {
          btn.classList.add('active');
        } else {
          btn.classList.remove('active');
        }
      }
    });

    const user = window.vioraApi.getUser();
    const dashLabel = document.getElementById('navTabDashboardLabel');
    if (dashLabel && user) {
      if (user.role === 'admin' || user.role === 'branch_manager') {
        dashLabel.textContent = 'Admin';
      } else if (user.role === 'stylist') {
        dashLabel.textContent = 'Stylist';
      } else {
        dashLabel.textContent = 'Atelier';
      }
    }
  }

  // ==========================================
  // DATA RENDERING: PROFILE SCREEN
  // ==========================================
  function renderProfile(customer) {
    if (!customer) return;

    profileNameDisplay.textContent = customer.name || 'Member';
    profileContactDisplay.textContent = `${customer.email || ''} ${customer.phone ? '• ' + customer.phone : ''}`;
    profileCustomerIdBadge.textContent = customer.customerId || 'CUST-0001';

    // Profile photo fallback
    const defaultPhoto = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80';
    profileAvatarImg.src = customer.profilePhoto && customer.profilePhoto.trim() ? customer.profilePhoto : defaultPhoto;
    profileAvatarImg.onerror = () => { profileAvatarImg.src = defaultPhoto; };

    // Preferences summary tile
    updatePreferencesSummaryTile(customer.preferences);
  }

  function updatePreferencesSummaryTile(prefs) {
    if (!prefs) {
      profilePreferencesSummary.textContent = 'None set';
      return;
    }

    const totalSelected = (prefs.hair?.length || 0) +
                          (prefs.nails?.length || 0) +
                          (prefs.skin?.length || 0) +
                          (prefs.makeup?.length || 0);

    if (totalSelected === 0) {
      profilePreferencesSummary.textContent = 'Set preferences';
    } else {
      const parts = [];
      if (prefs.hair?.length) parts.push(`${prefs.hair.length} Hair`);
      if (prefs.nails?.length) parts.push(`${prefs.nails.length} Nails`);
      if (prefs.skin?.length) parts.push(`${prefs.skin.length} Skin`);
      if (prefs.makeup?.length) parts.push(`${prefs.makeup.length} Makeup`);
      profilePreferencesSummary.textContent = parts.slice(0, 2).join(', ') + (parts.length > 2 ? ` +${parts.length - 2}` : '');
    }
  }

  // ==========================================
  // DATA POPULATION: EDIT PROFILE SCREEN
  // ==========================================
  function populateEditProfileForm(customer) {
    if (!customer) return;

    // Strict non-editable fields (Day 2 security requirement)
    editCustomerId.value = customer.customerId || '';
    editEmail.value = customer.email || '';

    // Permitted editable fields
    editName.value = customer.name || '';
    editPhone.value = customer.phone || '';

    // Date of Birth format for <input type="date">
    if (customer.dateOfBirth) {
      try {
        const d = new Date(customer.dateOfBirth);
        editDob.value = d.toISOString().split('T')[0];
      } catch {
        editDob.value = '';
      }
    } else {
      editDob.value = '';
    }

    editPhotoUrl.value = customer.profilePhoto || '';

    // Highlight selected preset avatar if matches
    avatarOptionBtns.forEach(btn => {
      btn.classList.toggle('active', btn.dataset.url === customer.profilePhoto);
    });

    clearEditErrors();
  }

  function clearEditErrors() {
    ['editNameError', 'editPhoneError', 'editDobError', 'editPhotoUrlError'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = '';
    });
  }

  // Frontend Validation for Profile Edit
  function validateProfileForm() {
    clearEditErrors();
    let isValid = true;

    // Name Validation
    const nameVal = editName.value.trim();
    if (!nameVal) {
      document.getElementById('editNameError').textContent = 'Full name is required.';
      isValid = false;
    } else if (nameVal.length < 2) {
      document.getElementById('editNameError').textContent = 'Name must be at least 2 characters.';
      isValid = false;
    }

    // Phone Validation (Optional, but if entered must be valid format)
    const phoneVal = editPhone.value.trim();
    if (phoneVal) {
      const phoneRegex = /^[+]?[\d\s-]{7,15}$/;
      if (!phoneRegex.test(phoneVal)) {
        document.getElementById('editPhoneError').textContent = 'Please enter a valid phone number format.';
        isValid = false;
      }
    }

    // Date of Birth Validation (Optional, must not be future date)
    const dobVal = editDob.value;
    if (dobVal) {
      const dobDate = new Date(dobVal);
      if (isNaN(dobDate.getTime()) || dobDate > new Date()) {
        document.getElementById('editDobError').textContent = 'Date of birth cannot be in the future.';
        isValid = false;
      }
    }

    // Photo URL Validation (Optional, basic URL structure check)
    const photoVal = editPhotoUrl.value.trim();
    if (photoVal) {
      try {
        new URL(photoVal);
      } catch {
        document.getElementById('editPhotoUrlError').textContent = 'Please enter a valid web image URL.';
        isValid = false;
      }
    }

    return isValid;
  }

  // ==========================================
  // DATA RENDERING: PREFERENCES SCREEN
  // ==========================================
  function renderPreferencesScreen() {
    ['hair', 'nails', 'skin', 'makeup'].forEach(cat => {
      const grid = document.getElementById(`${cat}ChipsGrid`);
      if (!grid) return;

      grid.innerHTML = '';

      // Combine default options with any user-selected custom tags
      const allCategoryOptions = Array.from(new Set([
        ...defaultPreferenceOptions[cat],
        ...Array.from(state.preferences[cat] || [])
      ]));

      allCategoryOptions.forEach(optionText => {
        const isSelected = state.preferences[cat]?.has(optionText);

        const chip = document.createElement('button');
        type = 'button';
        chip.className = `pref-chip ${isSelected ? 'selected' : ''}`;
        chip.dataset.category = cat;
        chip.dataset.value = optionText;

        chip.innerHTML = `
          <svg class="chip-check" viewBox="0 0 24 24" stroke-width="3" fill="none">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
          <span class="chip-label">${escapeHtml(optionText)}</span>
        `;

        chip.addEventListener('click', () => {
          togglePreferenceChip(cat, optionText, chip);
        });

        grid.appendChild(chip);
      });

      updateCategoryCountBadge(cat);
    });
  }

  function togglePreferenceChip(category, value, chipElement) {
    if (!state.preferences[category]) {
      state.preferences[category] = new Set();
    }

    if (state.preferences[category].has(value)) {
      state.preferences[category].delete(value);
      chipElement.classList.remove('selected');
    } else {
      state.preferences[category].add(value);
      chipElement.classList.add('selected');
    }

    updateCategoryCountBadge(category);
  }

  function updateCategoryCountBadge(category) {
    const badge = document.getElementById(`${category}CountBadge`);
    if (!badge) return;

    const count = state.preferences[category]?.size || 0;
    badge.textContent = `${count} selected`;
    badge.classList.toggle('has-items', count > 0);
  }

  function addCustomPreferenceTag(category) {
    const inputId = `custom${category.charAt(0).toUpperCase() + category.slice(1)}Input`;
    const input = document.getElementById(inputId);
    if (!input) return;

    const val = input.value.trim();
    if (!val) return;

    if (!state.preferences[category]) {
      state.preferences[category] = new Set();
    }

    state.preferences[category].add(val);
    input.value = '';
    renderPreferencesScreen();
    showToast(`Added "${val}" to ${category} preferences.`, 'info');
  }

  // ==========================================
  // API ACTIONS: LOAD & SYNC
  // ==========================================
  async function loadCustomerProfile() {
    setGlobalLoading(true, 'Loading your profile...');
    try {
      const response = await window.vioraApi.getProfile();
      if (response && response.success && response.data) {
        state.customerProfile = response.data;

        // Sync local preferences state
        const p = response.data.preferences || {};
        state.preferences.hair = new Set(p.hair || []);
        state.preferences.nails = new Set(p.nails || []);
        state.preferences.skin = new Set(p.skin || []);
        state.preferences.makeup = new Set(p.makeup || []);

        state.savedPreferences = {
          hair: Array.from(state.preferences.hair),
          nails: Array.from(state.preferences.nails),
          skin: Array.from(state.preferences.skin),
          makeup: Array.from(state.preferences.makeup)
        };

        renderProfile(state.customerProfile);

        // Background update for cross-branch journey count
        window.vioraApi.getHistory('all').then(res => {
          if (res && res.success && profileJourneySummary) {
            const count = res.count || (res.data ? res.data.length : 0);
            profileJourneySummary.textContent = `${count} Treatment${count === 1 ? '' : 's'}`;
          }
        }).catch(() => {});

        // Background update for beauty quiz results
        loadQuizState();

        navigateTo('screenProfile');
      } else {
        throw new Error(response.message || 'Failed to load profile.');
      }
    } catch (err) {
      console.error('Error loading profile:', err);
      showToast(err.message || 'Could not retrieve profile.', 'error');
      // If unauthorized, back to auth screen
      if (err.status === 401 || !window.vioraApi.isAuthenticated()) {
        navigateTo('screenAuth');
      }
    } finally {
      setGlobalLoading(false);
    }
  }

  async function handleProfileSave(e) {
    if (e) e.preventDefault();

    if (!validateProfileForm()) {
      showToast('Please fix the validation errors.', 'error');
      return;
    }

    const payload = {
      name: editName.value.trim(),
      phone: editPhone.value.trim(),
      dateOfBirth: editDob.value ? new Date(editDob.value).toISOString() : null,
      profilePhoto: editPhotoUrl.value.trim()
    };

    setButtonLoading(document.getElementById('btnSaveProfile'), true);
    setButtonLoading(btnSaveProfileHeader, true);

    try {
      const response = await window.vioraApi.updateProfile(payload);
      if (response && response.success && response.data) {
        state.customerProfile = response.data;
        renderProfile(state.customerProfile);
        showToast('Profile updated successfully!', 'success');
        navigateTo('screenProfile');
      } else {
        throw new Error(response.message || 'Failed to save profile changes.');
      }
    } catch (err) {
      console.error('Error saving profile:', err);
      showToast(err.message || 'Could not update profile.', 'error');
    } finally {
      setButtonLoading(document.getElementById('btnSaveProfile'), false);
      setButtonLoading(btnSaveProfileHeader, false);
    }
  }

  async function handlePreferencesSave() {
    const payload = {
      hair: Array.from(state.preferences.hair),
      nails: Array.from(state.preferences.nails),
      skin: Array.from(state.preferences.skin),
      makeup: Array.from(state.preferences.makeup)
    };

    setButtonLoading(btnSavePreferences, true);
    setButtonLoading(btnSavePreferencesHeader, true);

    try {
      const response = await window.vioraApi.updatePreferences(payload);
      if (response && response.success) {
        state.savedPreferences = {
          hair: [...payload.hair],
          nails: [...payload.nails],
          skin: [...payload.skin],
          makeup: [...payload.makeup]
        };

        if (state.customerProfile) {
          state.customerProfile.preferences = payload;
          renderProfile(state.customerProfile);
        }

        showToast('Preferences saved successfully!', 'success');
        navigateTo('screenProfile');
      } else {
        throw new Error(response.message || 'Failed to update preferences.');
      }
    } catch (err) {
      console.error('Error saving preferences:', err);
      showToast(err.message || 'Could not save preferences.', 'error');
    } finally {
      setButtonLoading(btnSavePreferences, false);
      setButtonLoading(btnSavePreferencesHeader, false);
    }
  }

  function handlePreferencesReset() {
    state.preferences.hair = new Set(state.savedPreferences.hair);
    state.preferences.nails = new Set(state.savedPreferences.nails);
    state.preferences.skin = new Set(state.savedPreferences.skin);
    state.preferences.makeup = new Set(state.savedPreferences.makeup);

    renderPreferencesScreen();
    showToast('Reverted to saved preferences.', 'info');
  }

  // ==========================================
  // DAY 3: MY BEAUTY JOURNEY & REBOOK WORKFLOW
  // Visual Source of Truth: Group 51.png
  // ==========================================

  function formatMonthHeader(dateVal) {
    if (!dateVal) return 'PAST SERVICES';
    const d = new Date(dateVal);
    if (isNaN(d.getTime())) return 'PAST SERVICES';
    const month = d.toLocaleString('en-US', { month: 'long' }).toUpperCase();
    const year = d.getFullYear();
    return `${month} ${year}`;
  }

  function formatCompletedDate(dateVal) {
    if (!dateVal) return 'Completed';
    const d = new Date(dateVal);
    if (isNaN(d.getTime())) return 'Completed';
    const day = d.getDate().toString().padStart(2, '0');
    const month = d.toLocaleString('en-US', { month: 'short' });
    return `Completed on ${day} ${month}`;
  }

  function formatPrice(amount) {
    if (typeof amount !== 'number') return '₹0';
    return `₹${amount.toLocaleString('en-IN')}`;
  }

  async function loadBeautyJourney(category = 'all') {
    state.journeyFilter = category;

    // Update filter pills UI
    journeyFilterPills.forEach(pill => {
      const pillCat = pill.dataset.category;
      const isActive = (pillCat === category) || (category === 'all' && pillCat === 'all');
      pill.classList.toggle('active', isActive);
      pill.setAttribute('aria-selected', isActive ? 'true' : 'false');
    });

    // Show loading state, hide error, empty, timeline
    if (journeyLoadingBox) journeyLoadingBox.style.display = 'flex';
    if (journeyErrorBox) journeyErrorBox.style.display = 'none';
    if (journeyEmptyBox) journeyEmptyBox.style.display = 'none';
    if (journeyTimelineContent) journeyTimelineContent.innerHTML = '';

    try {
      const response = await window.vioraApi.getHistory(category);
      if (response && response.success) {
        state.journeyHistory = response.data || [];

        if (profileJourneySummary) {
          const count = response.count || state.journeyHistory.length;
          profileJourneySummary.textContent = `${count} Treatment${count === 1 ? '' : 's'}`;
        }

        renderBeautyJourney(state.journeyHistory);
      } else {
        throw new Error(response.message || 'Failed to retrieve beauty journey.');
      }
    } catch (err) {
      console.error('Error loading beauty journey:', err);
      if (journeyLoadingBox) journeyLoadingBox.style.display = 'none';
      if (journeyErrorBox) {
        journeyErrorBox.style.display = 'flex';
        if (journeyErrorMessage) {
          journeyErrorMessage.textContent = err.message || 'Could not connect to retrieve cross-branch history.';
        }
      }
      showToast(err.message || 'Failed to load treatment history.', 'error');
    } finally {
      if (journeyLoadingBox) journeyLoadingBox.style.display = 'none';
    }
  }

  function renderBeautyJourney(items) {
    if (!items || items.length === 0) {
      if (journeyEmptyBox) journeyEmptyBox.style.display = 'flex';
      if (journeyTimelineContent) journeyTimelineContent.innerHTML = '';
      return;
    }

    if (journeyEmptyBox) journeyEmptyBox.style.display = 'none';
    if (journeyErrorBox) journeyErrorBox.style.display = 'none';

    // Group items by Month & Year (Group 51.png timeline)
    const monthGroups = new Map();
    items.forEach(item => {
      const groupKey = formatMonthHeader(item.date);
      if (!monthGroups.has(groupKey)) {
        monthGroups.set(groupKey, []);
      }
      monthGroups.get(groupKey).push(item);
    });

    let html = '';
    monthGroups.forEach((groupItems, monthTitle) => {
      html += `
        <div class="journey-month-group">
          <div class="journey-month-header">${escapeHtml(monthTitle)}</div>
          <div class="journey-cards-list">
      `;

      groupItems.forEach(item => {
        const serviceName = item.service?.name || 'Salon Treatment';
        const price = formatPrice(item.service?.price || 0);
        const branchName = item.branch?.name || 'VIORA Salon';
        const stylistName = item.stylist?.name || 'Salon Stylist';
        const completedDate = formatCompletedDate(item.date);
        const isAvailable = (item.service?.availability !== false) && (item.branch?.status !== 'inactive');

        html += `
          <div class="treatment-card" data-appointment-id="${escapeHtml(item.appointmentId)}">
            <div class="treatment-card-header">
              <h3 class="treatment-name">${escapeHtml(serviceName)}</h3>
              <span class="treatment-price">${price}</span>
            </div>
            <div class="treatment-card-body">
              <div class="treatment-meta-line">
                <span class="treatment-branch">${escapeHtml(branchName)}</span>
                <span class="meta-dot">•</span>
                <span class="treatment-stylist">${escapeHtml(stylistName)}</span>
              </div>
              <div class="treatment-sub-line">
                <span class="treatment-date">${escapeHtml(completedDate)}</span>
                <button type="button" 
                  class="btn-rebook ${!isAvailable ? 'unavailable' : ''}" 
                  data-appointment-id="${escapeHtml(item.appointmentId)}"
                  data-available="${isAvailable}">
                  ${isAvailable ? 'Rebook' : 'Unavailable'}
                </button>
              </div>
            </div>
          </div>
        `;
      });

      html += `
          </div>
        </div>
      `;
    });

    if (journeyTimelineContent) {
      journeyTimelineContent.innerHTML = html;

      // Attach rebook click listeners
      journeyTimelineContent.querySelectorAll('.btn-rebook').forEach(btn => {
        btn.addEventListener('click', (e) => {
          e.stopPropagation();
          const apptId = btn.dataset.appointmentId;
          const isAvail = btn.dataset.available === 'true';
          handleRebookClick(apptId, isAvail);
        });
      });
    }
  }

  async function handleRebookClick(appointmentId, isAvailable) {
    if (!isAvailable) {
      showToast('This service is currently unavailable for online rebooking. Please contact the salon directly.', 'error');
      return;
    }

    setGlobalLoading(true, 'Preparing rebooking context...');
    try {
      const response = await window.vioraApi.getRebookContext(appointmentId);
      if (response && response.success && response.data) {
        state.selectedRebookData = response.data;
        openRebookModal(response.data);
      } else {
        const localRecord = state.journeyHistory.find(i => i.appointmentId === appointmentId);
        if (localRecord) {
          state.selectedRebookData = {
            service: localRecord.service,
            branch: localRecord.branch,
            preferredStylist: localRecord.stylist,
            sourceAppointmentId: localRecord.appointmentId
          };
          openRebookModal(state.selectedRebookData);
        } else {
          throw new Error('Unable to prepare rebook context.');
        }
      }
    } catch (err) {
      console.error('Error preparing rebook context:', err);
      showToast(err.message || 'Could not prepare rebook context.', 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  function openRebookModal(rebookData) {
    const service = rebookData.service || {};
    const branch = rebookData.branch || {};
    const stylist = rebookData.preferredStylist || {};
    const isEligible = (rebookData.eligible !== false) && (service.available !== false) && (branch.active !== false);

    let warningNotice = '';
    if (!isEligible) {
      warningNotice = `
        <div class="rebook-unavailable-notice" style="background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); color: #DC2626; padding: 10px 14px; border-radius: 8px; font-size: 12px; margin-top: 12px; line-height: 1.4;">
          <strong>Service Currently Unavailable:</strong> This treatment or salon branch is currently not accepting automated rebookings. Please contact the salon directly.
        </div>
      `;
    }

    rebookModalBody.innerHTML = `
      <div class="rebook-detail-card">
        <h4 class="rebook-service-name">${escapeHtml(service.name || 'Salon Treatment')}</h4>
        <div class="rebook-service-price">${formatPrice(service.price || 0)}</div>

        <div class="rebook-info-row">
          <span class="rebook-info-label">Category</span>
          <span class="rebook-info-val">${escapeHtml(service.category || 'General')}</span>
        </div>
        <div class="rebook-info-row">
          <span class="rebook-info-label">Duration</span>
          <span class="rebook-info-val">${service.duration || 60} mins</span>
        </div>
        <div class="rebook-info-row">
          <span class="rebook-info-label">Branch</span>
          <span class="rebook-info-val">${escapeHtml(branch.name || 'VIORA Salon')}${branch.active === false ? ' (Inactive)' : ''}</span>
        </div>
        <div class="rebook-info-row">
          <span class="rebook-info-label">Preferred Stylist</span>
          <span class="rebook-info-val">${escapeHtml(stylist.name || 'Any Senior Stylist')}</span>
        </div>
        ${warningNotice}
      </div>

      <div class="rebook-integration-badge">
        <strong>BOOKING FLOW INTEGRATION HOOK</strong>
        Selected service and branch parameters are prefilled. Proceeding transfers context to the booking flow for slot scheduling and stylist confirmation without creating unconfirmed duplicates.
      </div>
    `;

    if (btnProceedRebook) {
      btnProceedRebook.disabled = !isEligible;
      btnProceedRebook.style.opacity = isEligible ? '1' : '0.5';
      btnProceedRebook.style.cursor = isEligible ? 'pointer' : 'not-allowed';
    }

    if (rebookModal) rebookModal.style.display = 'flex';
  }

  function closeRebookModal() {
    if (rebookModal) rebookModal.style.display = 'none';
    if (btnProceedRebook) {
      btnProceedRebook.disabled = false;
      btnProceedRebook.style.opacity = '1';
      btnProceedRebook.style.cursor = 'pointer';
    }
    state.selectedRebookData = null;
  }

  function handleProceedRebook() {
    if (!state.selectedRebookData) return;

    const data = state.selectedRebookData;
    if (data.eligible === false || data.service?.available === false || data.branch?.active === false) {
      showToast('This service or branch is currently unavailable for rebooking.', 'error');
      return;
    }

    const rebookPayload = { ...state.selectedRebookData };
    closeRebookModal();

    // Dispatch custom event for modular booking integration
    window.dispatchEvent(new CustomEvent('viora:rebook-initiated', {
      detail: rebookPayload
    }));

    showToast(`Rebook context for "${rebookPayload.service?.name || 'treatment'}" prepared for booking flow!`, 'success');
  }

  // ==========================================
  // AUTHENTICATION HANDLERS
  // ==========================================
  async function handleSignIn(e) {
    e.preventDefault();
    const email = document.getElementById('loginEmail').value.trim();
    const password = document.getElementById('loginPassword').value;

    let hasError = false;
    document.getElementById('loginEmailError').textContent = '';
    document.getElementById('loginPasswordError').textContent = '';

    if (!email) {
      document.getElementById('loginEmailError').textContent = 'Email is required.';
      hasError = true;
    }
    if (!password) {
      document.getElementById('loginPasswordError').textContent = 'Password is required.';
      hasError = true;
    }
    if (hasError) return;

    const btnSubmit = document.getElementById('btnSignInSubmit');
    setButtonLoading(btnSubmit, true);

    try {
      await window.vioraApi.login(email, password);
      showToast('Welcome back to VIORA!', 'success');

      const user = window.vioraApi.getUser();
      if (user && (user.role === 'admin' || user.role === 'branch_manager')) {
        if (tileAdminCustomers) tileAdminCustomers.style.display = 'flex';
        navigateTo('screenAdminCustomers');
        await loadAdminDashboard();
      } else {
        if (tileAdminCustomers) tileAdminCustomers.style.display = 'none';
        await loadCustomerProfile();
      }
    } catch (err) {
      showToast(err.message || 'Login failed. Please check credentials.', 'error');
    } finally {
      setButtonLoading(btnSubmit, false);
    }
  }

  async function handleSignUp(e) {
    e.preventDefault();
    const name = document.getElementById('regName').value.trim();
    const email = document.getElementById('regEmail').value.trim();
    const phone = document.getElementById('regPhone').value.trim();
    const password = document.getElementById('regPassword').value;

    let hasError = false;
    ['regNameError', 'regEmailError', 'regPhoneError', 'regPasswordError'].forEach(id => {
      document.getElementById(id).textContent = '';
    });

    if (!name || name.length < 2) {
      document.getElementById('regNameError').textContent = 'Please enter your name.';
      hasError = true;
    }
    if (!email || !email.includes('@')) {
      document.getElementById('regEmailError').textContent = 'Please enter a valid email address.';
      hasError = true;
    }
    if (!password || password.length < 6) {
      document.getElementById('regPasswordError').textContent = 'Password must be at least 6 characters.';
      hasError = true;
    }
    if (hasError) return;

    const btnSubmit = document.getElementById('btnSignUpSubmit');
    setButtonLoading(btnSubmit, true);

    try {
      await window.vioraApi.register({ name, email, phone, password });
      showToast('Account created successfully!', 'success');
      if (tileAdminCustomers) tileAdminCustomers.style.display = 'none';
      await loadCustomerProfile();
    } catch (err) {
      showToast(err.message || 'Registration failed.', 'error');
    } finally {
      setButtonLoading(btnSubmit, false);
    }
  }

  // Quick Demo Access Helper (Customer)
  async function handleDemoLogin() {
    setGlobalLoading(true, 'Entering luxury demo experience...');
    const demoEmail = 'sarah.sen@maison.com';
    const demoPassword = 'Password123!';

    try {
      try {
        await window.vioraApi.login(demoEmail, demoPassword);
      } catch (loginErr) {
        // If demo user does not exist yet, auto-register
        await window.vioraApi.register({
          name: 'Sarah Sen',
          email: demoEmail,
          phone: '+91 98200 12345',
          password: demoPassword,
          role: 'customer'
        });
      }

      showToast('Connected as Sarah Sen', 'success');
      if (tileAdminCustomers) tileAdminCustomers.style.display = 'none';
      await loadCustomerProfile();
    } catch (err) {
      console.error('Demo login error:', err);
      showToast('Could not launch demo customer. ' + err.message, 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  // Quick Demo Access Helper (Administrator - Day 5)
  async function handleDemoAdminLogin() {
    setGlobalLoading(true, 'Entering VIORA Admin Intelligence...');
    const adminEmail = 'admin@viora.com';
    const adminPassword = 'AdminPass123!';

    try {
      try {
        await window.vioraApi.login(adminEmail, adminPassword);
      } catch (loginErr) {
        // If admin demo user does not exist yet, auto-register as admin
        await window.vioraApi.register({
          name: 'Executive Administrator',
          email: adminEmail,
          phone: '+91 98000 00000',
          password: adminPassword,
          role: 'admin'
        });
      }

      showToast('Welcome, Administrator', 'success');
      if (tileAdminCustomers) tileAdminCustomers.style.display = 'flex';
      navigateTo('screenAdminCustomers');
      await loadAdminDashboard();
    } catch (err) {
      console.error('Demo admin login error:', err);
      showToast('Could not launch admin portal: ' + err.message, 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  function handleSignOut() {
    window.vioraApi.clearSession();
    state.customerProfile = null;
    state.adminOverview = null;
    state.adminCustomers = [];
    state.selectedAdminCustomer = null;
    showToast('You have signed out.', 'info');
    navigateTo('screenAuth');
  }

  // ==========================================
  // EVENT LISTENERS BINDING
  // ==========================================

  // Auth tabs toggle
  tabSignIn.addEventListener('click', () => {
    tabSignIn.classList.add('active');
    tabSignIn.setAttribute('aria-selected', 'true');
    tabSignUp.classList.remove('active');
    tabSignUp.setAttribute('aria-selected', 'false');
    signInForm.style.display = 'flex';
    signUpForm.style.display = 'none';
  });

  tabSignUp.addEventListener('click', () => {
    tabSignUp.classList.add('active');
    tabSignUp.setAttribute('aria-selected', 'true');
    tabSignIn.classList.remove('active');
    tabSignIn.setAttribute('aria-selected', 'false');
    signUpForm.style.display = 'flex';
    signInForm.style.display = 'none';
  });

  // Password visibility toggles
  document.querySelectorAll('.password-toggle-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const targetId = btn.dataset.target;
      const input = document.getElementById(targetId);
      if (input) {
        input.type = input.type === 'password' ? 'text' : 'password';
      }
    });
  });

  // Auth forms
  signInForm.addEventListener('submit', handleSignIn);
  signUpForm.addEventListener('submit', handleSignUp);
  btnDemoLogin.addEventListener('click', handleDemoLogin);

  // Profile actions
  btnEditProfile.addEventListener('click', () => {
    populateEditProfileForm(state.customerProfile);
    navigateTo('screenEditProfile');
  });

  btnChangeAvatar.addEventListener('click', () => {
    populateEditProfileForm(state.customerProfile);
    navigateTo('screenEditProfile');
  });

  tilePreferences.addEventListener('click', () => {
    renderPreferencesScreen();
    navigateTo('screenPreferences');
  });

  tileSignOut.addEventListener('click', handleSignOut);

  // Edit Profile actions
  btnEditProfileBack.addEventListener('click', () => navigateTo('screenProfile'));
  btnCancelEditProfile.addEventListener('click', () => navigateTo('screenProfile'));
  editProfileForm.addEventListener('submit', handleProfileSave);
  btnSaveProfileHeader.addEventListener('click', handleProfileSave);

  // Avatar presets selection
  avatarOptionBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      avatarOptionBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      editPhotoUrl.value = btn.dataset.url;
    });
  });

  // Preferences actions
  btnPreferencesBack.addEventListener('click', () => navigateTo('screenProfile'));
  btnSavePreferences.addEventListener('click', handlePreferencesSave);
  btnSavePreferencesHeader.addEventListener('click', handlePreferencesSave);
  btnResetPreferences.addEventListener('click', handlePreferencesReset);

  // Custom chip add buttons
  document.querySelectorAll('.btn-add-chip').forEach(btn => {
    btn.addEventListener('click', () => {
      const category = btn.dataset.category;
      addCustomPreferenceTag(category);
    });
  });

  // Custom chip input on Enter key
  ['customHairInput', 'customNailsInput', 'customSkinInput', 'customMakeupInput'].forEach(id => {
    const input = document.getElementById(id);
    if (input) {
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
          e.preventDefault();
          const category = id.replace('custom', '').replace('Input', '').toLowerCase();
          addCustomPreferenceTag(category);
        }
      });
    }
  });

  // ==========================================
  // DAY 3 EVENT LISTENERS: BEAUTY JOURNEY & REBOOK
  // ==========================================

  if (tileBeautyJourney) {
    tileBeautyJourney.addEventListener('click', () => {
      navigateTo('screenBeautyJourney');
      loadBeautyJourney(state.journeyFilter || 'all');
    });
  }

  // DAY 4: Beauty Quiz tile in Profile opens Quiz or Results directly
  if (tileBeautyProfile) {
    tileBeautyProfile.addEventListener('click', () => {
      if (state.quizResult) {
        navigateTo('screenQuizResults');
        renderQuizResults(state.quizResult);
      } else {
        startQuiz();
      }
    });
  }

  if (btnJourneyBack) {
    btnJourneyBack.addEventListener('click', () => {
      navigateTo('screenProfile');
    });
  }

  if (btnRetryJourney) {
    btnRetryJourney.addEventListener('click', () => {
      loadBeautyJourney(state.journeyFilter || 'all');
    });
  }

  // Category Filter Pills Toggle
  journeyFilterPills.forEach(pill => {
    pill.addEventListener('click', () => {
      const cat = pill.dataset.category;
      loadBeautyJourney(cat);
    });
  });

  // Rebook Modal Buttons
  if (btnCloseRebookModal) {
    btnCloseRebookModal.addEventListener('click', closeRebookModal);
  }

  if (btnCancelRebook) {
    btnCancelRebook.addEventListener('click', closeRebookModal);
  }

  if (btnProceedRebook) {
    btnProceedRebook.addEventListener('click', handleProceedRebook);
  }

  // ==========================================
  // DAY 4: BEAUTY QUIZ & RECOMMENDATIONS CONTROLLER
  // ==========================================

  // SVG Icon generator for quiz cards matching Group 52.png
  function getOptionIconSvg(iconKey) {
    switch (iconKey) {
      case 'frizz':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M9.59 4.59A2 2 0 1 1 11 8H2m10.59 11.41A2 2 0 1 0 14 16H2m15.73-8.27A2.5 2.5 0 1 1 19.5 12H2"></path></svg>`;
      case 'volume':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>`;
      case 'color':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"></path></svg>`;
      case 'damage':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path></svg>`;
      case 'scalp':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"></path><path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"></path></svg>`;
      case 'straight':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="2" x2="8" y2="22"></line><line x1="16" y1="2" x2="16" y2="22"></line></svg>`;
      case 'wavy':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12c2.5-3 5.5-3 8 0s5.5 3 8 0 5.5-3 8 0"></path></svg>`;
      case 'curly':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="8"></circle><path d="M12 8a4 4 0 1 0 4 4"></path></svg>`;
      case 'coily':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 12a4 4 0 0 1 8 0 4 4 0 0 1 8 0"></path><path d="M4 16a4 4 0 0 0 8 0 4 4 0 0 0 8 0"></path></svg>`;
      case 'combination':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><path d="M12 2a10 10 0 0 0 0 20z"></path></svg>`;
      case 'dry':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2"></path></svg>`;
      case 'normal':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><path d="M8 12s1.5 2 4 2 4-2 4-2"></path></svg>`;
      case 'sensitive':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"></path></svg>`;
      case 'oily':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"></path><circle cx="12" cy="14" r="2"></circle></svg>`;
      case 'hydration':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"></path></svg>`;
      case 'glow':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4"></path></svg>`;
      case 'fortify':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>`;
      case 'style':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><circle cx="6" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><line x1="20" y1="4" x2="8.12" y2="15.88"></line><line x1="14.47" y1="14.48" x2="20" y2="20"></line></svg>`;
      case 'sulfate_free':
      case 'all_clear':
      case 'vegan':
      case 'fragrance_free':
      case 'ammonia_free':
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path><path d="m9 12 2 2 4-4"></path></svg>`;
      default:
        return `<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 14 14"></polyline></svg>`;
    }
  }

  async function loadQuizState() {
    try {
      const res = await window.vioraApi.getQuizResult();
      if (res && res.success && res.data) {
        state.quizResult = res.data;
        if (profileQuizSummary) {
          profileQuizSummary.textContent = res.data.profileArchetype || 'Completed';
        }
      } else {
        state.quizResult = null;
        if (profileQuizSummary) {
          profileQuizSummary.textContent = 'Take Quiz';
        }
      }
    } catch {
      // Graceful background fallback
    }
  }

  async function startQuiz() {
    try {
      setGlobalLoading(true, 'Preparing your Beauty Quiz...');
      if (!state.quizQuestions || state.quizQuestions.length === 0) {
        const res = await window.vioraApi.getQuizQuestions();
        if (res && res.success && Array.isArray(res.data)) {
          state.quizQuestions = res.data;
        } else {
          throw new Error('Failed to retrieve quiz questions.');
        }
      }

      // Prefill previous answers if available for retake convenience
      if (state.quizResult && state.quizResult.answers) {
        const a = state.quizResult.answers;
        state.quizAnswers = {
          hairType: a.hairType || '',
          hairConcerns: Array.isArray(a.hairConcerns) ? [...a.hairConcerns] : [],
          skinType: a.skinType || '',
          goals: Array.isArray(a.goals) ? [...a.goals] : [],
          sensitivities: Array.isArray(a.sensitivities) ? [...a.sensitivities] : []
        };
      } else {
        state.quizAnswers = {
          hairType: '',
          hairConcerns: [],
          skinType: '',
          goals: [],
          sensitivities: []
        };
      }

      state.currentQuizStepIndex = 0;
      renderQuizStep(state.currentQuizStepIndex);
      navigateTo('screenBeautyQuiz');
    } catch (err) {
      console.error('Error starting quiz:', err);
      showToast(err.message || 'Could not load quiz questions.', 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  function renderQuizStep(stepIndex) {
    if (!state.quizQuestions || stepIndex >= state.quizQuestions.length) return;

    const q = state.quizQuestions[stepIndex];
    const totalSteps = state.quizQuestions.length;

    // Header & Progress (Group 52.png)
    quizStepNumberTag.textContent = `STEP ${stepIndex + 1} OF ${totalSteps}`;
    quizStepCategoryTag.textContent = q.category || 'Profile';
    const progressPercent = Math.round(((stepIndex + 1) / totalSteps) * 100);
    quizProgressFill.style.width = `${progressPercent}%`;

    // Question title & subtitle
    quizQuestionTitle.textContent = q.title;
    quizQuestionSubtitle.textContent = q.subtitle;

    // Build Options
    quizOptionsList.innerHTML = '';
    const currentVal = state.quizAnswers[q.id];

    q.options.forEach(opt => {
      const isSelected = q.isMultiSelect
        ? (Array.isArray(currentVal) && currentVal.includes(opt.id))
        : (currentVal === opt.id);

      const card = document.createElement('div');
      card.className = `quiz-option-card ${isSelected ? 'selected' : ''}`;
      card.setAttribute('role', q.isMultiSelect ? 'checkbox' : 'radio');
      card.setAttribute('aria-checked', isSelected ? 'true' : 'false');
      card.tabIndex = 0;

      card.innerHTML = `
        <div class="quiz-option-icon">
          ${getOptionIconSvg(opt.icon)}
        </div>
        <div class="quiz-option-content">
          <div class="quiz-option-name">${escapeHtml(opt.title)}</div>
          <div class="quiz-option-desc">${escapeHtml(opt.description || '')}</div>
        </div>
        <div class="quiz-option-check">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="3">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
        </div>
      `;

      card.addEventListener('click', () => {
        handleOptionSelection(q, opt.id);
      });

      card.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          handleOptionSelection(q, opt.id);
        }
      });

      quizOptionsList.appendChild(card);
    });

    // Navigation buttons state
    if (stepIndex > 0) {
      btnQuizPrev.style.display = 'block';
    } else {
      btnQuizPrev.style.display = 'none';
    }

    if (stepIndex === totalSteps - 1) {
      btnQuizNextText.textContent = 'SUBMIT QUIZ';
    } else {
      btnQuizNextText.textContent = 'NEXT';
    }
  }

  function handleOptionSelection(question, optionId) {
    if (question.isMultiSelect) {
      let currentArr = Array.isArray(state.quizAnswers[question.id]) ? [...state.quizAnswers[question.id]] : [];

      if (optionId === 'No Sensitivities') {
        currentArr = ['No Sensitivities'];
      } else {
        // If clicking another option while 'No Sensitivities' is checked, remove it
        currentArr = currentArr.filter(id => id !== 'No Sensitivities');

        if (currentArr.includes(optionId)) {
          currentArr = currentArr.filter(id => id !== optionId);
        } else {
          currentArr.push(optionId);
        }
      }
      state.quizAnswers[question.id] = currentArr;
    } else {
      state.quizAnswers[question.id] = optionId;
    }

    renderQuizStep(state.currentQuizStepIndex);
  }

  function validateCurrentQuizStep() {
    const q = state.quizQuestions[state.currentQuizStepIndex];
    if (!q || !q.required) return true;

    const val = state.quizAnswers[q.id];
    if (q.isMultiSelect) {
      if (!Array.isArray(val) || val.length === 0) {
        showToast('Please select at least one option to continue.', 'info');
        return false;
      }
    } else {
      if (!val || typeof val !== 'string' || !val.trim()) {
        showToast('Please select an option to continue.', 'info');
        return false;
      }
    }
    return true;
  }

  function handleQuizNextStep() {
    if (!validateCurrentQuizStep()) {
      return;
    }

    if (state.currentQuizStepIndex < state.quizQuestions.length - 1) {
      state.currentQuizStepIndex++;
      renderQuizStep(state.currentQuizStepIndex);
      const container = document.getElementById('appContainer');
      if (container) container.scrollTop = 0;
    } else {
      submitQuizForm();
    }
  }

  function handleQuizPrevStep() {
    if (state.currentQuizStepIndex > 0) {
      state.currentQuizStepIndex--;
      renderQuizStep(state.currentQuizStepIndex);
      const container = document.getElementById('appContainer');
      if (container) container.scrollTop = 0;
    }
  }

  async function submitQuizForm() {
    if (state.isSubmittingQuiz) return;

    state.isSubmittingQuiz = true;
    setButtonLoading(btnQuizNext, true);

    try {
      const response = await window.vioraApi.submitQuiz(state.quizAnswers);
      if (response && response.success && response.data) {
        state.quizResult = response.data;
        showToast('Your personalized recommendations are ready!', 'success');
        if (profileQuizSummary) {
          profileQuizSummary.textContent = response.data.profileArchetype || 'Completed';
        }
        renderQuizResults(state.quizResult);
        navigateTo('screenQuizResults');
      } else {
        throw new Error(response.message || 'Failed to submit quiz.');
      }
    } catch (err) {
      console.error('Error submitting quiz:', err);
      showToast(err.message || 'Submission failed. Please check required fields.', 'error');
    } finally {
      state.isSubmittingQuiz = false;
      setButtonLoading(btnQuizNext, false);
    }
  }

  function renderQuizResults(result) {
    if (!result) {
      resultsScrollContainer.style.display = 'none';
      resultsErrorBox.style.display = 'block';
      resultsErrorMessage.textContent = 'No quiz results found. Take the quiz to generate personalized recommendations.';
      return;
    }

    resultsLoadingBox.style.display = 'none';
    resultsErrorBox.style.display = 'none';
    resultsScrollContainer.style.display = 'block';

    // 1. Profile Summary & Chips (Group 53.png)
    profileChipsContainer.innerHTML = '';
    const chips = Array.isArray(result.profileChips) && result.profileChips.length > 0
      ? result.profileChips
      : [
          `Hair: ${result.answers?.hairType || 'Custom'}`,
          `Skin: ${result.answers?.skinType || 'Custom'}`,
          ...(result.answers?.hairConcerns || []).map(c => `Concern: ${c}`)
        ];

    chips.forEach(chipText => {
      const chipEl = document.createElement('span');
      chipEl.className = 'profile-chip';
      chipEl.textContent = chipText;
      profileChipsContainer.appendChild(chipEl);
    });

    archetypeTitle.textContent = result.profileArchetype || 'Luminous Glow & Hydration';
    archetypeSummaryText.textContent = result.summary || 'Specifically curated to restore hydration and enhance natural texture.';

    // 2. Recommended Services (Group 53.png)
    recommendedServicesList.innerHTML = '';
    const services = result.recommendations?.services || [];
    if (services.length === 0) {
      recommendedServicesList.innerHTML = `<p class="state-desc" style="text-align: left; margin: 0;">Our salon stylists are tailoring bespoke services for your profile.</p>`;
    } else {
      services.forEach(srv => {
        const card = document.createElement('div');
        card.className = 'rec-service-card';
        card.innerHTML = `
          <div class="rec-service-header">
            <span class="rec-service-name">${escapeHtml(srv.name)}</span>
            <span class="rec-service-price">${escapeHtml(srv.formattedPrice || ('From ₹' + srv.price))}</span>
          </div>
          <p class="rec-service-desc">${escapeHtml(srv.description)}</p>
          <div class="rec-service-footer">
            <span class="rec-service-duration">Duration: ${srv.duration || 60} mins</span>
            <button type="button" class="btn-rec-book" data-service="${escapeHtml(srv.name)}">Book Now</button>
          </div>
        `;

        const btnBook = card.querySelector('.btn-rec-book');
        if (btnBook) {
          btnBook.addEventListener('click', () => {
            showToast(`Concierge booked: ${srv.name}. Connecting to booking calendar.`, 'info');
          });
        }

        recommendedServicesList.appendChild(card);
      });
    }

    // 3. Prescribed Products (Group 53.png)
    prescribedProductsGrid.innerHTML = '';
    const products = result.recommendations?.products || [];
    if (products.length === 0) {
      prescribedProductsGrid.innerHTML = `<p class="state-desc" style="grid-column: 1 / -1; text-align: left; margin: 0;">Gentle all-around products will be recommended at your next consultation.</p>`;
    } else {
      products.forEach(prod => {
        const card = document.createElement('div');
        card.className = 'rec-product-card';
        card.innerHTML = `
          <div class="rec-product-img-box">
            <img src="${prod.imageUrl}" alt="${escapeHtml(prod.name)}" class="rec-product-img" loading="lazy" onerror="this.src='https://images.unsplash.com/photo-1608248597359-2ff99479b188?w=300&auto=format&fit=crop&q=80'">
          </div>
          <div class="rec-product-info">
            <div class="rec-product-name">${escapeHtml(prod.name)}</div>
            <div class="rec-product-price">${escapeHtml(prod.formattedPrice || ('₹' + prod.price))}</div>
            <div class="rec-product-reason">${escapeHtml(prod.matchReason || '')}</div>
          </div>
        `;
        prescribedProductsGrid.appendChild(card);
      });
    }

    // 4. Matched Stylists (Day 4 Feature D)
    recommendedStylistsList.innerHTML = '';
    const stylists = result.recommendations?.stylists || [];
    if (stylists.length === 0) {
      recommendedStylistsList.innerHTML = `<p class="state-desc" style="text-align: left; margin: 0;">Specialists matching your criteria will be listed as branch schedules become available.</p>`;
    } else {
      stylists.forEach(st => {
        const card = document.createElement('div');
        card.className = 'rec-stylist-card';
        const initials = (st.name || 'S').split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
        card.innerHTML = `
          <div class="rec-stylist-avatar">${initials}</div>
          <div class="rec-stylist-info">
            <div class="rec-stylist-header">
              <span class="rec-stylist-name">${escapeHtml(st.name)}</span>
              <span class="rec-stylist-rating">★ ${st.rating ? st.rating.toFixed(1) : '5.0'}</span>
            </div>
            <div class="rec-stylist-branch">${escapeHtml(st.branchName || 'VIORA Salon')}</div>
            <div class="rec-stylist-reason">${escapeHtml(st.matchReason || '')}</div>
          </div>
        `;
        recommendedStylistsList.appendChild(card);
      });
    }
  }

  // --- DAY 4 EVENT LISTENERS ---
  if (btnQuizBack) {
    btnQuizBack.addEventListener('click', () => {
      navigateTo('screenProfile');
    });
  }

  if (btnQuizPrev) {
    btnQuizPrev.addEventListener('click', handleQuizPrevStep);
  }

  if (btnQuizNext) {
    btnQuizNext.addEventListener('click', handleQuizNextStep);
  }

  if (btnResultsBack) {
    btnResultsBack.addEventListener('click', () => {
      navigateTo('screenProfile');
    });
  }

  if (btnRetakeQuiz) {
    btnRetakeQuiz.addEventListener('click', startQuiz);
  }

  if (btnRetryResults) {
    btnRetryResults.addEventListener('click', async () => {
      setGlobalLoading(true, 'Refreshing recommendations...');
      try {
        const res = await window.vioraApi.getQuizResult();
        if (res && res.success && res.data) {
          state.quizResult = res.data;
          renderQuizResults(state.quizResult);
        } else {
          startQuiz();
        }
      } catch (err) {
        showToast(err.message || 'Failed to refresh.', 'error');
      } finally {
        setGlobalLoading(false);
      }
    });
  }

  // ==========================================
  // DAY 5: ADMIN CUSTOMER MANAGEMENT CONTROLLER
  // Unified identity, retention, segments & history
  // ==========================================

  function formatShortDate(dateVal) {
    if (!dateVal) return '--';
    const d = new Date(dateVal);
    if (isNaN(d.getTime())) return '--';
    const day = d.getDate().toString().padStart(2, '0');
    const month = d.toLocaleString('en-US', { month: 'short' });
    const year = d.getFullYear();
    return `${day} ${month} ${year}`;
  }

  function getRetentionBadgeClass(status) {
    const s = String(status || '').trim().toLowerCase();
    if (s === 'active') return 'badge-active';
    if (s.includes('engagement')) return 'badge-needs-engagement';
    if (s.includes('risk')) return 'badge-at-risk';
    if (s === 'new') return 'badge-new';
    return 'badge-novisits';
  }

  async function loadAdminDashboard() {
    if (adminLoadingBox) adminLoadingBox.style.display = 'flex';
    if (adminErrorBox) adminErrorBox.style.display = 'none';
    if (adminEmptyBox) adminEmptyBox.style.display = 'none';
    if (adminCustomersList) adminCustomersList.innerHTML = '';
    if (adminCustomerCountLabel) adminCustomerCountLabel.textContent = 'Loading directory...';

    try {
      // 1. Fetch overview analytics (non-blocking)
      window.vioraApi.getAdminOverview().then(res => {
        if (res && res.success && res.data) {
          state.adminOverview = res.data;
          renderAdminOverview(res.data);
        }
      }).catch(err => console.warn('Admin overview fetch warning:', err));

      // 2. Fetch customer list
      const listRes = await window.vioraApi.getAdminCustomers({
        search: state.adminSearch,
        segment: state.adminSegment
      });

      if (listRes && listRes.success) {
        state.adminCustomers = listRes.data || [];
        renderAdminCustomersList(state.adminCustomers, listRes.totalCount);
      } else {
        throw new Error(listRes.message || 'Failed to load customer list.');
      }
    } catch (err) {
      console.error('Error in loadAdminDashboard:', err);
      if (adminLoadingBox) adminLoadingBox.style.display = 'none';
      if (adminErrorBox) {
        adminErrorBox.style.display = 'flex';
        if (adminErrorMessage) adminErrorMessage.textContent = err.message || 'Could not connect to admin customer directory.';
      }
      showToast(err.message || 'Failed to load customers.', 'error');
    } finally {
      if (adminLoadingBox) adminLoadingBox.style.display = 'none';
    }
  }

  function renderAdminOverview(overview) {
    if (!overview) return;
    if (kpiTotalCustomers) kpiTotalCustomers.textContent = overview.totalCustomers || 0;
    if (kpiVisitsCount) kpiVisitsCount.textContent = `${overview.totalCompletedVisits || 0} completed visits`;
    if (kpiRepeatRate) kpiRepeatRate.textContent = `${overview.repeatCustomerRate || 0}%`;
    if (kpiReturningCount) kpiReturningCount.textContent = `${overview.segments?.returning || 0} repeat clients`;
    if (kpiActiveClients) kpiActiveClients.textContent = overview.segments?.active || 0;
    if (kpiMultiBranch) kpiMultiBranch.textContent = overview.segments?.multiBranch || 0;
  }

  function renderAdminCustomersList(customers, totalCount) {
    if (adminLoadingBox) adminLoadingBox.style.display = 'none';

    const count = totalCount !== undefined ? totalCount : (customers ? customers.length : 0);
    if (adminCustomerCountLabel) {
      adminCustomerCountLabel.textContent = `${count} Client${count === 1 ? '' : 's'} in Directory`;
    }

    if (!customers || customers.length === 0) {
      if (adminEmptyBox) adminEmptyBox.style.display = 'flex';
      if (adminCustomersList) adminCustomersList.innerHTML = '';
      return;
    }

    if (adminEmptyBox) adminEmptyBox.style.display = 'none';
    if (adminErrorBox) adminErrorBox.style.display = 'none';

    let html = '';
    customers.forEach(c => {
      const initials = (c.name || 'C').split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
      const badgeClass = getRetentionBadgeClass(c.retentionStatus);
      const visitsText = `${c.totalCompletedVisits || 0} Visit${c.totalCompletedVisits === 1 ? '' : 's'}`;

      let lastVisitInfo = 'No completed visits yet';
      if (c.lastCompletedVisit) {
        const visitDate = formatShortDate(c.lastCompletedVisit.date);
        lastVisitInfo = `${visitDate} • ${escapeHtml(c.lastCompletedVisit.serviceName)} (${escapeHtml(c.lastCompletedVisit.branchName)})`;
      }

      html += `
        <div class="admin-customer-card" data-customer-id="${escapeHtml(c.customerId)}" tabindex="0" role="button" aria-label="View ${escapeHtml(c.name)} details">
          <div class="admin-customer-card-top">
            <div class="admin-customer-identity">
              ${c.profilePhoto ? `<img src="${escapeHtml(c.profilePhoto)}" alt="${escapeHtml(c.name)}" class="admin-customer-avatar" onerror="this.outerHTML='<div class=\\'admin-avatar-initials\\'>${initials}</div>'">` : `<div class="admin-avatar-initials">${initials}</div>`}
              <div class="admin-customer-meta">
                <h4 class="admin-customer-name">${escapeHtml(c.name)}</h4>
                <span class="admin-customer-id-pill">${escapeHtml(c.customerId)}</span>
                <span class="admin-customer-contact">${escapeHtml(c.email)} ${c.phone ? '• ' + escapeHtml(c.phone) : ''}</span>
              </div>
            </div>
            <div class="admin-customer-status-field">
              <span class="admin-retention-badge ${badgeClass}">${escapeHtml(c.retentionStatus || 'New')}</span>
            </div>
          </div>
          <div class="admin-customer-metrics-row">
            <div class="admin-metric-left">
              <span class="admin-visits-pill">${visitsText}</span>
              ${c.branchesVisited && c.branchesVisited.length >= 2 ? `<span class="tag-pill" style="font-size: 9px; padding: 1px 6px;">Multi-Branch (${c.branchesVisited.length})</span>` : ''}
            </div>
            <div class="admin-metric-right">
              <span>Inspect</span>
              <svg class="chevron-arrow" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor">
                <path d="M9 18l6-6-6-6"></path>
              </svg>
            </div>
          </div>
        </div>
      `;
    });

    if (adminCustomersList) {
      adminCustomersList.innerHTML = html;

      adminCustomersList.querySelectorAll('.admin-customer-card').forEach(card => {
        card.addEventListener('click', () => {
          const cId = card.dataset.customerId;
          openAdminCustomerDetail(cId);
        });
        card.addEventListener('keydown', (e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            const cId = card.dataset.customerId;
            openAdminCustomerDetail(cId);
          }
        });
      });
    }
  }

  async function openAdminCustomerDetail(customerId) {
    if (!customerId) return;
    state.selectedAdminCustomer = customerId;
    state.adminHistoryFilter = 'all';

    navigateTo('screenAdminCustomerDetail');

    if (adminDetailLoadingBox) adminDetailLoadingBox.style.display = 'flex';
    if (adminDetailErrorBox) adminDetailErrorBox.style.display = 'none';
    if (adminDetailContent) adminDetailContent.style.display = 'none';

    try {
      const [detailRes, historyRes] = await Promise.all([
        window.vioraApi.getAdminCustomerDetails(customerId),
        window.vioraApi.getAdminCustomerHistory(customerId, 'all')
      ]);

      if (detailRes && detailRes.success && detailRes.data) {
        populateAdminCustomerDetail(detailRes.data);
      } else {
        throw new Error(detailRes.message || 'Could not retrieve customer details.');
      }

      if (historyRes && historyRes.success) {
        state.selectedAdminCustomerHistory = historyRes.data || [];
        updateHistoryCounts(historyRes.counts);
        renderAdminCustomerHistory(state.selectedAdminCustomerHistory, 'all');
      }

      if (adminDetailContent) adminDetailContent.style.display = 'flex';
    } catch (err) {
      console.error('Error in openAdminCustomerDetail:', err);
      if (adminDetailErrorBox) {
        adminDetailErrorBox.style.display = 'flex';
        if (adminDetailErrorMessage) adminDetailErrorMessage.textContent = err.message || 'Could not load client details.';
      }
      showToast(err.message || 'Failed to load client record.', 'error');
    } finally {
      if (adminDetailLoadingBox) adminDetailLoadingBox.style.display = 'none';
    }
  }

  function populateAdminCustomerDetail(data) {
    const profile = data.profile || {};
    const retention = data.retention || {};
    const prefs = data.preferences || {};
    const quiz = data.beautyQuiz;

    if (adminDetailCustomerIdBadge) adminDetailCustomerIdBadge.textContent = profile.customerId || 'CUST-0000';
    if (adminDetailIdPill) adminDetailIdPill.textContent = profile.customerId || 'CUST-0000';
    if (adminDetailName) adminDetailName.textContent = profile.name || 'Client';
    if (adminDetailContact) {
      adminDetailContact.textContent = `${profile.email || ''} ${profile.phone ? '• ' + profile.phone : ''}`;
    }

    const defaultAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80';
    if (adminDetailAvatarImg) {
      adminDetailAvatarImg.src = profile.profilePhoto && profile.profilePhoto.trim() ? profile.profilePhoto : defaultAvatar;
      adminDetailAvatarImg.onerror = () => { adminDetailAvatarImg.src = defaultAvatar; };
    }

    if (adminDetailMemberSince) {
      adminDetailMemberSince.textContent = `Member since ${formatShortDate(profile.createdAt)}`;
    }
    if (adminDetailDobPill) {
      if (profile.dateOfBirth) {
        adminDetailDobPill.style.display = 'inline-block';
        adminDetailDobPill.textContent = `DOB: ${formatShortDate(profile.dateOfBirth)}`;
      } else {
        adminDetailDobPill.style.display = 'none';
      }
    }

    // Retention metrics
    if (adminDetailCompletedVisits) adminDetailCompletedVisits.textContent = retention.totalCompletedVisits || 0;
    if (adminDetailTotalSpend) adminDetailTotalSpend.textContent = formatPrice(retention.totalSpend || 0);
    if (adminDetailRetentionStatusPill) {
      adminDetailRetentionStatusPill.textContent = retention.retentionStatus || 'New';
    }

    if (adminDetailLastVisitText) {
      if (retention.lastCompletedVisit) {
        adminDetailLastVisitText.textContent = `${formatShortDate(retention.lastCompletedVisit.date)} (${escapeHtml(retention.lastCompletedVisit.serviceName)} at ${escapeHtml(retention.lastCompletedVisit.branchName)})`;
      } else {
        adminDetailLastVisitText.textContent = 'No completed visits recorded';
      }
    }

    if (adminDetailBranchesText) {
      const branches = retention.branchesVisited || [];
      if (branches.length === 0) {
        adminDetailBranchesText.textContent = 'None yet';
      } else {
        adminDetailBranchesText.textContent = `${branches.length} Branch${branches.length === 1 ? '' : 'es'}: ${branches.join(', ')}`;
      }
    }

    // Segment tags
    if (adminDetailSegmentTags) {
      const tags = retention.segmentTags || [];
      adminDetailSegmentTags.innerHTML = tags.map(t => `<span class="tag-pill">${escapeHtml(t)}</span>`).join('');
    }

    // Preferences categories
    if (adminDetailPreferencesContainer) {
      const categories = [
        { key: 'hair', label: 'Hair Styling & Care', items: prefs.hair || [] },
        { key: 'nails', label: 'Nails & Finishes', items: prefs.nails || [] },
        { key: 'skin', label: 'Skin & Facials', items: prefs.skin || [] },
        { key: 'makeup', label: 'Makeup & Artistry', items: prefs.makeup || [] }
      ];

      let prefHtml = '';
      categories.forEach(cat => {
        prefHtml += `
          <div class="admin-pref-category-block">
            <span class="admin-pref-cat-name">${cat.label}</span>
            <div class="admin-pref-chips-list">
              ${cat.items && cat.items.length > 0 ? cat.items.map(i => `<span class="admin-view-chip">${escapeHtml(i)}</span>`).join('') : '<span class="state-desc" style="font-size: 11px; margin: 0;">No preferences recorded</span>'}
            </div>
          </div>
        `;
      });
      adminDetailPreferencesContainer.innerHTML = prefHtml;
    }

    // Beauty Quiz
    if (adminDetailQuizCard) {
      if (quiz) {
        adminDetailQuizCard.style.display = 'flex';
        if (adminDetailArchetypeTitle) adminDetailArchetypeTitle.textContent = quiz.archetype || 'Personalized Care';
        if (adminDetailArchetypeSummary) adminDetailArchetypeSummary.textContent = quiz.summary || '';
        if (adminDetailQuizChipsContainer) {
          const chips = quiz.profileChips || [];
          adminDetailQuizChipsContainer.innerHTML = chips.map(ch => `<span class="beauty-profile-chip">${escapeHtml(ch)}</span>`).join('');
        }
      } else {
        adminDetailQuizCard.style.display = 'none';
      }
    }
  }

  function updateHistoryCounts(counts) {
    if (!counts) return;
    if (countHistAll) countHistAll.textContent = counts.total || 0;
    if (countHistCompleted) countHistCompleted.textContent = counts.completed || 0;
    if (countHistUpcoming) countHistUpcoming.textContent = counts.upcoming || 0;
    if (countHistCancelled) countHistCancelled.textContent = counts.cancelled || 0;
    if (adminHistoryTotalBadge) adminHistoryTotalBadge.textContent = `${counts.total || 0} Records`;
  }

  function renderAdminCustomerHistory(historyItems, statusFilter = 'all') {
    state.adminHistoryFilter = statusFilter;

    if (adminHistoryFilterBar) {
      adminHistoryFilterBar.querySelectorAll('.history-filter-pill').forEach(pill => {
        const isActive = pill.dataset.historyStatus === statusFilter;
        pill.classList.toggle('active', isActive);
        pill.setAttribute('aria-selected', isActive ? 'true' : 'false');
      });
    }

    let filtered = historyItems;
    if (statusFilter === 'Completed') {
      filtered = historyItems.filter(h => h.status === 'Completed');
    } else if (statusFilter === 'Upcoming') {
      filtered = historyItems.filter(h => h.status === 'Pending' || h.status === 'Confirmed');
    } else if (statusFilter === 'Cancelled') {
      filtered = historyItems.filter(h => h.status === 'Cancelled' || h.status === 'No-show');
    }

    if (!filtered || filtered.length === 0) {
      if (adminHistoryEmptyBox) adminHistoryEmptyBox.style.display = 'block';
      if (adminHistoryTimelineContent) adminHistoryTimelineContent.innerHTML = '';
      return;
    }

    if (adminHistoryEmptyBox) adminHistoryEmptyBox.style.display = 'none';

    let html = '';
    filtered.forEach(h => {
      const serviceName = h.service ? h.service.name : 'Salon Treatment';
      const category = h.service ? h.service.category : 'General';
      const price = h.service ? formatPrice(h.service.price) : '₹0';
      const branchName = h.branch ? h.branch.name : 'VIORA Salon';
      const branchAddress = h.branch ? h.branch.address : '';
      const stylistName = h.stylist ? h.stylist.name : 'VIORA Specialist';
      const apptDate = formatShortDate(h.date);
      const apptTime = h.startTime ? `${h.startTime} - ${h.endTime || ''}` : '';

      let statusBadgeClass = 'status-completed';
      if (h.status === 'Pending' || h.status === 'Confirmed') statusBadgeClass = 'status-upcoming';
      if (h.status === 'Cancelled' || h.status === 'No-show') statusBadgeClass = 'status-cancelled';

      html += `
        <div class="admin-history-card">
          <div class="admin-hist-header">
            <h4 class="admin-hist-service-name">${escapeHtml(serviceName)}</h4>
            <span class="admin-hist-status-badge ${statusBadgeClass}">${escapeHtml(h.status)}</span>
          </div>
          <div class="admin-hist-details">
            <div><strong>Branch:</strong> ${escapeHtml(branchName)} ${branchAddress ? `<span style="color: var(--color-text-light);">(${escapeHtml(branchAddress)})</span>` : ''}</div>
            <div><strong>Stylist:</strong> ${escapeHtml(stylistName)}</div>
            <div><strong>Category:</strong> ${escapeHtml(category)} • <strong>Price:</strong> ${price}</div>
          </div>
          <div class="admin-hist-meta-row">
            <span>Date: ${apptDate} ${apptTime ? '• ' + apptTime : ''}</span>
            <span>ID: ${escapeHtml(h.appointmentId)}</span>
          </div>
        </div>
      `;
    });

    if (adminHistoryTimelineContent) {
      adminHistoryTimelineContent.innerHTML = html;
    }
  }

  // --- DAY 5 ADMIN EVENT LISTENERS ---
  if (btnDemoAdminLogin) {
    btnDemoAdminLogin.addEventListener('click', handleDemoAdminLogin);
  }

  if (tileAdminCustomers) {
    tileAdminCustomers.addEventListener('click', () => {
      navigateTo('screenAdminCustomers');
      loadAdminDashboard();
    });
  }

  if (btnAdminBackToClient) {
    btnAdminBackToClient.addEventListener('click', () => {
      if (state.customerProfile) {
        navigateTo('screenProfile');
      } else {
        loadCustomerProfile();
      }
    });
  }

  if (btnAdminSignOut) {
    btnAdminSignOut.addEventListener('click', handleSignOut);
  }

  if (btnAdminCustomerDetailBack) {
    btnAdminCustomerDetailBack.addEventListener('click', () => {
      navigateTo('screenAdminCustomers');
    });
  }

  if (btnRefreshAdminList) {
    btnRefreshAdminList.addEventListener('click', () => {
      loadAdminDashboard();
    });
  }

  if (btnRetryAdminCustomers) {
    btnRetryAdminCustomers.addEventListener('click', () => {
      loadAdminDashboard();
    });
  }

  if (btnRetryAdminDetail) {
    btnRetryAdminDetail.addEventListener('click', () => {
      openAdminCustomerDetail(state.selectedAdminCustomer);
    });
  }

  // Search Input Debounce
  if (adminSearchInput) {
    let searchDebounceTimer;
    adminSearchInput.addEventListener('input', () => {
      clearTimeout(searchDebounceTimer);
      state.adminSearch = adminSearchInput.value.trim();
      if (btnClearAdminSearch) {
        btnClearAdminSearch.style.display = state.adminSearch ? 'block' : 'none';
      }
      searchDebounceTimer = setTimeout(() => {
        loadAdminDashboard();
      }, 300);
    });
  }

  if (btnClearAdminSearch) {
    btnClearAdminSearch.addEventListener('click', () => {
      adminSearchInput.value = '';
      state.adminSearch = '';
      btnClearAdminSearch.style.display = 'none';
      loadAdminDashboard();
    });
  }

  // Segment Filter Bar Pills
  if (adminSegmentFilterBar) {
    adminSegmentFilterBar.querySelectorAll('.admin-filter-pill').forEach(pill => {
      pill.addEventListener('click', () => {
        adminSegmentFilterBar.querySelectorAll('.admin-filter-pill').forEach(p => {
          p.classList.remove('active');
          p.setAttribute('aria-selected', 'false');
        });
        pill.classList.add('active');
        pill.setAttribute('aria-selected', 'true');
        state.adminSegment = pill.dataset.segment;
        loadAdminDashboard();
      });
    });
  }

  // History Filter Bar Pills
  if (adminHistoryFilterBar) {
    adminHistoryFilterBar.querySelectorAll('.history-filter-pill').forEach(pill => {
      pill.addEventListener('click', () => {
        const status = pill.dataset.historyStatus;
        renderAdminCustomerHistory(state.selectedAdminCustomerHistory, status);
      });
    });
  }

  // =========================================================================
  // PERSON 3: INSPIRATION, REVIEWS, NOTIFICATIONS & ANALYTICS MODULE
  // =========================================================================
  state.inspReferenceImages = [];
  state.activeInspCategory = 'All';
  state.compareMode = false;
  state.selectedInspRequestId = null;
  state.reviewStylistRating = 5;
  state.reviewLookRating = 5;

  // Selectors for Person 3
  const tileInspiration = document.getElementById('tileInspiration');
  const tileReviews = document.getElementById('tileReviews');
  const tileNotifications = document.getElementById('tileNotifications');
  const tileStylistPortal = document.getElementById('tileStylistPortal');
  const tileAdminAnalytics = document.getElementById('tileAdminAnalytics');

  const btnInspBack = document.getElementById('btnInspBack');
  const btnOpenInspirationForm = document.getElementById('btnOpenInspirationForm');
  const btnInspReqBack = document.getElementById('btnInspReqBack');
  const btnInspResponsesBack = document.getElementById('btnInspResponsesBack');
  const btnReviewsBack = document.getElementById('btnReviewsBack');
  const btnNotifBack = document.getElementById('btnNotifBack');
  const btnStylistPortalBack = document.getElementById('btnStylistPortalBack');
  const btnAdminAnalyticsBack = document.getElementById('btnAdminAnalyticsBack');

  // Bottom Nav Elements
  const navTabProfile = document.getElementById('navTabProfile');
  const navTabInspiration = document.getElementById('navTabInspiration');
  const navTabReviews = document.getElementById('navTabReviews');
  const navTabNotifications = document.getElementById('navTabNotifications');
  const navTabDashboard = document.getElementById('navTabDashboard');
  const navNotifDot = document.getElementById('navNotifDot');

  // Bottom Nav Navigation Wireup
  if (navTabProfile) navTabProfile.addEventListener('click', () => navigateTo('screenProfile'));
  if (navTabInspiration) navTabInspiration.addEventListener('click', () => { navigateTo('screenInspiration'); loadInspirationFeed(); });
  if (navTabReviews) navTabReviews.addEventListener('click', () => { navigateTo('screenReviews'); loadReviewsScreen(); });
  if (navTabNotifications) navTabNotifications.addEventListener('click', () => { navigateTo('screenNotifications'); loadNotificationsScreen(); });
  if (navTabDashboard) navTabDashboard.addEventListener('click', () => {
    const user = window.vioraApi.getUser();
    if (user && (user.role === 'admin' || user.role === 'branch_manager')) {
      navigateTo('screenAdminAnalytics');
      loadAdminAnalyticsScreen();
    } else if (user && user.role === 'stylist') {
      navigateTo('screenStylistPortal');
      loadStylistPortalScreen();
    } else {
      navigateTo('screenInspiration');
      loadInspirationFeed();
    }
  });

  // Profile Tile Wireup
  if (tileInspiration) tileInspiration.addEventListener('click', () => { navigateTo('screenInspiration'); loadInspirationFeed(); });
  if (tileReviews) tileReviews.addEventListener('click', () => { navigateTo('screenReviews'); loadReviewsScreen(); });
  if (tileNotifications) tileNotifications.addEventListener('click', () => { navigateTo('screenNotifications'); loadNotificationsScreen(); });
  if (tileStylistPortal) tileStylistPortal.addEventListener('click', () => { navigateTo('screenStylistPortal'); loadStylistPortalScreen(); });
  if (tileAdminAnalytics) tileAdminAnalytics.addEventListener('click', () => { navigateTo('screenAdminAnalytics'); loadAdminAnalyticsScreen(); });

  // Back Buttons
  if (btnInspBack) btnInspBack.addEventListener('click', () => navigateTo('screenProfile'));
  if (btnInspReqBack) btnInspReqBack.addEventListener('click', () => navigateTo('screenInspiration'));
  if (btnInspResponsesBack) btnInspResponsesBack.addEventListener('click', () => navigateTo('screenInspiration'));
  if (btnReviewsBack) btnReviewsBack.addEventListener('click', () => navigateTo('screenProfile'));
  if (btnNotifBack) btnNotifBack.addEventListener('click', () => navigateTo('screenProfile'));
  if (btnStylistPortalBack) btnStylistPortalBack.addEventListener('click', () => navigateTo('screenProfile'));
  if (btnAdminAnalyticsBack) btnAdminAnalyticsBack.addEventListener('click', () => navigateTo('screenProfile'));

  if (btnOpenInspirationForm) {
    btnOpenInspirationForm.addEventListener('click', () => openNewInspirationForm());
  }

  // ==========================================
  // INSPIRATION MODULE FUNCTIONS
  // ==========================================
  async function loadInspirationFeed() {
    try {
      setGlobalLoading(true);

      // Load branches if not cached
      if (!state.branches || state.branches.length === 0) {
        const branchRes = await window.vioraApi.getBranches().catch(() => null);
        if (branchRes && branchRes.data) {
          state.branches = branchRes.data;
        }
      }

      // 1. Load active client inspiration requests
      const reqRes = await window.vioraApi.getInspirationRequests().catch(() => null);
      renderMyInspirationRequests(reqRes && reqRes.data ? reqRes.data : []);

      // 2. Load discovery feed
      const discRes = await window.vioraApi.getDiscovery(state.activeInspCategory).catch(() => null);
      renderDiscoveryGrid(discRes && discRes.data ? discRes.data : []);

    } catch (err) {
      console.error('Error loading inspiration feed:', err);
      showToast('Could not load inspiration feed.', 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  function renderMyInspirationRequests(requests) {
    const container = document.getElementById('myRequestsContainer');
    const badge = document.getElementById('myRequestsCountBadge');
    if (!container) return;

    if (badge) badge.textContent = `${requests.length} Request${requests.length === 1 ? '' : 's'}`;

    if (!requests || requests.length === 0) {
      container.innerHTML = `
        <div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 16px; text-align: center;">
          <p style="font-size: 12px; color: var(--color-text-muted); margin-bottom: 8px;">No active look consultations yet.</p>
          <button type="button" class="btn-secondary" id="btnEmptyNewInsp" style="padding: 6px 12px; font-size: 11px;">+ Request Custom Look</button>
        </div>
      `;
      const btn = document.getElementById('btnEmptyNewInsp');
      if (btn) btn.addEventListener('click', () => openNewInspirationForm());
      return;
    }

    container.innerHTML = requests.map(req => {
      let statusClass = 'status-pending';
      let statusLabel = 'Awaiting Stylists';
      if (req.status === 'responded') { statusClass = 'status-responded'; statusLabel = 'Proposals Ready'; }
      if (req.status === 'accepted') { statusClass = 'status-accepted'; statusLabel = 'Stylist Selected'; }
      if (req.status === 'declined') { statusClass = 'status-declined'; statusLabel = 'Declined'; }

      const dateStr = req.createdAt ? new Date(req.createdAt).toLocaleDateString() : '';
      const thumb = (req.referenceImages && req.referenceImages.length > 0)
        ? req.referenceImages[0]
        : 'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=200&auto=format&fit=crop&q=80';

      return `
        <div class="request-summary-card" data-req-id="${req.requestId}" style="cursor: pointer;" tabindex="0">
          <div class="request-card-header">
            <span class="request-status-pill ${statusClass}">${statusLabel}</span>
            <span style="font-size: 11px; color: var(--color-text-light);">${req.requestId} • ${dateStr}</span>
          </div>
          <div style="display: flex; gap: 12px; align-items: center; margin-top: 6px;">
            <img src="${thumb}" alt="Ref" style="width: 48px; height: 48px; border-radius: var(--radius-sm); object-fit: cover; flex-shrink: 0;">
            <div style="flex: 1; min-width: 0;">
              <h5 style="font-family: var(--font-serif); font-size: 15px; margin-bottom: 2px;">${req.category} Bespoke Look</h5>
              <p style="font-size: 11.5px; color: var(--color-text-muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${req.description || ''}</p>
            </div>
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"></path></svg>
          </div>
        </div>
      `;
    }).join('');

    container.querySelectorAll('.request-summary-card').forEach(card => {
      card.addEventListener('click', () => {
        const rId = card.dataset.reqId;
        openInspirationResponses(rId);
      });
    });
  }

  function renderDiscoveryGrid(looks) {
    const grid = document.getElementById('discoveryGrid');
    if (!grid) return;

    if (!looks || looks.length === 0) {
      grid.innerHTML = '<p style="font-size: 12px; color: var(--color-text-muted); padding: 16px; text-align: center;">No looks matching this category.</p>';
      return;
    }

    grid.innerHTML = looks.map(look => `
      <div class="inspiration-card">
        <div class="inspiration-card-img-wrap">
          <img src="${look.imageUrl}" alt="${look.title}" class="inspiration-card-img" onerror="this.src='https://images.unsplash.com/photo-1560869713-7d0a29430803?w=600&auto=format&fit=crop&q=80'">
          <span class="inspiration-card-badge">${look.category}</span>
          <span class="inspiration-card-rating">★ ${look.rating || '5.0'}</span>
        </div>
        <div class="inspiration-card-body">
          <h4 class="inspiration-card-title">${look.title}</h4>
          <div class="inspiration-card-meta">
            <span>By ${look.stylistName || 'Master Stylist'}</span>
            <span>${look.branchName || 'MAISON'}</span>
          </div>
          <p class="inspiration-card-desc">${look.description || ''}</p>
          <div class="inspiration-card-footer">
            <button type="button" class="btn-secondary btn-request-this-look" data-title="${look.title}" data-category="${look.category}" style="padding: 6px 12px; font-size: 11px;">
              Request Similar Look
            </button>
          </div>
        </div>
      </div>
    `).join('');

    grid.querySelectorAll('.btn-request-this-look').forEach(btn => {
      btn.addEventListener('click', () => {
        openNewInspirationForm(btn.dataset.category, `Inspired by ${btn.dataset.title}: `);
      });
    });
  }

  // Category filter chips in Inspiration Home
  const inspCategoryFilterScroll = document.getElementById('inspCategoryFilterScroll');
  if (inspCategoryFilterScroll) {
    inspCategoryFilterScroll.querySelectorAll('.category-chip-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        inspCategoryFilterScroll.querySelectorAll('.category-chip-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.activeInspCategory = btn.dataset.category;
        loadInspirationFeed();
      });
    });
  }

  // ==========================================
  // INSPIRATION REQUEST FORM
  // ==========================================
  function openNewInspirationForm(prefillCategory = 'Hair', prefillDesc = '') {
    state.inspReferenceImages = [];
    renderInspPreviews();

    const catSelect = document.getElementById('inspReqCategory');
    if (catSelect && prefillCategory) catSelect.value = prefillCategory;

    const descInput = document.getElementById('inspReqDesc');
    if (descInput) descInput.value = prefillDesc || '';

    // Populate branch select
    const branchSelect = document.getElementById('inspReqBranch');
    if (branchSelect && state.branches && state.branches.length > 0) {
      branchSelect.innerHTML = '<option value="">Any MAISON Flagship</option>' +
        state.branches.map(b => `<option value="${b._id}">${b.name} (${b.address || ''})</option>`).join('');
    }

    navigateTo('screenInspirationRequest');
  }

  // Dropzone file handling
  const inspDropzone = document.getElementById('inspDropzone');
  const inspFileInput = document.getElementById('inspFileInput');

  if (inspDropzone && inspFileInput) {
    inspDropzone.addEventListener('click', () => inspFileInput.click());

    inspDropzone.addEventListener('dragover', (e) => {
      e.preventDefault();
      inspDropzone.classList.add('dragover');
    });

    inspDropzone.addEventListener('dragleave', () => inspDropzone.classList.remove('dragover'));

    inspDropzone.addEventListener('drop', (e) => {
      e.preventDefault();
      inspDropzone.classList.remove('dragover');
      if (e.dataTransfer.files) handleInspFiles(e.dataTransfer.files);
    });

    inspFileInput.addEventListener('change', (e) => {
      if (e.target.files) handleInspFiles(e.target.files);
    });
  }

  function handleInspFiles(files) {
    const maxFiles = 5;
    Array.from(files).slice(0, maxFiles - state.inspReferenceImages.length).forEach(file => {
      if (file.size > 5 * 1024 * 1024) {
        showToast(`File ${file.name} exceeds 5MB limit.`, 'error');
        return;
      }
      const reader = new FileReader();
      reader.onload = (e) => {
        state.inspReferenceImages.push(e.target.result);
        renderInspPreviews();
      };
      reader.readAsDataURL(file);
    });
  }

  function renderInspPreviews() {
    const grid = document.getElementById('inspPreviewsGrid');
    if (!grid) return;

    grid.innerHTML = state.inspReferenceImages.map((src, index) => `
      <div class="upload-preview-item">
        <img src="${src}" alt="Preview ${index + 1}" class="upload-preview-img">
        <button type="button" class="upload-preview-remove" data-index="${index}" aria-label="Remove photo">×</button>
      </div>
    `).join('');

    grid.querySelectorAll('.upload-preview-remove').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const idx = parseInt(btn.dataset.index, 10);
        state.inspReferenceImages.splice(idx, 1);
        renderInspPreviews();
      });
    });
  }

  // Submit Inspiration Request Form
  const inspRequestForm = document.getElementById('inspRequestForm');
  if (inspRequestForm) {
    inspRequestForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const desc = document.getElementById('inspReqDesc').value.trim();
      const category = document.getElementById('inspReqCategory').value;
      const preferredBranchId = document.getElementById('inspReqBranch').value || null;
      const preferredDate = document.getElementById('inspReqDate').value || null;
      const flexibleDate = document.getElementById('inspReqFlexible').checked;
      const estimatedBudget = document.getElementById('inspReqBudget').value || null;

      if (!desc) {
        showToast('Please provide a description of your desired look.', 'error');
        return;
      }

      try {
        setGlobalLoading(true);

        const payload = {
          category,
          referenceImages: state.inspReferenceImages,
          description: desc,
          preferredBranchId,
          preferredDate,
          flexibleDate,
          estimatedBudget
        };

        const response = await window.vioraApi.createInspirationRequest(payload);
        if (response && response.success) {
          showToast('Inspiration request dispatched to stylists!', 'success');
          inspRequestForm.reset();
          state.inspReferenceImages = [];
          navigateTo('screenInspiration');
          loadInspirationFeed();
        } else {
          throw new Error(response.message || 'Submission failed');
        }
      } catch (err) {
        console.error('Error submitting inspiration request:', err);
        showToast(err.message || 'Failed to submit request.', 'error');
      } finally {
        setGlobalLoading(false);
      }
    });
  }

  // ==========================================
  // STYLIST RESPONSES & COMPARISON
  // ==========================================
  async function openInspirationResponses(requestId) {
    state.selectedInspRequestId = requestId;
    state.compareMode = false;

    try {
      setGlobalLoading(true);
      const res = await window.vioraApi.getInspirationRequest(requestId);
      if (!res || !res.success || !res.data) {
        throw new Error('Could not retrieve request details.');
      }

      const { request, responses } = res.data;

      // Update Header Summary
      const pill = document.getElementById('respDetailStatusPill');
      if (pill) {
        pill.textContent = request.status.toUpperCase();
        pill.className = `request-status-pill status-${request.status}`;
      }

      const reqIdEl = document.getElementById('respDetailRequestId');
      if (reqIdEl) reqIdEl.textContent = request.requestId;

      const catTitle = document.getElementById('respDetailCategoryTitle');
      if (catTitle) catTitle.textContent = `${request.category} Atelier Consultation`;

      const descText = document.getElementById('respDetailDescText');
      if (descText) descText.textContent = request.description;

      renderStylistResponses(request, responses || []);

      navigateTo('screenInspirationResponses');
    } catch (err) {
      console.error('Error opening inspiration responses:', err);
      showToast(err.message || 'Failed to load responses.', 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  function renderStylistResponses(request, responses) {
    const container = document.getElementById('stylistResponsesContainer');
    const handoffCard = document.getElementById('bookingHandoffCard');
    const handoffTitle = document.getElementById('handoffStylistTitle');
    if (!container) return;

    if (request.status === 'accepted' && request.chosenStylistId) {
      if (handoffCard) handoffCard.style.display = 'block';
    } else {
      if (handoffCard) handoffCard.style.display = 'none';
    }

    if (!responses || responses.length === 0) {
      container.innerHTML = `
        <div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 24px 16px; text-align: center;">
          <p style="font-size: 13px; font-weight: 500; color: var(--color-text-main); margin-bottom: 4px;">Stylists are reviewing your request</p>
          <p style="font-size: 11.5px; color: var(--color-text-muted);">You will receive a notification as soon as our master stylists formulate a look proposal.</p>
        </div>
      `;
      return;
    }

    if (state.compareMode) {
      // Comparison Table Layout
      container.innerHTML = `
        <div class="analytics-table-wrap">
          <table class="analytics-table">
            <thead>
              <tr>
                <th>Stylist</th>
                <th>Rating</th>
                <th>Branch</th>
                <th>Suggested Service</th>
                <th>Est. Price</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              ${responses.map(r => {
                const s = r.stylistId || {};
                const u = s.userId || {};
                const b = s.branchId || {};
                const serv = r.suggestedServiceId || {};
                const isSelected = request.chosenResponseId && (request.chosenResponseId === r._id || request.chosenResponseId._id === r._id);

                return `
                  <tr style="${isSelected ? 'background: #FAF5EF; font-weight: 600;' : ''}">
                    <td>${u.name || 'Master Stylist'}</td>
                    <td>★ ${s.rating || 5.0}</td>
                    <td>${b.name || 'MAISON'}</td>
                    <td>${serv.name || 'Bespoke Atelier Treatment'}</td>
                    <td>${r.estimatedPrice ? '₹' + r.estimatedPrice : 'Standard'}</td>
                    <td>
                      ${isSelected ? '<span style="color: var(--color-success); font-size: 11px;">✓ Selected</span>' : `
                        <button type="button" class="btn-primary btn-choose-stylist" data-resp-id="${r._id}" style="padding: 4px 8px; font-size: 10px;">Select</button>
                      `}
                    </td>
                  </tr>
                `;
              }).join('')}
            </tbody>
          </table>
        </div>
      `;
    } else {
      // Card list layout
      container.innerHTML = responses.map(r => {
        const s = r.stylistId || {};
        const u = s.userId || {};
        const b = s.branchId || {};
        const serv = r.suggestedServiceId || {};
        const isSelected = request.chosenResponseId && (request.chosenResponseId === r._id || request.chosenResponseId._id === r._id);

        const avatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80';

        return `
          <div class="stylist-response-card ${isSelected ? 'selected-stylist' : ''}">
            <div class="stylist-response-header">
              <img src="${avatar}" alt="${u.name}" class="stylist-response-avatar">
              <div class="stylist-response-info">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                  <h4 class="stylist-response-name">${u.name || 'Master Stylist'}</h4>
                  ${isSelected ? '<span class="request-status-pill status-accepted">Selected Stylist</span>' : ''}
                </div>
                <div class="stylist-response-rating">
                  <span style="color: #F59E0B;">★ ${s.rating || 5.0}</span>
                  <span>•</span>
                  <span>${b.name || 'MAISON Atelier'}</span>
                </div>
              </div>
            </div>

            <div class="stylist-response-bubble">
              "${r.message || 'I would love to craft this bespoke look for you.'}"
            </div>

            <div class="stylist-response-details">
              <span>Suggested Service: <strong>${serv.name || 'Bespoke Treatment'}</strong></span>
              <span>Estimated: <strong>${r.estimatedPrice ? '₹' + r.estimatedPrice : 'Standard Pricing'}</strong></span>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 8px;">
              ${isSelected ? `
                <button type="button" class="btn-primary" disabled style="opacity: 0.8; padding: 8px 14px; font-size: 11px;">
                  ✓ Confirmed Selection
                </button>
              ` : `
                <button type="button" class="btn-primary btn-choose-stylist" data-resp-id="${r._id}" style="padding: 8px 14px; font-size: 11px;">
                  Choose This Stylist
                </button>
              `}
            </div>
          </div>
        `;
      }).join('');
    }

    // Attach Choose Stylist click handlers
    container.querySelectorAll('.btn-choose-stylist').forEach(btn => {
      btn.addEventListener('click', async () => {
        const responseId = btn.dataset.respId;
        try {
          setGlobalLoading(true);
          const chooseRes = await window.vioraApi.chooseStylist(request.requestId, { responseId });
          if (chooseRes && chooseRes.success) {
            showToast('Stylist selected! You can now proceed to scheduling.', 'success');
            openInspirationResponses(request.requestId);
          } else {
            throw new Error(chooseRes.message || 'Failed to select stylist');
          }
        } catch (err) {
          console.error('Error choosing stylist:', err);
          showToast(err.message || 'Could not select stylist.', 'error');
        } finally {
          setGlobalLoading(false);
        }
      });
    });
  }

  // Toggle Compare Mode Button
  const btnToggleCompareMode = document.getElementById('btnToggleCompareMode');
  if (btnToggleCompareMode) {
    btnToggleCompareMode.addEventListener('click', () => {
      state.compareMode = !state.compareMode;
      btnToggleCompareMode.textContent = state.compareMode ? 'Standard Cards' : 'Compare Side-by-Side';
      if (state.selectedInspRequestId) {
        openInspirationResponses(state.selectedInspRequestId);
      }
    });
  }

  // Booking Handoff Button
  const btnProceedBookingHandoff = document.getElementById('btnProceedBookingHandoff');
  if (btnProceedBookingHandoff) {
    btnProceedBookingHandoff.addEventListener('click', async () => {
      if (!state.selectedInspRequestId) return;
      try {
        setGlobalLoading(true);
        const handoffRes = await window.vioraApi.getBookingHandoff(state.selectedInspRequestId);
        if (handoffRes && handoffRes.success && handoffRes.data) {
          const payload = handoffRes.data;

          // Dispatch event contract for booking engine integration
          const handoffEvent = new CustomEvent('viora:inspiration-booking-handoff', {
            detail: payload
          });
          window.dispatchEvent(handoffEvent);

          // Populate rebook/booking modal safely
          const modal = document.getElementById('rebookModal');
          const modalBody = document.getElementById('rebookModalBody');
          const modalTitle = document.getElementById('rebookModalTitle');

          if (modal && modalBody) {
            if (modalTitle) modalTitle.textContent = `Schedule Atelier Look (${payload.category})`;
            modalBody.innerHTML = `
              <div class="rebook-service-summary">
                <span class="detail-section-eyebrow">LOOK CONSULTATION HANDOFF</span>
                <h4 style="font-family: var(--font-serif); font-size: 17px; margin: 4px 0;">${payload.suggestedService ? payload.suggestedService.name : payload.category + ' Styling'}</h4>
                <p style="font-size: 12px; color: var(--color-text-muted);">
                  Stylist: <strong>${payload.stylist.name}</strong> • Branch: <strong>${payload.branch.name}</strong>
                </p>
                <p style="font-size: 12px; color: var(--color-bronze); margin-top: 6px;">
                  Estimated Price: ${payload.estimatedPrice ? '₹' + payload.estimatedPrice : 'Standard Atelier Rate'}
                </p>
              </div>
            `;
            modal.style.display = 'flex';
          }
        }
      } catch (err) {
        console.error('Error during booking handoff:', err);
        showToast(err.message || 'Could not complete booking handoff.', 'error');
      } finally {
        setGlobalLoading(false);
      }
    });
  }

  // ==========================================
  // REVIEWS & RATINGS MODULE
  // ==========================================
  const tabReviewsEligible = document.getElementById('tabReviewsEligible');
  const tabReviewsHistory = document.getElementById('tabReviewsHistory');
  const viewReviewsEligible = document.getElementById('viewReviewsEligible');
  const viewReviewsHistory = document.getElementById('viewReviewsHistory');

  if (tabReviewsEligible && tabReviewsHistory) {
    tabReviewsEligible.addEventListener('click', () => {
      tabReviewsEligible.classList.add('active');
      tabReviewsHistory.classList.remove('active');
      if (viewReviewsEligible) viewReviewsEligible.style.display = 'block';
      if (viewReviewsHistory) viewReviewsHistory.style.display = 'none';
      loadEligibleReviews();
    });

    tabReviewsHistory.addEventListener('click', () => {
      tabReviewsHistory.classList.add('active');
      tabReviewsEligible.classList.remove('active');
      if (viewReviewsEligible) viewReviewsEligible.style.display = 'none';
      if (viewReviewsHistory) viewReviewsHistory.style.display = 'block';
      loadMyReviews();
    });
  }

  async function loadReviewsScreen() {
    loadEligibleReviews();
  }

  async function loadEligibleReviews() {
    const container = document.getElementById('reviewsEligibleList');
    if (!container) return;

    try {
      setGlobalLoading(true);
      const res = await window.vioraApi.getEligibleAppointments();
      const appointments = res && res.data ? res.data : [];

      if (appointments.length === 0) {
        container.innerHTML = `
          <div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 24px 16px; text-align: center;">
            <p style="font-size: 12.5px; color: var(--color-text-muted);">All completed treatments have been reviewed. Thank you!</p>
          </div>
        `;
        return;
      }

      container.innerHTML = appointments.map(apt => {
        const s = apt.serviceId || {};
        const st = (apt.stylistId && apt.stylistId.userId) ? apt.stylistId.userId.name : 'Master Stylist';
        const br = apt.branchId ? apt.branchId.name : 'MAISON Atelier';
        const dateStr = apt.date ? new Date(apt.date).toLocaleDateString() : 'Recent';

        return `
          <div class="request-summary-card">
            <div class="request-card-header">
              <span class="request-status-pill status-accepted">Completed Treatment</span>
              <span style="font-size: 11px; color: var(--color-text-light);">${dateStr}</span>
            </div>
            <h4 style="font-family: var(--font-serif); font-size: 16px; margin: 4px 0;">${s.name || 'Salon Treatment'}</h4>
            <p style="font-size: 12px; color: var(--color-text-muted); margin-bottom: 10px;">Stylist: ${st} • ${br}</p>
            <button type="button" class="btn-primary btn-open-review-modal" data-appt-id="${apt._id}" data-service-name="${s.name || 'Treatment'}" style="padding: 7px 14px; font-size: 11px;">
              ★ Rate This Treatment
            </button>
          </div>
        `;
      }).join('');

      container.querySelectorAll('.btn-open-review-modal').forEach(btn => {
        btn.addEventListener('click', () => {
          openReviewModal(btn.dataset.apptId, btn.dataset.serviceName);
        });
      });
    } catch (err) {
      console.error('Error loading eligible reviews:', err);
    } finally {
      setGlobalLoading(false);
    }
  }

  async function loadMyReviews() {
    const container = document.getElementById('reviewsHistoryList');
    if (!container) return;

    try {
      setGlobalLoading(true);
      const res = await window.vioraApi.getMyReviews();
      const reviews = res && res.data ? res.data : [];

      if (reviews.length === 0) {
        container.innerHTML = `
          <div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 24px 16px; text-align: center;">
            <p style="font-size: 12.5px; color: var(--color-text-muted);">No reviews submitted yet.</p>
          </div>
        `;
        return;
      }

      container.innerHTML = reviews.map(rev => {
        const st = (rev.stylistId && rev.stylistId.userId) ? rev.stylistId.userId.name : 'Master Stylist';
        const s = rev.serviceId ? rev.serviceId.name : 'Bespoke Look';
        const dateStr = rev.createdAt ? new Date(rev.createdAt).toLocaleDateString() : '';

        return `
          <div class="stylist-response-card">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px;">
              <div>
                <h4 style="font-family: var(--font-serif); font-size: 16px;">${s}</h4>
                <p style="font-size: 11.5px; color: var(--color-text-muted);">Stylist: ${st} • ${dateStr}</p>
              </div>
              <span class="inspiration-card-rating">★ ${rev.rating}.0 (Look: ${rev.lookRating}.0)</span>
            </div>
            ${rev.reviewText ? `<p style="font-size: 12px; color: var(--color-text-main); line-height: 1.4; margin-top: 6px;">"${rev.reviewText}"</p>` : ''}
          </div>
        `;
      }).join('');
    } catch (err) {
      console.error('Error loading my reviews:', err);
    } finally {
      setGlobalLoading(false);
    }
  }

  function openReviewModal(appointmentId, serviceName) {
    const modal = document.getElementById('submitReviewModal');
    const hiddenId = document.getElementById('reviewAppointmentId');
    const titleEl = document.getElementById('reviewModalServiceName');

    if (hiddenId) hiddenId.value = appointmentId;
    if (titleEl) titleEl.textContent = serviceName;

    // Reset stars
    state.reviewStylistRating = 5;
    state.reviewLookRating = 5;
    updateStarWidget('starWidgetStylist', 'starValStylist', 5);
    updateStarWidget('starWidgetLook', 'starValLook', 5);

    if (modal) modal.style.display = 'flex';
  }

  const btnCloseReviewModal = document.getElementById('btnCloseReviewModal');
  if (btnCloseReviewModal) {
    btnCloseReviewModal.addEventListener('click', () => {
      const modal = document.getElementById('submitReviewModal');
      if (modal) modal.style.display = 'none';
    });
  }

  // Star Rating Interaction
  function setupStarWidgets() {
    ['starWidgetStylist', 'starWidgetLook'].forEach(widgetId => {
      const widget = document.getElementById(widgetId);
      if (!widget) return;
      const valElId = widgetId === 'starWidgetStylist' ? 'starValStylist' : 'starValLook';

      widget.querySelectorAll('.star-icon').forEach(star => {
        star.addEventListener('click', () => {
          const rating = parseInt(star.dataset.rating, 10);
          if (widgetId === 'starWidgetStylist') state.reviewStylistRating = rating;
          if (widgetId === 'starWidgetLook') state.reviewLookRating = rating;
          updateStarWidget(widgetId, valElId, rating);
        });
      });
    });
  }

  function updateStarWidget(widgetId, valElId, rating) {
    const widget = document.getElementById(widgetId);
    const valEl = document.getElementById(valElId);
    if (!widget) return;

    widget.querySelectorAll('.star-icon').forEach(star => {
      const r = parseInt(star.dataset.rating, 10);
      if (r <= rating) {
        star.classList.add('active');
      } else {
        star.classList.remove('active');
      }
    });

    if (valEl) valEl.textContent = `${rating}.0`;
  }

  setupStarWidgets();

  // Submit Review Form
  const reviewSubmitForm = document.getElementById('reviewSubmitForm');
  if (reviewSubmitForm) {
    reviewSubmitForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const appointmentId = document.getElementById('reviewAppointmentId').value;
      const reviewText = document.getElementById('reviewTextInput').value.trim();

      try {
        setGlobalLoading(true);
        const res = await window.vioraApi.submitReview({
          appointmentId,
          rating: state.reviewStylistRating,
          lookRating: state.reviewLookRating,
          reviewText
        });

        if (res && res.success) {
          showToast('Thank you! Your verified review is published.', 'success');
          const modal = document.getElementById('submitReviewModal');
          if (modal) modal.style.display = 'none';
          reviewSubmitForm.reset();
          loadEligibleReviews();
        } else {
          throw new Error(res.message || 'Review submission failed');
        }
      } catch (err) {
        console.error('Error submitting review:', err);
        showToast(err.message || 'Failed to submit review.', 'error');
      } finally {
        setGlobalLoading(false);
      }
    });
  }

  // ==========================================
  // NOTIFICATIONS MODULE
  // ==========================================
  async function loadNotificationsScreen(unreadOnly = false) {
    const container = document.getElementById('notificationsContainer');
    if (!container) return;

    try {
      setGlobalLoading(true);
      const res = await window.vioraApi.getNotifications(unreadOnly);
      const notifs = res && res.data ? res.data : [];
      const unreadCount = res ? res.unreadCount : 0;

      // Update badges
      if (navNotifDot) navNotifDot.style.display = unreadCount > 0 ? 'block' : 'none';
      const pNotifSum = document.getElementById('profileNotifSummary');
      if (pNotifSum) pNotifSum.textContent = `${unreadCount} Unread`;

      if (notifs.length === 0) {
        container.innerHTML = `
          <div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 24px 16px; text-align: center;">
            <p style="font-size: 12.5px; color: var(--color-text-muted);">No notifications at this time.</p>
          </div>
        `;
        return;
      }

      container.innerHTML = notifs.map(n => `
        <div class="notification-item ${n.read ? '' : 'unread'}" data-notif-id="${n.notificationId}" data-entity-type="${n.entityType}" data-entity-id="${n.entityId}" tabindex="0" style="cursor: pointer;">
          <div class="notification-icon-wrap">
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
              <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
            </svg>
          </div>
          <div class="notification-content">
            <h5 class="notification-title">${n.title}</h5>
            <p class="notification-message">${n.message}</p>
            <span class="notification-time">${new Date(n.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} • ${new Date(n.createdAt).toLocaleDateString()}</span>
          </div>
        </div>
      `).join('');

      container.querySelectorAll('.notification-item').forEach(item => {
        item.addEventListener('click', async () => {
          const id = item.dataset.notifId;
          const entityType = item.dataset.entityType;
          const entityId = item.dataset.entityId;

          // Mark read
          await window.vioraApi.markNotificationRead(id).catch(() => {});
          item.classList.remove('unread');

          // Navigate if relevant
          if (entityType === 'InspirationRequest') {
            navigateTo('screenInspiration');
            loadInspirationFeed();
          } else if (entityType === 'Review') {
            navigateTo('screenReviews');
            loadReviewsScreen();
          }
        });
      });
    } catch (err) {
      console.error('Error loading notifications:', err);
    } finally {
      setGlobalLoading(false);
    }
  }

  const btnMarkAllNotifsRead = document.getElementById('btnMarkAllNotifsRead');
  if (btnMarkAllNotifsRead) {
    btnMarkAllNotifsRead.addEventListener('click', async () => {
      try {
        await window.vioraApi.markAllNotificationsRead();
        showToast('All notifications marked as read', 'success');
        loadNotificationsScreen();
      } catch (err) {
        showToast('Could not mark all as read.', 'error');
      }
    });
  }

  // ==========================================
  // STYLIST PORTAL MODULE
  // ==========================================
  const tabStylistRequests = document.getElementById('tabStylistRequests');
  const tabStylistPortfolio = document.getElementById('tabStylistPortfolio');
  const tabStylistReviews = document.getElementById('tabStylistReviews');

  const viewStylistRequests = document.getElementById('viewStylistRequests');
  const viewStylistPortfolio = document.getElementById('viewStylistPortfolio');
  const viewStylistReviews = document.getElementById('viewStylistReviews');

  if (tabStylistRequests && tabStylistPortfolio && tabStylistReviews) {
    tabStylistRequests.addEventListener('click', () => {
      tabStylistRequests.classList.add('active');
      tabStylistPortfolio.classList.remove('active');
      tabStylistReviews.classList.remove('active');
      if (viewStylistRequests) viewStylistRequests.style.display = 'block';
      if (viewStylistPortfolio) viewStylistPortfolio.style.display = 'none';
      if (viewStylistReviews) viewStylistReviews.style.display = 'none';
      loadStylistRequests();
    });

    tabStylistPortfolio.addEventListener('click', () => {
      tabStylistPortfolio.classList.add('active');
      tabStylistRequests.classList.remove('active');
      tabStylistReviews.classList.remove('active');
      if (viewStylistRequests) viewStylistRequests.style.display = 'none';
      if (viewStylistPortfolio) viewStylistPortfolio.style.display = 'block';
      if (viewStylistReviews) viewStylistReviews.style.display = 'none';
      loadStylistPortfolio();
    });

    tabStylistReviews.addEventListener('click', () => {
      tabStylistReviews.classList.add('active');
      tabStylistRequests.classList.remove('active');
      tabStylistPortfolio.classList.remove('active');
      if (viewStylistRequests) viewStylistRequests.style.display = 'none';
      if (viewStylistPortfolio) viewStylistPortfolio.style.display = 'none';
      if (viewStylistReviews) viewStylistReviews.style.display = 'block';
      loadStylistReviews();
    });
  }

  async function loadStylistPortalScreen() {
    loadStylistRequests();
  }

  async function loadStylistRequests() {
    const container = document.getElementById('stylistInboxList');
    const badge = document.getElementById('stylistRequestsBadge');
    if (!container) return;

    try {
      setGlobalLoading(true);
      const res = await window.vioraApi.getInspirationRequests();
      const requests = res && res.data ? res.data : [];

      if (badge) badge.textContent = `${requests.length} Requests`;

      if (requests.length === 0) {
        container.innerHTML = '<div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 24px 16px; text-align: center;"><p style="font-size: 12.5px; color: var(--color-text-muted);">No client consultation requests matching your branch.</p></div>';
        return;
      }

      container.innerHTML = requests.map(req => {
        const thumb = (req.referenceImages && req.referenceImages.length > 0)
          ? req.referenceImages[0]
          : 'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=200&auto=format&fit=crop&q=80';

        return `
          <div class="stylist-response-card">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
              <span class="request-status-pill status-${req.status}">${req.status}</span>
              <span style="font-size: 11px; color: var(--color-text-light);">${req.requestId}</span>
            </div>
            <div style="display: flex; gap: 12px; margin-bottom: 10px;">
              <img src="${thumb}" alt="Client Ref" style="width: 56px; height: 56px; border-radius: var(--radius-sm); object-fit: cover;">
              <div style="flex: 1;">
                <h5 style="font-family: var(--font-serif); font-size: 16px;">${req.category} Consultation</h5>
                <p style="font-size: 12px; color: var(--color-text-muted); line-height: 1.35;">"${req.description}"</p>
              </div>
            </div>
            <div style="display: flex; justify-content: flex-end; gap: 8px;">
              <button type="button" class="btn-primary btn-stylist-respond-trigger" data-req-id="${req.requestId}" style="padding: 6px 12px; font-size: 11px;">
                Respond to Client
              </button>
            </div>
          </div>
        `;
      }).join('');

      container.querySelectorAll('.btn-stylist-respond-trigger').forEach(btn => {
        btn.addEventListener('click', () => {
          const reqId = btn.dataset.reqId;
          const modal = document.getElementById('stylistRespondModal');
          const hiddenId = document.getElementById('respondRequestId');
          const title = document.getElementById('respondModalTitle');

          if (hiddenId) hiddenId.value = reqId;
          if (title) title.textContent = `Respond to ${reqId}`;
          if (modal) modal.style.display = 'flex';
        });
      });
    } catch (err) {
      console.error('Error loading stylist requests:', err);
    } finally {
      setGlobalLoading(false);
    }
  }

  const btnCloseRespondModal = document.getElementById('btnCloseRespondModal');
  if (btnCloseRespondModal) {
    btnCloseRespondModal.addEventListener('click', () => {
      const modal = document.getElementById('stylistRespondModal');
      if (modal) modal.style.display = 'none';
    });
  }

  const stylistRespondForm = document.getElementById('stylistRespondForm');
  if (stylistRespondForm) {
    stylistRespondForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const requestId = document.getElementById('respondRequestId').value;
      const message = document.getElementById('respondMessage').value.trim();
      const estimatedPrice = document.getElementById('respondEstPrice').value || null;

      try {
        setGlobalLoading(true);
        const res = await window.vioraApi.respondToInspiration(requestId, {
          message,
          estimatedPrice
        });

        if (res && res.success) {
          showToast('Proposal sent to client successfully!', 'success');
          const modal = document.getElementById('stylistRespondModal');
          if (modal) modal.style.display = 'none';
          stylistRespondForm.reset();
          loadStylistRequests();
        } else {
          throw new Error(res.message || 'Failed to send response');
        }
      } catch (err) {
        showToast(err.message || 'Error responding to request.', 'error');
      } finally {
        setGlobalLoading(false);
      }
    });
  }

  async function loadStylistPortfolio() {
    const grid = document.getElementById('stylistPortfolioGrid');
    if (!grid) return;

    try {
      setGlobalLoading(true);
      const res = await window.vioraApi.getMyPortfolio();
      const items = res && res.data ? res.data : [];

      if (items.length === 0) {
        grid.innerHTML = '<div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 24px 16px; text-align: center;"><p style="font-size: 12.5px; color: var(--color-text-muted);">No portfolio work uploaded yet.</p></div>';
        return;
      }

      grid.innerHTML = items.map(item => `
        <div class="inspiration-card">
          <div class="inspiration-card-img-wrap">
            <img src="${item.imageUrl}" alt="${item.title}" class="inspiration-card-img">
            <span class="inspiration-card-badge">${item.category}</span>
          </div>
          <div class="inspiration-card-body">
            <h4 class="inspiration-card-title">${item.title}</h4>
            <p class="inspiration-card-desc">${item.description || ''}</p>
            <div style="display: flex; justify-content: flex-end;">
              <button type="button" class="btn-secondary btn-delete-portfolio-item" data-item-id="${item.portfolioId}" style="padding: 4px 8px; font-size: 10px; color: var(--color-danger);">
                Delete
              </button>
            </div>
          </div>
        </div>
      `).join('');

      grid.querySelectorAll('.btn-delete-portfolio-item').forEach(btn => {
        btn.addEventListener('click', async () => {
          if (!confirm('Are you sure you want to remove this portfolio look?')) return;
          try {
            await window.vioraApi.deletePortfolioItem(btn.dataset.itemId);
            showToast('Portfolio item removed', 'success');
            loadStylistPortfolio();
          } catch (err) {
            showToast('Could not delete portfolio item.', 'error');
          }
        });
      });
    } catch (err) {
      console.error('Error loading portfolio:', err);
    } finally {
      setGlobalLoading(false);
    }
  }

  const btnOpenAddPortfolioModal = document.getElementById('btnOpenAddPortfolioModal');
  const btnClosePortfolioModal = document.getElementById('btnClosePortfolioModal');
  const addPortfolioModal = document.getElementById('addPortfolioModal');

  if (btnOpenAddPortfolioModal && addPortfolioModal) {
    btnOpenAddPortfolioModal.addEventListener('click', () => {
      addPortfolioModal.style.display = 'flex';
    });
  }

  if (btnClosePortfolioModal && addPortfolioModal) {
    btnClosePortfolioModal.addEventListener('click', () => {
      addPortfolioModal.style.display = 'none';
    });
  }

  const addPortfolioForm = document.getElementById('addPortfolioForm');
  if (addPortfolioForm) {
    addPortfolioForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const title = document.getElementById('portTitle').value.trim();
      const category = document.getElementById('portCategory').value;
      const description = document.getElementById('portDesc').value.trim();
      const tags = document.getElementById('portTags').value.split(',').map(t => t.trim()).filter(Boolean);
      const urlInput = document.getElementById('portUrlInput').value.trim();
      const fileInput = document.getElementById('portFileInput');

      try {
        setGlobalLoading(true);

        let finalImage = urlInput || 'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=800&auto=format&fit=crop&q=80';

        if (fileInput && fileInput.files && fileInput.files[0]) {
          const reader = new FileReader();
          const base64Promise = new Promise(resolve => {
            reader.onload = ev => resolve(ev.target.result);
            reader.readAsDataURL(fileInput.files[0]);
          });
          finalImage = await base64Promise;
        }

        const res = await window.vioraApi.createPortfolioItem({
          title,
          category,
          description,
          tags,
          image: finalImage.startsWith('data:') ? finalImage : null,
          imageUrl: !finalImage.startsWith('data:') ? finalImage : null
        });

        if (res && res.success) {
          showToast('Portfolio look published!', 'success');
          addPortfolioModal.style.display = 'none';
          addPortfolioForm.reset();
          loadStylistPortfolio();
        }
      } catch (err) {
        showToast(err.message || 'Could not upload portfolio work.', 'error');
      } finally {
        setGlobalLoading(false);
      }
    });
  }

  async function loadStylistReviews() {
    const container = document.getElementById('stylistReviewsList');
    if (!container) return;

    try {
      setGlobalLoading(true);
      const res = await window.vioraApi.getMyStylistReviews();
      const { stats, data } = res || {};

      if (stats) {
        const avgR = document.getElementById('stylistKpiAvgRating');
        if (avgR) avgR.textContent = `${stats.avgStylistRating}★`;
        const totalR = document.getElementById('stylistKpiTotalReviews');
        if (totalR) totalR.textContent = `${stats.totalReviews} Reviews`;
        const avgL = document.getElementById('stylistKpiAvgLook');
        if (avgL) avgL.textContent = `${stats.avgLookRating}★`;
      }

      if (!data || data.length === 0) {
        container.innerHTML = '<div style="background: var(--color-surface); border: 1px dashed var(--color-border); border-radius: var(--radius-md); padding: 24px 16px; text-align: center;"><p style="font-size: 12.5px; color: var(--color-text-muted);">No client reviews recorded yet.</p></div>';
        return;
      }

      container.innerHTML = data.map(rev => `
        <div class="stylist-response-card">
          <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px;">
            <div>
              <h5 style="font-family: var(--font-serif); font-size: 15px;">${rev.serviceId ? rev.serviceId.name : 'Salon Look'}</h5>
              <span style="font-size: 11px; color: var(--color-text-light);">${new Date(rev.createdAt).toLocaleDateString()}</span>
            </div>
            <span class="inspiration-card-rating">★ ${rev.rating}.0 (Look: ${rev.lookRating}.0)</span>
          </div>
          ${rev.reviewText ? `<p style="font-size: 12px; color: var(--color-text-main); margin-top: 4px;">"${rev.reviewText}"</p>` : ''}
        </div>
      `).join('');
    } catch (err) {
      console.error('Error loading stylist reviews:', err);
    } finally {
      setGlobalLoading(false);
    }
  }

  // ==========================================
  // ADMIN ANALYTICS & INTELLIGENCE DASHBOARD
  // ==========================================
  const tabAdminOverview = document.getElementById('tabAdminOverview');
  const tabAdminPerformance = document.getElementById('tabAdminPerformance');
  const tabAdminPopular = document.getElementById('tabAdminPopular');
  const tabAdminModeration = document.getElementById('tabAdminModeration');

  const adminPanelOverview = document.getElementById('adminPanelOverview');
  const adminPanelPerformance = document.getElementById('adminPanelPerformance');
  const adminPanelPopular = document.getElementById('adminPanelPopular');
  const adminPanelModeration = document.getElementById('adminPanelModeration');

  if (tabAdminOverview && tabAdminPerformance && tabAdminPopular && tabAdminModeration) {
    tabAdminOverview.addEventListener('click', () => switchAdminAnalyticsTab(tabAdminOverview, adminPanelOverview));
    tabAdminPerformance.addEventListener('click', () => switchAdminAnalyticsTab(tabAdminPerformance, adminPanelPerformance));
    tabAdminPopular.addEventListener('click', () => switchAdminAnalyticsTab(tabAdminPopular, adminPanelPopular));
    tabAdminModeration.addEventListener('click', () => switchAdminAnalyticsTab(tabAdminModeration, adminPanelModeration));
  }

  function switchAdminAnalyticsTab(activeTab, activePanel) {
    [tabAdminOverview, tabAdminPerformance, tabAdminPopular, tabAdminModeration].forEach(t => t.classList.remove('active'));
    [adminPanelOverview, adminPanelPerformance, adminPanelPopular, adminPanelModeration].forEach(p => p.style.display = 'none');

    activeTab.classList.add('active');
    activePanel.style.display = 'block';
  }

  const btnRefreshAnalytics = document.getElementById('btnRefreshAnalytics');
  if (btnRefreshAnalytics) {
    btnRefreshAnalytics.addEventListener('click', () => loadAdminAnalyticsScreen());
  }

  const analyticsBranchFilter = document.getElementById('analyticsBranchFilter');
  const analyticsDateFilter = document.getElementById('analyticsDateFilter');

  if (analyticsBranchFilter) analyticsBranchFilter.addEventListener('change', () => loadAdminAnalyticsScreen());
  if (analyticsDateFilter) analyticsDateFilter.addEventListener('change', () => loadAdminAnalyticsScreen());

  async function loadAdminAnalyticsScreen() {
    try {
      setGlobalLoading(true);

      const branchId = analyticsBranchFilter ? analyticsBranchFilter.value : '';
      const dateOption = analyticsDateFilter ? analyticsDateFilter.value : 'all';

      let startDate = null;
      if (dateOption === '7') {
        startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
      } else if (dateOption === '30') {
        startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
      }

      // Populate branches dropdown
      if (analyticsBranchFilter && analyticsBranchFilter.options.length <= 1) {
        const bRes = await window.vioraApi.getBranches().catch(() => null);
        if (bRes && bRes.data) {
          bRes.data.forEach(b => {
            const opt = document.createElement('option');
            opt.value = b._id;
            opt.textContent = b.name;
            analyticsBranchFilter.appendChild(opt);
          });
        }
      }

      const params = {};
      if (branchId) params.branchId = branchId;
      if (startDate) params.startDate = startDate;

      // 1. Overview KPIs
      const overviewRes = await window.vioraApi.getAnalyticsOverview(params).catch(() => null);
      if (overviewRes && overviewRes.data && overviewRes.data.overview) {
        const o = overviewRes.data.overview;
        const totalB = document.getElementById('kpiTotalBookings');
        if (totalB) totalB.textContent = o.totalBookings;
        const compB = document.getElementById('kpiCompletedBookings');
        if (compB) compB.textContent = `${o.completedBookings} Completed`;

        const revEl = document.getElementById('kpiTotalRevenue');
        if (revEl) revEl.textContent = `₹${o.totalRevenue.toLocaleString()}`;

        const custEl = document.getElementById('kpiTotalCustomers');
        if (custEl) custEl.textContent = o.totalCustomers;
        const actCustEl = document.getElementById('kpiActiveCustomers');
        if (actCustEl) actCustEl.textContent = `${o.activeCustomers} Active`;

        const retEl = document.getElementById('kpiRetentionRate');
        if (retEl) retEl.textContent = `${o.returningRate}%`;
        const retSub = document.getElementById('kpiReturningClients');
        if (retSub) retSub.textContent = `${o.returningCustomers} Returning Clients`;

        // Render Trend Timeline
        const trendEl = document.getElementById('analyticsTrendTimeline');
        if (trendEl && overviewRes.data.trends) {
          trendEl.innerHTML = overviewRes.data.trends.map(t => `
            <div style="display: flex; justify-content: space-between; font-size: 11.5px; padding: 6px 0; border-bottom: 1px dashed var(--color-border);">
              <span>${t.date}</span>
              <span><strong>${t.bookings}</strong> Bookings (₹${t.revenue.toLocaleString()})</span>
            </div>
          `).join('') || '<p style="font-size: 12px; color: var(--color-text-muted);">No timeline data.</p>';
        }
      }

      // 2. Branch Performance Table
      const branchRes = await window.vioraApi.getBranchPerformance(params).catch(() => null);
      const branchTbody = document.getElementById('branchPerformanceTbody');
      if (branchTbody && branchRes && branchRes.data) {
        branchTbody.innerHTML = branchRes.data.map(b => `
          <tr>
            <td><strong>${b.name}</strong></td>
            <td>${b.totalBookings} (${b.completedBookings} completed)</td>
            <td>₹${b.revenue.toLocaleString()}</td>
            <td>${b.uniqueCustomers} (${b.returningClients} returning)</td>
            <td>★ ${b.avgRating}</td>
          </tr>
        `).join('');
      }

      // 3. Stylist Performance Table
      const stylistRes = await window.vioraApi.getStylistPerformance(params).catch(() => null);
      const stylistTbody = document.getElementById('stylistPerformanceTbody');
      if (stylistTbody && stylistRes && stylistRes.data) {
        stylistTbody.innerHTML = stylistRes.data.map(s => `
          <tr>
            <td><strong>${s.name}</strong></td>
            <td>${s.branchName}</td>
            <td>${s.completedBookings}</td>
            <td>₹${s.revenue.toLocaleString()}</td>
            <td>★ ${s.avgRating} (${s.reviewCount})</td>
          </tr>
        `).join('');
      }

      // 4. Popular Services & Looks
      const servicesRes = await window.vioraApi.getPopularServices(params).catch(() => null);
      const servEl = document.getElementById('adminPopularServicesContent');
      if (servEl && servicesRes && servicesRes.data) {
        servEl.innerHTML = servicesRes.data.map(s => `
          <div style="display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid var(--color-border); font-size: 12px;">
            <div>
              <strong>${s.name}</strong> <span style="font-size: 10.5px; color: var(--color-text-muted);">(${s.category})</span>
              <div style="font-size: 11px; color: var(--color-text-light);">${s.branches.join(', ')}</div>
            </div>
            <div style="text-align: right;">
              <div><strong>${s.totalBookings}</strong> Bookings</div>
              <div style="color: var(--color-bronze);">₹${s.totalRevenue.toLocaleString()}</div>
            </div>
          </div>
        `).join('') || '<p style="font-size: 12px; color: var(--color-text-muted);">No booking data recorded.</p>';
      }

      const looksRes = await window.vioraApi.getPopularLooks().catch(() => null);
      const looksEl = document.getElementById('adminPopularLooksContent');
      if (looksEl && looksRes && looksRes.data) {
        looksEl.innerHTML = looksRes.data.map(l => `
          <div style="display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid var(--color-border); font-size: 12px;">
            <div>
              <strong>${l.category} Look</strong>
              <div style="font-size: 11px; color: var(--color-text-muted);">${l.requestCount} Requests • ${l.portfolioCount} Portfolio Works</div>
            </div>
            <div style="text-align: right;">
              <span class="inspiration-card-rating">★ ${l.avgLookRating}</span>
            </div>
          </div>
        `).join('');
      }

      // 5. Review Moderation
      const revRes = await window.vioraApi.getAdminReviews(params).catch(() => null);
      const revTbody = document.getElementById('adminReviewsTbody');
      const revBadge = document.getElementById('adminReviewCountBadge');

      if (revBadge && revRes && revRes.data) {
        revBadge.textContent = `${revRes.data.length} Total`;
      }

      if (revTbody && revRes && revRes.data) {
        revTbody.innerHTML = revRes.data.map(r => {
          const st = (r.stylistId && r.stylistId.userId) ? r.stylistId.userId.name : 'Stylist';
          return `
            <tr>
              <td>${r.customerId}<br><span style="font-size: 10px; color: var(--color-text-muted);">${st}</span></td>
              <td>★ ${r.rating}</td>
              <td>★ ${r.lookRating}</td>
              <td style="max-width: 140px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${r.reviewText || '-'}</td>
              <td><span class="request-status-pill status-${r.moderationStatus === 'approved' ? 'accepted' : (r.moderationStatus === 'flagged' ? 'pending' : 'declined')}">${r.moderationStatus}</span></td>
              <td>
                <div style="display: flex; gap: 4px;">
                  <button type="button" class="btn-secondary btn-mod-action" data-id="${r.reviewId}" data-status="approved" style="padding: 2px 6px; font-size: 9.5px;">Approve</button>
                  <button type="button" class="btn-secondary btn-mod-action" data-id="${r.reviewId}" data-status="flagged" style="padding: 2px 6px; font-size: 9.5px; color: #B45309;">Flag</button>
                  <button type="button" class="btn-secondary btn-mod-action" data-id="${r.reviewId}" data-status="hidden" style="padding: 2px 6px; font-size: 9.5px; color: var(--color-danger);">Hide</button>
                </div>
              </td>
            </tr>
          `;
        }).join('') || '<tr><td colspan="6" style="text-align: center; color: var(--color-text-muted);">No reviews found.</td></tr>';

        revTbody.querySelectorAll('.btn-mod-action').forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = btn.dataset.id;
            const status = btn.dataset.status;
            try {
              await window.vioraApi.moderateReview(id, status);
              showToast(`Review status updated to ${status}`, 'success');
              loadAdminAnalyticsScreen();
            } catch (err) {
              showToast('Could not moderate review.', 'error');
            }
          });
        });
      }

    } catch (err) {
      console.error('Error loading admin analytics:', err);
      showToast('Could not load analytics.', 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  // ==========================================
  // INITIALIZATION (EXTENDED FOR ROLES & TILES)
  // ==========================================
  if (window.vioraApi.isAuthenticated()) {
    const user = window.vioraApi.getUser();
    if (user && (user.role === 'admin' || user.role === 'branch_manager')) {
      if (tileAdminCustomers) tileAdminCustomers.style.display = 'flex';
      if (tileAdminAnalytics) tileAdminAnalytics.style.display = 'flex';
      if (tileStylistPortal) tileStylistPortal.style.display = 'flex';
      navigateTo('screenAdminAnalytics');
      loadAdminAnalyticsScreen();
    } else if (user && user.role === 'stylist') {
      if (tileStylistPortal) tileStylistPortal.style.display = 'flex';
      navigateTo('screenStylistPortal');
      loadStylistPortalScreen();
    } else {
      if (tileAdminCustomers) tileAdminCustomers.style.display = 'none';
      if (tileAdminAnalytics) tileAdminAnalytics.style.display = 'none';
      if (tileStylistPortal) tileStylistPortal.style.display = 'none';
      loadCustomerProfile();
    }
  } else {
    navigateTo('screenAuth');
  }
});
