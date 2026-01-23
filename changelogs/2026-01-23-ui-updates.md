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
