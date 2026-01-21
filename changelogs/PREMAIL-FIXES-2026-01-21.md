# PreMail Fixes - January 21, 2026

## Issues Identified & Resolved

### 1. API Routes Returning 404

**Symptom:** All API routes (`/api/v1/accounts`, `/api/v1/labels`, etc.) returned 404 Not Found.

**Root Cause:** Nginx config had a rewrite rule that stripped `/api/` from requests:
```nginx
rewrite ^/api/(.*) /$1 break;
```
This caused `/api/v1/accounts` to become `/v1/accounts` before reaching the backend, but the Hono API routes are mounted at `/api/v1/*`.

**Fix:** Removed the rewrite rule from nginx config. Requests now pass through unchanged.

**Files Changed:**
- `deploy/nginx/premail.site.conf` - Added to repo with correct config

**Commit:** `223d4b2` - fix: Remove nginx rewrite rule that broke API routing

---

### 2. Encrypted Mail Password Decryption Failure

**Symptom:** 500 Internal Server Error when accessing messages, threads, or sending email.

**Error:**
```
Error: Unsupported state or unable to authenticate data
at Decipheriv.final (node:internal/crypto/cipher:193:29)
at decrypt (/opt/premail/apps/api/src/lib/encryption.ts:106:25)
at decryptMailPassword
```

**Root Cause:** The `mail_password` stored in `email_accounts` table was encrypted with a different `ENCRYPTION_KEY` than what's currently configured. This happens when the key changes after accounts are created.

**Fix:** Retrieved the actual password from Stalwart mail server via its admin API, then re-encrypted it with the current `ENCRYPTION_KEY` and updated the database.

**Commands Used:**
```bash
# Get password from Stalwart
curl -s -u admin:adminpass123 'http://localhost:8080/api/principal?limit=20'

# Re-encrypt and update database
docker exec premail-postgres psql -U premail -d premail -c \
  "UPDATE email_accounts SET mail_password = '<newly-encrypted>' WHERE id = '<account-id>';"
```

**Note:** This is a manual fix per account. A migration script should be created if this affects multiple accounts.

---

### 3. Expired JWT Token Not Handled by Frontend

**Symptom:** Users remained in authenticated UI state even after JWT token expired. API calls returned 500 errors (which were actually 401s being mishandled).

**Root Cause:** The API client (`api.ts`) threw errors on 401 responses but didn't clear auth state or redirect to login.

**Fix:** Added `handleUnauthorized()` function to clear localStorage and redirect to `/login?expired=true` on 401 responses.

**Files Changed:**
- `apps/web/src/lib/api.ts`

**Code Added:**
```typescript
function handleUnauthorized(): void {
  localStorage.removeItem("premail_token");
  localStorage.removeItem("premail_user");
  if (!window.location.pathname.includes("/login")) {
    window.location.href = "/login?expired=true";
  }
}

// In request() function:
if (response.status === 401) {
  handleUnauthorized();
}
```

**Commit:** `4a415df` - fix: Handle 401 errors by redirecting to login

---

## Deployment Steps

```bash
# 1. Push changes to GitHub
cd ~/Documents/Documents-MacBook/presearch/premail
git push

# 2. Pull on server
ssh root@76.13.1.117 "cd /opt/premail && git pull"

# 3. Build and restart
ssh root@76.13.1.117 "cd /opt/premail && pnpm build && pm2 restart premail-api premail-web"
```

---

## Verification

| Test | Expected | Result |
|------|----------|--------|
| `/api/v1/accounts` | 401 (no auth) or 200 (with auth) | ✅ |
| `/api/v1/labels` | 401 (no auth) or 200 (with auth) | ✅ |
| Login flow | Returns JWT, redirects to inbox | ✅ |
| Expired token | Redirects to `/login?expired=true` | ✅ |
| Send email | Needs verification | ⏳ |

---

## Related Infrastructure

- **Server:** 76.13.1.117
- **Services:** `premail-api` (PM2), `premail-web` (PM2)
- **Database:** PostgreSQL in Docker (`premail-postgres`)
- **Mail Server:** Stalwart in Docker (`stalwart-mail`)
- **Nginx Config:** `/etc/nginx/sites-enabled/premail.site`

---

## Recommendations

1. **Encryption Key Management:** Store `ENCRYPTION_KEY` securely and ensure it never changes without a migration plan for existing encrypted data.

2. **Session Check:** The `auth.ts` store has a 30-second session check interval (`initSessionSync`). Verify this is being called on app load.

3. **Error Handling:** Consider adding a toast notification on the login page when `?expired=true` is present to inform users why they were logged out.

4. **Monitoring:** Add alerting for 500 errors on message routes to catch encryption issues early.
