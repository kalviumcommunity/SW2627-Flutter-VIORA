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
    screenAdminCustomerDetail: document.getElementById('screenAdminCustomerDetail')
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
      if (key === screenId) {
        screens[key].style.display = 'flex';
      } else {
        screens[key].style.display = 'none';
      }
    });
    // Scroll container to top
    const container = document.getElementById('appContainer');
    if (container) container.scrollTop = 0;
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
        const isAvailable = item.service?.availability !== false;

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
          <span class="rebook-info-val">${escapeHtml(branch.name || 'VIORA Salon')}</span>
        </div>
        <div class="rebook-info-row">
          <span class="rebook-info-label">Preferred Stylist</span>
          <span class="rebook-info-val">${escapeHtml(stylist.name || 'Any Senior Stylist')}</span>
        </div>
      </div>

      <div class="rebook-integration-badge">
        <strong>BOOKING FLOW INTEGRATION HOOK</strong>
        Selected service and branch parameters are prefilled. Proceeding transfers context to the booking flow for slot scheduling and stylist confirmation without creating unconfirmed duplicates.
      </div>
    `;

    if (rebookModal) rebookModal.style.display = 'flex';
  }

  function closeRebookModal() {
    if (rebookModal) rebookModal.style.display = 'none';
    state.selectedRebookData = null;
  }

  function handleProceedRebook() {
    if (!state.selectedRebookData) return;

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
    if (confirm('Are you sure you want to sign out of your VIORA account?')) {
      window.vioraApi.clearSession();
      state.customerProfile = null;
      state.adminOverview = null;
      state.adminCustomers = [];
      state.selectedAdminCustomer = null;
      showToast('You have signed out.', 'info');
      navigateTo('screenAuth');
    }
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
    switch (status) {
      case 'Active': return 'badge-active';
      case 'Needs Engagement': return 'badge-needs-engagement';
      case 'At-Risk': return 'badge-at-risk';
      case 'New': return 'badge-new';
      default: return 'badge-novisits';
    }
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
            <span class="admin-retention-badge ${badgeClass}">${escapeHtml(c.retentionStatus || 'New')}</span>
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

  // ==========================================
  // INITIALIZATION
  // ==========================================
  if (window.vioraApi.isAuthenticated()) {
    const user = window.vioraApi.getUser();
    if (user && (user.role === 'admin' || user.role === 'branch_manager')) {
      if (tileAdminCustomers) tileAdminCustomers.style.display = 'flex';
      navigateTo('screenAdminCustomers');
      loadAdminDashboard();
    } else {
      if (tileAdminCustomers) tileAdminCustomers.style.display = 'none';
      loadCustomerProfile();
    }
  } else {
    navigateTo('screenAuth');
  }
});
