# NewUI-PreDrive - UI Implementation Guide

Tailored UI/UX implementation guide for **PreDrive** (predrive.eu) to align with the Presearch brand identity.

**Server:** 76.13.1.110
**Code Location:** `/opt/predrive/apps/web/src/`
**Framework:** React 18 + TypeScript + Vite + Tailwind CSS

---

## Current State Analysis

### Components Inventory

| Component | File | Size | Purpose |
|-----------|------|------|---------|
| Sidebar | `Sidebar.tsx` | 6,957 | Navigation, storage indicator |
| FileList | `FileList.tsx` | 8,663 | File listing (list view) |
| FileCard | `FileCard.tsx` | 7,076 | File display (grid view) |
| FileRow | `FileRow.tsx` | 5,743 | Individual file row |
| FilePreview | `FilePreview.tsx` | 6,322 | Image/PDF/video preview |
| FileDetails | `FileDetails.tsx` | 3,115 | Selected file info panel |
| DropZone | `DropZone.tsx` | 2,127 | Drag-and-drop upload |
| SharesList | `SharesList.tsx` | 4,979 | Manage shared links |
| Toast | `Toast.tsx` | 3,517 | Notification toasts |
| ContextMenu | `ContextMenu.tsx` | 2,731 | Right-click menu |
| Skeleton | `Skeleton.tsx` | 1,422 | Loading placeholders |
| Breadcrumb | `Breadcrumb.tsx` | 952 | Navigation path |
| Layout | `Layout.tsx` | 2,665 | App layout wrapper |

### Current Color System (CSS Variables)

```css
/* Current in index.css */
:root {
  --color-brand-500: 45 142 255;  /* RGB for #2D8EFF */
}
```

**Issue:** Using `#2D8EFF` instead of Presearch brand `#0190FF`

---

## CSS Variables Update

### Current index.css

```css
:root {
  --color-surface-primary: 255 255 255;
  --color-surface-secondary: 249 250 251;
  --color-surface-accent: 239 246 255;
  --color-text-primary: 17 24 39;
  --color-text-secondary: 107 114 128;
  --color-brand-500: 45 142 255;  /* ❌ #2D8EFF */
}

.dark {
  --color-surface-primary: 17 24 39;
  --color-surface-secondary: 31 41 55;
  --color-brand-500: 45 142 255;  /* ❌ Same issue */
}
```

### Target index.css

```css
:root {
  /* Surface Colors */
  --color-surface-primary: 255 255 255;
  --color-surface-secondary: 250 251 252;
  --color-surface-accent: 230 244 255;  /* #E6F4FF */

  /* Text Colors */
  --color-text-primary: 17 24 39;
  --color-text-secondary: 107 114 128;
  --color-text-inverse: 255 255 255;

  /* Brand Colors - Presearch Azure */
  --color-brand-50: 230 244 255;   /* #E6F4FF */
  --color-brand-100: 186 224 255;  /* #BAE0FF */
  --color-brand-200: 142 202 255;  /* #8ECAFF */
  --color-brand-400: 46 158 255;   /* #2E9EFF */
  --color-brand-500: 1 144 255;    /* #0190FF ✅ */
  --color-brand-600: 1 119 214;    /* #0177D6 */
}

.dark {
  --color-surface-primary: 30 30 30;    /* #1E1E1E */
  --color-surface-secondary: 50 50 50;  /* #323232 - Mine Shaft */
  --color-surface-accent: 55 65 81;

  --color-text-primary: 249 250 251;
  --color-text-secondary: 156 163 175;

  /* Brand stays same in dark mode */
  --color-brand-500: 1 144 255;  /* #0190FF */
  --color-brand-600: 46 158 255; /* Lighter for dark bg */
}
```

---

## Tailwind Config Update

**File:** `/opt/predrive/apps/web/tailwind.config.ts`

### Current Config

```typescript
colors: {
  brand: {
    500: 'rgb(var(--color-brand-500) / <alpha-value>)',
    // Uses CSS variables
  }
}
```

### Add Missing Shades

```typescript
colors: {
  brand: {
    50: 'rgb(var(--color-brand-50) / <alpha-value>)',
    100: 'rgb(var(--color-brand-100) / <alpha-value>)',
    200: 'rgb(var(--color-brand-200) / <alpha-value>)',
    300: '#5CB3FF',
    400: 'rgb(var(--color-brand-400) / <alpha-value>)',
    500: 'rgb(var(--color-brand-500) / <alpha-value>)',  // #0190FF
    600: 'rgb(var(--color-brand-600) / <alpha-value>)',
    700: '#015EAD',
    800: '#014584',
    900: '#012C5B',
  }
}
```

---

## Component-Specific Updates

### 1. Sidebar Component

**File:** `Sidebar.tsx`

**Current Logo Colors:**
```tsx
<span className="text-xl font-semibold text-text-primary">Pre</span>
<span className="text-xl font-semibold text-brand-500">Drive</span>
```
✅ Already using CSS variable - will update automatically

**Storage Indicator Progress Bar:**
```tsx
// Current
className="bg-brand-500"

// Keep - already uses variable
```

**Network Health Status Colors:**
```tsx
// Current - needs semantic color alignment
const statusColor = data?.status === 'healthy'
  ? 'bg-green-500'    // ✅ Keep
  : 'bg-yellow-500';  // ✅ Keep

// Text colors - update for brand consistency
const textColor = data?.status === 'healthy'
  ? 'text-green-600'
  : 'text-yellow-600';
```

### 2. Button Styles

**File:** `index.css` - component layer

**Current:**
```css
.btn-primary {
  @apply bg-brand-500 text-text-inverse hover:bg-brand-600;
}
```

**Update hover shadow:**
```css
.btn-primary {
  @apply bg-brand-500 text-text-inverse hover:bg-brand-600;
  box-shadow: 0 4px 14px rgba(1, 144, 255, 0.39);
}

.btn-primary:hover {
  box-shadow: 0 6px 20px rgba(1, 144, 255, 0.45);
  transform: translateY(-1px);
}
```

### 3. FileCard Component

**File:** `FileCard.tsx`

**Current Selection Indicator:**
```tsx
className={clsx(
  'border-2',
  isSelected ? 'border-brand-500' : 'border-transparent'
)}
```
✅ Already using CSS variable

**Add hover effect:**
```tsx
className={clsx(
  'border-2 transition-all duration-200',
  isSelected
    ? 'border-brand-500 shadow-[0_4px_14px_rgba(1,144,255,0.25)]'
    : 'border-transparent hover:border-brand-200'
)}
```

### 4. Toast Component

**File:** `Toast.tsx`

**Current Success/Error Colors:**
```tsx
// Verify these match semantic colors
const toastStyles = {
  success: 'bg-green-500',  // ✅ Keep #10B981
  error: 'bg-red-500',      // Update to #EF4444
  info: 'bg-brand-500',     // ✅ Will be #0190FF
  warning: 'bg-yellow-500', // ✅ Keep #F59E0B
};
```

### 5. ContextMenu Component

**File:** `ContextMenu.tsx`

**Update hover states:**
```tsx
// Current
className="hover:bg-surface-accent"

// Ensure accent uses brand tint
// In CSS: --color-surface-accent should be #E6F4FF equivalent
```

### 6. Skeleton Component

**File:** `Skeleton.tsx`

**Current Animation:**
```css
@keyframes skeleton-pulse {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 0.8; }
}
```
✅ Good - keep this animation

---

## New Upload Button Styling

**File:** `UploadButton.tsx`

**Add brand shadow:**
```tsx
<button className="
  flex items-center gap-2
  px-4 py-3
  rounded-xl
  bg-surface-primary
  border border-brand-200
  shadow-md
  hover:shadow-lg
  hover:border-brand-400
  transition-all duration-200
">
  <Plus className="text-brand-500" />
  <span className="font-semibold">New</span>
</button>
```

---

## Dark Mode Specific Updates

### File Preview Modal

```tsx
// Dark mode overlay
className="bg-black/60 dark:bg-black/80 backdrop-blur-sm"

// Modal container
className="bg-surface-primary dark:bg-[#323232] rounded-xl shadow-2xl"
```

### File Details Panel

```tsx
// Section headers in dark mode
className="text-text-secondary dark:text-gray-400"

// Metadata values
className="text-text-primary dark:text-white"
```

---

## Animation Updates

### Add to index.css

```css
/* Smooth slide animations for panels */
@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* File card hover lift */
.file-card-hover {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.file-card-hover:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(1, 144, 255, 0.15);
}
```

---

## Implementation Checklist

### Phase 1: CSS Variables (High Priority)

- [ ] Update `--color-brand-500` RGB values in index.css
- [ ] Add missing brand color shades (50, 100, 200, etc.)
- [ ] Update dark mode surface colors to Mine Shaft (#323232)
- [ ] Verify surface-accent uses `#E6F4FF` equivalent

### Phase 2: Component Polish (Medium Priority)

- [ ] Add hover shadows to btn-primary
- [ ] Update FileCard selection shadow
- [ ] Add file-card-hover animation class
- [ ] Verify Toast colors match semantic palette

### Phase 3: Dark Mode (Medium Priority)

- [ ] Test all components in dark mode
- [ ] Verify contrast ratios
- [ ] Update modal overlays

### Phase 4: Consistency Check

- [ ] Grep for hardcoded `#2D8EFF` - replace with variable
- [ ] Grep for hardcoded `45 142 255` - update to `1 144 255`
- [ ] Test brand consistency across all views

---

## Files to Modify

| File | Changes | Priority |
|------|---------|----------|
| `src/index.css` | CSS variables update | High |
| `tailwind.config.ts` | Add brand color shades | High |
| `src/components/Sidebar.tsx` | Verify variables used | Low |
| `src/components/FileCard.tsx` | Add hover shadow | Medium |
| `src/components/Toast.tsx` | Verify semantic colors | Low |

---

## Deployment Commands

```bash
# SSH to server
ssh root@76.13.1.110

# Navigate to project
cd /opt/predrive

# Pull latest changes (if using git)
git pull

# Build
pnpm build

# Restart Docker
docker compose -f deploy/docker-compose.prod.yml up -d --build

# Verify
curl https://predrive.eu/health
```

---

## Color Verification Script

```bash
# Check for old color values
ssh root@76.13.1.110 "cd /opt/predrive && grep -r '2D8EFF' apps/web/src/"
ssh root@76.13.1.110 "cd /opt/predrive && grep -r '45 142 255' apps/web/src/"
ssh root@76.13.1.110 "cd /opt/predrive && grep -r '3591FC' apps/web/src/"
```

---

## presearch-web Patterns to Adopt

> Reference: `UIPatterns-PresearchWeb.md` for complete documentation

### Custom Scrollbar

Add presearch-web scrollbar styling to file lists:

```css
/* Add to index.css */

/* File list scrollbar */
.custom-scrollbar {
  scrollbar-color: rgb(var(--color-brand-500)) transparent;
  scrollbar-width: thin;
}

.custom-scrollbar::-webkit-scrollbar {
  height: 4px;
  width: 4px;
  background: transparent;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 5px;
  background-color: rgb(var(--color-brand-500));
}

/* File preview panel scrollbar */
.preview-scrollbar::-webkit-scrollbar {
  width: 6px;
}

.preview-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}

.preview-scrollbar::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.5);
  border-radius: 3px;
}

.preview-scrollbar::-webkit-scrollbar-thumb:hover {
  background-color: rgba(156, 163, 175, 0.7);
}
```

### File Card Hover Effects

Update FileCard.tsx with presearch-web hover pattern:

```tsx
// FileCard with presearch-web hover
<div
  className={clsx(
    'relative p-4 rounded-lg border cursor-pointer',
    'bg-surface-primary dark:bg-[#323232]',
    'border-[#BFBFBF] dark:border-[rgba(255,255,255,0.12)]',
    'transition-all duration-150',
    'hover:-translate-y-0.5 hover:shadow-[0_4px_12px_rgba(0,0,0,0.25)]',
    isSelected && 'ring-2 ring-brand-500 border-brand-500'
  )}
>
```

### Context Menu (Dark Glass Style)

Update ContextMenu.tsx with glassmorphism:

```tsx
// Context menu with Dark Glass styling
<div
  className="
    min-w-[200px] py-2 rounded-xl
    bg-[rgba(26,26,26,0.92)] dark:bg-[rgba(26,26,26,0.92)]
    border border-[rgba(255,255,255,0.12)]
    backdrop-blur-[16px]
    shadow-[0_0_12px_rgba(0,0,0,0.6)]
  "
>
  {items.map((item) => (
    <button
      className="
        w-full px-4 py-2 text-left text-sm
        text-[#e9e9e9] hover:bg-[rgba(255,255,255,0.08)]
        transition-colors duration-150
      "
    >
      {item.label}
    </button>
  ))}
</div>
```

### Slide Animations

Add panel slide animations:

```css
/* Add to index.css */

/* File details panel slide-in */
@keyframes slideInRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

.details-panel {
  animation: slideInRight 0.3s ease-out;
}

/* Upload modal slide-down */
@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.upload-modal {
  animation: slideDown 0.2s ease-out;
}

/* Dropdown menu animation */
.dropdown-menu {
  transform: scale(0.96);
  opacity: 0;
  transition: transform 160ms ease-out, opacity 160ms ease-out;
}

.dropdown-menu.open {
  transform: scale(1);
  opacity: 1;
}
```

### Loading States

Add presearch-web loading animations:

```tsx
// Loading dots component
const LoadingDots = () => (
  <div className="flex gap-1">
    {[0, 1, 2].map((i) => (
      <div
        key={i}
        className="w-2 h-2 rounded-full bg-brand-500"
        style={{
          animation: 'bounce 1.4s infinite ease-in-out both',
          animationDelay: `${-0.32 + i * 0.16}s`
        }}
      />
    ))}
  </div>
);

// Skeleton with pulse (already exists - verify animation)
```

```css
@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}
```

### Upload Button (presearch-web style)

Update UploadButton with brand shadow:

```tsx
<button
  className="
    flex items-center gap-2
    px-4 py-3 rounded-xl
    bg-brand-500 text-white font-semibold
    shadow-[0_4px_14px_rgba(1,144,255,0.39)]
    hover:bg-brand-600
    hover:shadow-[0_6px_20px_rgba(1,144,255,0.45)]
    hover:-translate-y-0.5
    transition-all duration-200
    active:translate-y-0
  "
>
  <Plus className="w-5 h-5" />
  Upload
</button>
```

### Dark Mode Modal Overlay

Update modal overlays to match presearch-web:

```tsx
// Modal backdrop
<div className="fixed inset-0 bg-black/60 dark:bg-black/80 backdrop-blur-sm z-50">
  {/* Modal content */}
  <div
    className="
      bg-surface-primary dark:bg-[#323232]
      rounded-xl shadow-[0_25px_50px_rgba(0,0,0,0.25)]
      border border-transparent dark:border-[rgba(255,255,255,0.1)]
    "
  >
```

### Additional Implementation Checklist

- [ ] Add custom scrollbar to FileList and Sidebar
- [ ] Update FileCard hover with translateY effect
- [ ] Implement Dark Glass context menu
- [ ] Add slide animations to panels
- [ ] Add loading dots animation
- [ ] Update upload button styling
- [ ] Update modal overlays with backdrop-blur

---

*Last Updated: January 15, 2026*
