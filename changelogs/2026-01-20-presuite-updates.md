# PreSuite Updates - January 20, 2026

## Summary
Added Web3 session verification across all services and UI improvements to the PreSuite dashboard.

---

## Web3 Session Verification

### Problem
When a user logged in with Web3/MetaMask and their wallet extension locked, the user would remain signed in even though they no longer had access to their wallet. This created a security gap.

### Solution
Implemented session verification on every page load that checks both:
1. JWT token validity with the server
2. Web3 wallet accessibility (for Web3 users)

If the wallet is locked or disconnected, the user is automatically logged out.

### Changes Made

**PreSuite Hub (presuite.eu)**
- `src/services/web3Auth.js`: Added `isWalletAccessible()` and `getConnectedAddress()` functions
- `src/services/authService.js`: Added `verifySessionOnLoad()` function
- `src/components/AuthVerifier.jsx`: New component that runs verification on route changes
- `src/App.jsx`: Integrated AuthVerifier

**PreMail (premail.site)**
- `apps/web/src/lib/web3Auth.ts`: Added wallet accessibility check functions
- `apps/web/src/store/auth.ts`: Added `verifySessionOnLoad()` function
- `apps/web/src/components/AuthVerifier.tsx`: New verification component
- `apps/web/src/App.tsx`: Integrated AuthVerifier

**PreDrive (predrive.eu)**
- `apps/web/src/lib/web3Auth.ts`: Added wallet accessibility check functions
- `apps/web/src/hooks/useAuth.ts`: Added session verification in the auth hook

---

## UI Improvements

### Dashboard Layout Changes

1. **Removed "All systems verified" card**
   - Removed the static status card showing "All systems verified / 12 nodes • EU region"
   - Cleaned up unused `ShieldCheckIcon` import

2. **App Grid: 9 columns → 10 columns**
   - Changed from `grid-cols-9` to `grid-cols-10`
   - All 10 app icons now display in a single row

3. **Search Bar Width**
   - Removed `max-w-xl` constraint from SearchBar component
   - Search bar now spans full width of the 10-column grid
   - Both search bar and app icons share the same grid container

### Files Changed
- `src/components/PreSuiteLaunchpad.jsx`
- `src/components/SearchBar.jsx`

---

## Deployment Status

All changes deployed to production:
- ✅ PreSuite Hub (presuite.eu)
- ✅ PreMail (premail.site)
- ✅ PreDrive (predrive.eu)

---

## Unread Email Preview Widget

### Feature
Added a new widget to the dashboard that shows the latest unread emails, giving users a quick preview without opening PreMail.

### Changes
- Added `getUnreadEmails()` function to `preMailService.js`
- Changed bottom section from 2-column to 3-column layout
- New widget displays:
  - Sender avatar (first letter of name)
  - Sender name
  - Subject line (truncated)
  - Time received
  - Badge showing total unread count
  - Empty state when no unread emails

### Layout
Changed from 3-column to 2-column layout after removing Storage and PRE Balance widgets.

---

## Widget Removal

Removed the following widgets from the dashboard:
- **Storage Widget** - Showed storage usage (e.g., "188.1 KB / 15 GB")
- **PRE Balance Widget** - Showed static PRE token balance

### Final Layout (2 columns)
1. **Recent Files** - Latest PreDrive files
2. **Unread Emails** - Latest 3 unread emails

---

## Email Verification System

### Feature
New users must verify their email address after registration. Existing users are grandfathered in as verified. Unverified users can log in but see a warning banner with limited functionality.

### How It Works

```
Registration Flow:
1. User submits registration form
2. User created with email_verified = false
3. Verification token generated (32 bytes, hashed with SHA-256)
4. Email sent with verification link via Stalwart SMTP
5. User redirected to dashboard with verification banner

Verification Flow:
1. User clicks link in email
2. GET /api/auth/verify-email?token=xxx
3. Token validated (hash match, not expired, not used)
4. users.email_verified = TRUE
5. Token marked as used
6. Redirect to login with success message
```

### Backend Changes

**New Files:**
- `migrations/002_email_verification.sql` - Creates `email_verification_tokens` table
- `utils/email.js` - Email service with nodemailer (Stalwart SMTP)

**Modified Files:**
- `package.json` - Added nodemailer dependency
- `config/constants.js` - Email verification constants, SMTP config
- `middleware/rate-limiter.js` - Added `verificationLimiter` (1 req/min)
- `server.js` - Updated register, added verify-email & resend endpoints

**New API Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/auth/verify-email` | Process verification link from email |
| POST | `/api/auth/resend-verification` | Resend verification email (rate limited) |

**Updated Endpoints:**
- `GET /api/auth/verify` - Now includes `email_verified` status
- `POST /api/auth/register` - Now returns `email_verified: false` and sends verification email

### Frontend Changes

**Modified Files:**
- `src/services/authService.js` - Added `resendVerification()` function
- `src/components/PreSuiteLaunchpad.jsx` - Added verification banner with resend button

**Verification Banner:**
- Yellow warning banner shown for unverified users
- "Resend email" button with loading state
- Success/error feedback messages
- Disappears automatically when email is verified

### Database Schema

```sql
CREATE TABLE email_verification_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Configuration

New environment variables in `.env.example`:
```
SMTP_HOST=mail.premail.site
SMTP_PORT=465
SMTP_SECURE=true
SMTP_USER=noreply@premail.site
SMTP_PASS=
VERIFICATION_EMAIL_FROM=noreply@premail.site
BASE_URL=https://presuite.eu
```

---

## Git Commits

1. `df7eda7` - Remove 'All systems verified' UI element from launchpad
2. `35d8dd3` - Add session verification with Web3 wallet check on page load
3. `989a79a` - Change app grid to 10 columns for all icons in single row
4. `3d23264` - Make search bar same width as app grid
5. `3c6bc76` - Fix search bar to span all 10 grid columns
6. `8666f5a` - Remove max-w-xl constraint from SearchBar component
7. `10b642a` - Add unread email preview widget to dashboard
8. `ff26c33` - Remove Storage and PRE Balance widgets from dashboard
9. `c6832d5` - Add email verification for new user registrations
10. `5b3805f` - Fix SMTP: allow self-signed certificates for Stalwart

---

## Email Verification Deployment Notes

### SMTP Configuration Fix

During deployment, email sending initially failed due to:

1. **Self-signed certificate rejection** - Stalwart uses self-signed TLS certificates
2. **Authentication failure** - Stalwart only enables PLAIN/LOGIN auth for admin users by default

### Fixes Applied

**1. TLS Certificate (code fix):**
```javascript
// utils/email.js
tls: {
  rejectUnauthorized: false, // Allow Stalwart's self-signed certs
}
```

**2. Stalwart Auth Mechanisms (server config):**
```toml
# /opt/stalwart/etc/config.toml
session.auth.mechanisms = ["plain", "login"]
```

**3. SMTP Credentials (environment):**
```bash
# Use admin credentials (regular users don't have PLAIN auth)
SMTP_USER=admin
SMTP_PASS=adminpass123
```

### Testing Results

| Test | Status |
|------|--------|
| Registration creates unverified user | ✅ Pass |
| Verification email sent on register | ✅ Pass |
| `/api/auth/verify` includes email_verified | ✅ Pass |
| `/api/auth/resend-verification` works | ✅ Pass |
| Rate limiting (1 req/min) | ✅ Pass |
| Tokens stored with SHA-256 hash | ✅ Pass |
| 24-hour token expiry | ✅ Pass |

### Production Verification

```bash
# Test registration
curl -X POST https://presuite.eu/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@premail.site","password":"TestPass123#","name":"Test"}'
# Returns: email_verified: false, message about checking email

# Check verification status
curl https://presuite.eu/api/auth/verify -H "Authorization: Bearer <token>"
# Returns: email_verified: false/true
```
