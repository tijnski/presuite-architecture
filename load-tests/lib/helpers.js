/**
 * k6 Load Test Helpers
 * Common utilities for PreSuite load tests
 */

import http from 'k6/http';
import { check, fail } from 'k6';
import { config } from './config.js';

/**
 * Authenticate and get JWT token
 * Uses test credentials from environment variables
 */
export function authenticate() {
  const email = __ENV.TEST_EMAIL;
  const password = __ENV.TEST_PASSWORD;

  if (!email || !password) {
    console.warn('TEST_EMAIL and TEST_PASSWORD not set, skipping authentication');
    return null;
  }

  const response = http.post(
    `${config.presuite.baseUrl}${config.presuite.endpoints.login}`,
    JSON.stringify({ email, password }),
    {
      headers: { 'Content-Type': 'application/json' },
      tags: { name: 'auth_login' },
    }
  );

  const success = check(response, {
    'login successful': (r) => r.status === 200,
    'token received': (r) => r.json('token') !== undefined,
  });

  if (!success) {
    console.error(`Authentication failed: ${response.status} - ${response.body}`);
    return null;
  }

  return response.json('token');
}

/**
 * Create authenticated request headers
 */
export function authHeaders(token) {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  };
}

/**
 * Make authenticated GET request
 */
export function authGet(url, token, tags = {}) {
  return http.get(url, {
    headers: authHeaders(token),
    tags,
  });
}

/**
 * Make authenticated POST request
 */
export function authPost(url, body, token, tags = {}) {
  return http.post(url, JSON.stringify(body), {
    headers: authHeaders(token),
    tags,
  });
}

/**
 * Standard response checks
 */
export function checkResponse(response, name) {
  return check(response, {
    [`${name} status 200`]: (r) => r.status === 200,
    [`${name} response time < 500ms`]: (r) => r.timings.duration < 500,
  });
}

/**
 * Generate random string for test data
 */
export function randomString(length = 10) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

/**
 * Generate test email
 */
export function testEmail() {
  return `loadtest-${randomString(8)}@test.premail.site`;
}

/**
 * Sleep with random jitter (human-like behavior)
 */
export function humanSleep(baseMs, jitterMs = 500) {
  const jitter = Math.random() * jitterMs;
  return new Promise((resolve) => setTimeout(resolve, baseMs + jitter));
}
