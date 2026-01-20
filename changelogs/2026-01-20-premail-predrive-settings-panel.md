# PreMail, PreDrive, PreSocial & PreOffice UI Update - January 20, 2026

## Summary
Updated PreMail, PreDrive, PreSocial, and PreOffice to have consistent UI with PreSuite-style settings panels and profile icons in the top-right corner.

---

## PreMail Changes

### Commits
- `007019c` - Update footer tagline to Pre-verify messaging
- `d92e51f` - Remove unused imports
- `484cc22` - Replace profile menu with PreSuite-style settings panel
- `78cd8cb` - Fix TypeScript errors: remove unused isDark state, fix SocialIcon type
- `d6e3bcd` - Center search bar in header, profile icon to top-right

### UI Updates

#### Footer Tagline
Changed from:
> All emails encrypted with **E2E encryption** • Your data never leaves your control

To:
> Don't trust us, **Pre-verify us** - Your data. Your control.

#### Header Layout
- Search bar centered in the middle of the header
- Profile icon moved to top-right corner
- Mobile menu button on the left (hidden on desktop)

#### Settings Panel (Slide-out from right)
Clicking the profile icon opens a PreSuite-style settings panel with:

1. **Header** - Back button, "Settings" title, Share button
2. **Account Section**
   - Avatar with user initials
   - User name and email
   - Sign out button
3. **Notifications**
   - Email alerts toggle
   - Desktop notifications toggle
   - Sound effects toggle
4. **Display**
   - Compact mode toggle
   - Show avatars toggle
5. **Appearance**
   - Theme toggle (Light/Dark pill buttons)
6. **Resources**
   - Help Center (external link)
   - Keyboard Shortcuts (external link)
   - Privacy Policy (external link)
   - Terms of Service (external link)
7. **Footer**
   - Social icons (Twitter, Discord, Telegram)
   - Privacy, Terms, About links
   - Version number

### Files Modified
- `apps/web/src/layouts/AppLayout.tsx`

---

## PreDrive Changes

### Commits
- `71a63d7` - Add PreSuite-style settings panel with centered search
- `f4a8335` - Fix TypeScript: convert null email to undefined

### UI Updates

#### Header Layout
- Search bar centered in the middle of the header
- Profile icon moved to top-right corner
- Removed old dropdown menu with theme/help/settings buttons

#### Settings Panel (Slide-out from right)
Clicking the profile icon opens a PreSuite-style settings panel with:

1. **Header** - Back button, "Settings" title, Share button
2. **Account Section**
   - Avatar with user initials
   - User name and email
   - Sign out button
3. **Quick Actions**
   - Encryption Keys management button
4. **Notifications**
   - Email alerts toggle
   - Desktop notifications toggle
5. **Display**
   - Compact mode toggle
6. **Appearance**
   - Theme toggle (Light/Dark pill buttons)
7. **Resources**
   - Help Center (external link)
   - Privacy Policy (external link)
   - Terms of Service (external link)
8. **Footer**
   - Social icons (Twitter, Discord, Telegram)
   - Privacy, Terms, About links
   - Version number

### Files Modified
- `apps/web/src/App.tsx`

---

## PreSocial Changes

### Commits
- `f4dd3e5` - Add PreSuite-style settings panel with centered search

### UI Updates

#### Header Layout
- Search bar centered in the header (already was, maintained)
- Profile icon in top-right opens Settings panel (replaced dropdown)
- Nav links (Feed, Trending, Communities) kept on desktop
- Mobile menu updated with Settings button

#### Settings Panel (Slide-out from right)
Clicking the profile icon opens a PreSuite-style settings panel with:

1. **Header** - Back button, "Settings" title, Share button
2. **Account Section**
   - Avatar with gradient (from-social to-presearch)
   - User name and email
   - Sign out button
3. **Notifications**
   - Email alerts toggle
   - Desktop notifications toggle
4. **Display**
   - Compact mode toggle
5. **Appearance**
   - Theme toggle (Light/Dark pill buttons)
6. **Resources**
   - Help Center (external link)
   - Community Guidelines (external link)
   - Privacy Policy (external link)
   - Terms of Service (external link)
7. **Footer**
   - Social icons (Twitter, Discord, Telegram)
   - Privacy, Terms, About links
   - Version number

### Files Modified
- `apps/web/src/components/Header.jsx`

---

## PreOffice Changes

### Commits
- `3792030` - Add PreSuite-style settings panel with profile icon
- `3f4b240` - Fix ethers.js CDN path for Web3 authentication

### UI Updates

#### Header Layout
- Profile icon added to top-right corner (visible when logged in)
- Sign In button shown for logged-out users
- Logo and nav links remain on left side

#### Settings Panel (Slide-out from right)
Clicking the profile icon opens a PreSuite-style settings panel with:

1. **Header** - Back button, "Settings" title, Share button
2. **Account Section**
   - Avatar with user initials (blue background)
   - User name and email
   - Sign out button
3. **Notifications**
   - Email alerts toggle
   - Desktop notifications toggle
4. **Display**
   - Auto-save documents toggle
5. **Appearance**
   - Theme toggle (Light/Dark pill buttons)
6. **Resources**
   - Help Center (external link)
   - Privacy Policy (external link)
   - Terms of Service (external link)
7. **Footer**
   - Social icons (Twitter, Discord, Telegram)
   - Privacy, Terms, About links
   - Version number

### Bug Fixes
- Fixed ethers.js CDN path for Web3 authentication (changed to correct UMD bundle `ethers.umd.min.js`)

### Files Modified
- `presearch/online/branding/static/index.html`

---

## Design Consistency

All four services (PreMail, PreDrive, PreSocial, PreOffice) now share:
- Profile icon in top-right corner
- PreSuite-style slide-out settings panel
- Same color scheme (`#212224` panel background)
- Same toggle switch design
- Same section headers and layout
- Same footer with social icons (Twitter, Discord, Telegram)
- Same external link styling

### Service-Specific Customizations
- **PreMail**: Blue primary (`#127FFF`), centered search bar, email-specific settings (sound effects, show avatars)
- **PreDrive**: Blue primary (`#127FFF`), centered search bar, Quick Actions for Encryption Keys
- **PreSocial**: Gradient avatar (purple-blue), centered search bar, Community Guidelines link
- **PreOffice**: Blue primary (`#127FFF`), auto-save toggle, no search bar (landing page)

---

## Production URLs
- PreMail: https://premail.site
- PreDrive: https://predrive.eu
- PreSocial: https://presocial.presuite.eu
- PreOffice: https://preoffice.site

## Deployment
All services were deployed via:
- Git push to GitHub
- Git pull on production servers
- Build and restart:
  - PreMail: PM2 (`pm2 restart premail-api premail-web`)
  - PreDrive: Docker Compose (`docker compose up -d --build`)
  - PreSocial: PM2 (`pm2 restart presocial-api`)
  - PreOffice: Docker Compose (`docker compose up -d --build`)
