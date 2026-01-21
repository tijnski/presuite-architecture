/**
 * PreMail Inbox Load Test
 * Tests email listing, account management, and labels
 *
 * Run with:
 *   k6 run scenarios/premail-inbox.js
 *   k6 run -e SCENARIO=load -e TEST_EMAIL=user@test.com -e TEST_PASSWORD=pass scenarios/premail-inbox.js
 */

import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';
import { config, thresholds, getScenario } from '../lib/config.js';

// Custom metrics
const accountsSuccessRate = new Rate('accounts_success_rate');
const messagesSuccessRate = new Rate('messages_success_rate');
const inboxDuration = new Trend('inbox_duration');

export const options = {
  scenarios: getScenario('smoke'),
  thresholds: {
    ...thresholds,
    accounts_success_rate: ['rate>0.95'],
    messages_success_rate: ['rate>0.90'],
    inbox_duration: ['p(95)<1000'],
  },
};

const PREMAIL_URL = config.premail.baseUrl;
const PRESUITE_URL = config.presuite.baseUrl;

export function setup() {
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

  if (!token) {
    console.warn('No auth token - skipping tests');
    sleep(1);
    return;
  }

  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };

  let accountId = null;

  group('List Email Accounts', () => {
    const accountsRes = http.get(`${PREMAIL_URL}/api/v1/accounts`, {
      headers,
      tags: { name: 'list_accounts' },
    });

    const success = check(accountsRes, {
      'accounts returns 200': (r) => r.status === 200,
      'accounts returns array': (r) => {
        try {
          const data = r.json();
          return Array.isArray(data);
        } catch {
          return false;
        }
      },
      'accounts response time < 500ms': (r) => r.timings.duration < 500,
    });

    accountsSuccessRate.add(success);

    // Get first account ID for subsequent tests
    if (success && accountsRes.status === 200) {
      try {
        const accounts = accountsRes.json();
        if (accounts.length > 0) {
          accountId = accounts[0].id;
        }
      } catch (e) {
        console.warn('Failed to parse accounts response');
      }
    }
  });

  if (accountId) {
    group('List Inbox Messages', () => {
      const startTime = Date.now();
      const messagesRes = http.get(
        `${PREMAIL_URL}/api/v1/messages?accountId=${accountId}&folder=INBOX&page=0&pageSize=20`,
        {
          headers,
          tags: { name: 'list_messages' },
        }
      );
      inboxDuration.add(Date.now() - startTime);

      const success = check(messagesRes, {
        'messages returns 200': (r) => r.status === 200,
        'messages response time < 1s': (r) => r.timings.duration < 1000,
      });

      messagesSuccessRate.add(success);
    });

    group('List Labels', () => {
      const labelsRes = http.get(`${PREMAIL_URL}/api/v1/labels?accountId=${accountId}`, {
        headers,
        tags: { name: 'list_labels' },
      });

      check(labelsRes, {
        'labels returns 200': (r) => r.status === 200,
        'labels response time < 500ms': (r) => r.timings.duration < 500,
      });
    });

    group('List Folders', () => {
      const foldersRes = http.get(`${PREMAIL_URL}/api/v1/folders?accountId=${accountId}`, {
        headers,
        tags: { name: 'list_folders' },
      });

      check(foldersRes, {
        'folders returns 200 or 404': (r) => r.status === 200 || r.status === 404,
      });
    });

    group('Unread Count', () => {
      const unreadRes = http.get(`${PREMAIL_URL}/api/v1/accounts/${accountId}/unread`, {
        headers,
        tags: { name: 'unread_count' },
      });

      check(unreadRes, {
        'unread returns 200 or 404': (r) => r.status === 200 || r.status === 404,
        'unread response time < 300ms': (r) => r.timings.duration < 300,
      });
    });
  }

  // Simulate email checking behavior
  sleep(Math.random() * 5 + 2);
}

export function handleSummary(data) {
  const metrics = data.metrics;
  let output = '\n=== PreMail Inbox Load Test Results ===\n\n';

  output += `Total Requests: ${metrics.http_reqs?.values?.count || 0}\n`;
  output += `Failed Requests: ${metrics.http_req_failed?.values?.passes || 0}\n`;
  output += `Avg Response Time: ${(metrics.http_req_duration?.values?.avg || 0).toFixed(2)}ms\n`;
  output += `P95 Response Time: ${(metrics.http_req_duration?.values?.['p(95)'] || 0).toFixed(2)}ms\n`;
  output += `Accounts Success Rate: ${((metrics.accounts_success_rate?.values?.rate || 0) * 100).toFixed(1)}%\n`;
  output += `Messages Success Rate: ${((metrics.messages_success_rate?.values?.rate || 0) * 100).toFixed(1)}%\n`;
  output += `P95 Inbox Load Time: ${(metrics.inbox_duration?.values?.['p(95)'] || 0).toFixed(2)}ms\n`;

  return {
    stdout: output,
    'results/premail-inbox-summary.json': JSON.stringify(data, null, 2),
  };
}
