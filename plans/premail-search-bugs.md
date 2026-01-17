# PreMail Search Bugs

**Created:** January 17, 2026
**Status:** FIXED
**Fixed:** January 17, 2026
**Commit:** 67a3f33 - Fix search result navigation and IMAP filter combination

---

## Bug 1: From/To Filters Not Working - FIXED

**Description:** The "From" and "To" filter fields in the search bar do not filter results correctly for Stalwart accounts.

**Root Cause:** The IMAP search criteria were being built as a single object, which resulted in only the last filter being applied. The criteria needed to be combined as an array for AND conditions.

**Fix Applied:**
Changed `stalwart-mail.ts` to build search criteria as an array:
```typescript
// Before (broken):
const searchCriteria: any = {};
if (options.from) {
  searchCriteria.from = options.from;
}
if (options.to) {
  searchCriteria.to = options.to;
}

// After (fixed):
const searchCriteria: any[] = [];
if (options.from) {
  searchCriteria.push({ from: options.from });
}
if (options.to) {
  searchCriteria.push({ to: options.to });
}
```

---

## Bug 2: Search Results Not Clickable / Don't Navigate to Message - FIXED

**Description:** When clicking on a search result, it doesn't navigate to the message view.

**Root Cause:** Search results used a composite ID format (`accountId-messageUid`) but the click handler was using the full composite ID instead of extracting just the message UID. Also, the accountId wasn't being passed in the URL.

**Fix Applied:**
1. Updated `InboxPage.tsx` click handler to extract message UID from composite ID:
```typescript
onClick={() => {
  const messageUid = result.id.includes("-")
    ? result.id.split("-").pop()
    : result.id;
  const resultFolder = result.folder || folder;
  navigate(`/message/${messageUid}?folder=${resultFolder}&accountId=${result.accountId}`);
}}
```

2. Added `accountId` to the SearchResult interface in `api.ts`

3. Updated `MessagePage.tsx` to use accountId from URL params:
```typescript
const urlAccountId = searchParams.get("accountId");
const effectiveAccountId = urlAccountId || selectedAccount?.id;
```

---

## Files Changed

- `apps/api/src/lib/stalwart-mail.ts` - Fixed IMAP search criteria combination
- `apps/web/src/lib/api.ts` - Added accountId to SearchResult interface
- `apps/web/src/pages/InboxPage.tsx` - Fixed search result click handler
- `apps/web/src/pages/MessagePage.tsx` - Added accountId URL param support

---

## Testing

Verified by checking API logs:
- Before fix: `GET /api/v1/messages/9633c669-553a-4dc0-b743-4c41a250fcf5-1` (500 error)
- After fix: `GET /api/v1/messages/1?accountId=9633c669-553a-4dc0-b743-4c41a250fcf5&folder=INBOX` (200 success)
