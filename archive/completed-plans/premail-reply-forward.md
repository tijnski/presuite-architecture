# PreMail Reply/Reply All/Forward Implementation

**Date:** January 19, 2026
**Status:** Completed
**Commit:** `5cf2884`

---

## Overview

Added Reply, Reply All, and Forward functionality to PreMail. Users can now respond to or forward emails directly from the message view.

---

## Features

### Reply
- Replies to the sender only
- Pre-fills To field with sender's email
- Subject prefixed with `Re:` (if not already)
- Original message quoted with attribution line

### Reply All
- Replies to sender and all recipients
- Pre-fills To field with sender's email
- Pre-fills Cc field with all other recipients (excluding self)
- Subject prefixed with `Re:`
- Original message quoted with attribution line

### Forward
- Leaves To field empty for user to fill
- Subject prefixed with `Fwd:`
- Original message included with forwarding header showing From, Date, Subject, To

---

## Implementation Details

### MessagePage.tsx Changes

Added click handlers for the toolbar buttons:

```typescript
const handleReply = () => {
  if (!message || !effectiveAccountId) return;
  const params = new URLSearchParams({
    mode: "reply",
    messageId: messageId!,
    accountId: effectiveAccountId,
    folder,
  });
  navigate(`/compose?${params.toString()}`);
};

const handleReplyAll = () => {
  // Similar with mode: "replyAll"
};

const handleForward = () => {
  // Similar with mode: "forward"
};
```

Buttons now use these handlers:
```tsx
<button onClick={handleReply} title="Reply">
  <Reply className="h-5 w-5" />
</button>
<button onClick={handleReplyAll} title="Reply All">
  <ReplyAll className="h-5 w-5" />
</button>
<button onClick={handleForward} title="Forward">
  <Forward className="h-5 w-5" />
</button>
```

### ComposePage.tsx Changes

1. **URL Parameter Parsing**
```typescript
const mode = (searchParams.get("mode") as ComposeMode) || "new";
const replyMessageId = searchParams.get("messageId");
const replyAccountId = searchParams.get("accountId");
const replyFolder = searchParams.get("folder") || "INBOX";
```

2. **Fetch Original Message**
```typescript
const originalMessageQuery = useQuery({
  queryKey: ["message", replyAccountId, replyMessageId, replyFolder],
  queryFn: () => messagesApi.get(replyAccountId, replyMessageId, replyFolder),
  enabled: mode !== "new" && !!replyAccountId && !!replyMessageId,
});
```

3. **Initialize Fields Based on Mode**
```typescript
useEffect(() => {
  if (initialized || !originalMessageQuery.data?.message) return;

  const msg = originalMessageQuery.data.message;

  // Set subject with Re:/Fwd: prefix
  if (mode === "forward") {
    setSubject(`Fwd: ${originalSubject}`);
  } else {
    setSubject(`Re: ${originalSubject}`);
  }

  // Set recipients based on mode
  if (mode === "reply") {
    setTo(msg.from?.address ?? "");
  } else if (mode === "replyAll") {
    setTo(msg.from?.address ?? "");
    setCc(otherRecipients.join(", "));
  }
  // Forward: leave To empty

  // Generate quoted content
  const quoted = generateQuotedContent(mode, msg);
  setBodyHtml(quoted.html);
  setBodyText(quoted.text);

  setInitialized(true);
}, [originalMessageQuery.data, mode]);
```

4. **Quoted Content Generation**

For Reply/Reply All:
```
On Mon, Jan 19, 2026, 8:30 PM, John Doe <john@example.com> wrote:
> Original message content
> quoted with > prefix
```

HTML version uses blockquote with left border styling.

For Forward:
```
---------- Forwarded message ---------
From: John Doe <john@example.com>
Date: Mon, Jan 19, 2026, 8:30 PM
Subject: Original Subject
To: recipient@example.com

Original message content
```

5. **Dynamic Header Title**
```tsx
<h1>
  {mode === "reply" ? "Reply" :
   mode === "replyAll" ? "Reply All" :
   mode === "forward" ? "Forward" :
   "New Message"}
</h1>
```

6. **Loading State**
Shows spinner while fetching original message for reply/forward.

---

## URL Format

```
/compose?mode=reply&messageId=123&accountId=abc-def&folder=INBOX
/compose?mode=replyAll&messageId=123&accountId=abc-def&folder=INBOX
/compose?mode=forward&messageId=123&accountId=abc-def&folder=INBOX
```

---

## Files Changed

| File | Changes |
|------|---------|
| `apps/web/src/pages/MessagePage.tsx` | Added reply/forward handlers, wired buttons |
| `apps/web/src/pages/ComposePage.tsx` | Added mode handling, original message fetching, quoted content |

---

## Testing

1. Open an email in PreMail
2. Click Reply - should open compose with To pre-filled, subject with "Re:"
3. Click Reply All - should include Cc recipients
4. Click Forward - should have empty To, subject with "Fwd:", forwarding header

---

## Future Improvements

- [ ] Include original attachments in forward
- [ ] Reply-To header support (use Reply-To instead of From when present)
- [ ] In-reply-to and References headers for threading
- [ ] Draft auto-save for replies
- [ ] Inline reply (compose within message view)
