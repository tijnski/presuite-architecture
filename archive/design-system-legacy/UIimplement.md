# PreSuite UI/UX Design Guide

A comprehensive design system to ensure visual coherence between PreSuite services and the Presearch brand identity.

---

## Brand Alignment with Presearch

### Official Presearch Brand Colors

Source: [Brandfetch - Presearch](https://brandfetch.com/presearch.com)

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Azure Radiance** | `#0190FF` | Primary accent color |
| **White** | `#FFFFFF` | Light theme background |
| **Mine Shaft** | `#323232` | Dark theme background |

### Current PreSuite Colors (To Be Updated)

The current PreSuite implementation uses slightly different blues:
- Current: `#3591FC`, `#2D8EFF`
- Official Presearch: `#0190FF`

**Recommendation:** Update primary colors across all services to use `#0190FF` for brand consistency.

---

## Unified Color System

### Primary Colors

```css
:root {
  /* Primary Blue - Presearch Brand */
  --color-primary-50: #E6F4FF;    /* Lightest tint */
  --color-primary-100: #BAE0FF;   /* Light tint */
  --color-primary-200: #8ECAFF;   /* Lighter */
  --color-primary-300: #5CB3FF;   /* Light */
  --color-primary-400: #2E9EFF;   /* Medium light */
  --color-primary-500: #0190FF;   /* Main brand color (Presearch Azure) */
  --color-primary-600: #0177D6;   /* Medium dark */
  --color-primary-700: #015EAD;   /* Dark */
  --color-primary-800: #014584;   /* Darker */
  --color-primary-900: #012C5B;   /* Darkest */
}
```

### Neutral Colors

```css
:root {
  /* Light Mode Neutrals */
  --color-white: #FFFFFF;
  --color-gray-50: #FAFBFC;
  --color-gray-100: #F4F5F7;
  --color-gray-200: #E8EAED;
  --color-gray-300: #D1D5DB;
  --color-gray-400: #9CA3AF;
  --color-gray-500: #6B7280;
  --color-gray-600: #4B5563;
  --color-gray-700: #374151;
  --color-gray-800: #1F2937;
  --color-gray-900: #111827;

  /* Dark Mode Neutrals */
  --color-dark-50: #3A3A3A;
  --color-dark-100: #323232;   /* Mine Shaft - Presearch Dark */
  --color-dark-200: #2A2A2A;
  --color-dark-300: #242424;
  --color-dark-400: #1E1E1E;
  --color-dark-500: #181818;
  --color-dark-600: #121212;
  --color-dark-700: #0F0F0F;
  --color-dark-800: #0A0A0A;
  --color-dark-900: #000000;
}
```

### Semantic Colors

```css
:root {
  /* Status Colors */
  --color-success: #10B981;      /* Green - Emerald 500 */
  --color-success-light: #D1FAE5;
  --color-success-dark: #059669;

  --color-warning: #F59E0B;      /* Amber 500 */
  --color-warning-light: #FEF3C7;
  --color-warning-dark: #D97706;

  --color-error: #EF4444;        /* Red 500 */
  --color-error-light: #FEE2E2;
  --color-error-dark: #DC2626;

  --color-info: #0190FF;         /* Primary Blue */
  --color-info-light: #E6F4FF;
  --color-info-dark: #0177D6;
}
```

### Accent Colors (For Charts, Tags, Badges)

```css
:root {
  --color-purple: #8B5CF6;
  --color-pink: #EC4899;
  --color-orange: #F97316;
  --color-teal: #14B8A6;
  --color-indigo: #6366F1;
  --color-cyan: #06B6D4;
}
```

---

## Typography

### Font Stack

```css
:root {
  /* Primary font - System UI for performance */
  --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
               'Helvetica Neue', Arial, sans-serif;

  /* Monospace for code */
  --font-mono: 'SF Mono', 'Fira Code', 'Fira Mono', Menlo, Monaco,
               Consolas, 'Liberation Mono', monospace;
}
```

### Font Sizes

```css
:root {
  --text-xs: 0.75rem;      /* 12px */
  --text-sm: 0.875rem;     /* 14px */
  --text-base: 1rem;       /* 16px */
  --text-lg: 1.125rem;     /* 18px */
  --text-xl: 1.25rem;      /* 20px */
  --text-2xl: 1.5rem;      /* 24px */
  --text-3xl: 1.875rem;    /* 30px */
  --text-4xl: 2.25rem;     /* 36px */
  --text-5xl: 3rem;        /* 48px */
}
```

### Font Weights

```css
:root {
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;
}
```

### Line Heights

```css
:root {
  --leading-tight: 1.25;
  --leading-snug: 1.375;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
  --leading-loose: 2;
}
```

### Typography Usage

| Element | Size | Weight | Color (Light) | Color (Dark) |
|---------|------|--------|---------------|--------------|
| H1 | 2.25rem (36px) | 700 | gray-900 | white |
| H2 | 1.875rem (30px) | 700 | gray-900 | white |
| H3 | 1.5rem (24px) | 600 | gray-900 | white |
| H4 | 1.25rem (20px) | 600 | gray-800 | gray-100 |
| Body | 1rem (16px) | 400 | gray-700 | gray-300 |
| Small | 0.875rem (14px) | 400 | gray-600 | gray-400 |
| Caption | 0.75rem (12px) | 400 | gray-500 | gray-500 |

---

## Spacing System

Use a consistent 4px base unit for all spacing.

```css
:root {
  --space-0: 0;
  --space-1: 0.25rem;    /* 4px */
  --space-2: 0.5rem;     /* 8px */
  --space-3: 0.75rem;    /* 12px */
  --space-4: 1rem;       /* 16px */
  --space-5: 1.25rem;    /* 20px */
  --space-6: 1.5rem;     /* 24px */
  --space-8: 2rem;       /* 32px */
  --space-10: 2.5rem;    /* 40px */
  --space-12: 3rem;      /* 48px */
  --space-16: 4rem;      /* 64px */
  --space-20: 5rem;      /* 80px */
  --space-24: 6rem;      /* 96px */
}
```

---

## Border Radius

```css
:root {
  --radius-none: 0;
  --radius-sm: 0.25rem;    /* 4px - Subtle */
  --radius-md: 0.375rem;   /* 6px - Default */
  --radius-lg: 0.5rem;     /* 8px - Cards */
  --radius-xl: 0.75rem;    /* 12px - Modals */
  --radius-2xl: 1rem;      /* 16px - Large cards */
  --radius-3xl: 1.5rem;    /* 24px - Hero sections */
  --radius-full: 9999px;   /* Pills, avatars */
}
```

---

## Shadows

```css
:root {
  /* Light Mode Shadows */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
               0 2px 4px -1px rgba(0, 0, 0, 0.06);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1),
               0 4px 6px -2px rgba(0, 0, 0, 0.05);
  --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1),
               0 10px 10px -5px rgba(0, 0, 0, 0.04);
  --shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);

  /* Dark Mode Shadows */
  --shadow-dark-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.3);
  --shadow-dark-md: 0 4px 6px -1px rgba(0, 0, 0, 0.4);
  --shadow-dark-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.5);

  /* Colored Shadows (for buttons, cards) */
  --shadow-primary: 0 4px 14px 0 rgba(1, 144, 255, 0.39);
}
```

---

## Glassmorphism (PreSuite Signature Style)

PreSuite uses glassmorphism for cards and modals to create a modern, layered look.

### Light Mode Glass

```css
.glass-light {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.07);
}
```

### Dark Mode Glass

```css
.glass-dark {
  background: rgba(50, 50, 50, 0.8);  /* Using Mine Shaft */
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
}
```

### Glass Card Component

```css
.glass-card {
  border-radius: var(--radius-xl);
  padding: var(--space-6);
  transition: all 0.3s ease;
}

.glass-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 40px 0 rgba(1, 144, 255, 0.15);
}
```

---

## Component Styles

### Buttons

#### Primary Button

```css
.btn-primary {
  background: var(--color-primary-500);  /* #0190FF */
  color: white;
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-lg);
  font-weight: var(--font-medium);
  font-size: var(--text-sm);
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: var(--shadow-primary);
}

.btn-primary:hover {
  background: var(--color-primary-600);  /* #0177D6 */
  transform: translateY(-1px);
  box-shadow: 0 6px 20px 0 rgba(1, 144, 255, 0.45);
}

.btn-primary:active {
  transform: translateY(0);
}

.btn-primary:disabled {
  background: var(--color-gray-400);
  cursor: not-allowed;
  box-shadow: none;
}
```

#### Secondary Button

```css
.btn-secondary {
  background: transparent;
  color: var(--color-primary-500);
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-lg);
  font-weight: var(--font-medium);
  font-size: var(--text-sm);
  border: 1px solid var(--color-primary-500);
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: var(--color-primary-50);
}
```

#### Ghost Button

```css
.btn-ghost {
  background: transparent;
  color: var(--color-gray-700);
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-lg);
  font-weight: var(--font-medium);
  font-size: var(--text-sm);
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-ghost:hover {
  background: var(--color-gray-100);
}
```

#### Button Sizes

| Size | Padding | Font Size | Height |
|------|---------|-----------|--------|
| Small | 8px 16px | 12px | 32px |
| Medium | 12px 24px | 14px | 40px |
| Large | 16px 32px | 16px | 48px |

### Input Fields

```css
.input {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  font-size: var(--text-base);
  border: 1px solid var(--color-gray-300);
  border-radius: var(--radius-lg);
  background: var(--color-white);
  color: var(--color-gray-900);
  transition: all 0.2s ease;
}

.input:focus {
  outline: none;
  border-color: var(--color-primary-500);
  box-shadow: 0 0 0 3px rgba(1, 144, 255, 0.1);
}

.input:disabled {
  background: var(--color-gray-100);
  cursor: not-allowed;
}

/* Dark mode */
.dark .input {
  background: var(--color-dark-300);
  border-color: var(--color-dark-100);
  color: var(--color-white);
}
```

### Cards

```css
.card {
  background: var(--color-white);
  border-radius: var(--radius-xl);
  padding: var(--space-6);
  box-shadow: var(--shadow-md);
  border: 1px solid var(--color-gray-200);
  transition: all 0.3s ease;
}

.card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

/* Dark mode */
.dark .card {
  background: var(--color-dark-200);
  border-color: var(--color-dark-100);
}
```

### Navigation

```css
.nav-item {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-lg);
  color: var(--color-gray-600);
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all 0.2s ease;
}

.nav-item:hover {
  background: var(--color-gray-100);
  color: var(--color-gray-900);
}

.nav-item.active {
  background: var(--color-primary-50);
  color: var(--color-primary-600);
}

/* Dark mode */
.dark .nav-item {
  color: var(--color-gray-400);
}

.dark .nav-item:hover {
  background: var(--color-dark-300);
  color: var(--color-white);
}

.dark .nav-item.active {
  background: rgba(1, 144, 255, 0.15);
  color: var(--color-primary-400);
}
```

### Badges

```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: var(--space-1) var(--space-2);
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  border-radius: var(--radius-full);
}

.badge-primary {
  background: var(--color-primary-100);
  color: var(--color-primary-700);
}

.badge-success {
  background: var(--color-success-light);
  color: var(--color-success-dark);
}

.badge-warning {
  background: var(--color-warning-light);
  color: var(--color-warning-dark);
}

.badge-error {
  background: var(--color-error-light);
  color: var(--color-error-dark);
}
```

---

## Iconography

### Icon Library

Use **Lucide React** consistently across all PreSuite services for icon consistency.

```bash
npm install lucide-react
```

### Icon Sizes

| Size | Pixels | Usage |
|------|--------|-------|
| xs | 14px | Inline with small text |
| sm | 16px | Buttons, badges |
| md | 20px | Default, navigation |
| lg | 24px | Section headers |
| xl | 32px | Feature highlights |
| 2xl | 48px | Hero sections, empty states |

### Icon Colors

- **Default:** `currentColor` (inherits text color)
- **Primary actions:** `var(--color-primary-500)`
- **Success:** `var(--color-success)`
- **Warning:** `var(--color-warning)`
- **Error:** `var(--color-error)`
- **Muted:** `var(--color-gray-400)`

---

## Dark Mode Implementation

### CSS Variables Approach

```css
/* Light mode (default) */
:root {
  --bg-primary: var(--color-white);
  --bg-secondary: var(--color-gray-50);
  --bg-tertiary: var(--color-gray-100);
  --text-primary: var(--color-gray-900);
  --text-secondary: var(--color-gray-600);
  --text-tertiary: var(--color-gray-500);
  --border-color: var(--color-gray-200);
}

/* Dark mode */
.dark {
  --bg-primary: var(--color-dark-400);
  --bg-secondary: var(--color-dark-300);
  --bg-tertiary: var(--color-dark-200);
  --text-primary: var(--color-white);
  --text-secondary: var(--color-gray-300);
  --text-tertiary: var(--color-gray-400);
  --border-color: var(--color-dark-100);
}
```

### Toggle Implementation

```jsx
// React hook for dark mode
const useDarkMode = () => {
  const [isDark, setIsDark] = useState(() => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('darkMode') === 'true' ||
        window.matchMedia('(prefers-color-scheme: dark)').matches;
    }
    return false;
  });

  useEffect(() => {
    document.documentElement.classList.toggle('dark', isDark);
    localStorage.setItem('darkMode', isDark);
  }, [isDark]);

  return [isDark, setIsDark];
};
```

---

## Animations & Transitions

### Standard Transitions

```css
:root {
  --transition-fast: 150ms ease;
  --transition-base: 200ms ease;
  --transition-slow: 300ms ease;
  --transition-slower: 500ms ease;
}
```

### Common Animation Classes

```css
/* Fade in */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.animate-fadeIn {
  animation: fadeIn var(--transition-base);
}

/* Slide up */
@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slideUp {
  animation: slideUp var(--transition-slow);
}

/* Scale in */
@keyframes scaleIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.animate-scaleIn {
  animation: scaleIn var(--transition-base);
}
```

### Hover States

All interactive elements should have smooth hover transitions:

```css
.interactive {
  transition:
    background-color var(--transition-fast),
    border-color var(--transition-fast),
    color var(--transition-fast),
    transform var(--transition-fast),
    box-shadow var(--transition-base);
}
```

---

## Responsive Breakpoints

```css
:root {
  --screen-sm: 640px;
  --screen-md: 768px;
  --screen-lg: 1024px;
  --screen-xl: 1280px;
  --screen-2xl: 1536px;
}

/* Tailwind-style media queries */
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
@media (min-width: 1536px) { /* 2xl */ }
```

---

## Service-Specific Branding

While all services share the core design system, each has a subtle accent for identification:

| Service | Accent Color | Icon |
|---------|--------------|------|
| PreSuite Hub | `#0190FF` (Primary Blue) | Grid/Dashboard |
| PreMail | `#0190FF` + Mail icon tint | Mail |
| PreDrive | `#0190FF` + Cloud icon tint | HardDrive |
| PreOffice | `#0190FF` + Document icon tint | FileText |

All services use the same primary blue (`#0190FF`) to maintain brand unity.

---

## Implementation Checklist

### Colors to Update

- [ ] PreSuite Hub: Change `#3591FC` → `#0190FF`
- [ ] PreSuite Hub: Change `#2D8EFF` → `#0177D6` (hover state)
- [ ] PreDrive: Verify primary color matches `#0190FF`
- [ ] PreMail: Verify primary color matches `#0190FF`
- [ ] PreOffice: Change `#2D8EFF` → `#0190FF` in design tokens

### Component Updates

- [ ] Unify button styles across all services
- [ ] Standardize card shadows and borders
- [ ] Consistent input field styling
- [ ] Unified navigation component
- [ ] Standard modal/dialog styling
- [ ] Consistent toast/notification design

### Typography Updates

- [ ] Standardize font stack across services
- [ ] Consistent heading sizes
- [ ] Unified text color tokens

### Dark Mode

- [ ] Ensure all services use `#323232` (Mine Shaft) for dark backgrounds
- [ ] Test glassmorphism in dark mode
- [ ] Verify contrast ratios meet WCAG AA

---

## Accessibility Guidelines

### Color Contrast

- All text must meet WCAG AA contrast ratio (4.5:1 for normal text, 3:1 for large text)
- `#0190FF` on white background: **4.54:1** (passes AA)
- Use darker shades for small text on light backgrounds

### Focus States

```css
*:focus-visible {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
}
```

### Interactive Elements

- Minimum touch target: 44x44px
- Clear hover/active states
- Keyboard navigable

---

## Assets & Resources

### Logo Files

- Primary logo: `/assets/presearch-logo-borderless-blue.svg`
- White logo: `/assets/presearch-logo-border-white-transparent.svg`
- PrePanda mascot: `/assets/PandaSVG.svg`

### Brand Resources

- [Brandfetch - Presearch Assets](https://brandfetch.com/presearch.com)
- [Logotyp.us - Presearch Logo](https://logotyp.us/logo/presearch/)

---

*Last Updated: January 15, 2026*
*Based on Presearch official brand guidelines*
