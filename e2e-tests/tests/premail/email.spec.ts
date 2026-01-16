import { test, expect } from '@playwright/test';

const PREMAIL_URL = process.env.PREMAIL_URL || 'https://premail.site';

test.describe('PreMail', () => {
  test.describe('Landing Page', () => {
    test('should load the login page', async ({ page }) => {
      await page.goto(PREMAIL_URL);
      await expect(page).toHaveTitle(/PreMail/i);
    });

    test('should display login form', async ({ page }) => {
      await page.goto(PREMAIL_URL);

      // Should show login options
      await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
    });

    test('should show PreSuite SSO option', async ({ page }) => {
      await page.goto(PREMAIL_URL);

      // Should show SSO button
      await expect(page.getByRole('button', { name: /sign in with presuite/i })).toBeVisible();
    });
  });

  test.describe('OAuth Callback', () => {
    test('should handle OAuth callback route', async ({ page }) => {
      // Navigate to OAuth callback without code (should handle gracefully)
      const response = await page.goto(`${PREMAIL_URL}/oauth/callback`);
      expect(response?.status()).toBeLessThan(500);
    });
  });

  test.describe('UI Components', () => {
    test('should have responsive layout', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto(PREMAIL_URL);

      // Should still be functional on mobile
      await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
    });
  });
});

test.describe('PreMail Authenticated Features', () => {
  // These tests require authentication
  // Use test.skip or implement proper auth setup
  test.describe.skip('Inbox', () => {
    test('should display inbox', async ({ page }) => {
      // Would need to set up authentication first
      await page.goto(`${PREMAIL_URL}/inbox`);
      await expect(page.getByText(/inbox/i)).toBeVisible();
    });

    test('should display email list', async ({ page }) => {
      await page.goto(`${PREMAIL_URL}/inbox`);
      // Check for email list container
      await expect(page.locator('[data-testid="email-list"]')).toBeVisible();
    });
  });

  test.describe.skip('Compose', () => {
    test('should open compose modal', async ({ page }) => {
      await page.goto(`${PREMAIL_URL}/inbox`);
      await page.getByRole('button', { name: /compose/i }).click();
      await expect(page.getByRole('dialog')).toBeVisible();
    });
  });
});
