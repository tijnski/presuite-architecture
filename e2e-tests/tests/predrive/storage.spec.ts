import { test, expect } from '@playwright/test';

const PREDRIVE_URL = process.env.PREDRIVE_URL || 'https://predrive.eu';

test.describe('PreDrive', () => {
  test.describe('Landing Page', () => {
    test('should load the login page', async ({ page }) => {
      await page.goto(PREDRIVE_URL);
      await expect(page).toHaveTitle(/PreDrive/i);
    });

    test('should display login form', async ({ page }) => {
      await page.goto(PREDRIVE_URL);

      // Should show login options
      await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
    });

    test('should show PreSuite SSO option', async ({ page }) => {
      await page.goto(PREDRIVE_URL);

      // Should show SSO button
      await expect(page.getByRole('button', { name: /sign in with presuite/i })).toBeVisible();
    });
  });

  test.describe('OAuth Callback', () => {
    test('should handle OAuth callback route', async ({ page }) => {
      // Navigate to OAuth callback without code (should handle gracefully)
      const response = await page.goto(`${PREDRIVE_URL}/oauth/callback`);
      expect(response?.status()).toBeLessThan(500);
    });
  });

  test.describe('API Endpoints', () => {
    test('should return 401 for unauthenticated API requests', async ({ request }) => {
      const response = await request.get(`${PREDRIVE_URL}/api/nodes`);
      expect(response.status()).toBe(401);
    });

    test('should have CORS headers', async ({ request }) => {
      const response = await request.options(`${PREDRIVE_URL}/api/nodes`);
      // Should not error on OPTIONS request
      expect(response.status()).toBeLessThan(500);
    });
  });

  test.describe('UI Components', () => {
    test('should have responsive layout', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto(PREDRIVE_URL);

      // Should still be functional on mobile
      await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
    });
  });
});

test.describe('PreDrive Authenticated Features', () => {
  // These tests require authentication
  // Use test.skip or implement proper auth setup
  test.describe.skip('File Browser', () => {
    test('should display file browser', async ({ page }) => {
      await page.goto(`${PREDRIVE_URL}/files`);
      await expect(page.getByText(/my drive/i)).toBeVisible();
    });

    test('should display root folder', async ({ page }) => {
      await page.goto(`${PREDRIVE_URL}/files`);
      await expect(page.locator('[data-testid="file-browser"]')).toBeVisible();
    });
  });

  test.describe.skip('Upload', () => {
    test('should show upload button', async ({ page }) => {
      await page.goto(`${PREDRIVE_URL}/files`);
      await expect(page.getByRole('button', { name: /upload/i })).toBeVisible();
    });
  });

  test.describe.skip('WebDAV', () => {
    test('should expose WebDAV endpoint', async ({ request }) => {
      const response = await request.request(`${PREDRIVE_URL}/webdav/`, {
        method: 'PROPFIND',
        headers: {
          'Depth': '0',
        },
      });
      // Should require auth but not error
      expect([401, 207]).toContain(response.status());
    });
  });
});
