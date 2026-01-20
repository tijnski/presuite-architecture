# PreSuite Testing Infrastructure

> **Date:** January 20, 2026 (Updated)
> **Author:** Claude Opus 4.5
> **Status:** Implemented

---

## Overview

This document describes the testing infrastructure set up for the PreSuite ecosystem, including unit tests, integration tests, end-to-end (E2E) tests, and security auditing.

### Testing Stack

| Type | Framework | Location | Purpose |
|------|-----------|----------|---------|
| Unit Tests | Vitest | Each project's `__tests__` directory | Business logic, validation |
| React Tests | Vitest + Testing Library | `presuite/src/__tests__` | Component testing |
| Integration Tests | Playwright | `ARC/e2e-tests/tests/integration/` | Cross-service flows |
| E2E Tests | Playwright | `ARC/e2e-tests/tests/` | User journeys |
| Security Audit | Custom Script | `ARC/scripts/security-audit.sh` | Vulnerability scanning |

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

**Configuration:** `predrive/vitest.config.ts`

```bash
# Run tests
cd predrive
pnpm test
```

**Test Files:**
| File | Coverage | Description |
|------|----------|-------------|
| `apps/api/__tests__/auth.test.ts` | Authentication | JWT validation, session management |
| `apps/api/__tests__/nodes.test.ts` | File/Folder API | CRUD operations, permissions, trash |
| `apps/api/__tests__/shares.test.ts` | Sharing | Tokens, scopes, invitations, access control |
| `apps/api/__tests__/collaboration.test.ts` | Real-time | Sessions, cursors, locking, comments |

**Key Test Coverage:**

**nodes.test.ts:**
- Input validation (required fields, max lengths)
- Node operations (create, read, update, delete)
- Permission checks (owner, editor, viewer)
- Pagination (offset, limit, total count)
- Path operations (ancestors, validation)
- File upload (size limits, MIME types)
- Trash operations (soft delete, restore, permanent delete)
- Activity logging

**shares.test.ts:**
- Token generation (uniqueness, format)
- Share scopes (view, download, edit)
- Password protection (hashing, verification)
- Expiration handling
- Access limits (max downloads, max views)
- Organization-only shares
- Share invitations
- Access logging
- Granular permissions

**collaboration.test.ts:**
- Document sessions (connection IDs, colors, activity tracking)
- Cursor positions (validation, pixel conversion)
- Selection ranges (collapsed detection, length calculation)
- Document locking (tokens, expiration, ownership)
- Operational Transformation foundation
- Presence broadcasting
- WebSocket events
- Comments (threading, resolution, reactions, mentions)

### PreMail

**Configuration:** `premail/vitest.config.ts`

```bash
# Run tests
cd premail
pnpm test
```

**Test Files:**
| File | Coverage | Description |
|------|----------|-------------|
| `apps/api/__tests__/filters.test.ts` | Email filters | Conditions, actions, contacts, aliases |

**Key Test Coverage:**

**filters.test.ts (Email Filters API):**
- Filter conditions (from, to, cc, subject, body, has_attachment)
- Operators (contains, not_contains, equals, starts_with, ends_with, matches_regex)
- Filter actions (move_to_folder, apply_label, mark_as_read, forward_to)
- Match types (all/AND, any/OR)
- Filter priority ordering
- Stop processing flag
- Filter testing against sample messages

**filters.test.ts (Contacts API):**
- Email format validation
- Phone format validation
- Contact name sanitization
- Contact groups (add, remove, prevent duplicates)
- Autocomplete (search, limit, favorites priority)
- CSV import/export

**filters.test.ts (Aliases API):**
- Alias email format validation
- Domain allowlist checking
- Default send address (single default enforcement)
- Alias statistics (sent/received count, last used)

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

# Run integration tests
npm run test:integration
npm run test:auth
npm run test:api

# Run all service tests
npm run test:all-services
```

### Test Suites

#### Integration Tests (`tests/integration/`)

**auth-flow.spec.ts** - Cross-Service Authentication
| Test | Description |
|------|-------------|
| JWT Validation | Token format, expiration, signature |
| Health Endpoints | All services respond to /health |
| CORS Configuration | Allowed origins verified |
| OAuth Endpoints | Authorization, token, userinfo |
| Web3 Auth | Wallet signature, nonce, linking |
| Rate Limiting | Auth endpoint protection |

**cross-service-api.spec.ts** - API Consistency
| Test | Description |
|------|-------------|
| Auth Required | Protected endpoints return 401 |
| Public Endpoints | Health, docs accessible |
| Service Discovery | All services reachable |
| Error Format | Consistent error response structure |

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

## Security Audit

### Automated Script

```bash
cd ~/Documents/Documents-MacBook/presearch/ARC
./scripts/security-audit.sh
```

### What It Checks

| Check | Tool | Output |
|-------|------|--------|
| npm vulnerabilities | `npm audit` | JSON report per service |
| Hardcoded secrets | grep patterns | Text report |
| Security headers | curl | Console output |
| Outdated packages | `npm outdated` | Console output |

### Reports Location

```
security-reports/
├── npm-audit-presuite-YYYYMMDD_HHMMSS.json
├── npm-audit-predrive-YYYYMMDD_HHMMSS.json
├── npm-audit-premail-YYYYMMDD_HHMMSS.json
├── secrets-presuite-YYYYMMDD_HHMMSS.txt
├── secrets-predrive-YYYYMMDD_HHMMSS.txt
├── secrets-premail-YYYYMMDD_HHMMSS.txt
└── summary-YYYYMMDD_HHMMSS.md
```

### Running Security Audit

```bash
# Full audit
./scripts/security-audit.sh

# Quick npm audit only
cd presuite && npm audit
cd predrive && pnpm audit
cd premail && pnpm audit

# Check outdated packages
npm outdated
```

### Security Checklist

See [SECURITY-CHECKLIST.md](SECURITY-CHECKLIST.md) for:
- OWASP Top 10 compliance status
- Additional security checks
- Recommended nginx security headers
- Penetration testing scope
- Incident response procedures

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
    strategy:
      matrix:
        service: [presuite, predrive, premail]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install Playwright
        run: |
          cd ARC/e2e-tests
          npm install
          npx playwright install --with-deps
      - name: Run integration tests
        run: |
          cd ARC/e2e-tests
          npm run test:integration
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

  security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high
```

---

## Test Coverage Goals

| Service | Current | Target | Priority |
|---------|---------|--------|----------|
| PreSuite Hub | ~30% | 70% | Medium |
| PreDrive API | ~50% | 80% | High |
| PreMail API | ~40% | 75% | High |
| PreOffice | ~20% | 50% | Low |
| Integration | ~60% | 90% | High |

---

## Writing New Tests

### Unit Test Guidelines

1. **Location:** Place tests in `__tests__` directory next to source
2. **Naming:** Use `.test.ts` or `.test.tsx` suffix
3. **Structure:**
   ```typescript
   import { describe, it, expect, vi, beforeEach } from 'vitest';

   describe('Component/Service Name', () => {
     beforeEach(() => {
       // Setup
     });

     describe('method/feature', () => {
       it('should do something specific', () => {
         // Arrange
         const input = { ... };

         // Act
         const result = someFunction(input);

         // Assert
         expect(result).toBe(expected);
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
  describe('myFunction', () => {
    it('should return expected value', () => {
      // Arrange
      const input = 'test';

      // Act
      const result = myFunction(input);

      // Assert
      expect(result).toBe('expected');
    });

    it('should handle edge cases', () => {
      expect(() => myFunction(null)).toThrow();
    });
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

### Example Integration Test

```typescript
import { test, expect } from '@playwright/test';

test.describe('Cross-Service Integration', () => {
  test('should authenticate across services', async ({ request }) => {
    // Get token from PreSuite
    const authResponse = await request.post('https://presuite.eu/api/auth/login', {
      data: { email: 'test@example.com', password: 'password' }
    });
    expect(authResponse.ok()).toBeTruthy();

    const { token } = await authResponse.json();

    // Verify token works on PreDrive
    const driveResponse = await request.get('https://predrive.eu/api/nodes', {
      headers: { Authorization: `Bearer ${token}` }
    });
    expect(driveResponse.ok()).toBeTruthy();
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

# Playwright UI mode
npm run test:ui
```

### Fixing Vulnerabilities

```bash
# Fix vulnerabilities automatically
npm audit fix

# Force fix (may break things)
npm audit fix --force

# Review before fixing
npm audit
```

---

## Related Documentation

- [Security Checklist](./SECURITY-CHECKLIST.md)
- [Architecture Diagrams](./architecture/README.md)
- [API Reference](./API-REFERENCE.md)
- [Implementation Status](./IMPLEMENTATION-STATUS.md)
