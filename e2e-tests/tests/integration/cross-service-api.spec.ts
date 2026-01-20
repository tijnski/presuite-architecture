import { test, expect } from '@playwright/test';

const PRESUITE_URL = process.env.PRESUITE_URL || 'https://presuite.eu';
const PREMAIL_URL = process.env.PREMAIL_URL || 'https://premail.site';
const PREDRIVE_URL = process.env.PREDRIVE_URL || 'https://predrive.eu';
const PREOFFICE_URL = process.env.PREOFFICE_URL || 'https://preoffice.site';
const PRESOCIAL_URL = process.env.PRESOCIAL_URL || 'https://presocial.presuite.eu';

/**
 * Integration tests for cross-service API interactions
 * These tests verify that services can communicate correctly
 */
test.describe('Cross-Service API Integration', () => {
  test.describe('PreDrive API', () => {
    test('API should require authentication', async ({ request }) => {
      const response = await request.get(`${PREDRIVE_URL}/api/nodes`);
      expect([401, 403]).toContain(response.status());
    });

    test('Public share endpoint should work without auth', async ({ request }) => {
      // Public shares should be accessible (will 404 for invalid token)
      const response = await request.get(`${PREDRIVE_URL}/api/public/shares/invalid-token`);
      expect([404, 401]).toContain(response.status());
    });

    test('WebDAV endpoint should exist', async ({ request }) => {
      const response = await request.fetch(`${PREDRIVE_URL}/webdav`, {
        method: 'PROPFIND',
      });

      // WebDAV without auth should return 401
      expect([401, 405]).toContain(response.status());
    });
  });

  test.describe('PreMail API', () => {
    test('API should require authentication', async ({ request }) => {
      const response = await request.get(`${PREMAIL_URL}/api/v1/messages`);
      expect([401, 403]).toContain(response.status());
    });

    test('Labels endpoint should require auth', async ({ request }) => {
      const response = await request.get(`${PREMAIL_URL}/api/v1/labels`);
      expect([401, 403]).toContain(response.status());
    });

    test('Contacts endpoint should require auth', async ({ request }) => {
      const response = await request.get(`${PREMAIL_URL}/api/v1/contacts`);
      expect([401, 403]).toContain(response.status());
    });

    test('Filters endpoint should require auth', async ({ request }) => {
      const response = await request.get(`${PREMAIL_URL}/api/v1/filters`);
      expect([401, 403]).toContain(response.status());
    });
  });

  test.describe('PreOffice API', () => {
    test('Health endpoint should be accessible', async ({ request }) => {
      const response = await request.get(`${PREOFFICE_URL}/health`);
      expect(response.ok()).toBeTruthy();
    });

    test('AI status endpoint should be accessible', async ({ request }) => {
      const response = await request.get(`${PREOFFICE_URL}/api/ai/status`);
      expect(response.ok()).toBeTruthy();

      const data = await response.json();
      expect(data).toHaveProperty('available');
    });

    test('AI chat endpoint should require authentication', async ({ request }) => {
      const response = await request.post(`${PREOFFICE_URL}/api/ai/chat`, {
        headers: { 'Content-Type': 'application/json' },
        data: JSON.stringify({ message: 'test' }),
      });

      expect([401, 403]).toContain(response.status());
    });
  });

  test.describe('PreSocial API', () => {
    test('Health endpoint should be accessible', async ({ request }) => {
      const response = await request.get(`${PRESOCIAL_URL}/health`);
      expect(response.ok()).toBeTruthy();
    });

    test('Communities endpoint should be accessible', async ({ request }) => {
      const response = await request.get(`${PRESOCIAL_URL}/api/social/communities`);
      expect(response.ok()).toBeTruthy();

      const data = await response.json();
      expect(data).toHaveProperty('communities');
    });

    test('Posts should be publicly readable', async ({ request }) => {
      const response = await request.get(`${PRESOCIAL_URL}/api/social/posts`);
      expect(response.ok()).toBeTruthy();

      const data = await response.json();
      expect(data).toHaveProperty('posts');
    });

    test('Voting should require authentication', async ({ request }) => {
      const response = await request.post(`${PRESOCIAL_URL}/api/social/votes`, {
        headers: { 'Content-Type': 'application/json' },
        data: JSON.stringify({ postId: 'test', value: 1 }),
      });

      expect([401, 403]).toContain(response.status());
    });
  });
});

test.describe('JWT Token Cross-Service Validation', () => {
  // These tests verify that a valid PreSuite token works across services
  // Note: Requires TEST_JWT_TOKEN environment variable for full testing

  test.skip('Valid PreSuite token should work on PreDrive', async ({ request }) => {
    const token = process.env.TEST_JWT_TOKEN;
    if (!token) {
      test.skip();
      return;
    }

    const response = await request.get(`${PREDRIVE_URL}/api/nodes`, {
      headers: { Authorization: `Bearer ${token}` },
    });

    expect(response.ok()).toBeTruthy();
  });

  test.skip('Valid PreSuite token should work on PreMail', async ({ request }) => {
    const token = process.env.TEST_JWT_TOKEN;
    if (!token) {
      test.skip();
      return;
    }

    const response = await request.get(`${PREMAIL_URL}/api/v1/messages`, {
      headers: { Authorization: `Bearer ${token}` },
    });

    expect(response.ok()).toBeTruthy();
  });
});

test.describe('Service Discovery & Connectivity', () => {
  const services = [
    { name: 'PreSuite Hub', url: PRESUITE_URL, healthPath: '/api/health' },
    { name: 'PreDrive', url: PREDRIVE_URL, healthPath: '/health' },
    { name: 'PreMail', url: PREMAIL_URL, healthPath: '/health' },
    { name: 'PreOffice', url: PREOFFICE_URL, healthPath: '/health' },
    { name: 'PreSocial', url: PRESOCIAL_URL, healthPath: '/health' },
  ];

  for (const service of services) {
    test(`${service.name} should be reachable`, async ({ request }) => {
      const response = await request.get(`${service.url}${service.healthPath}`, {
        timeout: 10000,
      });

      expect(response.ok()).toBeTruthy();
      const data = await response.json();
      expect(data.status).toBe('ok');
    });
  }
});

test.describe('Error Response Consistency', () => {
  test('PreDrive should return consistent error format', async ({ request }) => {
    const response = await request.get(`${PREDRIVE_URL}/api/nodes/invalid-uuid`);

    if (!response.ok()) {
      const data = await response.json();
      expect(data).toHaveProperty('error');
      expect(data.error).toHaveProperty('message');
    }
  });

  test('PreMail should return consistent error format', async ({ request }) => {
    const response = await request.get(`${PREMAIL_URL}/api/v1/messages/invalid-uuid`);

    if (!response.ok()) {
      const data = await response.json();
      expect(data).toHaveProperty('error');
    }
  });
});
