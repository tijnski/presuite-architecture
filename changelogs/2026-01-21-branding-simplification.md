# Branding Simplification - January 21, 2026

## Summary
Simplified branding across all PreSuite services by removing text labels from logos and standardizing on the Presearch "P" icon only.

---

## Changes Overview

All services now display only the Presearch logo icon without any accompanying text (e.g., "PreDrive", "PreMail", etc.) in their headers/sidebars.

---

## PreDrive (predrive.eu)

### Commits
- `dbe0181` - Remove text from sidebar logo, keep only icon
- `cf87dea` - Remove PreDrive text from public share view logo
- `afd854d` - Simplify UI labels: Drive and Shares

### Files Changed
- `apps/web/src/components/Sidebar.tsx`
  - Removed "PreDrive" text from logo section
  - Changed "Encrypted Shares" label to "Shares"
- `apps/web/src/components/Layout.tsx`
  - Changed header text from "PreDrive" to "Drive"
- `apps/web/src/components/PublicShareView.tsx`
  - Removed "PreDrive" text from public share page logo

---

## PreMail (premail.site)

### Commits
- `5f31a9b` - Remove text from sidebar logo, keep only icon
- `7640a0e` - Replace mail icon with Presearch logo in sidebar
- `0b74a7a` - Remove unused Mail import
- `f499011` - Remove account selector from sidebar and /accounts page
- `07117dd` - Remove unused ChevronDown import

### Files Changed
- `apps/web/src/layouts/AppLayout.tsx`
  - Replaced Mail icon with Presearch "P" SVG logo
  - Removed "PreMail" text from logo
  - Removed account selector from sidebar bottom
  - Cleaned up unused imports (Mail, ChevronDown)
- `apps/web/src/App.tsx`
  - Removed `/accounts` route
  - Removed AccountsPage import

### Features Removed
- Account selector in sidebar bottom-left corner
- `/accounts` page route

---

## PreSuite Hub (presuite.eu)

### Commits
- `a33f1ac` - Remove Suite text from header logo

### Files Changed
- `src/components/PreSuiteLaunchpad.jsx`
  - Removed "Suite" text from header logo
  - Now displays only the Presearch logo icon

---

## PreSocial (presocial.presuite.eu)

### Commits
- `f529dcb` - Replace logo with Presearch icon, remove text

### Files Changed
- `apps/web/src/components/Header.jsx`
  - Added PresearchLogo SVG component
  - Replaced MessageCircle icon + "PreSocial" text with Presearch logo
  - Logo now displays as blue (#0190FF) Presearch "P" icon

---

## PreOffice (preoffice.site)

### Commits
- `2224635` - Replace logo with Presearch icon, remove text

### Files Changed
- `branding/static/index.html`
  - Replaced checkmark circle SVG with Presearch "P" logo
  - Removed "PreOffice Online" text from header

---

## Visual Summary

| Service | Before | After |
|---------|--------|-------|
| PreDrive | P icon + "PreDrive" | P icon only |
| PreMail | Mail icon + "PreMail" | P icon only |
| PreSuite | P icon + "Suite" | P icon only |
| PreSocial | Chat icon + "PreSocial" | P icon only |
| PreOffice | Checkmark icon + "PreOffice Online" | P icon only |

---

## Deployment

All changes deployed to production on January 21, 2026.
