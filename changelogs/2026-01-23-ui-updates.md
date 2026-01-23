# Changelog - January 23, 2026

## PreOffice UI Refinement

### Visual Updates
- **Replaced emoji icons with Lucide SVG icons** - Professional vector icons for all app cards and features
- **Dark theme by default** - Background `#191919`, cards `#2E2E2E`
- **Refined typography** - Reduced heading sizes (2.5rem → 2rem), Inter font family
- **Reduced spacing** - Hero padding 5rem (was 8rem), sections 3rem (was 4rem)
- **Updated buttons** - Pill-shaped primary buttons (border-radius: 9999px)
- **Color-coded app icons** - Writer (blue), Calc (green), Impress (amber), Draw (pink)

### Layout Changes
- **Single-row grids** - Apps grid: 5 columns, Features grid: 4 columns
- **Responsive breakpoints** - 2 columns on tablet, 1 column on mobile

### Navigation Updates
- Removed PrePanda button from top menu
- Added "Sign up" link with animated underline on hover
- Added "Login" button with arrow icon (matches PreSuite)

### Files Modified
- `/branding/static/index.html`
- `/brand/tokens.json` (v2.2.0)
- `/branding/static/prepanda/prepanda.css`
- `/ai-assistant/css/prepanda.css`

---

## PreSuite Updates

### Navigation
- Added animated blue underline to "Sign up" link on hover (matches PreOffice/PreDrive/Presearch)

### Mockup Data Removal
All demo/placeholder data has been removed:

| Component | Before | After |
|-----------|--------|-------|
| Recent widget | 4 fake files | "No recent files" message |
| PreMail modal | 3 demo emails (Colin Pape, etc.) | Empty state |
| PreDrive modal | 4 demo files + 4.2 GB storage | Empty state + 0 GB |
| PreDocs modal | 5 demo documents | Empty state |
| PreSheets modal | 4 demo spreadsheets | Empty state |
| PreSlides modal | 3 demo presentations | Empty state |

### Files Modified
- `/src/index.css` - Added `.nav-link-animated` class
- `/src/components/PreSuiteLaunchpad.jsx` - Removed `defaultRecentItems`, added empty state
- `/src/components/AppModal.jsx` - Cleared all demo arrays (`demoEmails`, `demoFiles`, `demoDocuments`, `demoSpreadsheets`, `demoPresentations`, storage fallback)

---

## Deployment Summary

| Service | Server | Status |
|---------|--------|--------|
| PreOffice | 76.13.2.220 | Deployed |
| PreSuite | 76.13.2.221 | Deployed |

---

## Commits

### PreOffice (preoffice-web)
1. `e0ed534` - Refine UI to match PreSuite design system
2. `227cf5b` - Change app and feature grids to single row layout
3. `78ed001` - Remove PrePanda button from top navigation
4. `36a5ebd` - Update nav to match PreSuite: Sign up link + Login button with icon
5. `38adfa5` - Add underline animation to Sign up link on hover

### PreSuite (presuite)
1. `1c952cb` - Add animated underline to Sign up link on hover
2. `b2312c2` - Remove mockup/demo data from dashboard and modals
3. `742fb09` - Remove storage mockup data from PreDrive modal

### ARC (presuite-architecture)
1. `7e31eee` - Add PreOffice UI refinement plan (implemented)

---

## PreMail Updates (Session 2)

### UI Improvements
- **Removed AI Summary banner** - Removed the AI-generated email summary feature from inbox
- **Fixed settings panel theme** - Settings panel now respects light/dark mode instead of always showing dark
- **Fixed sidebar dimming** - Sidebar now properly dims (z-30) when settings panel is open (backdrop z-40)
- **Improved theme toggle visibility** - Selected theme button now uses blue background (`#127FFF`) with white text in light mode
- **Darker text colors** - Updated text colors throughout to match PreDrive "Shares" styling:
  - Sidebar icons: `text-gray-400` → `text-[#6B7280]`
  - Sidebar text: `text-gray-600` → `text-[#374151]`
  - Muted text: `text-gray-400` → `text-[#9CA3AF] dark:text-gray-500`

### Bug Fixes
- **Fixed PreDrive connector** - Corrected `PREDRIVE_URL` from `https://predrive.eu/api/v1` to `https://predrive.eu` (API client adds `/api/nodes` internally)
- **Fixed email sending encryption error** - Re-encrypted mail password with current `ENCRYPTION_KEY` after "Unsupported state or unable to authenticate data" error

### Files Modified
- `apps/web/src/layouts/AppLayout.tsx` - Theme-aware colors, z-index fixes, darker text colors
- `apps/web/src/pages/InboxPage.tsx` - Removed AI Summary banner, updated text colors
- `apps/web/src/components/settings/*.tsx` - Added colors prop for theme awareness
- `.env` (server) - Fixed `PREDRIVE_URL`

---

## PreDrive Updates (Session 2)

### UI Changes
- **Sidebar button changed** - "Upload" button → "New Folder" button
  - Icon: `Upload` → `FolderPlus`
  - Action: Opens CreateFolderModal instead of UploadModal
- **Toolbar Upload button unchanged** - Still allows uploading files to current folder

### Bug Fixes
- **Fixed share link creation** - Added missing columns to `shares` table:
  ```sql
  ALTER TABLE shares
  ADD COLUMN IF NOT EXISTS max_downloads INTEGER,
  ADD COLUMN IF NOT EXISTS download_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS max_views INTEGER,
  ADD COLUMN IF NOT EXISTS view_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS description TEXT;
  ```

### Files Modified
- `apps/web/src/components/Sidebar.tsx` - Changed button to New Folder
- `apps/web/src/App.tsx` - Updated `onNewClick` to open CreateFolderModal

### Database Changes
- Added missing columns to `deploy-postgres-1` → `shares` table

---

## Deployment Summary (Session 2)

| Service | Server | Status |
|---------|--------|--------|
| PreMail | 76.13.1.117 | Deployed (PM2 restart) |
| PreDrive | 76.13.1.110 | Deployed (Docker rebuild) |

---

## Commits (Session 2)

### PreMail (premail)
1. Removed AI Summary banner from InboxPage
2. Fixed settings panel theme support
3. Updated text colors to darker values

### PreDrive (predrive)
1. `8437c91` - Change sidebar button from Upload to New Folder
