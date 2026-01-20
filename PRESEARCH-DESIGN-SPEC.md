# Presearch Design System Specification

> **Purpose**: Align PreSuite's visual design with Presearch's current design language
> **Extracted from**: presearch.com (January 2026)

---

## Color Palette

### Primary Colors

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--presearch-blue` | `#127FFF` | `rgb(18, 127, 255)` | Primary brand color, links, active states |
| `--presearch-blue-light` | `#2D8EFF` | `rgb(45, 142, 255)` | Hover states, secondary blue elements |

### Background Colors (Dark Theme)

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--bg-base` | `#202020` | `rgb(32, 32, 32)` | Main page background |
| `--bg-darker` | `#191919` | `rgb(25, 25, 25)` | Deeper backgrounds, overlays |
| `--bg-card` | `#2E2E2E` | `rgb(46, 46, 46)` | Cards, input fields, elevated surfaces |
| `--bg-panel` | `#212224` | `rgb(33, 34, 36)` | Settings panels, sidebars |
| `--bg-elevated` | `#383838` | `rgb(56, 56, 56)` | Elevated elements, hover states |

### Text Colors

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--text-primary` | `#FFFFFF` | `rgb(255, 255, 255)` | Primary text, headings |
| `--text-secondary` | `#E5E7EB` | `rgb(229, 231, 235)` | Body text, descriptions |
| `--text-muted` | `#6B7280` | `rgb(107, 114, 128)` | Helper text, disabled states |
| `--text-subtle` | `#4B5563` | `rgb(75, 85, 99)` | Very subtle text, timestamps |
| `--text-link` | `#C9C9C9` | `rgb(201, 201, 201)` | Footer links, tertiary text |

### Border & Divider Colors

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--border-default` | `#E5E7EB` | `rgb(229, 231, 235)` | Standard borders |
| `--border-subtle` | `#D1D5DB` | `rgb(209, 213, 219)` | Subtle dividers |

### State Colors

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `--toggle-active` | `#2D8EFF` | `rgb(45, 142, 255)` | Active toggle background |
| `--toggle-inactive` | `#6B7280` | `rgb(107, 114, 128)` | Inactive toggle background |
| `--error` | `#EF4444` | `rgb(239, 68, 68)` | Error states |

---

## Typography

### Font Stack

```css
font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif;
```

### Heading Styles

| Element | Size | Weight | Line Height | Color |
|---------|------|--------|-------------|-------|
| H1 | 30px | 700 (bold) | 36px | White |
| H2 | 36px | 600 (semibold) | 40px | White |
| H3 | 20px | 600 (semibold) | 28px | White |
| Body | 14px | 400 (regular) | 20px | `#E5E7EB` |
| Small/Helper | 12px | 400-600 | 16px | `#6B7280` |

### Section Headers (Settings)

```css
.section-header {
  font-size: 16px;
  font-weight: 600;
  color: #FFFFFF;
  margin-top: 24px;
  margin-bottom: 16px;
}
```

---

## Components

### Toggle Switches

**Dimensions:**
- Track: 48px × 24px
- Knob: 16-20px diameter
- Border-radius: 9999px (full pill)

**Active State:**
```css
.toggle-track-active {
  background-color: #2D8EFF;
  border-radius: 9999px;
}

.toggle-knob {
  width: 16px;
  height: 16px;
  background-color: #FFFFFF;
  border-radius: 9999px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
  /* Position: right side when active */
}
```

**Inactive State:**
```css
.toggle-track-inactive {
  background-color: #6B7280;
  border-radius: 9999px;
}

.toggle-knob {
  /* Same styles, position: left side when inactive */
}
```

### Dark/Light Mode Selector (Pill Toggle)

**Container:** Side-by-side pill buttons

```css
.theme-toggle-container {
  display: flex;
  gap: 0;
}

.theme-toggle-button {
  padding: 2px 8px;
  border: 1px solid #E5E7EB;
  border-radius: 9999px;
  font-size: 14px;
  cursor: pointer;
}

.theme-toggle-button.active {
  background-color: #E5E7EB;
  color: #2E2E2E;
}

.theme-toggle-button.inactive {
  background-color: transparent;
  color: #FFFFFF;
}
```

### Search Bar

**Container:**
```css
.search-container {
  height: 48px;
  border-radius: 9999px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}
```

**Input Field:**
```css
.search-input {
  height: 48px;
  background-color: #2E2E2E;
  border: none;
  padding: 0 12px;
  font-size: 14px;
  font-weight: 300;
  color: #FFFFFF;
}

.search-input::placeholder {
  color: #9CA3AF;
}
```

**Search Icon:**
```css
.search-icon {
  color: #127FFF;
  width: 20px;
  height: 20px;
}
```

### Buttons

**Primary Button (e.g., "Learn" badge):**
```css
.btn-primary {
  background-color: #127FFF;
  color: #FFFFFF;
  border-radius: 9999px;
  padding: 4px 12px;
  font-size: 14px;
  font-weight: 600;
}
```

**Menu/Hamburger Button:**
```css
.btn-menu {
  width: 48px;
  height: 48px;
  background-color: #2D8EFF;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}
```

**Text Size Selector Buttons:**
```css
.text-size-btn {
  padding: 4px 12px;
  border: 1px solid #E5E7EB;
  border-radius: 9999px;
  font-size: 14px;
}

.text-size-btn.active {
  background-color: #2D8EFF;
  color: #FFFFFF;
  border-color: #2D8EFF;
}
```

### Dropdown Buttons

```css
.dropdown-btn {
  background-color: transparent;
  color: #E5E7EB;
  border: 1px solid #E5E7EB;
  border-radius: 9999px;
  padding: 4px 12px;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.dropdown-btn svg {
  width: 12px;
  height: 12px;
}
```

### Settings List Items

```css
.settings-item {
  padding: 16px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.settings-item-title {
  font-size: 14px;
  font-weight: 500;
  color: #FFFFFF;
}

.settings-item-description {
  font-size: 12px;
  font-weight: 400;
  color: #9CA3AF;
  margin-top: 2px;
}
```

### External Link Items

```css
.external-link-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  cursor: pointer;
}

.external-link-icon {
  width: 20px;
  height: 20px;
  color: #E5E7EB;
}
```

### Footer Links

```css
.footer-link {
  font-size: 12px;
  color: #C9C9C9;
  text-decoration: underline;
}

.footer-link:hover {
  color: #2D8EFF;
}
```

---

## Spacing System

| Token | Value | Usage |
|-------|-------|-------|
| `--space-xs` | 4px | Tight spacing, icon gaps |
| `--space-sm` | 8px | Small gaps, button padding |
| `--space-md` | 16px | Standard padding, list items |
| `--space-lg` | 24px | Section spacing |
| `--space-xl` | 32px | Large section gaps |

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | 4px | Small elements |
| `--radius-md` | 8px | Cards, buttons, icons |
| `--radius-lg` | 12px | Larger cards |
| `--radius-full` | 9999px | Pills, toggles, search bar |

---

## Icons

- **Style**: Outlined stroke icons
- **Stroke width**: 1.5-2px
- **Default size**: 20px × 20px
- **Default color**: `#E5E7EB` (inherit text color)

**Common icons used:**
- Search (magnifying glass): `#127FFF` (blue)
- External link (arrow pointing up-right)
- Plus/Add button
- Chevron down (dropdowns)
- Sun/Moon (theme toggle)
- Menu/Hamburger (three lines)

---

## CSS Variables (Ready to Use)

```css
:root {
  /* Primary */
  --presearch-blue: #127FFF;
  --presearch-blue-light: #2D8EFF;

  /* Backgrounds */
  --bg-base: #202020;
  --bg-darker: #191919;
  --bg-card: #2E2E2E;
  --bg-panel: #212224;
  --bg-elevated: #383838;

  /* Text */
  --text-primary: #FFFFFF;
  --text-secondary: #E5E7EB;
  --text-muted: #6B7280;
  --text-subtle: #4B5563;

  /* Borders */
  --border-default: #E5E7EB;
  --border-subtle: #D1D5DB;

  /* Toggle */
  --toggle-active: #2D8EFF;
  --toggle-inactive: #6B7280;
  --toggle-knob: #FFFFFF;

  /* Spacing */
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;

  /* Typography */
  --font-sans: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  --text-xs: 12px;
  --text-sm: 14px;
  --text-base: 16px;
  --text-lg: 20px;
  --text-xl: 30px;
  --text-2xl: 36px;
}
```

---

## Tailwind CSS Classes (If Using Tailwind)

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        presearch: {
          blue: '#127FFF',
          'blue-light': '#2D8EFF',
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
      },
      borderRadius: {
        'full': '9999px',
      },
    },
  },
}
```

---

## Implementation Checklist for PreSuite

### High Priority
- [ ] Update background color from pure black to `#202020`
- [ ] Replace toggle switches with pill-style (48x24px)
- [ ] Apply Presearch blue (`#127FFF`) to active toggles
- [ ] Update search bar to rounded pill design
- [ ] Match section header typography (16px, semibold, white)

### Medium Priority
- [ ] Implement Dark/Light mode pill selector
- [ ] Add external link icons to navigation items
- [ ] Update dropdown button styling (rounded pill, border)
- [ ] Apply correct text colors (white primary, gray secondary)

### Low Priority
- [ ] Add footer link styling
- [ ] Implement hover states with `#2D8EFF`
- [ ] Add subtle shadows to elevated elements
- [ ] Match icon stroke weights and colors

---

## Quick Reference

| Element | Value |
|---------|-------|
| **Primary Blue** | `#127FFF` |
| **Hover Blue** | `#2D8EFF` |
| **Background** | `#202020` |
| **Card Background** | `#2E2E2E` |
| **Panel Background** | `#212224` |
| **Primary Text** | `#FFFFFF` |
| **Secondary Text** | `#E5E7EB` |
| **Muted Text** | `#6B7280` |
| **Border Radius (Pill)** | `9999px` |
| **Border Radius (Card)** | `8px` |
