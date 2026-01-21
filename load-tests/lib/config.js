/**
 * k6 Load Test Configuration
 * Shared configuration for all PreSuite load tests
 */

// Environment URLs (override with -e flags)
export const config = {
  presuite: {
    baseUrl: __ENV.PRESUITE_URL || 'https://presuite.eu',
    endpoints: {
      health: '/api/health',
      login: '/api/auth/login',
      verify: '/api/auth/verify',
      register: '/api/auth/register',
    },
  },
  predrive: {
    baseUrl: __ENV.PREDRIVE_URL || 'https://predrive.eu',
    endpoints: {
      health: '/health',
      nodes: '/api/nodes',
      recent: '/api/nodes/recent',
      search: '/api/nodes/search',
    },
  },
  premail: {
    baseUrl: __ENV.PREMAIL_URL || 'https://premail.site',
    endpoints: {
      accounts: '/api/v1/accounts',
      messages: '/api/v1/messages',
      labels: '/api/v1/labels',
    },
  },
  preoffice: {
    baseUrl: __ENV.PREOFFICE_URL || 'https://preoffice.site',
    endpoints: {
      health: '/health',
      create: '/api/create',
      recent: '/api/recent',
    },
  },
};

// Standard load test thresholds
export const thresholds = {
  // 95% of requests should complete within 500ms
  http_req_duration: ['p(95)<500'],
  // 99% of requests should complete within 1500ms
  'http_req_duration{scenario:smoke}': ['p(99)<1500'],
  // Error rate should be below 1%
  http_req_failed: ['rate<0.01'],
  // Checks should pass 99% of the time
  checks: ['rate>0.99'],
};

// Test scenarios
export const scenarios = {
  // Smoke test - minimal load to verify functionality
  smoke: {
    executor: 'constant-vus',
    vus: 1,
    duration: '30s',
  },
  // Load test - normal expected traffic
  load: {
    executor: 'ramping-vus',
    startVUs: 0,
    stages: [
      { duration: '2m', target: 10 },  // Ramp up
      { duration: '5m', target: 10 },  // Hold
      { duration: '2m', target: 0 },   // Ramp down
    ],
  },
  // Stress test - find breaking point
  stress: {
    executor: 'ramping-vus',
    startVUs: 0,
    stages: [
      { duration: '2m', target: 10 },
      { duration: '5m', target: 50 },
      { duration: '2m', target: 100 },
      { duration: '5m', target: 100 },
      { duration: '2m', target: 0 },
    ],
  },
  // Spike test - sudden traffic surge
  spike: {
    executor: 'ramping-vus',
    startVUs: 0,
    stages: [
      { duration: '10s', target: 100 },
      { duration: '1m', target: 100 },
      { duration: '10s', target: 0 },
    ],
  },
};

// Get scenario based on environment variable
export function getScenario(defaultScenario = 'smoke') {
  const scenarioName = __ENV.SCENARIO || defaultScenario;
  return { [scenarioName]: scenarios[scenarioName] };
}
