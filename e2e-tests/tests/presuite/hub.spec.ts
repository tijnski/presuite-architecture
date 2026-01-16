import { test, expect } from '@playwright/test';

const PRESUITE_URL = process.env.PRESUITE_URL || 'https://presuite.eu';

test.describe('PreSuite Hub', () => {
  test.describe('Landing Page', () => {
    test('should load the landing page', async ({ page }) => {
      await page.goto(PRESUITE_URL);
      await expect(page).toHaveTitle(/PreSuite/i);
    });

    test('should display the launchpad', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Check for app icons in launchpad
      await expect(page.getByText(/PreMail/i)).toBeVisible();
      await expect(page.getByText(/PreDrive/i)).toBeVisible();
      await expect(page.getByText(/PreOffice/i)).toBeVisible();
    });
  });

  test.describe('App Modals', () => {
    test('should open PreDocs modal', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Click on PreDocs
      await page.getByText(/PreDocs/i).click();

      // Modal should open
      await expect(page.getByRole('dialog')).toBeVisible();
      await expect(page.getByText(/Documents/i)).toBeVisible();
    });

    test('should open PreSheets modal', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Click on PreSheets
      await page.getByText(/PreSheets/i).click();

      // Modal should open
      await expect(page.getByRole('dialog')).toBeVisible();
      await expect(page.getByText(/Spreadsheets/i)).toBeVisible();
    });

    test('should open PreSlides modal', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Click on PreSlides
      await page.getByText(/PreSlides/i).click();

      // Modal should open
      await expect(page.getByRole('dialog')).toBeVisible();
      await expect(page.getByText(/Presentations/i)).toBeVisible();
    });

    test('should open PreCalendar modal', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Click on PreCalendar
      await page.getByText(/PreCalendar/i).click();

      // Modal should open with calendar
      await expect(page.getByRole('dialog')).toBeVisible();

      // Check for calendar navigation
      await expect(page.getByRole('button', { name: /previous|</ })).toBeVisible();
      await expect(page.getByRole('button', { name: /next|>/ })).toBeVisible();
    });

    test('should open PreWallet modal', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Click on PreWallet
      await page.getByText(/PreWallet/i).click();

      // Modal should open
      await expect(page.getByRole('dialog')).toBeVisible();
      await expect(page.getByText(/PRE/i)).toBeVisible();
    });

    test('should close modal on X button click', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Open a modal
      await page.getByText(/PreDocs/i).click();
      await expect(page.getByRole('dialog')).toBeVisible();

      // Close the modal
      await page.getByRole('button', { name: /close|×/i }).click();

      // Modal should be closed
      await expect(page.getByRole('dialog')).not.toBeVisible();
    });
  });

  test.describe('Navigation', () => {
    test('should navigate to PreMail on click', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Click PreMail link
      const [newPage] = await Promise.all([
        page.context().waitForEvent('page'),
        page.getByText(/PreMail/i).click(),
      ]);

      await newPage.waitForLoadState();
      expect(newPage.url()).toContain('premail');
    });

    test('should navigate to PreDrive on click', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Click PreDrive link
      const [newPage] = await Promise.all([
        page.context().waitForEvent('page'),
        page.getByText(/PreDrive/i).click(),
      ]);

      await newPage.waitForLoadState();
      expect(newPage.url()).toContain('predrive');
    });
  });

  test.describe('Search Functionality', () => {
    test('should display search bar', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      // Check for search input
      const searchInput = page.getByPlaceholder(/search/i);
      await expect(searchInput).toBeVisible();
    });

    test('should filter apps on search', async ({ page }) => {
      await page.goto(PRESUITE_URL);

      const searchInput = page.getByPlaceholder(/search/i);
      await searchInput.fill('mail');

      // PreMail should be visible, others may be filtered
      await expect(page.getByText(/PreMail/i)).toBeVisible();
    });
  });

  test.describe('Responsive Design', () => {
    test('should work on mobile viewport', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto(PRESUITE_URL);

      // Should still show app icons
      await expect(page.getByText(/PreMail/i)).toBeVisible();
    });

    test('should work on tablet viewport', async ({ page }) => {
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.goto(PRESUITE_URL);

      // Should still show app icons
      await expect(page.getByText(/PreMail/i)).toBeVisible();
    });
  });
});
