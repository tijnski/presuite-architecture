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

## Git Commits

1. `df7eda7` - Remove 'All systems verified' UI element from launchpad
2. `35d8dd3` - Add session verification with Web3 wallet check on page load
3. `989a79a` - Change app grid to 10 columns for all icons in single row
4. `3d23264` - Make search bar same width as app grid
5. `3c6bc76` - Fix search bar to span all 10 grid columns
6. `8666f5a` - Remove max-w-xl constraint from SearchBar component
7. `10b642a` - Add unread email preview widget to dashboard
8. `ff26c33` - Remove Storage and PRE Balance widgets from dashboard
