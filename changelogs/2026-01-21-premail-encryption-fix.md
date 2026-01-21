# PreMail Encryption Key Loading Fix

**Date:** January 21, 2026
**Service:** PreMail API
**Severity:** High (prevented email access for users)
**Status:** Resolved

---

## Summary

Fixed a critical bug where the `ENCRYPTION_KEY` environment variable was not being loaded, causing mail password decryption to fail with the error:

```
Error: error:1C80006B:Provider routines::wrong final block length
at Decipheriv.final (node:internal/crypto/cipher:193:29)
at decrypt (/opt/premail/apps/api/src/lib/encryption.ts:106:25)
```

---

## Symptoms

- Users could not fetch emails from their inbox
- API returned 500 errors when accessing messages
- Error logs showed decryption failures for mail passwords
- Only affected accounts with encrypted passwords (most Web3 accounts)

---

## Root Cause Analysis

### The Bug

In `/apps/api/src/index.ts`, the import order was incorrect:

```typescript
// BROKEN ORDER
import { serve } from "@hono/node-server";
import { app } from "./app";         // ← Loaded FIRST
import { env } from "./config/env";  // ← Loaded SECOND (too late!)
```

### Why It Mattered

1. **`env.ts`** uses `dotenv` to load environment variables from `../../.env` into `process.env`
2. **`encryption.ts`** reads `process.env.ENCRYPTION_KEY` at module load time (line 10)
3. When `app` is imported, it imports routes → routes import `encryption.ts`
4. At that point, `env.ts` hasn't been imported yet, so dotenv hasn't run
5. `ENCRYPTION_KEY` is `undefined` when `encryption.ts` initializes

### Import Chain

```
index.ts
  └── app.ts (imported FIRST)
        └── routes/messages.ts
              └── lib/encryption.ts  ← Reads process.env.ENCRYPTION_KEY (undefined!)
  └── config/env.ts (imported SECOND)
        └── dotenv.config()          ← Too late, encryption.ts already loaded
```

---

## The Fix

Changed import order in `/apps/api/src/index.ts`:

```typescript
// FIXED ORDER
import { serve } from "@hono/node-server";
// IMPORTANT: Import env FIRST to configure dotenv before any other modules
// that may read from process.env (like encryption.ts)
import { env } from "./config/env";  // ← NOW FIRST
import { app } from "./app";         // ← NOW SECOND
```

### Commit

```
commit 05290ff
Author: tijnski
Date:   January 21, 2026

Fix ENCRYPTION_KEY not loaded due to import order

The env config (which loads dotenv) was imported AFTER app,
but encryption.ts reads process.env.ENCRYPTION_KEY at module
load time. By the time encryption.ts was loaded, dotenv hadn't
run yet, so ENCRYPTION_KEY was undefined.

Fix: Import env before app to ensure dotenv configures
process.env before any modules try to read from it.
```

---

## Verification

### Before Fix

```bash
# Process environment check
cat /proc/$(pm2 pid premail-api)/environ | tr '\0' '\n' | grep ENCRYPTION
# Result: Not found in process environment

# API logs showed decryption errors
pm2 logs premail-api --lines 10
# Error: error:1C80006B:Provider routines::wrong final block length
```

### After Fix

```bash
# API starts cleanly
pm2 logs premail-api --lines 10
# [dotenv@17.2.3] injecting env (19) from ../../.env
# Starting PreMail API on port 4001...
# PreMail API running at http://localhost:4001

# Health check passes
curl http://localhost:4001/health
# {"status":"ok","timestamp":"2026-01-21T16:13:09.487Z"}

# No decryption errors in logs
pm2 logs premail-api --lines 30 | grep -i 'decrypt\|cipher'
# (no results - good!)
```

### Manual Decryption Test

The encrypted data was valid - tested by running decryption directly:

```javascript
const crypto = require('crypto');
const ENCRYPTION_KEY = '7089fa42b9b38cf6e7d881a18a2534c4c6ff5e04e3ce9250ed7f5b57118acbeb';
const encryptedData = 'f7RmIG/vh/2apVr8:CN9EyIRW/4ZT39n26tKo9w==:twRcol+IPKK48Xff8u38+V3MVC3BkGlgma7/tIbcXQ==';

// ... decryption code ...
console.log('Decrypted:', decrypted);
// Decrypted: e18flkZcf5iTwrqS9SJmIyE1IAXDPje  ✓
```

---

## Database State

During investigation, found mixed password formats in `email_accounts` table:

| Format | Example | Count | Status |
|--------|---------|-------|--------|
| Encrypted (correct) | `iv:authTag:ciphertext` | ~20 | ✅ Working |
| Plaintext (legacy) | `TestPass123` | ~3 | ⚠️ Should migrate |
| Corrupted | SSH key stored as password | 1 | ❌ Needs manual fix |
| NULL | Empty | 1 | ✅ OK (no IMAP) |

### Accounts Needing Attention

```sql
-- Plaintext passwords (should be encrypted)
SELECT email FROM email_accounts
WHERE mail_password IS NOT NULL
AND mail_password NOT LIKE '%:%';

-- Results:
-- tijn4@premail.site (TestPass123)
-- tijn5@premail.site (contains SSH key - corrupted)
-- test123@web3.premail.site (testpass123)
-- 0xf451...@web3.premail.site (unencrypted generated password)
```

---

## Lessons Learned

1. **Import order matters** - In Node.js/TypeScript, modules are executed in import order. Environment setup should always be imported first.

2. **Fail-fast is good** - The `encryption.ts` module correctly threw an error rather than silently returning unencrypted data.

3. **Test with real data** - The bug only manifested with accounts that had encrypted passwords, not test accounts with plaintext.

4. **Check process environment** - When debugging env var issues, check the actual process environment with `/proc/<pid>/environ`, not just the `.env` file.

---

## Files Changed

| File | Change |
|------|--------|
| `apps/api/src/index.ts` | Reordered imports to load `env` before `app` |

---

## Related Issues

- Original encryption implementation: TD-004 (mail_password stored in plain text)
- Encryption key setup documented in: PREMAIL.md

---

## Prevention

To prevent similar issues:

1. **Always import config/env first** in entry points
2. **Add startup validation** that logs whether critical env vars are loaded
3. **Consider using a singleton pattern** for encryption that validates config on first use

### Suggested Enhancement

Add startup validation to `encryption.ts`:

```typescript
// Log encryption status at startup (but don't expose the key)
if (isEncryptionConfigured()) {
  console.log('[Security] ENCRYPTION_KEY configured ✓');
} else {
  console.error('[Security] ENCRYPTION_KEY NOT configured - decryption will fail!');
}
```
