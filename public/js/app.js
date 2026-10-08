/**
 * VIORA Customer Profile & Personal Preferences Application Controller
 * Manages State, UI Views, Validations, and Day 1 API Integrations.
 */

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
    isLoading: false
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
    screenPreferences: document.getElementById('screenPreferences')
  };

  // Auth elements
  const tabSignIn = document.getElementById('tabSignIn');
  const tabSignUp = document.getElementById('tabSignUp');
  const signInForm = document.getElementById('signInForm');
  const signUpForm = document.getElementById('signUpForm');
  const btnDemoLogin = document.getElementById('btnDemoLogin');

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
      await loadCustomerProfile();
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
      await loadCustomerProfile();
    } catch (err) {
      showToast(err.message || 'Registration failed.', 'error');
    } finally {
      setButtonLoading(btnSubmit, false);
    }
  }

  // Quick Demo Access Helper
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
          password: demoPassword
        });
      }

      showToast('Connected as Sarah Sen', 'success');
      await loadCustomerProfile();
    } catch (err) {
      console.error('Demo login error:', err);
      showToast('Could not launch demo customer. ' + err.message, 'error');
    } finally {
      setGlobalLoading(false);
    }
  }

  function handleSignOut() {
    if (confirm('Are you sure you want to sign out of your VIORA account?')) {
      window.vioraApi.clearSession();
      state.customerProfile = null;
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

  // Utility to escape HTML
  function escapeHtml(str) {
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // ==========================================
  // INITIALIZATION
  // ==========================================
  if (window.vioraApi.isAuthenticated()) {
    loadCustomerProfile();
  } else {
    navigateTo('screenAuth');
  }
});
