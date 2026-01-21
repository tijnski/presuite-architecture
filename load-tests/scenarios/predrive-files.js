/**
 * PreDrive Files Load Test
 * Tests file listing, navigation, and search endpoints
 *
 * Run with:
 *   k6 run scenarios/predrive-files.js
 *   k6 run -e SCENARIO=load -e TEST_EMAIL=user@test.com -e TEST_PASSWORD=pass scenarios/predrive-files.js
 */

import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';
import { config, thresholds, getScenario } from '../lib/config.js';

// Custom metrics
const listSuccessRate = new Rate('list_success_rate');
const searchSuccessRate = new Rate('search_success_rate');
const listDuration = new Trend('list_duration');

export const options = {
  scenarios: getScenario('smoke'),
  thresholds: {
    ...thresholds,
    list_success_rate: ['rate>0.95'],
    list_duration: ['p(95)<800'],
  },
};

const PREDRIVE_URL = config.predrive.baseUrl;
const PRESUITE_URL = config.presuite.baseUrl;

// Store token between iterations
let authToken = null;

export function setup() {
  // Authenticate once at the start
  const email = __ENV.TEST_EMAIL;
  const password = __ENV.TEST_PASSWORD;

  if (!email || !password) {
    console.warn('TEST_EMAIL/TEST_PASSWORD not set - some tests may fail');
    return { token: null };
  }

  const loginRes = http.post(
    `${PRESUITE_URL}/api/auth/login`,
    JSON.stringify({ email, password }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  if (loginRes.status !== 200) {
    console.error('Setup authentication failed');
    return { token: null };
  }

  return { token: loginRes.json('token') };
}

export default function (data) {
  const token = data.token;

  group('Health Check', () => {
    const healthRes = http.get(`${PREDRIVE_URL}/health`, {
      tags: { name: 'health_check' },
    });

    check(healthRes, {
      'health returns 200': (r) => r.status === 200,
      'health response time < 200ms': (r) => r.timings.duration < 200,
    });
  });

  if (!token) {
    console.warn('No auth token - skipping authenticated tests');
    sleep(1);
    return;
  }

  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };

  group('List Root Files', () => {
    const startTime = Date.now();
    const listRes = http.get(`${PREDRIVE_URL}/api/nodes`, {
      headers,
      tags: { name: 'list_root' },
    });
    listDuration.add(Date.now() - startTime);

    const success = check(listRes, {
      'list returns 200': (r) => r.status === 200,
      'list returns array': (r) => {
        try {
          const data = r.json();
          return Array.isArray(data) || Array.isArray(data.nodes);
        } catch {
          return false;
        }
      },
      'list response time < 500ms': (r) => r.timings.duration < 500,
    });

    listSuccessRate.add(success);
  });

  group('Recent Files', () => {
    const recentRes = http.get(`${PREDRIVE_URL}/api/nodes/recent`, {
      headers,
      tags: { name: 'recent_files' },
    });

    check(recentRes, {
      'recent returns 200': (r) => r.status === 200,
      'recent response time < 500ms': (r) => r.timings.duration < 500,
    });
  });

  group('Search Files', () => {
    const searchRes = http.get(`${PREDRIVE_URL}/api/nodes/search?q=test`, {
      headers,
      tags: { name: 'search_files' },
    });

    const success = check(searchRes, {
      'search returns 200': (r) => r.status === 200,
      'search response time < 800ms': (r) => r.timings.duration < 800,
    });

    searchSuccessRate.add(success);
  });

  group('Storage Stats', () => {
    const statsRes = http.get(`${PREDRIVE_URL}/api/storage/stats`, {
      headers,
      tags: { name: 'storage_stats' },
    });

    check(statsRes, {
      'stats returns 200 or 404': (r) => r.status === 200 || r.status === 404,
    });
  });

  // Simulate user browsing behavior
  sleep(Math.random() * 3 + 1);
}

export function handleSummary(data) {
  const metrics = data.metrics;
  let output = '\n=== PreDrive Files Load Test Results ===\n\n';

  output += `Total Requests: ${metrics.http_reqs?.values?.count || 0}\n`;
  output += `Failed Requests: ${metrics.http_req_failed?.values?.passes || 0}\n`;
  output += `Avg Response Time: ${(metrics.http_req_duration?.values?.avg || 0).toFixed(2)}ms\n`;
  output += `P95 Response Time: ${(metrics.http_req_duration?.values?.['p(95)'] || 0).toFixed(2)}ms\n`;
  output += `List Success Rate: ${((metrics.list_success_rate?.values?.rate || 0) * 100).toFixed(1)}%\n`;
  output += `Search Success Rate: ${((metrics.search_success_rate?.values?.rate || 0) * 100).toFixed(1)}%\n`;

  return {
    stdout: output,
    'results/predrive-files-summary.json': JSON.stringify(data, null, 2),
  };
}
