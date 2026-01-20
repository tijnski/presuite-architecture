# PreSuite Design System

> **Purpose**: Unified design system for all PreSuite applications
> **Source of Truth**: presearch-web repository (tailwind.config.js)
> **Last Updated**: January 20, 2026

---

## Quick Reference

| Element | Value | Usage |
|---------|-------|-------|
| Primary Blue | `#2D8EFF` | Brand color, links, active states |
| Button Blue | `#127FFF` | Primary buttons, CTAs |
| Primary UI | `#3591FC` | UI accents, tabs |
| Background (Dark) | `#191919` | Main dark background |
| Card/Surface | `#2E2E2E` | Cards, inputs, elevated surfaces |
| Panel | `#212224` | Side panels, settings, modals |
| Text Primary | `#FFFFFF` | Headings, important text |
| Text Secondary | `#E5E7EB` | Body text |
| Text Muted | `#6B7280` | Helper text, disabled |
| Border | `#383838` | Card borders, dividers |

---

## Color Palette

### Primary Colors (from presearch-web)

```css
:root {
  /* Presearch Brand Blues */
  --presearch-default: #2D8EFF;     /* Main brand blue */
  --presearch-alternative: #127FFF;  /* Buttons, CTAs */
  --presearch-dark: #80BAFF;         /* Dark mode accent */
  --background-presearch: #0079DA;   /* Blue backgrounds */

  /* Primary Scale (UI elements) */
  --primary-100: #EBF4FF;
  --primary-200: #CDE4FE;
  --primary-300: #AED3FE;
  --primary-400: #72B2FD;
  --primary-500: #3591FC;  /* Primary UI color */
  --primary-600: #3083E3;  /* Hover state */
  --primary-700: #205797;
  --primary-800: #184171;
  --primary-900: #102C4C;
}
```

### Dark Mode Backgrounds

```css
:root {
  /* NEUTRAL GRAYS - NOT blue-tinted */
  --dark-900: #191919;  /* Darkest - main background */
  --dark-800: #1e1e1e;  /* Page background */
  --dark-700: #2e2e2e;  /* Elevated surfaces */
  --dark-600: #383838;  /* Higher elevation */
  --dark-500: #5f5f5f;  /* Muted elements */

  /* Background Variants */
  --background-dark100: #2E2E2E;
  --background-dark200: #2e2e2e;
  --background-dark300: #383838;
  --background-dark400: #212224;
  --background-dark500: #191919;
}
```

### Light Mode Backgrounds

```css
:root {
  --background-light100: #F4F4F4;
  --background-light200: #EDF1F4;
  --background-light300: #E5E5E5;
}
```

### Text Colors

```css
:root {
  --text-primary: #FFFFFF;    /* Headings, important text */
  --text-secondary: #E5E7EB;  /* Body text */
  --text-muted: #6B7280;      /* Helper text, disabled */
  --text-subtle: #4B5563;     /* Very subtle text */
  --text-link: #C9C9C9;       /* Footer links */
}
```

### Status Colors

```css
:root {
  --success: #10B981;
  --success-light: #D1FAE5;
  --success-dark: #059669;

  --warning: #F59E0B;
  --warning-light: #FEF3C7;
  --warning-dark: #D97706;

  --error: #EF4444;
  --error-light: #FEE2E2;
  --error-dark: #DC2626;

  --info: #3B82F6;
}
```

### Borders & Dividers

```css
:root {
  --border-default: #383838;
  --border-subtle: #2E2E2E;
  --border-light: #E5E7EB;
}
```

---

## Typography

### Font Stack

```css
/* Primary - System UI for performance */
font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, "Noto Sans", sans-serif;

/* Alternative - ProximaNova (if available) */
font-family: 'ProximaNova', Inter, system-ui, -apple-system, Segoe UI,
             Roboto, Helvetica, Arial;

/* Monospace */
font-family: 'SF Mono', 'Fira Code', Menlo, Monaco, Consolas, monospace;
```

### Font Sizes

| Token | Size | Line Height | Usage |
|-------|------|-------------|-------|
| `--text-xs` | 12px | 16px | Captions, badges |
| `--text-sm` | 14px | 20px | Body small, buttons |
| `--text-base` | 16px | 24px | Body text |
| `--text-lg` | 20px | 28px | Section headers |
| `--text-xl` | 24px | 32px | H3 |
| `--text-2xl` | 30px | 36px | H2 |
| `--text-3xl` | 36px | 40px | H1 |

### Typography Usage

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| H1 | 30-36px | 700 | `#FFFFFF` |
| H2 | 24-30px | 600 | `#FFFFFF` |
| H3 | 20px | 600 | `#FFFFFF` |
| Section Header | 16px | 600 | `#FFFFFF` |
| Body | 14px | 400 | `#E5E7EB` |
| Small/Helper | 12px | 400 | `#6B7280` |

---

## Spacing System

```css
:root {
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
  --space-2xl: 48px;
  --space-3xl: 64px;
}
```

---

## Border Radius

```css
:root {
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-full: 9999px;  /* Pills, toggles */
}
```

---

## Shadows

```css
:root {
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.2);
  --shadow-md: 0 2px 8px rgba(0, 0, 0, 0.15);
  --shadow-lg: 0 4px 16px rgba(0, 0, 0, 0.2);
  --shadow-xl: 0 8px 32px rgba(0, 0, 0, 0.3);

  /* Colored shadow */
  --shadow-primary: 0 4px 14px rgba(45, 142, 255, 0.25);
}
```

---

## Components

### Toggle Switch (48x24px)

Standard Presearch toggle switch:

```css
.toggle {
  width: 48px;
  height: 24px;
  border-radius: 9999px;
  background-color: #6B7280;  /* Inactive */
  cursor: pointer;
  transition: background-color 150ms;
}

.toggle.active {
  background-color: #2D8EFF;  /* Active */
}

.toggle-knob {
  width: 16px;
  height: 16px;
  border-radius: 9999px;
  background-color: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
  transition: left 150ms;
  /* left: 4px (off) or 28px (on) */
}
```

### Primary Button

```css
.btn-primary {
  background-color: #127FFF;
  color: white;
  padding: 8px 16px;
  border-radius: 9999px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 150ms;
}

.btn-primary:hover {
  opacity: 0.9;
}
```

### Secondary Button (Outlined)

```css
.btn-secondary {
  background-color: transparent;
  color: #E5E7EB;
  padding: 8px 16px;
  border: 1px solid #E5E7EB;
  border-radius: 9999px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: opacity 150ms;
}

.btn-secondary:hover {
  opacity: 0.7;
}
```

### Card Component

```css
.card {
  background-color: #2E2E2E;
  border: 1px solid #383838;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
```

### Input Field

```css
.input {
  width: 100%;
  padding: 12px 16px;
  font-size: 14px;
  background-color: #2E2E2E;
  border: 1px solid #383838;
  border-radius: 8px;
  color: #FFFFFF;
  transition: border-color 150ms;
}

.input:focus {
  outline: none;
  border-color: #3591FC;
  box-shadow: 0 0 0 3px rgba(53, 145, 252, 0.1);
}

.input::placeholder {
  color: #6B7280;
}
```

### Search Bar (Pill Style)

```css
.search-bar {
  display: flex;
  align-items: center;
  height: 48px;
  background-color: #2E2E2E;
  border-radius: 9999px;
  padding: 0 16px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.search-icon {
  color: #127FFF;
  width: 20px;
  height: 20px;
}

.search-input {
  background: transparent;
  border: none;
  color: #FFFFFF;
  font-size: 14px;
  flex: 1;
  padding: 0 12px;
}
```

### Settings Panel (Side Slide-Out)

```css
.settings-panel {
  position: fixed;
  top: 0;
  right: 0;
  height: 100%;
  width: 400px;
  background-color: #212224;
  z-index: 50;
  overflow-y: auto;
}

.settings-header {
  position: sticky;
  top: 0;
  padding: 16px;
  background-color: #212224;
  border-bottom: 1px solid #383838;
}

.settings-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
}

.settings-item-title {
  font-size: 14px;
  font-weight: 500;
  color: #FFFFFF;
}

.settings-item-description {
  font-size: 12px;
  color: #9CA3AF;
  margin-top: 2px;
}
```

---

## Dark Glass Theme (Optional)

For AI/Chat interfaces (PreGPT):

```css
[data-theme='dark-glass'] {
  --dg-border: rgba(255, 255, 255, 0.12);
  --dg-bg: rgba(13, 15, 18, 0.55);
  --dg-text: #e9e9e9;
  --dg-placeholder: #838383;
}

.dg-panel {
  background: var(--dg-bg);
  border: 1px solid var(--dg-border);
  border-radius: 10px;
  backdrop-filter: blur(16px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
}
```

**When to use glassmorphism:**
- AI/Chat interfaces
- Floating overlays/tooltips

**When NOT to use:**
- Login/Register modals
- Search bar
- Standard cards
- Settings panel

---

## Hover Effects

Use **subtle opacity changes**, not scale transforms:

```css
/* CORRECT */
.interactive:hover {
  opacity: 0.7;
  transition: opacity 150ms;
}

/* AVOID */
.interactive:hover {
  transform: scale(1.05);  /* Too aggressive */
}
```

---

## Custom Scrollbar

```css
.custom-scrollbar {
  scrollbar-color: #2D8EFF transparent;
  scrollbar-width: thin;
}

.custom-scrollbar::-webkit-scrollbar {
  height: 4px;
  width: 4px;
  background: transparent;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 5px;
  background-color: #2D8EFF;
}
```

---

## Animations

### Standard Transitions

```css
:root {
  --transition-fast: 150ms ease;
  --transition-base: 200ms ease;
  --transition-slow: 300ms ease;
}
```

### Slide Animations

```css
@keyframes slideInRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@keyframes slideDown {
  from { transform: translateY(-10px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
```

---

## Responsive Breakpoints

```css
/* Standard breakpoints */
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
@media (min-width: 1536px) { /* 2xl */ }

/* Additional (from presearch-web) */
@media (min-width: 370px) { /* 3xs */ }
@media (min-width: 440px) { /* 2xs */ }
@media (min-width: 560px) { /* xs */ }
```

---

## Iconography

- **Library**: Lucide React
- **Default size**: 20px
- **Stroke width**: 1.5-2px
- **Default color**: `currentColor` (inherits text)
- **Primary actions**: `#127FFF`

---

## Tailwind Config Extension

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        presearch: {
          DEFAULT: '#2D8EFF',
          blue: '#127FFF',
          light: '#80BAFF',
        },
        background: {
          base: '#202020',
          darker: '#191919',
          card: '#2E2E2E',
          panel: '#212224',
          elevated: '#383838',
        },
        text: {
          primary: '#FFFFFF',
          secondary: '#E5E7EB',
          muted: '#6B7280',
          subtle: '#4B5563',
        },
        toggle: {
          active: '#2D8EFF',
          inactive: '#6B7280',
        },
        border: {
          DEFAULT: '#383838',
          subtle: '#2E2E2E',
        },
      },
      borderRadius: {
        'full': '9999px',
      },
    },
  },
}
```

---

## Implementation Status

| App | Status | Notes |
|-----|--------|-------|
| PreSuite Hub | Applied | Full implementation |
| PreMail | Applied | CSS vars, Tailwind config |
| PreDrive | Partial | Apply to web app |
| PreOffice | Partial | Landing page only |
| PreSocial | Pending | Lemmy integration |

---

## Implementation Checklist

When applying to a PreSuite app:

### Required
- [ ] Add CSS variables to main stylesheet
- [ ] Set dark background to `#191919` (not blue-tinted)
- [ ] Update primary buttons to use `#127FFF`
- [ ] Replace toggles with 48x24px pill style
- [ ] Use correct text colors (white primary, gray secondary)
- [ ] Use opacity hover effects (not scale transforms)

### Recommended
- [ ] Add settings panel (right slide-out, 400px)
- [ ] Use card component for elevated surfaces
- [ ] Match search bar styling (rounded pill, blue icon)
- [ ] Use consistent spacing (16px base)

---

## Related Documentation

- [architecture/](architecture/README.md) - System architecture
- [PRESUITE.md](PRESUITE.md) - PreSuite Hub documentation
- [PREMAIL.md](PREMAIL.md) - PreMail documentation
- [PREDRIVE.md](PREDRIVE.md) - PreDrive documentation

---

*Consolidated from: UIimplement.md, PRESEARCH-DESIGN-SYSTEM.md, PRESUITE-DESIGN-SYSTEM.md, PRESUITE_STYLING_GUIDE.md, UIPatterns-PresearchWeb.md*
