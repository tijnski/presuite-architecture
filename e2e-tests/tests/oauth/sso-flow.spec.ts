import { test, expect, Page } from '@playwright/test';

const PRESUITE_URL = process.env.PRESUITE_URL || 'https://presuite.eu';
const PREMAIL_URL = process.env.PREMAIL_URL || 'https://premail.site';
const PREDRIVE_URL = process.env.PREDRIVE_URL || 'https://predrive.eu';
const PREOFFICE_URL = process.env.PREOFFICE_URL || 'https://preoffice.site';

test.describe('OAuth SSO Flow', () => {
  test.describe('PreSuite Hub Authentication', () => {
    test('should load PreSuite Hub login page', async ({ page }) => {
      await page.goto(PRESUITE_URL);
      await expect(page).toHaveTitle(/PreSuite/i);
    });

    test('should display login form when not authenticated', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Check for login elements (adjust selectors based on actual implementation)
      const loginButton = page.getByRole('button', { name: /sign in|login/i });
      await expect(loginButton).toBeVisible();
    });

    test('should redirect to login when accessing protected routes', async ({ page }) => {
      await page.goto(`${PRESUITE_URL}/dashboard`);

      // Should redirect to login or show login prompt
      await expect(page.url()).toMatch(/login|signin|auth/i);
    });
  });

  test.describe('Cross-Service SSO - PreMail', () => {
    test('should show PreSuite SSO button on PreMail', async ({ page }) => {
      await page.goto(PREMAIL_URL);

      // Check for SSO button
      const ssoButton = page.getByRole('button', { name: /sign in with presuite/i });
      await expect(ssoButton).toBeVisible();
    });

    test('should redirect to PreSuite for authentication', async ({ page }) => {
      await page.goto(PREMAIL_URL);

      const ssoButton = page.getByRole('button', { name: /sign in with presuite/i });
      await ssoButton.click();

      // Should redirect to PreSuite OAuth authorize endpoint
      await page.waitForURL(/presuite\.eu.*oauth.*authorize/i, { timeout: 10000 });
      expect(page.url()).toContain('presuite.eu');
    });
  });

  test.describe('Cross-Service SSO - PreDrive', () => {
    test('should show PreSuite SSO button on PreDrive', async ({ page }) => {
      await page.goto(PREDRIVE_URL);

      // Check for SSO button
      const ssoButton = page.getByRole('button', { name: /sign in with presuite/i });
      await expect(ssoButton).toBeVisible();
    });

    test('should redirect to PreSuite for authentication', async ({ page }) => {
      await page.goto(PREDRIVE_URL);

      const ssoButton = page.getByRole('button', { name: /sign in with presuite/i });
      await ssoButton.click();

      // Should redirect to PreSuite OAuth authorize endpoint
      await page.waitForURL(/presuite\.eu.*oauth.*authorize/i, { timeout: 10000 });
      expect(page.url()).toContain('presuite.eu');
    });
  });

  test.describe('Cross-Service SSO - PreOffice', () => {
    test('should load PreOffice landing page', async ({ page }) => {
      await page.goto(PREOFFICE_URL);
      await expect(page).toHaveTitle(/PreOffice/i);
    });

    test('should show PreSuite SSO button on PreOffice', async ({ page }) => {
      await page.goto(PREOFFICE_URL);

      // Check for SSO button
      const ssoButton = page.getByRole('button', { name: /sign in with presuite/i });
      await expect(ssoButton).toBeVisible();
    });
  });

  test.describe('OAuth State Validation', () => {
    test('should include state parameter in OAuth redirect', async ({ page }) => {
      await page.goto(PREMAIL_URL);

      const ssoButton = page.getByRole('button', { name: /sign in with presuite/i });
      await ssoButton.click();

      await page.waitForURL(/presuite\.eu/i, { timeout: 10000 });

      // URL should contain state parameter
      expect(page.url()).toContain('state=');
    });

    test('should include correct client_id in OAuth redirect', async ({ page }) => {
      await page.goto(PREMAIL_URL);

      const ssoButton = page.getByRole('button', { name: /sign in with presuite/i });
      await ssoButton.click();

      await page.waitForURL(/presuite\.eu/i, { timeout: 10000 });

      // URL should contain correct client_id
      expect(page.url()).toContain('client_id=premail');
    });
  });
});

test.describe('OAuth Error Handling', () => {
  test('should handle invalid callback gracefully', async ({ page }) => {
    await page.goto(`${PREMAIL_URL}/oauth/callback?error=access_denied`);

    // Should show error message or redirect to login
    await expect(page.getByText(/error|denied|failed/i)).toBeVisible();
  });

  test('should handle missing code parameter', async ({ page }) => {
    await page.goto(`${PREMAIL_URL}/oauth/callback?state=test`);

    // Should handle gracefully
    await expect(page.url()).not.toContain('/dashboard');
  });
});
