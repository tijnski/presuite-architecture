/**
 * All Services Load Test
 * Combined test hitting all PreSuite services to simulate real usage
 *
 * Run with:
 *   k6 run scenarios/all-services.js
 *   k6 run -e SCENARIO=load -e TEST_EMAIL=user@test.com -e TEST_PASSWORD=pass scenarios/all-services.js
 */

import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Counter } from 'k6/metrics';
import { config, thresholds, getScenario } from '../lib/config.js';

// Custom metrics
const serviceErrors = new Counter('service_errors');
const presuiteSuccess = new Rate('presuite_success');
const predriveSuccess = new Rate('predrive_success');
const premailSuccess = new Rate('premail_success');
const preofficeSuccess = new Rate('preoffice_success');

export const options = {
  scenarios: getScenario('smoke'),
  thresholds: {
    ...thresholds,
    presuite_success: ['rate>0.95'],
    predrive_success: ['rate>0.95'],
    premail_success: ['rate>0.90'],
    preoffice_success: ['rate>0.95'],
    service_errors: ['count<10'],
  },
};

export function setup() {
  const email = __ENV.TEST_EMAIL;
  const password = __ENV.TEST_PASSWORD;

  if (!email || !password) {
    console.warn('TEST_EMAIL/TEST_PASSWORD not set');
    return { token: null };
  }

  const loginRes = http.post(
    `${config.presuite.baseUrl}/api/auth/login`,
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
  const headers = token
    ? {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      }
    : { 'Content-Type': 'application/json' };

  // PreSuite Hub
  group('PreSuite Hub', () => {
    const healthRes = http.get(`${config.presuite.baseUrl}/api/health`, {
      tags: { name: 'presuite_health', service: 'presuite' },
    });

    const success = check(healthRes, {
      'presuite health 200': (r) => r.status === 200,
    });
    presuiteSuccess.add(success);
    if (!success) serviceErrors.add(1);

    if (token) {
      const verifyRes = http.get(`${config.presuite.baseUrl}/api/auth/verify`, {
        headers,
        tags: { name: 'presuite_verify', service: 'presuite' },
      });
      check(verifyRes, { 'presuite verify 200': (r) => r.status === 200 });
    }
  });

  sleep(0.5);

  // PreDrive
  group('PreDrive', () => {
    const healthRes = http.get(`${config.predrive.baseUrl}/health`, {
      tags: { name: 'predrive_health', service: 'predrive' },
    });

    const success = check(healthRes, {
      'predrive health 200': (r) => r.status === 200,
    });
    predriveSuccess.add(success);
    if (!success) serviceErrors.add(1);

    if (token) {
      const nodesRes = http.get(`${config.predrive.baseUrl}/api/nodes`, {
        headers,
        tags: { name: 'predrive_nodes', service: 'predrive' },
      });
      check(nodesRes, { 'predrive nodes 200': (r) => r.status === 200 });
    }
  });

  sleep(0.5);

  // PreMail
  group('PreMail', () => {
    if (token) {
      const accountsRes = http.get(`${config.premail.baseUrl}/api/v1/accounts`, {
        headers,
        tags: { name: 'premail_accounts', service: 'premail' },
      });

      const success = check(accountsRes, {
        'premail accounts 200': (r) => r.status === 200,
      });
      premailSuccess.add(success);
      if (!success) serviceErrors.add(1);
    } else {
      premailSuccess.add(true); // Skip if no auth
    }
  });

  sleep(0.5);

  // PreOffice
  group('PreOffice', () => {
    const healthRes = http.get(`${config.preoffice.baseUrl}/health`, {
      tags: { name: 'preoffice_health', service: 'preoffice' },
    });

    const success = check(healthRes, {
      'preoffice health 200': (r) => r.status === 200,
    });
    preofficeSuccess.add(success);
    if (!success) serviceErrors.add(1);
  });

  // Simulate realistic user behavior with variable think time
  sleep(Math.random() * 3 + 1);
}

export function handleSummary(data) {
  const metrics = data.metrics;
  let output = '\n=== All Services Load Test Results ===\n\n';

  output += `Total Requests: ${metrics.http_reqs?.values?.count || 0}\n`;
  output += `Service Errors: ${metrics.service_errors?.values?.count || 0}\n`;
  output += `Avg Response Time: ${(metrics.http_req_duration?.values?.avg || 0).toFixed(2)}ms\n`;
  output += `P95 Response Time: ${(metrics.http_req_duration?.values?.['p(95)'] || 0).toFixed(2)}ms\n\n`;

  output += `Service Success Rates:\n`;
  output += `  PreSuite: ${((metrics.presuite_success?.values?.rate || 0) * 100).toFixed(1)}%\n`;
  output += `  PreDrive: ${((metrics.predrive_success?.values?.rate || 0) * 100).toFixed(1)}%\n`;
  output += `  PreMail:  ${((metrics.premail_success?.values?.rate || 0) * 100).toFixed(1)}%\n`;
  output += `  PreOffice: ${((metrics.preoffice_success?.values?.rate || 0) * 100).toFixed(1)}%\n`;

  return {
    stdout: output,
    'results/all-services-summary.json': JSON.stringify(data, null, 2),
  };
}
