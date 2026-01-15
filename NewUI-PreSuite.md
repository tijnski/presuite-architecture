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

*Last Updated: January 15, 2026*
