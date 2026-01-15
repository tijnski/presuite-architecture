# NewUI-PreOffice - UI Implementation Guide

Tailored UI/UX implementation guide for **PreOffice Online** (preoffice.site) to align with the Presearch brand identity.

**Server:** 76.13.2.220
**Code Location:** `/opt/preoffice/presearch/`
**Framework:** Static HTML + CSS + Collabora Online

---

## Current State Analysis

### Key Files

| File | Location | Purpose |
|------|----------|---------|
| Landing Page | `online/branding/static/index.html` | Main landing page |
| Design Tokens | `brand/tokens.json` | Color definitions |
| Branding Assets | `brand/assets/` | Logos, icons |

### Current Design Tokens (tokens.json)

```json
{
  "colors": {
    "primary": {
      "blue": "#2D8EFF",        // ❌ Should be #0190FF
      "blueHover": "#1A7AE8",   // ❌ Should be #0177D6
      "bluePressed": "#0066D6"
    },
    "background": {
      "base": "#FFFFFF",
      "soft": "#FAFBFC",
      "tint": "#EAF3FF"         // ❌ Should be #E6F4FF
    },
    "dark": {
      "background": "#1A1A2E",  // ❌ Should be #1E1E1E
      "surface": "#252540"      // ❌ Should be #323232
    }
  }
}
```

---

## Updated Design Tokens

**File:** `/opt/preoffice/presearch/brand/tokens.json`

```json
{
  "name": "Presearch Brand Tokens",
  "version": "2.0.0",
  "colors": {
    "primary": {
      "blue": "#0190FF",
      "blueHover": "#0177D6",
      "bluePressed": "#015EAD",
      "blueLight": "#E6F4FF",
      "blueMuted": "#5CB3FF"
    },
    "text": {
      "primary": "#000000",
      "secondary": "#494949",
      "tertiary": "#6B7280",
      "inverse": "#FFFFFF",
      "link": "#0190FF"
    },
    "background": {
      "base": "#FFFFFF",
      "soft": "#FAFBFC",
      "tint": "#E6F4FF",
      "overlay": "rgba(0, 0, 0, 0.5)"
    },
    "border": {
      "default": "#E8EAED",
      "focus": "#0190FF",
      "error": "#EF4444"
    },
    "status": {
      "success": "#10B981",
      "warning": "#F59E0B",
      "error": "#EF4444",
      "info": "#0190FF"
    },
    "dark": {
      "background": "#1E1E1E",
      "surface": "#323232",
      "surfaceHover": "#3A3A3A",
      "text": "#FFFFFF",
      "textSecondary": "#9CA3AF",
      "border": "rgba(255, 255, 255, 0.1)"
    }
  },
  "typography": {
    "fontFamily": {
      "primary": "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif",
      "mono": "ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, monospace"
    },
    "fontSize": {
      "xs": "12px",
      "sm": "14px",
      "base": "16px",
      "lg": "18px",
      "xl": "20px",
      "2xl": "24px",
      "3xl": "30px",
      "4xl": "36px",
      "5xl": "48px"
    },
    "fontWeight": {
      "normal": 400,
      "medium": 500,
      "semibold": 600,
      "bold": 700
    }
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "16px",
    "lg": "24px",
    "xl": "32px",
    "2xl": "48px",
    "3xl": "64px"
  },
  "borderRadius": {
    "sm": "4px",
    "md": "8px",
    "lg": "12px",
    "xl": "16px",
    "full": "9999px"
  },
  "shadow": {
    "sm": "0 1px 2px rgba(0, 0, 0, 0.05)",
    "md": "0 4px 6px rgba(0, 0, 0, 0.1)",
    "lg": "0 10px 15px rgba(0, 0, 0, 0.1)",
    "xl": "0 20px 25px rgba(0, 0, 0, 0.1)",
    "primary": "0 4px 14px rgba(1, 144, 255, 0.39)",
    "card": "0 4px 20px rgba(0, 0, 0, 0.08)",
    "cardHover": "0 8px 30px rgba(0, 0, 0, 0.12)"
  }
}
```

---

## Landing Page Updates

**File:** `/opt/preoffice/presearch/online/branding/static/index.html`

### CSS Variables Update

```css
/* Current */
:root {
    --presearch-blue: #2D8EFF;
    --presearch-dark: #1a1a2e;
    --background-tint: #EAF3FF;
}

/* Updated */
:root {
    --presearch-blue: #0190FF;
    --presearch-blue-hover: #0177D6;
    --presearch-blue-light: #E6F4FF;
    --presearch-dark: #1E1E1E;
    --presearch-dark-surface: #323232;
    --background-tint: #E6F4FF;
    --background-soft: #FAFBFC;
    --text-primary: #000000;
    --text-secondary: #494949;
    --shadow-primary: 0 4px 14px rgba(1, 144, 255, 0.39);
}
```

### Button Updates

```css
/* Current */
.btn-primary {
    background: var(--presearch-blue);
    color: white;
}

.btn-primary:hover {
    background: #1a7ae8;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(45, 142, 255, 0.3);
}

/* Updated */
.btn-primary {
    background: var(--presearch-blue);
    color: white;
    box-shadow: var(--shadow-primary);
    transition: all 0.2s ease;
}

.btn-primary:hover {
    background: var(--presearch-blue-hover);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(1, 144, 255, 0.45);
}

.btn-primary:active {
    transform: translateY(0);
}
```

### Secondary Button

```css
/* Current */
.btn-secondary {
    background: white;
    color: var(--presearch-blue);
    border: 2px solid var(--presearch-blue);
}

/* Updated */
.btn-secondary {
    background: white;
    color: var(--presearch-blue);
    border: 2px solid var(--presearch-blue);
    transition: all 0.2s ease;
}

.btn-secondary:hover {
    background: var(--presearch-blue-light);
    border-color: var(--presearch-blue-hover);
}
```

### App Cards

```css
/* Current */
.app-card {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
}

.app-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 30px rgba(0,0,0,0.12);
}

/* Updated */
.app-card {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    border: 1px solid transparent;
    transition: all 0.3s ease;
}

.app-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 30px rgba(1, 144, 255, 0.15);
    border-color: var(--presearch-blue-light);
}
```

### App Icon Backgrounds

```css
/* Update app icon tints to use brand-aligned colors */
.app-icon.writer {
    background: #E6F4FF;  /* Blue tint for documents */
}
.app-icon.calc {
    background: #D1FAE5;  /* Green tint for spreadsheets */
}
.app-icon.impress {
    background: #FEF3C7;  /* Amber tint for presentations */
}
.app-icon.draw {
    background: #FCE7F3;  /* Pink tint for drawings */
}
```

---

## Header Navigation

```css
/* Current */
.nav-links a:hover {
    color: var(--presearch-blue);
}

/* Updated */
.nav-links a {
    color: var(--text-secondary);
    text-decoration: none;
    font-weight: 500;
    transition: color 0.2s ease;
    position: relative;
}

.nav-links a:hover {
    color: var(--presearch-blue);
}

.nav-links a::after {
    content: '';
    position: absolute;
    bottom: -4px;
    left: 0;
    width: 0;
    height: 2px;
    background: var(--presearch-blue);
    transition: width 0.2s ease;
}

.nav-links a:hover::after {
    width: 100%;
}
```

---

## Modal Styling

```css
/* Current */
.modal-content {
    background: white;
    border-radius: 16px;
    padding: 2rem;
}

.modal-content input:focus {
    border-color: var(--presearch-blue);
}

/* Updated */
.modal-content {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
}

.modal-content input {
    width: 100%;
    padding: 0.75rem 1rem;
    border: 2px solid #E8EAED;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.2s ease;
}

.modal-content input:focus {
    outline: none;
    border-color: var(--presearch-blue);
    box-shadow: 0 0 0 3px rgba(1, 144, 255, 0.1);
}

.modal-content input::placeholder {
    color: #9CA3AF;
}
```

---

## Footer Styling

```css
/* Current */
.footer {
    background: var(--presearch-dark);
    color: white;
}

.footer a {
    color: var(--presearch-blue);
}

/* Updated */
.footer {
    background: var(--presearch-dark);
    color: white;
    padding: 3rem 2rem;
}

.footer a {
    color: #5CB3FF;  /* Lighter blue for dark background */
    transition: color 0.2s ease;
}

.footer a:hover {
    color: var(--presearch-blue-light);
}

.footer p {
    opacity: 0.7;
    margin-top: 1rem;
    font-size: 0.875rem;
}
```

---

## Dark Mode Support (Future)

Add dark mode toggle and styles:

```css
/* Dark mode variables */
@media (prefers-color-scheme: dark) {
    :root {
        --background-base: #1E1E1E;
        --background-soft: #323232;
        --text-primary: #FFFFFF;
        --text-secondary: #9CA3AF;
    }

    body {
        background: linear-gradient(135deg, #1E1E1E 0%, #323232 100%);
        color: var(--text-primary);
    }

    .header {
        background: #1E1E1E;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }

    .app-card {
        background: #323232;
        border-color: rgba(255, 255, 255, 0.1);
    }

    .modal-content {
        background: #323232;
    }

    .modal-content input {
        background: #1E1E1E;
        border-color: rgba(255, 255, 255, 0.1);
        color: white;
    }
}
```

---

## Collabora Integration Branding

For the Collabora Online editor itself, custom branding can be applied through:

### WOPI Server Config

**File:** `/opt/preoffice/presearch/online/wopi-server/src/index.js`

Ensure the editor receives brand colors:

```javascript
// When generating editor URL, pass brand parameters
const editorUrl = `${collaboraPublicUrl}/browser/${discovery.productVersion}/cool.html` +
  `?WOPISrc=${encodeURIComponent(wopiUrl)}` +
  `&access_token=${accessToken}` +
  `&brand.primaryColor=%230190FF` +  // Presearch Azure
  `&brand.logo=${encodeURIComponent(logoUrl)}`;
```

---

## Implementation Checklist

### Phase 1: Design Tokens (High Priority)

- [ ] Update `tokens.json` with correct Presearch colors
- [ ] Change `primary.blue` from `#2D8EFF` to `#0190FF`
- [ ] Change `dark.background` from `#1A1A2E` to `#1E1E1E`
- [ ] Change `dark.surface` from `#252540` to `#323232`

### Phase 2: Landing Page (High Priority)

- [ ] Update CSS variables in `index.html`
- [ ] Update button styles
- [ ] Update card hover effects
- [ ] Update footer link colors

### Phase 3: Modal & Forms (Medium Priority)

- [ ] Update input focus states
- [ ] Update modal shadows
- [ ] Add input placeholder styling

### Phase 4: Dark Mode (Future)

- [ ] Add dark mode CSS media query
- [ ] Test all components in dark mode
- [ ] Add manual dark mode toggle (optional)

---

## Files to Modify

| File | Changes | Priority |
|------|---------|----------|
| `brand/tokens.json` | Full color update | High |
| `online/branding/static/index.html` | CSS & colors | High |
| `online/wopi-server/src/index.js` | Brand params | Low |

---

## Deployment Commands

```bash
# SSH to server
ssh root@76.13.2.220

# Navigate to project
cd /opt/preoffice/presearch/online

# Pull changes
git pull origin main

# Rebuild and restart containers
docker compose down
docker compose up -d --build

# Verify
curl https://preoffice.site/health
```

---

## Color Verification

```bash
# Check current colors in HTML
ssh root@76.13.2.220 "grep -n '2D8EFF' /opt/preoffice/presearch/online/branding/static/index.html"

# Check tokens.json
ssh root@76.13.2.220 "cat /opt/preoffice/presearch/brand/tokens.json | grep -A5 'primary'"
```

---

## Visual Comparison

| Element | Current | Target |
|---------|---------|--------|
| Primary Button | ![#2D8EFF](https://via.placeholder.com/20/2D8EFF/2D8EFF) `#2D8EFF` | ![#0190FF](https://via.placeholder.com/20/0190FF/0190FF) `#0190FF` |
| Button Hover | ![#1A7AE8](https://via.placeholder.com/20/1A7AE8/1A7AE8) `#1A7AE8` | ![#0177D6](https://via.placeholder.com/20/0177D6/0177D6) `#0177D6` |
| Background Tint | ![#EAF3FF](https://via.placeholder.com/20/EAF3FF/EAF3FF) `#EAF3FF` | ![#E6F4FF](https://via.placeholder.com/20/E6F4FF/E6F4FF) `#E6F4FF` |
| Dark BG | ![#1A1A2E](https://via.placeholder.com/20/1A1A2E/1A1A2E) `#1A1A2E` | ![#1E1E1E](https://via.placeholder.com/20/1E1E1E/1E1E1E) `#1E1E1E` |
| Dark Surface | ![#252540](https://via.placeholder.com/20/252540/252540) `#252540` | ![#323232](https://via.placeholder.com/20/323232/323232) `#323232` |

---

## presearch-web Patterns to Adopt

> Reference: `UIPatterns-PresearchWeb.md` for complete documentation

### Dark Glass Theme for Modals

Add Dark Glass styling to modals and dropdowns:

```css
/* Add to index.html <style> section */

/* Dark Glass modal overlay */
.modal-overlay {
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
}

/* Dark Glass modal content (dark mode) */
@media (prefers-color-scheme: dark) {
  .modal-content {
    background: rgba(26, 26, 26, 0.92);
    border: 1px solid rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(16px);
    box-shadow: 0 0 12px rgba(0, 0, 0, 0.6);
  }
}

/* Dark Glass dropdown */
.dropdown-menu {
  background: rgba(26, 26, 26, 0.92);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 12px;
  backdrop-filter: blur(16px);
  box-shadow: 0 0 12px rgba(0, 0, 0, 0.6);
  transform: scale(0.96);
  opacity: 0;
  transition: transform 160ms ease-out, opacity 160ms ease-out;
}

.dropdown-menu.open {
  transform: scale(1);
  opacity: 1;
}
```

### App Card Hover Effects

Update app cards with presearch-web hover pattern:

```css
/* Updated app-card hover */
.app-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #BFBFBF;
  transition: all 0.15s ease-out;
  cursor: pointer;
}

.app-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
  border-color: var(--presearch-blue-light);
  background: #FAFAFA;
}

/* Dark mode app card */
@media (prefers-color-scheme: dark) {
  .app-card {
    background: #323232;
    border-color: rgba(255, 255, 255, 0.12);
  }

  .app-card:hover {
    background: #3A3A3A;
  }
}
```

### Custom Scrollbar

Add presearch-web scrollbar:

```css
/* Custom scrollbar for document list */
.custom-scrollbar {
  scrollbar-color: var(--presearch-blue) transparent;
  scrollbar-width: thin;
}

.custom-scrollbar::-webkit-scrollbar {
  width: 4px;
  height: 4px;
  background: transparent;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 5px;
  background-color: var(--presearch-blue);
}
```

### Animations

Add presearch-web animations:

```css
/* Slide animations */
@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Modal animation */
.modal-content {
  animation: slideUp 0.3s ease-out;
}

/* Dropdown animation */
.dropdown-content {
  animation: slideDown 0.2s ease-out;
}

/* Page load animation */
.app-grid {
  animation: fadeIn 0.4s ease-out;
}
```

### Loading States

Add loading animations:

```css
/* Loading dots */
.loading-dots {
  display: flex;
  gap: 4px;
  align-items: center;
}

.loading-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--presearch-blue);
  animation: bounce 1.4s infinite ease-in-out both;
}

.loading-dot:nth-child(1) { animation-delay: -0.32s; }
.loading-dot:nth-child(2) { animation-delay: -0.16s; }
.loading-dot:nth-child(3) { animation-delay: 0s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

/* Skeleton loading */
.skeleton {
  background: linear-gradient(
    90deg,
    #f0f0f0 25%,
    #e0e0e0 50%,
    #f0f0f0 75%
  );
  background-size: 200% 100%;
  animation: skeleton-pulse 1.5s ease-in-out infinite;
}

@keyframes skeleton-pulse {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

### Button Enhancements

Update buttons with presearch-web shadow and hover:

```css
/* Primary button - enhanced */
.btn-primary {
  background: var(--presearch-blue);
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(1, 144, 255, 0.39);
  transition: all 0.2s ease;
}

.btn-primary:hover {
  background: var(--presearch-blue-hover);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(1, 144, 255, 0.45);
}

.btn-primary:active {
  transform: translateY(0);
}

/* Secondary button */
.btn-secondary {
  background: white;
  color: var(--presearch-blue);
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  border: 2px solid var(--presearch-blue);
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: var(--presearch-blue-light);
  border-color: var(--presearch-blue-hover);
  transform: translateY(-1px);
}
```

### Font Stack

Add presearch-web font stack:

```css
/* Font stack - use ProximaNova if available */
@font-face {
  font-family: 'ProximaNova';
  src: url('/assets/ProximaNova-Regular.woff2') format('woff2');
  font-weight: normal;
  font-style: normal;
  font-display: swap;
}

body {
  font-family: 'ProximaNova', Inter, system-ui, -apple-system,
               'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
}
```

### Navigation Link Hover

Update nav links with animated underline:

```css
/* Nav link with animated underline */
.nav-links a {
  color: var(--text-secondary);
  text-decoration: none;
  font-weight: 500;
  position: relative;
  transition: color 0.2s ease;
}

.nav-links a::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--presearch-blue);
  transition: width 0.2s ease;
}

.nav-links a:hover {
  color: var(--presearch-blue);
}

.nav-links a:hover::after {
  width: 100%;
}
```

### Additional Implementation Checklist

- [ ] Add Dark Glass modal styling
- [ ] Update app card hover effects
- [ ] Add custom scrollbar
- [ ] Implement slide animations
- [ ] Add loading states (dots, skeleton)
- [ ] Update button shadows and hover
- [ ] Add font stack with ProximaNova
- [ ] Add animated nav link underline

---

*Last Updated: January 15, 2026*
