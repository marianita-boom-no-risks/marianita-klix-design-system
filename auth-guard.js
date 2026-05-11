/**
 * Marianita Klix Design System — Auth Guard
 *
 * Include this script on every protected page:
 *   <script src="auth-guard.js"></script>
 *
 * It checks localStorage for a valid session and redirects
 * unauthenticated users to login.html.
 *
 * API:
 *   window.marianitaKlixAuth.logout()   — clears session and redirects to login
 *   window.marianitaKlixAuth.isValid()  — returns true if session is valid
 */
(function () {
  'use strict';

  var AUTH_KEY = 'marianita-klix-ds-auth';
  var SESSION_DURATION = 24 * 60 * 60 * 1000; // 24 hours in ms

  /**
   * Check whether the current session is valid.
   * @returns {boolean}
   */
  function isValid() {
    var raw = localStorage.getItem(AUTH_KEY);
    if (!raw) return false;

    try {
      var data = JSON.parse(raw);
      if (data.status !== 'authenticated') return false;
      if (typeof data.timestamp !== 'number') return false;
      if (Date.now() - data.timestamp > SESSION_DURATION) {
        // Session expired — clean up
        localStorage.removeItem(AUTH_KEY);
        return false;
      }
      return true;
    } catch (e) {
      localStorage.removeItem(AUTH_KEY);
      return false;
    }
  }

  /**
   * Log out: clear the session and redirect to login.html.
   */
  function logout() {
    localStorage.removeItem(AUTH_KEY);
    window.location.replace('login.html');
  }

  // Expose public API
  window.marianitaKlixAuth = {
    isValid: isValid,
    logout: logout
  };

  // ---- Guard: redirect if not authenticated ----
  // Skip the check if we are already on login.html
  var currentPage = window.location.pathname.split('/').pop() || '';
  if (currentPage === 'login.html') return;

  if (!isValid()) {
    window.location.replace('login.html');
  }
})();
