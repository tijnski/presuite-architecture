# PreMail Development Progress - January 17, 2026

## Session Summary

This session focused on fixing Web3 email account functionality and search bugs in PreMail.

---

## Issues Fixed

### 1. Web3 Account SMTP Sending (Fixed)

**Problem:** Sending emails from Web3 accounts (`@web3.premail.site`) failed with "550 5.7.1 Your account is not authorized to use this service"

**Root Causes:**
- SMTP from address was hardcoded to `@premail.site` instead of detecting Web3 accounts
- Stalwart accounts were missing `enabledPermissions`
- Password sync between PreMail database and Stalwart was broken

**Fixes Applied:**
- Updated `stalwart-mail.ts` to detect Web3 accounts and use correct from address
- Added permissions to Stalwart accounts via API
- Synced passwords between systems

**Commit:** `7bf16fa` - Fix Web3 email account handling

---

### 2. Message View in Sent Folder (Fixed)

**Problem:** After sending an email, clicking on it in Sent folder showed "Message not found"

**Root Cause:** The folder parameter wasn't being passed to the message API

**Fix Applied:**
- Added folder parameter to `api.ts` get function
- Updated navigation in `InboxPage.tsx` to include folder in URL
- Updated `MessagePage.tsx` to read folder from URL params

**Commit:** `7bf16fa` - Fix Web3 email account handling

---

### 3. Web3 Account Classification (Fixed)

**Problem:** Web3 accounts (`@web3.premail.site`) were shown as "External" instead of "PreMail Account"

**Root Cause:** `AccountsPage.tsx` only checked for `@premail.site`, not `@web3.premail.site`

**Fix Applied:**
- Updated account classification checks to include both domains

**Commit:** `7bf16fa` - Fix Web3 email account handling

---

### 4. Search From/To Filters Not Working (Fixed)

**Problem:** Search filters for From and To fields were ignored for Stalwart accounts

**Root Cause:** IMAP search criteria were built as a single object, causing only the last filter to apply

**Fix Applied:**
- Changed `stalwart-mail.ts` to build search criteria as an array for AND conditions:
```typescript
// Before (broken):
const searchCriteria: any = {};
if (options.from) searchCriteria.from = options.from;

// After (fixed):
const searchCriteria: any[] = [];
if (options.from) searchCriteria.push({ from: options.from });
```

**Commit:** `67a3f33` - Fix search result navigation and IMAP filter combination

---

### 5. Search Results Not Clickable (Fixed)

**Problem:** Clicking on search results didn't navigate to the message view

**Root Cause:**
- Search results use composite ID format (`accountId-messageUid`)
- Click handler was using full composite ID instead of extracting just the UID
- AccountId wasn't being passed in the URL

**Fixes Applied:**
1. Updated click handler in `InboxPage.tsx`:
```typescript
const messageUid = result.id.includes("-")
  ? result.id.split("-").pop()
  : result.id;
navigate(`/message/${messageUid}?folder=${resultFolder}&accountId=${result.accountId}`);
```

2. Added `accountId` to SearchResult interface in `api.ts`

3. Updated `MessagePage.tsx` to use accountId from URL params

**Commit:** `67a3f33` - Fix search result navigation and IMAP filter combination

---

## Files Changed

### PreMail Repository (`tijnski/premail`)

| File | Changes |
|------|---------|
| `apps/api/src/lib/stalwart-mail.ts` | Web3 from address, IMAP search criteria array format |
| `apps/api/src/routes/search.ts` | IMAP search for Stalwart accounts |
| `apps/web/src/lib/api.ts` | Folder param in get(), accountId in SearchResult |
| `apps/web/src/pages/InboxPage.tsx` | Search result click handler, folder in navigation |
| `apps/web/src/pages/MessagePage.tsx` | AccountId from URL params |
| `apps/web/src/pages/AccountsPage.tsx` | Web3 account classification |

### Commits
- `7bf16fa` - Fix Web3 email account handling
- `6f79c16` - Add IMAP search for Stalwart accounts
- `67a3f33` - Fix search result navigation and IMAP filter combination

---

## Architecture Notes

### Stalwart Account Detection

```typescript
function isStalwartAccount(email: string): boolean {
  return email.endsWith("@premail.site") || email.endsWith("@web3.premail.site");
}
```

### Search Flow for Stalwart Accounts

1. User submits search with filters
2. `search.ts` route identifies Stalwart accounts
3. `StalwartMailClient.searchMessages()` builds IMAP criteria array
4. IMAP SEARCH command executed against Stalwart
5. Results returned with composite ID (`accountId-messageUid`)
6. Frontend extracts UID and navigates with accountId param

### Composite ID Format

Search results use: `${accountId}-${messageUid}`
- Example: `9633c669-553a-4dc0-b743-4c41a250fcf5-1`
- Frontend extracts UID by splitting on `-` and taking last element

---

## Deployment Status

- **Server:** `76.13.1.117` (premail.site)
- **Services:** Restarted via PM2
- **Build:** Fresh build deployed
- **Git:** All changes pushed to GitHub

---

## Testing Verification

API logs confirmed fix:
```
Before: GET /api/v1/messages/9633c669-553a-4dc0-b743-4c41a250fcf5-1 (500)
After:  GET /api/v1/messages/1?accountId=...&folder=INBOX (200)
```

---

## Related Documentation

- `plans/premail-search-bugs.md` - Detailed bug documentation (marked as FIXED)
- `PREMAIL.md` - PreMail service documentation
