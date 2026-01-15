# NewUI-PreMail - UI Implementation Guide

Tailored UI/UX implementation guide for **PreMail** (premail.site) to align with the Presearch brand identity.

**Server:** 76.13.1.117
**Code Location:** `/opt/premail/apps/web/src/`
**Framework:** React 18 + TypeScript + Vite + Tailwind CSS

---

## Current State Analysis

### Components Inventory

| Component | File | Purpose |
|-----------|------|---------|
| AppLayout | `layouts/AppLayout.tsx` | Main layout with sidebar |
| Logo | `components/Logo.tsx` | PreMail branding |
| PreDriveFilePicker | `components/PreDriveFilePicker.tsx` | File attachment picker |

### Current Styling

PreMail uses a comprehensive Tailwind setup with:
- **Font:** Inter (Google Fonts)
- **Primary Color:** `#2D8EFF` (needs update to `#0190FF`)
- **Dark Mode:** Class-based toggle
- **Custom Components:** `.btn`, `.input`, `.card`, `.glass`

---

## Current Color Palette

### From tailwind.config.ts

```typescript
colors: {
  presearch: {
    DEFAULT: "#2D8EFF",  // ❌ Should be #0190FF
    alt: "#127FFF",
    dark: "#80BAFF",
    bg: "#0079DA",
  },
  primary: {
    500: "#3591FC",      // ❌ Should be #0190FF
    600: "#2D8EFF",      // ❌ Should be #0177D6
  },
  dark: {
    800: "#1e1e1e",
    900: "#191919",      // ❌ Should be #323232
  }
}
```

### Target Color Palette

```typescript
colors: {
  presearch: {
    DEFAULT: "#0190FF",  // ✅ Presearch Azure
    alt: "#0177D6",      // Hover state
    dark: "#5CB3FF",     // For dark backgrounds
    bg: "#E6F4FF",       // Background tint
  },
  primary: {
    50: "#E6F4FF",
    100: "#BAE0FF",
    200: "#8ECAFF",
    300: "#5CB3FF",
    400: "#2E9EFF",
    500: "#0190FF",      // ✅ Main brand
    600: "#0177D6",      // ✅ Hover
    700: "#015EAD",
    800: "#014584",
    900: "#012C5B",
  },
  dark: {
    100: "#3A3A3A",
    200: "#323232",      // ✅ Mine Shaft
    300: "#2A2A2A",
    400: "#242424",
    500: "#1E1E1E",
    600: "#181818",
    700: "#121212",
    800: "#0F0F0F",
    900: "#0A0A0A",
  }
}
```

---

## CSS Component Updates

### Current index.css Classes

```css
/* Current button styles */
.btn-primary {
  @apply btn bg-presearch text-white hover:bg-presearch-alt;
}
```

### Updated CSS Components

```css
/* /src/index.css - Updated for Presearch brand */

@layer components {
  /* Primary Button - Presearch Brand */
  .btn-primary {
    @apply btn bg-[#0190FF] text-white hover:bg-[#0177D6]
           focus:ring-[#0190FF]/40 active:scale-[0.98];
    box-shadow: 0 4px 14px rgba(1, 144, 255, 0.39);
  }

  .btn-primary:hover {
    box-shadow: 0 6px 20px rgba(1, 144, 255, 0.45);
    transform: translateY(-1px);
  }

  /* Secondary Button */
  .btn-secondary {
    @apply btn bg-[#E6F4FF] text-[#0190FF] border border-[#0190FF]/20
           hover:bg-[#BAE0FF] hover:border-[#0190FF]/40;
  }

  /* Ghost Button */
  .btn-ghost {
    @apply btn text-text-muted hover:bg-[#E6F4FF] hover:text-[#0190FF]
           dark:hover:bg-[#323232] dark:hover:text-[#5CB3FF];
  }

  /* Input Fields */
  .input {
    @apply block w-full rounded-lg border border-light-300
           bg-white px-4 py-2.5 text-sm
           focus:border-[#0190FF] focus:ring-2 focus:ring-[#0190FF]/20
           dark:border-[#323232] dark:bg-[#1E1E1E]
           dark:focus:border-[#5CB3FF] dark:focus:ring-[#5CB3FF]/20;
  }

  /* Cards */
  .card {
    @apply rounded-lg border border-light-300 bg-white p-4
           shadow-card dark:border-[#323232] dark:bg-[#1E1E1E];
  }

  .card-hover {
    @apply card hover:shadow-[0_8px_25px_rgba(1,144,255,0.12)]
           hover:-translate-y-0.5 dark:hover:bg-[#323232];
  }

  /* Glass Effect */
  .glass {
    @apply backdrop-blur-[16px] border border-white/10;
    background: rgba(50, 50, 50, 0.92);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
  }
}
```

---

## Component-Specific Updates

### 1. AppLayout Sidebar

**File:** `layouts/AppLayout.tsx`

**Current SidebarItem:**
```tsx
className={`... ${
  active ? "bg-[#EAF3FF] dark:bg-[#2D8EFF]/10" : "hover:bg-gray-50"
}`}
```

**Updated:**
```tsx
className={`... ${
  active
    ? "bg-[#E6F4FF] dark:bg-[#0190FF]/15 shadow-sm"
    : "hover:bg-gray-50 dark:hover:bg-[#323232]"
}`}
```

**Icon Colors:**
```tsx
// Current
className={`w-5 h-5 ${active ? "text-[#2D8EFF]" : "text-gray-400"}`}

// Updated
className={`w-5 h-5 ${active ? "text-[#0190FF]" : "text-gray-400"}`}
```

**Label Colors:**
```tsx
// Current
className={`... ${active ? "text-[#2D8EFF]" : "text-gray-600"}`}

// Updated
className={`... ${active ? "text-[#0190FF]" : "text-gray-600 dark:text-gray-300"}`}
```

### 2. PreMailLogo Component

**Current:**
```tsx
<div className="w-9 h-9 rounded-xl bg-[#2D8EFF] ...">
```

**Updated:**
```tsx
<div className="w-9 h-9 rounded-xl bg-[#0190FF] shadow-[0_2px_8px_rgba(1,144,255,0.3)] ...">
```

**Logo Text:**
```tsx
// Current
<span className="font-semibold text-[#2D8EFF]">Mail</span>

// Updated
<span className="font-semibold text-[#0190FF]">Mail</span>
```

### 3. Badge/Count Styling

**Current:**
```tsx
className={`... ${
  active
    ? "bg-[#2D8EFF] text-white"
    : "bg-gray-100 text-gray-500"
}`}
```

**Updated:**
```tsx
className={`... ${
  active
    ? "bg-[#0190FF] text-white shadow-sm"
    : "bg-gray-100 dark:bg-[#323232] text-gray-500 dark:text-gray-400"
}`}
```

### 4. Compose Button

**Add prominent styling:**
```tsx
<button className="
  flex items-center gap-2
  w-full px-4 py-3
  rounded-xl
  bg-[#0190FF] text-white
  font-semibold
  shadow-[0_4px_14px_rgba(1,144,255,0.39)]
  hover:bg-[#0177D6]
  hover:shadow-[0_6px_20px_rgba(1,144,255,0.45)]
  transition-all duration-200
">
  <Plus className="w-5 h-5" />
  Compose
</button>
```

---

## Email List Styling

### Unread Email Indicator

```tsx
// Unread state
className="font-semibold text-gray-900 dark:text-white"

// Read state
className="font-normal text-gray-600 dark:text-gray-400"

// Unread dot indicator
<div className="w-2 h-2 rounded-full bg-[#0190FF]" />
```

### Email Row Hover

```tsx
className="
  flex items-center gap-4 px-4 py-3
  hover:bg-[#E6F4FF] dark:hover:bg-[#323232]
  transition-colors duration-150
  cursor-pointer
"
```

### Starred Email

```tsx
// Starred icon
<Star
  className={starred ? "text-yellow-500 fill-yellow-500" : "text-gray-400"}
/>
```

---

## Dark Mode Specifics

### Background Hierarchy

| Element | Light | Dark |
|---------|-------|------|
| App Background | `#F4F4F4` | `#0F0F0F` |
| Sidebar | `#FFFFFF` | `#1E1E1E` |
| Cards | `#FFFFFF` | `#1E1E1E` |
| Hover States | `#E6F4FF` | `#323232` |
| Borders | `#E5E5E5` | `#323232` |

### Dark Mode Text

| Element | Color |
|---------|-------|
| Primary Text | `#FFFFFF` |
| Secondary Text | `#B0B0B0` |
| Muted Text | `#6B6B6B` |
| Links | `#5CB3FF` |

---

## Tailwind Config Updates

**File:** `/opt/premail/apps/web/tailwind.config.ts`

```typescript
export default {
  // ... existing config
  theme: {
    extend: {
      colors: {
        // Update presearch colors
        presearch: {
          DEFAULT: "#0190FF",
          alt: "#0177D6",
          dark: "#5CB3FF",
          bg: "#E6F4FF",
        },
        // Update primary scale
        primary: {
          50: "#E6F4FF",
          100: "#BAE0FF",
          200: "#8ECAFF",
          300: "#5CB3FF",
          400: "#2E9EFF",
          500: "#0190FF",
          600: "#0177D6",
          700: "#015EAD",
          800: "#014584",
          900: "#012C5B",
        },
        // Update dark mode backgrounds
        dark: {
          100: "#3A3A3A",
          200: "#323232",  // Mine Shaft
          300: "#2A2A2A",
          400: "#242424",
          500: "#1E1E1E",
          600: "#181818",
          700: "#121212",
          800: "#0F0F0F",
          900: "#0A0A0A",
          glass: "rgba(50, 50, 50, 0.92)",
        },
      },
    },
  },
};
```

---

## Implementation Checklist

### Phase 1: Core Colors (High Priority)

- [ ] Update `presearch.DEFAULT` to `#0190FF` in tailwind.config.ts
- [ ] Update `primary-500` to `#0190FF`
- [ ] Update `primary-600` to `#0177D6`
- [ ] Update dark mode backgrounds to use `#323232`

### Phase 2: Component Updates (Medium Priority)

- [ ] Update AppLayout sidebar active states
- [ ] Update PreMailLogo background color
- [ ] Update badge/count colors
- [ ] Update compose button styling

### Phase 3: CSS Classes (Medium Priority)

- [ ] Update `.btn-primary` shadow to use `#0190FF`
- [ ] Update `.input` focus colors
- [ ] Update `.card-hover` shadow
- [ ] Update `.glass` background

### Phase 4: Search & Replace

- [ ] Replace all `#2D8EFF` with `#0190FF`
- [ ] Replace all `#127FFF` with `#0177D6`
- [ ] Replace all `#EAF3FF` with `#E6F4FF`

---

## Files to Modify

| File | Changes | Priority |
|------|---------|----------|
| `tailwind.config.ts` | Color palette update | High |
| `src/index.css` | Component classes | High |
| `src/layouts/AppLayout.tsx` | Sidebar colors | High |
| `src/components/Logo.tsx` | Logo background | Medium |
| `src/pages/*.tsx` | Hardcoded colors | Medium |

---

## Deployment Commands

```bash
# SSH to server
ssh root@76.13.1.117

# Navigate to project
cd /opt/premail

# Pull changes
git pull

# Install and build
pnpm install
pnpm build

# Restart services
pm2 restart premail-api --update-env
pm2 restart premail-web

# Verify
curl https://premail.site/health
```

---

## Color Verification

```bash
# Find hardcoded old colors
ssh root@76.13.1.117 "cd /opt/premail && grep -rn '2D8EFF' apps/web/src/"
ssh root@76.13.1.117 "cd /opt/premail && grep -rn '127FFF' apps/web/src/"
ssh root@76.13.1.117 "cd /opt/premail && grep -rn '3591FC' apps/web/src/"
```

---

*Last Updated: January 15, 2026*
