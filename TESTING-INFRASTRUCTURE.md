# PreSuite Testing Infrastructure

> **Date:** January 16, 2026
> **Author:** Claude Opus 4.5
> **Status:** Implemented

---

## Overview

This document describes the testing infrastructure set up for the PreSuite ecosystem, including unit tests, integration tests, and end-to-end (E2E) tests.

---

## Testing Stack

| Type | Framework | Location |
|------|-----------|----------|
| Unit Tests | Vitest | Each project's `__tests__` directory |
| React Component Tests | Vitest + Testing Library | `presuite/src/__tests__` |
| E2E Tests | Playwright | `ARC/e2e-tests` |

---

## Unit Testing with Vitest

### PreSuite Hub

**Configuration:** `presuite/vitest.config.ts`

```bash
# Run tests
cd presuite
npm test

# Run with coverage
npm run test:coverage

# Run with UI
npm run test:ui
```

**Test Files:**
- `src/__tests__/services/authService.test.ts` - Authentication service tests
- `src/__tests__/services/preBalanceService.test.ts` - PRE token balance tests
- `src/__tests__/services/preDriveService.test.ts` - PreDrive integration tests

### PreDrive

**Configuration:** `PreDrive/vitest.config.ts`

```bash
# Run tests
cd PreDrive
pnpm test
```

**Test Files:**
- `apps/api/__tests__/auth.test.ts` - API authentication tests

### PreMail

**Configuration:** `premail/vitest.config.ts`

```bash
# Run tests
cd premail
pnpm test
```

---

## E2E Testing with Playwright

### Location

All E2E tests are in `ARC/e2e-tests/`

### Setup

```bash
cd ARC/e2e-tests
npm install
npx playwright install
```

### Configuration

**File:** `playwright.config.ts`

- Runs tests in Chromium, Firefox, and WebKit
- Supports mobile viewports (Pixel 5, iPhone 12)
- Generates HTML and JSON reports
- Screenshots on failure
- Video recording on retry

### Running E2E Tests

```bash
# Run all tests
npm test

# Run with UI
npm run test:ui

# Run in headed mode (see browser)
npm run test:headed

# Run specific test suite
npm run test:oauth
npm run test:presuite
npm run test:premail
npm run test:predrive
```

### Test Suites

#### OAuth SSO Tests (`tests/oauth/sso-flow.spec.ts`)
- PreSuite Hub authentication
- Cross-service SSO to PreMail
- Cross-service SSO to PreDrive
- Cross-service SSO to PreOffice
- OAuth state validation
- Error handling

#### PreSuite Hub Tests (`tests/presuite/hub.spec.ts`)
- Landing page loading
- Launchpad display
- App modals (PreDocs, PreSheets, PreSlides, PreCalendar, PreWallet)
- Navigation
- Search functionality
- Responsive design

#### PreMail Tests (`tests/premail/email.spec.ts`)
- Login page loading
- SSO button display
- OAuth callback handling
- Responsive layout

#### PreDrive Tests (`tests/predrive/storage.spec.ts`)
- Login page loading
- SSO button display
- API authentication
- CORS headers
- Responsive layout

---

## Environment Variables

### E2E Tests

Copy `.env.example` to `.env` and configure:

```env
# Service URLs
PRESUITE_URL=https://presuite.eu
PREMAIL_URL=https://premail.site
PREDRIVE_URL=https://predrive.eu
PREOFFICE_URL=https://preoffice.site

# Test credentials (for authenticated tests)
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=your-test-password

# CI Environment
CI=false
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies (PreSuite)
        run: |
          cd presuite
          npm install

      - name: Run unit tests
        run: |
          cd presuite
          npm run test:coverage

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Playwright
        run: |
          cd ARC/e2e-tests
          npm install
          npx playwright install --with-deps

      - name: Run E2E tests
        run: |
          cd ARC/e2e-tests
          npm test
        env:
          CI: true
          PRESUITE_URL: https://presuite.eu
          PREMAIL_URL: https://premail.site
          PREDRIVE_URL: https://predrive.eu
          PREOFFICE_URL: https://preoffice.site

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: ARC/e2e-tests/playwright-report/
```

---

## Writing New Tests

### Unit Test Guidelines

1. **Location:** Place tests in `__tests__` directory next to source
2. **Naming:** Use `.test.ts` or `.test.tsx` suffix
3. **Structure:**
   ```typescript
   describe('Component/Service Name', () => {
     describe('method/feature', () => {
       it('should do something specific', () => {
         // Arrange
         // Act
         // Assert
       });
     });
   });
   ```

### E2E Test Guidelines

1. **Location:** Place tests in `ARC/e2e-tests/tests/<service>/`
2. **Naming:** Use `.spec.ts` suffix
3. **Best Practices:**
   - Use role-based selectors (`getByRole`, `getByText`)
   - Avoid hardcoded waits, use `waitForSelector` or `waitForURL`
   - Keep tests independent and atomic
   - Use page object pattern for complex pages

### Example Unit Test

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('MyService', () => {
  it('should return expected value', () => {
    const result = myFunction('input');
    expect(result).toBe('expected');
  });
});
```

### Example E2E Test

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature', () => {
  test('should work correctly', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Submit' }).click();
    await expect(page.getByText('Success')).toBeVisible();
  });
});
```

---

## Coverage Reports

### Vitest Coverage

```bash
# Generate coverage report
npm run test:coverage

# View coverage report
open coverage/index.html
```

### Playwright Report

```bash
# View test report
npm run test:report
```

---

## Troubleshooting

### Common Issues

1. **Tests timeout:** Increase timeout in config or test
2. **Flaky tests:** Add proper waits, avoid timing-dependent assertions
3. **Auth issues in E2E:** Ensure test credentials are correct
4. **CORS errors:** Tests run against real services, ensure they're accessible

### Debug Mode

```bash
# Vitest debug
npm test -- --reporter=verbose

# Playwright debug
npm run test:debug
```

---

## Related Documentation

- [Architecture Diagrams](./architecture/README.md)
- [User Guide](./USER-GUIDE.md)
- [SSO Implementation](./PRESUITE-SSO-IMPLEMENTATION.md)
