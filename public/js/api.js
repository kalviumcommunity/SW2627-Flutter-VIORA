/**
 * VIORA Customer Intelligence - API Service Layer
 * Interacts with Day 1 backend endpoints:
 * - /api/auth/login, /api/auth/register, /api/auth/me
 * - /api/customers/profile (GET, PUT)
 * - /api/customers/preferences (GET, PUT)
 */

const API_BASE_URL = window.location.origin;

class VioraApiService {
  constructor() {
    this.tokenKey = 'viora_auth_token';
    this.userKey = 'viora_auth_user';
  }

  // Token management
  getToken() {
    return localStorage.getItem(this.tokenKey);
  }

  setToken(token) {
    if (token) {
      localStorage.setItem(this.tokenKey, token);
    } else {
      localStorage.removeItem(this.tokenKey);
    }
  }

  getUser() {
    try {
      const data = localStorage.getItem(this.userKey);
      return data ? JSON.parse(data) : null;
    } catch {
      return null;
    }
  }

  setUser(user) {
    if (user) {
      localStorage.setItem(this.userKey, JSON.stringify(user));
    } else {
      localStorage.removeItem(this.userKey);
    }
  }

  isAuthenticated() {
    return Boolean(this.getToken());
  }

  clearSession() {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.userKey);
  }

  // Generic Request Helper
  async request(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };

    const token = this.getToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers
      });

      const data = await response.json().catch(() => null);

      if (!response.ok) {
        // If unauthorized, clear invalid token
        if (response.status === 401) {
          this.clearSession();
        }

        const errorMessage = (data && (data.message || data.error)) || `Request failed with status ${response.status}`;
        const error = new Error(errorMessage);
        error.status = response.status;
        error.data = data;
        throw error;
      }

      return data;
    } catch (err) {
      if (err.name === 'TypeError' && err.message.includes('fetch')) {
        throw new Error('Network connection error. Is the server online?');
      }
      throw err;
    }
  }

  // Auth APIs
  async login(email, password) {
    const res = await this.request('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    });

    if (res && res.token) {
      this.setToken(res.token);
      this.setUser(res.data);
    }
    return res;
  }

  async register({ name, email, phone, password }) {
    const res = await this.request('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify({ name, email, phone, password, role: 'customer' })
    });

    if (res && res.token) {
      this.setToken(res.token);
      this.setUser(res.data);
    }
    return res;
  }

  async getMe() {
    return this.request('/api/auth/me', { method: 'GET' });
  }

  // Customer Profile APIs (Day 1 / Day 2 Integration)
  async getProfile() {
    return this.request('/api/customers/profile', { method: 'GET' });
  }

  async updateProfile(profileData) {
    return this.request('/api/customers/profile', {
      method: 'PUT',
      body: JSON.stringify(profileData)
    });
  }

  // Customer Preferences APIs (Day 1 / Day 2 Integration)
  async getPreferences() {
    return this.request('/api/customers/preferences', { method: 'GET' });
  }

  async updatePreferences(preferencesData) {
    return this.request('/api/customers/preferences', {
      method: 'PUT',
      body: JSON.stringify(preferencesData)
    });
  }
}

// Global instance
window.vioraApi = new VioraApiService();
