# PreSuite UI Updates - January 21, 2026

## Summary

Multiple UI improvements and new features deployed to presuite.eu.

---

## Changes

### 1. PreGPT Modal Sizing Fix

**Problem:** When typing in PreGPT, the modal window would resize/expand unexpectedly.

**Solution:**
- Added `overflow: hidden`, `display: flex`, and `flex-direction: column` to `.pregpt-chat-component` CSS
- Changed content area from calculated height (`calc(100% - 108px)`) to flex layout (`flex-1 min-h-0 overflow-hidden`)
- Added `flex-shrink-0` to header and input areas
- Changed `min-h-full` to `h-full` in messages container

**Files Modified:**
- `src/index.css`
- `src/components/PreGPTChat.jsx`

---

### 2. Click-Outside-to-Close for App Modals

**Feature:** Clicking outside of app modals (PreMail, PreDrive, PreDocs, PreSheets, PreSlides, PreCalendar, PreWallet) now closes them.

**Implementation:**
- Added `onClick={onClose}` to backdrop div in `ModalWrapper`
- Added `onClick={(e) => e.stopPropagation()}` on modal content to prevent clicks inside from closing

**File Modified:**
- `src/components/AppModal.jsx`

---

### 3. Click-Outside-to-Close for PreGPT Modal

**Feature:** Clicking outside of the PreGPT chat modal now closes it.

**Implementation:**
- Added `onClick={handleClose}` to backdrop div
- Added `onClick={(e) => e.stopPropagation()}` on modal content

**File Modified:**
- `src/components/PreGPTChat.jsx`

---

### 4. PrePanda Standalone Page (`/prepanda`)

**Feature:** New dedicated full-page AI chat experience at https://presuite.eu/prepanda

**Features:**
- Full-screen chat interface with dark theme
- Collapsible sidebar with chat history
- New chat button
- Streaming responses with typing indicator
- Sources dropdown for citations
- Related searches suggestions
- Suggestion cards for new users
- "Back to PreSuite" navigation
- Privacy-focused messaging
- Persistent chat history via localStorage

**Files Created:**
- `src/components/PrePandaPage.jsx` (597 lines)

**Files Modified:**
- `src/App.jsx` (added route)

**Route:** `/prepanda`

---

## Deployment

All changes deployed to production at `presuite.eu` via:
1. Local build (`npm run build`)
2. Git commit and push to GitHub
3. Server pull and rebuild (`ssh root@76.13.2.221`)
4. PM2 restart

---

## Commits

1. `f399668` - Fix PreGPT modal size - prevent resize when typing
2. `89596f1` - Add click-outside-to-close for app modals
3. `c74982b` - Add click-outside-to-close for PreGPT modal
4. `e94eb4d` - Add PrePanda standalone page at /prepanda

---

## URLs

- PreSuite Dashboard: https://presuite.eu
- PrePanda AI Chat: https://presuite.eu/prepanda
