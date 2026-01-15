# NewUI-PreSuite - UI Implementation Guide

Tailored UI/UX implementation guide for **PreSuite Hub** (presuite.eu) to align with the Presearch brand identity.

**Server:** 76.13.2.221
**Code Location:** `/var/www/presuite/src/`
**Framework:** React 19 + Vite + Tailwind CSS 4

---

## Current State Analysis

### Components Inventory

| Component | File | Lines | Purpose |
|-----------|------|-------|---------|
| PreSuiteLaunchpad | `PreSuiteLaunchpad.jsx` | 24,758 | Main dashboard |
| AppModal | `AppModal.jsx` | 33,516 | App placeholder modals |
| PreGPTChat | `PreGPTChat.jsx` | 25,957 | AI chat interface |
| SearchBar | `SearchBar.jsx` | 8,072 | Search with autocomplete |
| Settings | `Settings.jsx` | 10,584 | User settings panel |
| Login | `Login.jsx` | 11,034 | Authentication |
| Register | `Register.jsx` | 16,698 | User registration |
| Notifications | `Notifications.jsx` | 10,274 | Notification panel |
| UserProfile | `UserProfile.jsx` | 9,999 | Profile management |

### Current Color Palette (Needs Update)

```javascript
// Current colors in PreSuiteLaunchpad.jsx
const colors = {
  primary: {
    50: '#EBF4FF',
    500: '#3591FC',   // ❌ Should be #0190FF
    600: '#2D8EFF',   // ❌ Should be #0177D6
    900: '#102C4C',
  },
  dark: {
    100: '#242424',
    200: '#1e1e1e',
    500: '#0f0f0f',   // ❌ Should be #323232 (Mine Shaft)
  }
}
```

---

## Required Color Updates

### Primary Blue Scale

| Token | Current | Target | Location |
|-------|---------|--------|----------|
| `primary-500` | `#3591FC` | `#0190FF` | PreSuiteLaunchpad.jsx:25 |
| `primary-600` | `#2D8EFF` | `#0177D6` | PreSuiteLaunchpad.jsx:26 |
| Hover shadows | `#2D8EFF40` | `#0190FF40` | Multiple locations |

### Dark Mode Background

| Token | Current | Target | Location |
|-------|---------|--------|----------|
| `dark-100` | `#242424` | `#323232` | PreSuiteLaunchpad.jsx:30 |
| Glass bg | `rgba(30,30,30,0.8)` | `rgba(50,50,50,0.8)` | GlassCard component |

---

## Component-Specific Updates

### 1. GlassCard Component

**Current Implementation:**
```jsx
// PreSuiteLaunchpad.jsx - GlassCard
<div
  style={{
    backgroundColor: isDark ? 'rgba(30, 30, 30, 0.8)' : 'rgba(255, 255, 255, 0.7)',
    border: `1px solid ${isDark ? 'rgba(255, 255, 255, 0.1)' : colors.primary[50]}`,
    boxShadow: isDark
      ? '0 8px 32px rgba(0, 0, 0, 0.3)'
      : '0 8px 32px rgba(45, 142, 255, 0.1)'
  }}
>
```

**Required Update:**
```jsx
// Update to use Presearch brand colors
<div
  style={{
    backgroundColor: isDark ? 'rgba(50, 50, 50, 0.8)' : 'rgba(255, 255, 255, 0.7)',
    border: `1px solid ${isDark ? 'rgba(255, 255, 255, 0.1)' : '#E6F4FF'}`,
    boxShadow: isDark
      ? '0 8px 32px rgba(0, 0, 0, 0.37)'
      : '0 8px 32px rgba(1, 144, 255, 0.1)'  // Updated to #0190FF
  }}
>
```

### 2. AppIcon Component

**Current Implementation:**
```jsx
<div
  style={{
    backgroundColor: color,
    boxShadow: `0 4px 14px ${color}40`
  }}
>
```

**Required Update:**
- Ensure all app icons use consistent shadow opacity
- Update badge color from `bg-red-500` to semantic error color

### 3. Button Styles

**Current (inline styles):**
```jsx
style={{ backgroundColor: '#3591FC' }}
```

**Required Update:**
```jsx
// Create reusable button classes
const buttonStyles = {
  primary: 'bg-[#0190FF] hover:bg-[#0177D6] text-white shadow-[0_4px_14px_rgba(1,144,255,0.39)]',
  secondary: 'border border-[#0190FF] text-[#0190FF] hover:bg-[#E6F4FF]',
  ghost: 'hover:bg-gray-100 dark:hover:bg-[#323232]'
};
```

### 4. Search Bar

**File:** `SearchBar.jsx`

**Updates Needed:**
- Focus ring color: `#3591FC` → `#0190FF`
- Autocomplete dropdown shadow alignment
- Dark mode border color

```jsx
// Current
className="focus:ring-[#3591FC]"

// Target
className="focus:ring-[#0190FF] focus:border-[#0190FF]"
```

### 5. Login/Register Pages

**Files:** `Login.jsx`, `Register.jsx`

**Updates Needed:**
- Primary button color
- Focus states on inputs
- Error state colors (keep `#EF4444` - already aligned)
- Link hover colors

---

## CSS Variables to Add

Create a new CSS file or update `index.css`:

```css
/* /src/index.css - Add PreSuite CSS variables */
:root {
  /* Primary - Presearch Azure */
  --presuite-primary: #0190FF;
  --presuite-primary-hover: #0177D6;
  --presuite-primary-light: #E6F4FF;
  --presuite-primary-dark: #012C5B;

  /* Shadows */
  --presuite-shadow-primary: 0 4px 14px rgba(1, 144, 255, 0.39);
  --presuite-shadow-card: 0 8px 32px rgba(1, 144, 255, 0.1);

  /* Glass */
  --presuite-glass-light: rgba(255, 255, 255, 0.7);
  --presuite-glass-dark: rgba(50, 50, 50, 0.8);
  --presuite-glass-border-light: rgba(255, 255, 255, 0.3);
  --presuite-glass-border-dark: rgba(255, 255, 255, 0.1);
}

.dark {
  --presuite-bg-primary: #1E1E1E;
  --presuite-bg-secondary: #323232;
}
```

---

## PreGPT Chat Styling

**File:** `PreGPTChat.jsx`

### Message Bubbles

**Current:**
```jsx
// User message
className="bg-[#3591FC] text-white"

// Assistant message
className="bg-gray-100 dark:bg-gray-800"
```

**Target:**
```jsx
// User message - Presearch brand
className="bg-[#0190FF] text-white shadow-[0_2px_8px_rgba(1,144,255,0.3)]"

// Assistant message
className="bg-[#E6F4FF] dark:bg-[#323232] text-gray-900 dark:text-white"
```

### Sources Dropdown

Update link colors to use `#0190FF` for consistency.

---

## Settings Panel

**File:** `Settings.jsx`

### Theme Toggle

Ensure toggle uses brand colors:
```jsx
// Active state
className="bg-[#0190FF]"

// Inactive state
className="bg-gray-300 dark:bg-gray-600"
```

### Section Headers

Use consistent typography:
```jsx
className="text-lg font-semibold text-gray-900 dark:text-white"
```

---

## Implementation Checklist

### Phase 1: Color Migration

- [ ] Update `colors` object in PreSuiteLaunchpad.jsx
- [ ] Update GlassCard background colors
- [ ] Update all inline `#3591FC` to `#0190FF`
- [ ] Update all inline `#2D8EFF` to `#0177D6`

### Phase 2: Component Updates

- [ ] Refactor buttons to use consistent classes
- [ ] Update SearchBar focus states
- [ ] Update PreGPTChat message colors
- [ ] Update Login/Register button colors

### Phase 3: Dark Mode

- [ ] Update dark background to `#323232`
- [ ] Test glassmorphism contrast
- [ ] Verify WCAG AA compliance

### Phase 4: CSS Variables

- [ ] Add CSS variables to index.css
- [ ] Migrate inline styles to use variables
- [ ] Test theme switching

---

## Files to Modify

| File | Changes | Priority |
|------|---------|----------|
| `src/components/PreSuiteLaunchpad.jsx` | Color palette, GlassCard | High |
| `src/components/SearchBar.jsx` | Focus colors | High |
| `src/components/PreGPTChat.jsx` | Message colors | Medium |
| `src/components/Login.jsx` | Button colors | Medium |
| `src/components/Register.jsx` | Button colors | Medium |
| `src/components/Settings.jsx` | Toggle colors | Medium |
| `src/index.css` | Add CSS variables | Low |

---

## Testing Commands

```bash
# SSH to server
ssh root@76.13.2.221

# Navigate to project
cd /var/www/presuite

# Build and verify
npm run build

# Check for color values
grep -r "3591FC" src/
grep -r "2D8EFF" src/

# After changes, deploy
scp -r dist/* root@76.13.2.221:/var/www/presuite/
```

---

## presearch-web Patterns to Adopt

> Reference: `UIPatterns-PresearchWeb.md` for complete documentation

### Dark Glass Theme

Add Dark Glass CSS variables for glassmorphism effects:

```css
/* Add to index.css */
[data-theme='dark-glass'] {
  --dg-border: rgba(255, 255, 255, 0.12);
  --dg-bg: rgba(13, 15, 18, 0.55);
  --dg-text: #e9e9e9;
  --dg-placeholder: #838383;
}

/* Glass panel (for search, modals, dropdowns) */
.dg-panel {
  background: var(--dg-bg);
  border: 1px solid var(--dg-border);
  border-radius: 10px;
  backdrop-filter: blur(16px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
}

/* Glass popover with caret */
.dg-popover {
  border-radius: 12px;
  box-shadow: 0 0 12px rgba(0, 0, 0, 0.6);
  background: rgba(26, 26, 26, 0.92);
  border: 1px solid rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(16px);
  transform: scale(0.96);
  opacity: 0;
  transition: transform 160ms ease-out, opacity 160ms ease-out;
}

.dg-popover.open {
  transform: scale(1);
  opacity: 1;
}
```

### iOS-Style Toggle Switch

Replace current toggles in Settings.jsx with presearch-web style:

```jsx
// Settings toggle component
const Toggle = ({ checked, onChange }) => (
  <button
    role="switch"
    aria-checked={checked}
    onClick={onChange}
    className={`
      relative w-10 h-5 rounded-full transition-colors duration-150
      ${checked ? 'bg-[#2266ff]' : 'bg-[#454545]'}
      shadow-[inset_0_0_0_1px_rgba(255,255,255,0.12)]
      focus:outline-none focus:ring-2 focus:ring-[#3478f6]/40
    `}
  >
    <span
      className={`
        absolute top-0.5 w-4 h-4 rounded-full bg-white
        transition-all duration-150 shadow-md
        ${checked ? 'left-[22px]' : 'left-0.5'}
      `}
    />
  </button>
);
```

### Custom Scrollbar

Add presearch-web scrollbar styling:

```css
/* Custom scrollbar - brand colored */
.custom-scrollbar {
  scrollbar-color: #0190FF transparent;
  scrollbar-width: thin;
}

.custom-scrollbar::-webkit-scrollbar {
  height: 4px;
  width: 4px;
  background: transparent;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 5px;
  background-color: #0190FF;
}

/* PreGPT chat scrollbar */
.pregpt-scrollbar::-webkit-scrollbar {
  width: 6px;
}

.pregpt-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}

.pregpt-scrollbar::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.5);
  border-radius: 3px;
}

.pregpt-scrollbar::-webkit-scrollbar-thumb:hover {
  background-color: rgba(156, 163, 175, 0.7);
}
```

### Animations

Add presearch-web animations:

```css
/* Slide animations */
@keyframes slideInRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@keyframes slideInTop {
  from { transform: translateY(-100%); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Loading dots animation */
.loading-dot {
  animation: bounce 1.4s infinite ease-in-out both;
}

.loading-dot:nth-child(1) { animation-delay: -0.32s; }
.loading-dot:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

/* Panel animations */
.pregpt-sidebar {
  animation: slideInRight 0.3s ease-out;
}

.settings-panel {
  animation: slideDown 0.2s ease-out;
}
```

### Card Hover Effects

Update GlassCard and AppCard with presearch-web hover:

```jsx
// Card with presearch-web hover effect
const Card = ({ children, className }) => (
  <div
    className={`
      bg-white dark:bg-[#323232]
      rounded-lg border border-[#BFBFBF] dark:border-[rgba(255,255,255,0.12)]
      transition-all duration-150
      hover:bg-[#2A2A2A] hover:transform hover:-translate-y-0.5
      hover:shadow-[0_4px_12px_rgba(0,0,0,0.25)]
      ${className}
    `}
  >
    {children}
  </div>
);
```

### PreGPT Chat Sizing

Match presearch-web PreGPT dimensions:

```css
.pregpt-chat-component {
  width: min(600px, 90vw);
  max-width: min(600px, 90vw);
  height: min(600px, 85vh);
  max-height: min(600px, 85vh);
  display: flex;
  flex-direction: column;
}

@media (max-width: 768px) {
  .pregpt-chat-component {
    width: min(95vw, 600px);
    max-width: min(95vw, 600px);
    height: min(80vh, 600px);
    max-height: min(80vh, 600px);
  }
}
```

### Font Stack

Consider adding ProximaNova or use the fallback:

```css
/* ProximaNova (if available) */
@font-face {
  font-family: 'ProximaNova';
  src: url('/assets/ProximaNova-Regular.woff2') format('woff2');
  font-weight: normal;
  font-style: normal;
  font-display: block;
}

/* Fallback stack (Inter-based) */
body {
  font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
}
```

### Additional Implementation Checklist

- [ ] Add Dark Glass CSS variables
- [ ] Replace toggles with iOS-style switches
- [ ] Add custom scrollbar styling
- [ ] Implement slide animations for panels
- [ ] Add loading dot animations
- [ ] Update card hover effects
- [ ] Match PreGPT chat dimensions

---

*Last Updated: January 15, 2026*
