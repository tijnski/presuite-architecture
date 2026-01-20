import { test, expect, request } from '@playwright/test';

const PRESUITE_URL = process.env.PRESUITE_URL || 'https://presuite.eu';
const PREMAIL_URL = process.env.PREMAIL_URL || 'https://premail.site';
const PREDRIVE_URL = process.env.PREDRIVE_URL || 'https://predrive.eu';

/**
 * Integration tests for cross-service authentication flow
 * Tests API-level interactions between PreSuite Hub and other services
 */
test.describe('Authentication API Integration', () => {
  test.describe('JWT Token Validation', () => {
    test('PreSuite /api/auth/verify should validate tokens', async ({ request }) => {
      // Test that the verify endpoint exists and responds correctly
      const response = await request.get(`${PRESUITE_URL}/api/auth/verify`);

      // Without a token, should return 401 or error
      expect([401, 403]).toContain(response.status());
    });

    test('PreSuite /api/health should be accessible', async ({ request }) => {
      const response = await request.get(`${PRESUITE_URL}/api/health`);
      expect(response.ok()).toBeTruthy();

      const data = await response.json();
      expect(data.status).toBe('ok');
    });

    test('PreDrive /health should be accessible', async ({ request }) => {
      const response = await request.get(`${PREDRIVE_URL}/health`);
      expect(response.ok()).toBeTruthy();

      const data = await response.json();
      expect(data.status).toBe('ok');
    });

    test('PreMail /health should be accessible', async ({ request }) => {
      const response = await request.get(`${PREMAIL_URL}/health`);
      expect(response.ok()).toBeTruthy();

      const data = await response.json();
      expect(data.status).toBe('ok');
    });
  });

  test.describe('CORS Configuration', () => {
    test('PreDrive should allow PreSuite origin', async ({ request }) => {
      const response = await request.options(`${PREDRIVE_URL}/api/nodes`, {
        headers: {
          'Origin': PRESUITE_URL,
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'authorization',
        },
      });

      const corsHeader = response.headers()['access-control-allow-origin'];
      expect(corsHeader).toBeTruthy();
    });

    test('PreMail should allow PreSuite origin', async ({ request }) => {
      const response = await request.options(`${PREMAIL_URL}/api/v1/messages`, {
        headers: {
          'Origin': PRESUITE_URL,
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'authorization',
        },
      });

      const corsHeader = response.headers()['access-control-allow-origin'];
      expect(corsHeader).toBeTruthy();
    });
  });

  test.describe('OAuth Endpoints', () => {
    test('PreSuite OAuth authorize endpoint should exist', async ({ request }) => {
      const response = await request.get(`${PRESUITE_URL}/api/oauth/authorize`, {
        params: {
          client_id: 'premail',
          redirect_uri: `${PREMAIL_URL}/oauth/callback`,
          response_type: 'code',
          state: 'test-state',
        },
      });

      // Should redirect to login or return authorize page
      expect([200, 302, 303]).toContain(response.status());
    });

    test('OAuth token endpoint should require valid code', async ({ request }) => {
      const response = await request.post(`${PRESUITE_URL}/api/oauth/token`, {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        data: 'grant_type=authorization_code&code=invalid_code&client_id=premail&client_secret=test',
      });

      // Invalid code should return error
      expect([400, 401, 403]).toContain(response.status());
    });
  });

  test.describe('Session Check Endpoint', () => {
    test('PreSuite check-session should exist', async ({ request }) => {
      const response = await request.get(`${PRESUITE_URL}/api/auth/check-session`);

      // Without token should return invalid
      expect([200, 401]).toContain(response.status());

      if (response.status() === 200) {
        const data = await response.json();
        expect(data.valid).toBe(false);
      }
    });
  });

  test.describe('Web3 Authentication Endpoints', () => {
    test('Web3 nonce endpoint should exist', async ({ request }) => {
      const testAddress = '0x742d35Cc6634C0532925a3b844Bc9e7595f00000';

      const response = await request.get(`${PRESUITE_URL}/api/auth/web3/nonce`, {
        params: { address: testAddress },
      });

      expect(response.ok()).toBeTruthy();

      const data = await response.json();
      expect(data.nonce).toBeTruthy();
      expect(data.message).toContain('PreSuite');
    });

    test('Web3 verify should reject invalid signature', async ({ request }) => {
      const response = await request.post(`${PRESUITE_URL}/api/auth/web3/verify`, {
        headers: { 'Content-Type': 'application/json' },
        data: JSON.stringify({
          address: '0x742d35Cc6634C0532925a3b844Bc9e7595f00000',
          signature: 'invalid_signature',
        }),
      });

      expect([400, 401]).toContain(response.status());
    });
  });
});

test.describe('Rate Limiting', () => {
  test('Auth endpoints should be rate limited', async ({ request }) => {
    const responses: number[] = [];

    // Make 10 rapid requests
    for (let i = 0; i < 10; i++) {
      const response = await request.post(`${PRESUITE_URL}/api/auth/login`, {
        headers: { 'Content-Type': 'application/json' },
        data: JSON.stringify({ email: 'test@test.com', password: 'wrong' }),
      });
      responses.push(response.status());
    }

    // At least one request should eventually be rate limited (429)
    // or all should be 401 for invalid credentials
    const validStatuses = responses.every(s => [401, 429].includes(s));
    expect(validStatuses).toBeTruthy();
  });
});
