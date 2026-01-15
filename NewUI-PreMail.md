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

## presearch-web Patterns to Adopt

> Reference: `UIPatterns-PresearchWeb.md` for complete documentation

### iOS-Style Toggle Switch

Update settings toggles with presearch-web pattern:

```tsx
// Toggle component for settings
const Toggle = ({ checked, onChange, disabled }) => (
  <button
    role="switch"
    aria-checked={checked}
    onClick={onChange}
    disabled={disabled}
    className={`
      relative w-10 h-5 rounded-full transition-colors duration-150
      ${checked ? 'bg-[#2266ff]' : 'bg-[#454545]'}
      ${disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
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

### Custom Scrollbar (Email List)

Add presearch-web scrollbar to email lists:

```css
/* Add to index.css */

/* Email list scrollbar */
.email-list-scrollbar {
  scrollbar-color: #0190FF transparent;
  scrollbar-width: thin;
}

.email-list-scrollbar::-webkit-scrollbar {
  width: 4px;
  background: transparent;
}

.email-list-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 5px;
  background-color: #0190FF;
}

/* Email content scrollbar */
.email-content-scrollbar::-webkit-scrollbar {
  width: 6px;
}

.email-content-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}

.email-content-scrollbar::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.5);
  border-radius: 3px;
}

.email-content-scrollbar::-webkit-scrollbar-thumb:hover {
  background-color: rgba(156, 163, 175, 0.7);
}
```

### Email Row Hover Effects

Update email row with presearch-web hover:

```tsx
// Email row with hover lift
<div
  className={`
    flex items-center gap-4 px-4 py-3 cursor-pointer
    border-b border-gray-100 dark:border-[#323232]
    transition-all duration-150
    hover:bg-[#E6F4FF] dark:hover:bg-[#323232]
    hover:-translate-y-px hover:shadow-sm
    ${isSelected && 'bg-[#E6F4FF] dark:bg-[#0190FF]/15'}
  `}
>
```

### Compose Modal (Dark Glass Style)

Update compose modal with glassmorphism in dark mode:

```tsx
// Compose modal overlay
<div className="fixed inset-0 bg-black/60 dark:bg-black/80 backdrop-blur-sm z-50">
  <div
    className="
      w-full max-w-2xl mx-auto mt-20
      bg-white dark:bg-[rgba(26,26,26,0.92)]
      rounded-xl
      border border-gray-200 dark:border-[rgba(255,255,255,0.12)]
      shadow-[0_25px_50px_rgba(0,0,0,0.25)]
      dark:backdrop-blur-[16px]
    "
  >
    {/* Compose form */}
  </div>
</div>
```

### Sidebar Navigation (presearch-web style)

Update sidebar items with hover effects:

```tsx
// Sidebar item with presearch-web styling
<button
  className={`
    w-full flex items-center gap-3 px-3 py-2 rounded-lg
    text-left text-sm font-medium
    transition-all duration-150
    ${active
      ? 'bg-[#E6F4FF] dark:bg-[#0190FF]/15 text-[#0190FF]'
      : 'text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-[#323232]'
    }
    hover:-translate-y-px
  `}
>
  <Icon className={active ? 'text-[#0190FF]' : 'text-gray-400'} />
  <span>{label}</span>
  {count > 0 && (
    <span
      className={`
        ml-auto px-2 py-0.5 text-xs rounded-full
        ${active
          ? 'bg-[#0190FF] text-white shadow-sm'
          : 'bg-gray-100 dark:bg-[#323232] text-gray-500 dark:text-gray-400'
        }
      `}
    >
      {count}
    </span>
  )}
</button>
```

### Animations

Add presearch-web animations:

```css
/* Add to index.css */

/* Email compose slide-up */
@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.compose-modal {
  animation: slideUp 0.3s ease-out;
}

/* Sidebar panel slide-in */
@keyframes slideInLeft {
  from { transform: translateX(-100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

.sidebar-mobile {
  animation: slideInLeft 0.3s ease-out;
}

/* Email preview slide-in */
@keyframes slideInRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

.email-preview-panel {
  animation: slideInRight 0.3s ease-out;
}

/* Dropdown animation */
.dropdown {
  transform: scale(0.96);
  opacity: 0;
  transition: transform 160ms ease-out, opacity 160ms ease-out;
}

.dropdown.open {
  transform: scale(1);
  opacity: 1;
}
```

### Loading States

Add loading animations:

```tsx
// Loading dots for sending email
const SendingIndicator = () => (
  <div className="flex items-center gap-2">
    <span className="text-sm text-gray-500">Sending</span>
    <div className="flex gap-1">
      {[0, 1, 2].map((i) => (
        <div
          key={i}
          className="w-1.5 h-1.5 rounded-full bg-[#0190FF]"
          style={{
            animation: 'bounce 1.4s infinite ease-in-out both',
            animationDelay: `${-0.32 + i * 0.16}s`
          }}
        />
      ))}
    </div>
  </div>
);
```

```css
@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}
```

### Compose Button (presearch-web prominent style)

Update compose button:

```tsx
<button
  className="
    flex items-center gap-2
    w-full px-4 py-3 rounded-xl
    bg-[#0190FF] text-white font-semibold
    shadow-[0_4px_14px_rgba(1,144,255,0.39)]
    hover:bg-[#0177D6]
    hover:shadow-[0_6px_20px_rgba(1,144,255,0.45)]
    hover:-translate-y-0.5
    transition-all duration-200
    active:translate-y-0
  "
>
  <PencilIcon className="w-5 h-5" />
  Compose
</button>
```

### Additional Implementation Checklist

- [ ] Add iOS-style toggle switches
- [ ] Add custom scrollbar to email lists
- [ ] Update email row hover effects
- [ ] Implement Dark Glass compose modal
- [ ] Update sidebar navigation styling
- [ ] Add slide animations
- [ ] Add loading indicators
- [ ] Update compose button styling

---

*Last Updated: January 15, 2026*
