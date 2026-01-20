# PreMail Widget Debug Findings

> **Date:** January 16, 2026
> **Issue:** PreMail widget on presuite.eu not syncing emails
> **Status:** Root cause identified

---

## Summary

The PreMail widget on presuite.eu fails to display emails because **users who register or login via PreSuite Hub do not have email account records in PreMail's database**. The widget authentication works, but queries return empty results.

---

## Root Cause

**Missing `email_accounts` record in PreMail database.**

When users access PreMail via SSO (token from PreSuite Hub), they have:
- Valid JWT token (authentication works)
- User record may or may not exist in PreMail's `users` table
- **NO record in `email_accounts` table** (required for email operations)

---

## Technical Details

### Test Results

| Test | Result | Notes |
|------|--------|-------|
| PreMail API health | Working | Returns 204 on OPTIONS |
| CORS headers | Correct | `access-control-allow-origin: https://presuite.eu` |
| JWT validation | Working | Token accepted, returns 401 for invalid tokens |
| `/api/v1/accounts` endpoint | Returns `{"accounts":[]}` | No email accounts for user |

### Database State

**PreMail `users` table:** 6 users
```
tijn4@premail.site, testuser@premail.site, tijn5@premail.site,
tijn6@premail.site, frontendtest@premail.site, premailtest@premail.site
```

**PreMail `email_accounts` table:** Only 2 records
```
tijn4@premail.site (connected)
tijn5@premail.site (connected)
```

**Test user `wojek@premail.site`:**
- Exists in PreSuite Hub database
- Has Stalwart mailbox (can send/receive email)
- Does NOT exist in PreMail `users` table
- Does NOT have `email_accounts` record

---

## Registration/Login Flow Analysis

### Registration via PreMail (`POST /api/v1/auth/register`)
1. Forwards request to PreSuite Hub
2. PreSuite Hub creates user, org, Stalwart mailbox
3. PreMail creates local user/org records
4. **PreMail creates `email_accounts` record with encrypted password**

### Registration via PreSuite Hub (`POST presuite.eu/api/auth/register`)
1. PreSuite Hub creates user, org, Stalwart mailbox
2. **PreMail knows nothing about this user**
3. No local user/org records created
4. No `email_accounts` record created

### Login via PreMail (`POST /api/v1/auth/login`)
1. Forwards request to PreSuite Hub
2. PreMail creates local user/org records (if missing)
3. **Does NOT create `email_accounts` record**

### SSO Access (via `?token=` parameter)
1. Token validated successfully
2. Auth middleware sets user context from JWT
3. **Does NOT create local records or `email_accounts`**

---

## Code References

### PreMail Auth Middleware (`apps/api/src/middleware/auth.ts`)
- Only validates JWT and sets context
- No auto-provisioning of users or email accounts
- Contrast with PreDrive which auto-provisions users

### PreMail Registration Route (`apps/api/src/routes/auth.ts:75-95`)
```typescript
// Creates email account record (only on registration)
await db.insert(emailAccounts).values({
  userId: user.id,
  engineAccountId: `stalwart:${user.email.split("@")[0]}`,
  name: user.name,
  email: user.email,
  provider: "imap",
  status: "connected",
  mailPassword: encryptMailPassword(password),
}).onConflictDoNothing();
```

### PreMail Login Route (`apps/api/src/routes/auth.ts:125-145`)
```typescript
// Only creates user/org, NOT email_accounts
await db.insert(users).values({...}).onConflictDoNothing();
// Missing: email_accounts creation
```

---

## Comparison: PreDrive vs PreMail

| Feature | PreDrive | PreMail |
|---------|----------|---------|
| Auto-provision user on SSO | Yes | No |
| Auto-provision org on SSO | Yes | No |
| Auto-provision resources on SSO | Yes (root folder) | No |
| Widget works with SSO | Yes | No |

### PreDrive Auth Middleware (`apps/api/src/middleware/auth.ts:80-110`)
```typescript
// Auto-provisions user if they don't exist (SSO flow)
if (existingUser.length === 0) {
  // Create org if not exists
  // Create user
  // Create root folder
}
```

---

## Why This Happens

1. **Design assumption:** PreMail assumes users will register/login through PreMail directly
2. **Missing SSO provisioning:** PreMail auth middleware doesn't auto-provision like PreDrive
3. **Password requirement:** Creating `email_accounts` requires the user's password for IMAP access (stored encrypted)
4. **SSO tokens don't contain passwords:** Can't create email account from JWT alone

---

## Affected Users

Any user who:
- Registered via PreSuite Hub (not PreMail)
- Only logged in via PreSuite Hub
- Uses SSO token to access PreMail

These users:
- Can authenticate to PreMail API
- Cannot access any email functionality
- Widget shows empty/no data

---

## Potential Solutions

### Option 1: Auto-provision email accounts on SSO (Recommended)
- Modify PreMail auth middleware to auto-provision user/org
- On first access, prompt user to "connect" their @premail.site account
- Or auto-create email_account without password (limited functionality)

### Option 2: Provision email accounts from PreSuite Hub
- When PreSuite Hub creates user, also call PreMail internal API
- Pass encrypted password to PreMail for storage
- Requires secure internal API between services

### Option 3: Sync on login
- When user logs in via PreMail (with password), create email_accounts
- Already implemented, but doesn't help SSO-only users

### Option 4: Manual account connection
- Require users to go to PreMail settings
- "Connect your @premail.site account" with password
- Creates the email_accounts record

---

## Immediate Workaround

For testing, manually create email_account record:

```sql
-- First ensure user exists
INSERT INTO users (id, org_id, email, name)
VALUES ('d9e0972a-e567-4777-94d5-b1872eeb5c1b', '7f77435a-5ef5-405d-9ee1-b730c83aa7f7', 'wojek@premail.site', 'wojek')
ON CONFLICT DO NOTHING;

-- Then create email account (requires encrypted password)
INSERT INTO email_accounts (user_id, engine_account_id, name, email, provider, status, mail_password)
VALUES (
  'd9e0972a-e567-4777-94d5-b1872eeb5c1b',
  'stalwart:wojek',
  'wojek',
  'wojek@premail.site',
  'imap',
  'connected',
  '<encrypted_password>'  -- Requires ENCRYPTION_KEY
);
```

**Note:** This requires the user's IMAP password to be encrypted with PreMail's ENCRYPTION_KEY.

---

## Files to Modify (For Fix)

1. `premail/apps/api/src/middleware/auth.ts` - Add auto-provisioning
2. `premail/apps/api/src/routes/auth.ts` - Create email_accounts on login
3. `presuite/server.js` - Call PreMail provision API on registration

---

## Conclusion

The PreMail widget fails because SSO users don't have `email_accounts` records. PreDrive works because it auto-provisions users on SSO access. PreMail needs similar auto-provisioning or a dedicated flow to create email accounts for SSO users.
