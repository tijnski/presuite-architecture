# PreMail Development Progress - January 19, 2026

## Session Summary

This session focused on fixing search functionality and the unread message indicator in PreMail.

---

## Issues Fixed

### 1. Search From/To Filters Not Working

**Problem:** The "From" and "To" filter fields in search returned 0 results even when matching emails existed.

**Root Cause:** Stalwart IMAP server doesn't support partial matching in the SEARCH command. When searching for `FROM "tijn"`, it wouldn't match `tijn@hoorneman.com`.

**Solution:** Implemented client-side filtering:
- IMAP search fetches all messages (or filters by other criteria like date/unread)
- From/To filters are applied client-side by checking envelope addresses
- Partial matching is done with `toLowerCase().includes()`

**Files Changed:**
- `apps/api/src/lib/stalwart-mail.ts` - Added client-side filtering for from/to

**Code Change:**
```typescript
// Build criteria without from/to (we'll filter those client-side)
const imapCriteria = searchCriteria.filter(
  (c: any) => !c.from && !c.to
);

// If we have from/to filters, fetch envelopes and filter client-side
if (hasFromToFilter && uids.length > 0) {
  for await (const msg of client.fetch(uidRange, { uid: true, envelope: true })) {
    if (options.from) {
      const fromLower = options.from.toLowerCase();
      const fromMatch = fromAddresses.some((addr: any) =>
        addr.address?.toLowerCase().includes(fromLower) ||
        addr.name?.toLowerCase().includes(fromLower)
      );
      if (!fromMatch) matches = false;
    }
    // Similar for options.to
  }
}
```

---

### 2. Unread Indicator Not Clearing When Opening Email

**Problem:** The blue unread indicator on emails didn't disappear after opening and reading the message.

**Root Cause:** The MessagePage component didn't call the `markRead` API when a message was opened.

**Solution:** Added auto-mark-as-read functionality:
- Added `useEffect` hook that triggers when message loads
- Calls `markRead` API if message is unread (`seen === false`)
- Uses ref to prevent duplicate API calls
- Invalidates message queries to refresh inbox display

**Files Changed:**
- `apps/web/src/pages/MessagePage.tsx` - Added mark-as-read logic
- `apps/web/src/lib/api.ts` - Added folder parameter to markRead, updated message type

**Code Change:**
```typescript
// Mark message as read mutation
const markReadMutation = useMutation({
  mutationFn: () =>
    effectiveAccountId && messageId
      ? messagesApi.markRead(effectiveAccountId, messageId, true, folder)
      : Promise.reject(),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ["messages"] });
    queryClient.invalidateQueries({ queryKey: ["threads"] });
  },
});

// Track if we've already marked this message as read
const markedAsReadRef = useRef<string | null>(null);

// Mark message as read when it loads (if unread)
useEffect(() => {
  const message = messageQuery.data?.message;
  if (
    message &&
    effectiveAccountId &&
    messageId &&
    message.seen === false &&
    markedAsReadRef.current !== `${effectiveAccountId}-${messageId}`
  ) {
    markedAsReadRef.current = `${effectiveAccountId}-${messageId}`;
    markReadMutation.mutate();
  }
}, [messageQuery.data, effectiveAccountId, messageId]);
```

---

## Commits

| Commit | Description |
|--------|-------------|
| `034f1ef` | Fix search filters and auto-mark messages as read |

---

## Deployment

All changes deployed to production:
- Server: `76.13.1.117` (`/opt/premail`)
- Services restarted: `premail-api`, `premail-web`
- GitHub repo synced

---

## Testing Verified

- ✅ Search with From filter returns correct results
- ✅ Search with To filter returns correct results
- ✅ Clicking search results navigates to message
- ✅ Opening unread email marks it as read
- ✅ Unread indicator disappears after viewing message
- ✅ Inbox refreshes to show updated read status

---

## Technical Notes

### Stalwart IMAP Limitations
- SEARCH command requires exact/full matches for FROM/TO
- Partial matching like `FROM "tijn"` won't match `tijn@example.com`
- Workaround: Fetch all UIDs then filter client-side with envelope data

### IMAP Flag Updates
- Must pass correct folder to `updateFlags` method
- Uses `messageFlagsAdd` with `["\\Seen"]` to mark as read
- Requires mailbox lock before flag operations
