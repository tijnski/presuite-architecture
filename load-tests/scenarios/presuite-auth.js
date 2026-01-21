/**
 * PreSuite Authentication Load Test
 * Tests login, token verification, and auth endpoints
 *
 * Run with:
 *   k6 run scenarios/presuite-auth.js
 *   k6 run -e SCENARIO=load scenarios/presuite-auth.js
 *   k6 run -e SCENARIO=stress scenarios/presuite-auth.js
 */

import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';
import { config, thresholds, getScenario } from '../lib/config.js';
import { randomString } from '../lib/helpers.js';

// Custom metrics
const loginSuccessRate = new Rate('login_success_rate');
const verifySuccessRate = new Rate('verify_success_rate');
const loginDuration = new Trend('login_duration');

export const options = {
  scenarios: getScenario('smoke'),
  thresholds: {
    ...thresholds,
    login_success_rate: ['rate>0.95'],
    verify_success_rate: ['rate>0.99'],
    login_duration: ['p(95)<1000'],
  },
};

const BASE_URL = config.presuite.baseUrl;

export default function () {
  // Test credentials (set via environment or use defaults for smoke test)
  const testEmail = __ENV.TEST_EMAIL || 'loadtest@premail.site';
  const testPassword = __ENV.TEST_PASSWORD || 'LoadTest123!';

  group('Health Check', () => {
    const healthRes = http.get(`${BASE_URL}/api/health`, {
      tags: { name: 'health_check' },
    });

    check(healthRes, {
      'health endpoint returns 200': (r) => r.status === 200,
      'health response time < 200ms': (r) => r.timings.duration < 200,
    });
  });

  group('Login Flow', () => {
    // Attempt login
    const loginStart = Date.now();
    const loginRes = http.post(
      `${BASE_URL}/api/auth/login`,
      JSON.stringify({
        email: testEmail,
        password: testPassword,
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        tags: { name: 'auth_login' },
      }
    );
    const loginTime = Date.now() - loginStart;

    loginDuration.add(loginTime);

    const loginSuccess = check(loginRes, {
      'login returns 200': (r) => r.status === 200,
      'login returns token': (r) => {
        try {
          return r.json('token') !== undefined;
        } catch {
          return false;
        }
      },
      'login response time < 1s': (r) => r.timings.duration < 1000,
    });

    loginSuccessRate.add(loginSuccess);

    if (loginSuccess) {
      const token = loginRes.json('token');

      // Verify token
      const verifyRes = http.get(`${BASE_URL}/api/auth/verify`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
        tags: { name: 'auth_verify' },
      });

      const verifySuccess = check(verifyRes, {
        'verify returns 200': (r) => r.status === 200,
        'verify confirms valid': (r) => {
          try {
            return r.json('valid') === true;
          } catch {
            return false;
          }
        },
        'verify response time < 200ms': (r) => r.timings.duration < 200,
      });

      verifySuccessRate.add(verifySuccess);

      // Get user info
      const meRes = http.get(`${BASE_URL}/api/auth/me`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
        tags: { name: 'auth_me' },
      });

      check(meRes, {
        'me returns 200': (r) => r.status === 200,
        'me returns user data': (r) => {
          try {
            return r.json('email') !== undefined;
          } catch {
            return false;
          }
        },
      });
    }
  });

  group('Invalid Auth', () => {
    // Test rate limiting and invalid credentials
    const invalidRes = http.post(
      `${BASE_URL}/api/auth/login`,
      JSON.stringify({
        email: `invalid-${randomString(5)}@test.com`,
        password: 'wrongpassword',
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        tags: { name: 'auth_invalid' },
      }
    );

    check(invalidRes, {
      'invalid login returns 401': (r) => r.status === 401,
    });

    // Test with invalid token
    const invalidTokenRes = http.get(`${BASE_URL}/api/auth/verify`, {
      headers: {
        Authorization: 'Bearer invalid-token-12345',
      },
      tags: { name: 'auth_invalid_token' },
    });

    check(invalidTokenRes, {
      'invalid token returns 401': (r) => r.status === 401,
    });
  });

  // Simulate user think time
  sleep(Math.random() * 2 + 1);
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: '  ', enableColors: true }),
    'results/presuite-auth-summary.json': JSON.stringify(data, null, 2),
  };
}

function textSummary(data, opts) {
  // Simple text summary for console output
  const metrics = data.metrics;
  let output = '\n=== PreSuite Auth Load Test Results ===\n\n';

  output += `Total Requests: ${metrics.http_reqs?.values?.count || 0}\n`;
  output += `Failed Requests: ${metrics.http_req_failed?.values?.passes || 0}\n`;
  output += `Avg Response Time: ${(metrics.http_req_duration?.values?.avg || 0).toFixed(2)}ms\n`;
  output += `P95 Response Time: ${(metrics.http_req_duration?.values?.['p(95)'] || 0).toFixed(2)}ms\n`;
  output += `Login Success Rate: ${((metrics.login_success_rate?.values?.rate || 0) * 100).toFixed(1)}%\n`;
  output += `Verify Success Rate: ${((metrics.verify_success_rate?.values?.rate || 0) * 100).toFixed(1)}%\n`;

  return output;
}
