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
      this.setUser(res.user || res.data);
    }
    return res;
  }

  async register({ name, email, phone, password, role = 'customer' }) {
    const res = await this.request('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify({ name, email, phone, password, role })
    });

    if (res && res.token) {
      this.setToken(res.token);
      this.setUser(res.user || res.data);
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

  // Customer Treatment History APIs (Day 3 Integration)
  async getHistory(category = null) {
    let endpoint = '/api/customers/history';
    if (category && category.toLowerCase() !== 'all') {
      endpoint += `?category=${encodeURIComponent(category)}`;
    }
    return this.request(endpoint, { method: 'GET' });
  }

  async getRebookContext(appointmentId) {
    return this.request(`/api/customers/history/${appointmentId}/rebook`, { method: 'GET' });
  }

  // Customer Beauty Quiz & Recommendations APIs (Day 4 Integration)
  async getQuizQuestions() {
    return this.request('/api/customers/quiz/questions', { method: 'GET' });
  }

  async getQuizResult() {
    return this.request('/api/customers/quiz', { method: 'GET' });
  }

  async submitQuiz(answers) {
    return this.request('/api/customers/quiz', {
      method: 'POST',
      body: JSON.stringify(answers)
    });
  }

  async retakeQuiz() {
    return this.request('/api/customers/quiz/retake', { method: 'POST' });
  }

  async getRecommendations() {
    return this.request('/api/customers/recommendations', { method: 'GET' });
  }

  // ==========================================
  // Day 5 Admin Customer Management APIs
  // ==========================================
  async getAdminOverview() {
    return this.request('/api/customers/admin/overview', { method: 'GET' });
  }

  async getAdminCustomers({ search = '', segment = 'all', page = 1, limit = 50 } = {}) {
    const params = new URLSearchParams();
    if (search && search.trim()) params.append('search', search.trim());
    if (segment && segment !== 'all') params.append('segment', segment);
    if (page) params.append('page', page);
    if (limit) params.append('limit', limit);

    const queryString = params.toString();
    const endpoint = `/api/customers/admin/list${queryString ? '?' + queryString : ''}`;
    return this.request(endpoint, { method: 'GET' });
  }

  async getAdminCustomerDetails(customerId) {
    return this.request(`/api/customers/admin/${encodeURIComponent(customerId)}`, { method: 'GET' });
  }

  async getAdminCustomerHistory(customerId, status = 'all') {
    let endpoint = `/api/customers/admin/${encodeURIComponent(customerId)}/history`;
    if (status && status !== 'all') {
      endpoint += `?status=${encodeURIComponent(status)}`;
    }
    return this.request(endpoint, { method: 'GET' });
  }

  // ==========================================
  // Person 3: Inspiration & Discovery APIs
  // ==========================================
  async getBranches() {
    return this.request('/api/branches', { method: 'GET' });
  }

  async getDiscovery(category = 'All', search = '') {
    const params = new URLSearchParams();
    if (category && category !== 'All') params.append('category', category);
    if (search && search.trim()) params.append('search', search.trim());
    const qs = params.toString();
    return this.request(`/api/inspiration/discovery${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async uploadImage(image, prefix = 'insp') {
    return this.request('/api/inspiration/upload', {
      method: 'POST',
      body: JSON.stringify({ image, prefix })
    });
  }

  async createInspirationRequest(payload) {
    return this.request('/api/inspiration/requests', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  }

  async getInspirationRequests(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/inspiration/requests${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async getInspirationRequest(id) {
    return this.request(`/api/inspiration/requests/${encodeURIComponent(id)}`, { method: 'GET' });
  }

  async respondToInspiration(requestId, payload) {
    return this.request(`/api/inspiration/requests/${encodeURIComponent(requestId)}/respond`, {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  }

  async updateInspirationStatus(requestId, status, message = '') {
    return this.request(`/api/inspiration/requests/${encodeURIComponent(requestId)}/status`, {
      method: 'PUT',
      body: JSON.stringify({ status, message })
    });
  }

  async chooseStylist(requestId, payload) {
    return this.request(`/api/inspiration/requests/${encodeURIComponent(requestId)}/choose`, {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  }

  async getBookingHandoff(requestId) {
    return this.request(`/api/inspiration/requests/${encodeURIComponent(requestId)}/handoff`, {
      method: 'POST'
    });
  }

  // ==========================================
  // Person 3: Stylist & Portfolio APIs
  // ==========================================
  async getAllStylists(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/stylists${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async getStylist(id) {
    return this.request(`/api/stylists/${encodeURIComponent(id)}`, { method: 'GET' });
  }

  async getMyPortfolio() {
    return this.request('/api/stylists/me/portfolio', { method: 'GET' });
  }

  async createPortfolioItem(payload) {
    return this.request('/api/stylists/me/portfolio', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  }

  async updatePortfolioItem(itemId, payload) {
    return this.request(`/api/stylists/me/portfolio/${encodeURIComponent(itemId)}`, {
      method: 'PUT',
      body: JSON.stringify(payload)
    });
  }

  async deletePortfolioItem(itemId) {
    return this.request(`/api/stylists/me/portfolio/${encodeURIComponent(itemId)}`, {
      method: 'DELETE'
    });
  }

  async getMyStylistReviews() {
    return this.request('/api/stylists/me/reviews', { method: 'GET' });
  }

  // ==========================================
  // Person 3: Reviews & Ratings APIs
  // ==========================================
  async getEligibleAppointments() {
    return this.request('/api/reviews/eligible-appointments', { method: 'GET' });
  }

  async submitReview(payload) {
    return this.request('/api/reviews', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  }

  async getMyReviews() {
    return this.request('/api/reviews/my-reviews', { method: 'GET' });
  }

  async getStylistReviews(stylistId) {
    return this.request(`/api/reviews/stylist/${encodeURIComponent(stylistId)}`, { method: 'GET' });
  }

  async getAdminReviews(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/reviews/admin${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async moderateReview(reviewId, status, notes = '') {
    return this.request(`/api/reviews/admin/${encodeURIComponent(reviewId)}/moderate`, {
      method: 'PUT',
      body: JSON.stringify({ status, notes })
    });
  }

  // ==========================================
  // Person 3: Notifications APIs
  // ==========================================
  async getNotifications(unreadOnly = false) {
    return this.request(`/api/notifications${unreadOnly ? '?unreadOnly=true' : ''}`, { method: 'GET' });
  }

  async markNotificationRead(id) {
    return this.request(`/api/notifications/${encodeURIComponent(id)}/read`, { method: 'PUT' });
  }

  async markAllNotificationsRead() {
    return this.request('/api/notifications/read-all', { method: 'PUT' });
  }

  async deleteNotification(id) {
    return this.request(`/api/notifications/${encodeURIComponent(id)}`, { method: 'DELETE' });
  }

  // ==========================================
  // Person 3: Admin Analytics & Intelligence APIs
  // ==========================================
  async getAnalyticsOverview(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/admin/analytics/overview${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async getBranchPerformance(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/admin/analytics/branches${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async getStylistPerformance(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/admin/analytics/stylists${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async getPopularServices(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/admin/analytics/services${qs ? '?' + qs : ''}`, { method: 'GET' });
  }

  async getPopularLooks() {
    return this.request('/api/admin/analytics/looks', { method: 'GET' });
  }

  async getReviewAnalytics() {
    return this.request('/api/admin/analytics/reviews', { method: 'GET' });
  }

  async getRetentionAnalytics() {
    return this.request('/api/admin/analytics/retention', { method: 'GET' });
  }
}

// Global instance
window.vioraApi = new VioraApiService();
