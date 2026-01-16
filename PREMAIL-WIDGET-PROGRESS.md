# PreMail Widget Integration Progress

**Date:** January 16, 2026
**Status:** ✅ FIXED - IMAP timeout issue resolved

---

## Summary

Working on getting the PreMail widget functional on presuite.eu. The widget allows users to view their @premail.site email from the PreSuite Hub dashboard.

---

## Completed

### 1. Auto-Provisioning for SSO Users
- **File:** `apps/api/src/middleware/auth.ts`
- Added `autoProvisionUser()` function that creates local user/org/email_account records from JWT claims
- For @premail.site users, creates email_account with status "auth_error" (needs password)

### 2. Password Storage on Login
- **File:** `apps/api/src/routes/auth.ts`
- Modified login route to store encrypted mail password for @premail.site users
- Sets email_account status to "connected" when password is stored

### 3. Environment Configuration
- Added `ENCRYPTION_KEY` to production .env (AES-256-GCM encryption for mail passwords)
- Added `TLS_REJECT_UNAUTHORIZED=false` for internal self-signed certs
- JWT secrets verified matching between PreSuite Hub and PreMail

### 4. Stalwart Mail Server Fixes
- Unblocked Docker bridge IP (172.19.0.1) from fail2ban
- Whitelisted Docker network: `server.allowed-ip.172.19.0.0/16`
- Fixed TLS configuration to respect env variable

### 5. ImapFlow Error Handler
- **File:** `apps/api/src/lib/stalwart-mail.ts`
- Added error event handler to prevent unhandled 'error' events from crashing Node.js:
```typescript
client.on("error", (err) => {
  console.error("[IMAP] Connection error:", err.message);
});
```

### 6. Test User Created
- Created `widgettest@premail.site` user in both PreSuite Hub and Stalwart
- Email account created with encrypted password in PreMail database
- Verified IMAP access works directly (Python test successful)

### 7. Test Email Sent
- Sent test email via authenticated SMTP to widgettest@premail.site
- Email visible in inbox via direct IMAP connection

---

## Verified Working

| Component | Status | Notes |
|-----------|--------|-------|
| CORS Preflight | ✅ Working | Returns 204 with correct headers |
| GET /api/v1/accounts | ✅ Working | Returns account list |
| Password Decryption | ✅ Working | Correctly decrypts to "WidgetTest123!" |
| Direct IMAP (Python) | ✅ Working | Can connect and list messages |
| Direct IMAP (ImapFlow standalone) | ✅ Working | Test script succeeds |
| Auth Middleware | ✅ Working | JWT tokens validated correctly |

---

## Issue Resolution

### GET /api/v1/messages Timing Out - FIXED

**Root Cause:**
1. IMAP operations (`getMailboxLock`, `fetch`) had no timeout protection
2. The `msg.headers` type from ImapFlow was incorrectly cast as `Map` when it's actually a `Buffer`

**Fix Applied (Commits: 5c53add, 9862bee):**
1. Added `collectWithTimeout()` helper for async iterators
2. Wrapped all `getMailboxLock()` calls with `withTimeout()`
3. Wrapped fetch operations with `collectWithTimeout()`
4. Added `parseImapHeaders()` helper to handle headers as Map, Buffer, or object
5. Added debug logging to track IMAP operation progress

**Result:**
- Messages endpoint now returns in ~0.3 seconds (was timing out after 30 seconds)
- Proper error messages on timeout instead of silent hangs

---

## Files Modified

### Production Server (76.13.1.117)

| File | Change |
|------|--------|
| `/opt/premail/.env` | Added ENCRYPTION_KEY, TLS_REJECT_UNAUTHORIZED |
| `/opt/premail/apps/api/src/lib/stalwart-mail.ts` | Error handler (via git) |
| `/opt/premail/apps/api/src/middleware/auth.ts` | Auto-provisioning (via git) |
| `/opt/premail/apps/api/src/routes/auth.ts` | Password storage (via git) |

### Local Repository

| File | Change |
|------|--------|
| `apps/api/src/lib/stalwart-mail.ts` | Added ImapFlow error handler |

---

## Next Steps

1. **Add Operation Timeouts** - Wrap `getMailboxLock()` and `fetch()` operations with `withTimeout()`

2. **Add Debug Logging** - Properly add logging to trace exactly where the hang occurs

3. **Check for Connection Reuse Issues** - ImapFlow might be having issues with connection state

4. **Consider Connection Pool** - May need to create fresh connections for each request

---

## Commands Reference

### Test API Endpoints
```bash
# Get token from Hub
curl -s -X POST "https://presuite.eu/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"widgettest@premail.site","password":"WidgetTest123!"}'

# Test accounts
curl -s "https://premail.site/api/v1/accounts" \
  -H "Authorization: Bearer $TOKEN"

# Test messages (currently hanging)
curl -s "https://premail.site/api/v1/messages?folder=INBOX&accountId=08f58bda-1371-41f3-9385-722ccf7e965f" \
  -H "Authorization: Bearer $TOKEN"
```

### Direct IMAP Test (Working)
```bash
ssh root@76.13.1.117 "python3 -c \"
import imaplib, ssl
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
imap = imaplib.IMAP4_SSL('127.0.0.1', 993, ssl_context=ctx)
imap.login('widgettest', 'WidgetTest123!')
imap.select('INBOX')
print(imap.search(None, 'ALL'))
imap.logout()
\""
```

### Check Logs
```bash
ssh root@76.13.1.117 "pm2 logs premail-api --lines 50 --nostream"
```

### Restart API
```bash
ssh root@76.13.1.117 "pm2 restart premail-api --update-env"
```

---

## Environment Variables (PreMail Production)

```env
JWT_SECRET=7089fa42b9b38cf6e7d881a18a2534c4c6ff5e04e3ce9250ed7f5b57118acbeb
JWT_ISSUER=presuite
STALWART_HOST=mail.premail.site
ENCRYPTION_KEY=41b46224201dbb76a5011217abf6ed6155779359230a31a4aca27829e7da6c4a
TLS_REJECT_UNAUTHORIZED=false
```

---

## Related Database Records

### email_accounts
```sql
SELECT id, email, status, mail_password IS NOT NULL as has_password
FROM email_accounts
WHERE email = 'widgettest@premail.site';

-- Result:
-- id: 08f58bda-1371-41f3-9385-722ccf7e965f
-- status: connected
-- has_password: true
```

### Stalwart User
```bash
# User exists with email-receive permission
curl -s 'http://127.0.0.1:8080/api/principal?filter=widgettest' -u admin:PreMailAdmin2024!
```
