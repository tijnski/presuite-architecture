# PreOffice UI Refinement Plan

> **Objective:** Align PreOffice's visual design with PreSuite Hub's professional aesthetic
> **Status:** Implemented
> **Created:** 2026-01-23
> **Completed:** 2026-01-23

---

## Executive Summary

PreOffice's current UI uses oversized emoji icons, bright pastel colors, and excessive spacing that creates an unprofessional "childish" appearance. This plan details the changes needed to match PreSuite Hub's refined, modern design system.

---

## Current Problems

### 1. Emoji Icons Instead of SVG Icons
**Location:** `/branding/static/index.html` (lines 1238-1284)
```html
<!-- Current - Childish emoji -->
<div class="app-icon writer">📝</div>
<div class="app-icon calc">📊</div>
<div class="app-icon impress">📽️</div>
<div class="app-icon draw">🎨</div>
<div class="app-icon upload">📤</div>
```

**Impact:** Emoji render inconsistently across platforms and look unprofessional.

### 2. Bright Pastel Background Colors
**Location:** `/branding/static/index.html` (lines 372-375)
```css
.app-icon.writer { background: var(--presearch-blue-light); }  /* #2D8EFF */
.app-icon.calc { background: #D1FAE5; }                        /* Mint green */
.app-icon.impress { background: #FEF3C7; }                     /* Pastel yellow */
.app-icon.draw { background: #FCE7F3; }                        /* Pastel pink */
```

**Impact:** Clashing colors, no cohesive brand identity.

### 3. Oversized Typography & Spacing
**Location:** `/branding/static/index.html` (lines 288-340)
```css
.hero { padding: 8rem 2rem 4rem; }           /* Too much vertical space */
.hero h1 { font-size: 2.5rem; }              /* Too large */
.apps-section h2 { font-size: 2rem; }        /* Disproportionate */
```

**Impact:** Bloated layout, lacks professional density.

### 4. Over-Rounded Corners
```css
.modal-content { border-radius: 16px; }
.app-card { border-radius: 12px; }
.feature { border-radius: 12px; }
```

**Impact:** Creates a playful "bubble" aesthetic instead of business-grade UI.

---

## PreSuite Design Reference

### Color Palette (from PreSuite `/src/index.css`)
```css
/* Primary Colors */
--presearch-blue: #127FFF;          /* Main brand color */
--presearch-blue-light: #2D8EFF;    /* Hover state */
--presearch-blue-tint: #EBF4FF;     /* Light background */

/* Dark Theme (default) */
--bg-darker: #191919;               /* Deepest background */
--bg-base: #202020;                 /* Page background */
--bg-card: #2E2E2E;                 /* Card backgrounds */
--bg-elevated: #383838;             /* Elevated surfaces */

/* Text Colors */
--text-primary: #FFFFFF;
--text-secondary: #E5E7EB;
--text-muted: #6B7280;

/* Borders */
--border-default: #383838;
--border-subtle: rgba(255, 255, 255, 0.1);
```

### Typography (from PreSuite)
```css
font-family: 'ProximaNova', Inter, system-ui, -apple-system, sans-serif;
--text-xs: 12px;
--text-sm: 14px;
--text-base: 16px;
--text-lg: 20px;
--text-xl: 30px;
```

### Icon Library
- **Library:** Lucide (SVG icons)
- **Package:** `lucide-react` or use CDN for static HTML
- **Size:** 28px (w-7 h-7) for app icons
- **Colors:** Monochrome with brand accent

### Spacing Scale
```css
--space-xs: 4px;
--space-sm: 8px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
```

### Border Radius
```css
--radius-sm: 4px;
--radius-md: 8px;
--radius-lg: 12px;     /* Cards only */
--radius-full: 9999px; /* Primary buttons */
```

---

## Implementation Tasks

### Phase 1: Replace Emoji with Lucide Icons

**Files to Modify:**
- `/branding/static/index.html`

**Changes:**

1. Add Lucide icons CDN in `<head>`:
```html
<script src="https://unpkg.com/lucide@latest"></script>
```

2. Replace emoji app icons with SVG:
```html
<!-- Writer - FileText icon -->
<div class="app-icon writer">
  <i data-lucide="file-text"></i>
</div>

<!-- Calc - Table icon -->
<div class="app-icon calc">
  <i data-lucide="table"></i>
</div>

<!-- Impress - Presentation icon -->
<div class="app-icon impress">
  <i data-lucide="presentation"></i>
</div>

<!-- Draw - Pen Tool icon -->
<div class="app-icon draw">
  <i data-lucide="pen-tool"></i>
</div>

<!-- Upload - Upload icon -->
<div class="app-icon upload">
  <i data-lucide="upload"></i>
</div>
```

3. Replace feature icons:
```html
<div class="feature-icon"><i data-lucide="lock"></i></div>
<div class="feature-icon"><i data-lucide="globe"></i></div>
<div class="feature-icon"><i data-lucide="refresh-cw"></i></div>
<div class="feature-icon"><i data-lucide="folder"></i></div>
```

4. Initialize Lucide at end of body:
```html
<script>lucide.createIcons();</script>
```

---

### Phase 2: Implement Unified Color System

**Update CSS Variables:**
```css
:root {
  /* Brand Colors */
  --presearch-blue: #127FFF;
  --presearch-blue-hover: #2D8EFF;
  --presearch-blue-tint: #EBF4FF;

  /* Dark Theme (default) */
  --bg-darker: #191919;
  --bg-base: #202020;
  --bg-card: #2E2E2E;
  --bg-elevated: #383838;

  /* Text */
  --text-primary: #FFFFFF;
  --text-secondary: #E5E7EB;
  --text-muted: #6B7280;

  /* Borders */
  --border-default: #383838;
  --border-subtle: rgba(255, 255, 255, 0.1);

  /* Shadows */
  --shadow-card: 0 2px 8px rgba(0, 0, 0, 0.2);
  --shadow-elevated: 0 8px 32px rgba(0, 0, 0, 0.3);
}
```

**Update App Icon Backgrounds:**
```css
/* All app icons use unified dark card background */
.app-icon {
  width: 64px;
  height: 64px;
  background-color: var(--bg-card);
  border: 1px solid var(--border-default);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: var(--shadow-card);
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.app-icon:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-elevated);
}

.app-icon svg {
  width: 28px;
  height: 28px;
  stroke-width: 1.5;
}

/* Color-coded icon strokes */
.app-icon.writer svg { color: #127FFF; }     /* Blue - Documents */
.app-icon.calc svg { color: #10B981; }       /* Green - Spreadsheets */
.app-icon.impress svg { color: #F59E0B; }    /* Amber - Presentations */
.app-icon.draw svg { color: #EC4899; }       /* Pink - Drawing */
.app-icon.upload svg { color: #127FFF; }     /* Blue - Upload */
```

---

### Phase 3: Typography & Spacing Refinement

**Update Typography:**
```css
/* Add ProximaNova font */
@font-face {
  font-family: 'ProximaNova';
  src: url('/assets/ProximaNova-Regular.woff2') format('woff2');
  font-weight: normal;
  font-style: normal;
}

body {
  font-family: 'ProximaNova', Inter, system-ui, -apple-system, sans-serif;
  background-color: var(--bg-darker);
  color: var(--text-primary);
}

/* Refined typography scale */
.hero h1 {
  font-size: 2rem;           /* Reduced from 2.5rem */
  font-weight: 600;
  letter-spacing: -0.025em;
  margin-bottom: 1rem;
}

.section-title {
  font-size: 1.5rem;         /* Reduced from 2rem */
  font-weight: 600;
  margin-bottom: 2rem;       /* Reduced from 3rem */
}

.app-card h3 {
  font-size: 1rem;           /* Reduced from 1.25rem */
  font-weight: 600;
}

.app-card p {
  font-size: 0.875rem;       /* 14px */
  color: var(--text-muted);
}
```

**Update Spacing:**
```css
.hero {
  padding: 4rem 2rem 3rem;   /* Reduced from 8rem 2rem 4rem */
}

.apps-section,
.features-section {
  padding: 3rem 2rem;        /* Reduced from 4rem */
}

.app-card {
  padding: 1.5rem;           /* Reduced from 2rem */
}

.modal-content {
  padding: 1.5rem;           /* Reduced from 2rem */
}
```

---

### Phase 4: Button Styling

**Primary Button (pill-shaped like PreSuite):**
```css
.btn-primary {
  background-color: var(--presearch-blue);
  color: white;
  padding: 0.5rem 1.25rem;
  border-radius: 9999px;     /* Fully rounded */
  font-weight: 600;
  font-size: 0.875rem;
  border: none;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.btn-primary:hover {
  background-color: var(--presearch-blue-hover);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
```

**Secondary Button:**
```css
.btn-secondary {
  background-color: var(--bg-elevated);
  color: var(--text-primary);
  padding: 0.5rem 1.25rem;
  border-radius: 8px;
  font-weight: 500;
  font-size: 0.875rem;
  border: 1px solid var(--border-default);
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.btn-secondary:hover {
  background-color: var(--bg-card);
}
```

---

### Phase 5: Card & Modal Refinement

**App Cards:**
```css
.app-card {
  background-color: var(--bg-card);
  border: 1px solid var(--border-default);
  border-radius: 12px;
  padding: 1.5rem;
  text-align: center;
  transition: opacity 0.15s ease;
}

.app-card:hover {
  opacity: 0.85;
}
```

**Modal:**
```css
.modal-overlay {
  background-color: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
}

.modal-content {
  background-color: var(--bg-base);
  border: 1px solid var(--border-default);
  border-radius: 12px;
  padding: 1.5rem;
  max-width: 500px;
  box-shadow: var(--shadow-elevated);
}
```

**Feature Cards:**
```css
.feature {
  background-color: var(--bg-card);
  border: 1px solid var(--border-default);
  border-radius: 8px;        /* Reduced from 12px */
  padding: 1.5rem;
  text-align: center;
}

.feature-icon {
  width: 48px;
  height: 48px;
  margin: 0 auto 1rem;
  background-color: var(--bg-elevated);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.feature-icon svg {
  width: 24px;
  height: 24px;
  color: var(--presearch-blue);
}
```

---

### Phase 6: Header & Navigation

**Header:**
```css
.header {
  background-color: var(--bg-base);
  border-bottom: 1px solid var(--border-default);
  padding: 1rem 2rem;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
}

.nav-link {
  color: var(--text-secondary);
  font-size: 0.875rem;
  font-weight: 500;
  padding: 0.5rem 1rem;
  transition: color 0.15s ease;
}

.nav-link:hover {
  color: var(--text-primary);
}

.nav-link.active {
  color: var(--presearch-blue);
}
```

---

### Phase 7: PrePanda AI Assistant Refinement

**Files to Modify:**
- `/branding/static/prepanda/prepanda.css`
- `/ai-assistant/css/prepanda.css`

**Chat Bubbles:**
```css
.message-user {
  background-color: var(--presearch-blue);
  color: white;
  border-radius: 12px 12px 4px 12px;
  padding: 0.75rem 1rem;
  max-width: 80%;
  margin-left: auto;
}

.message-assistant {
  background-color: var(--bg-elevated);
  color: var(--text-primary);
  border-radius: 12px 12px 12px 4px;
  padding: 0.75rem 1rem;
  max-width: 80%;
}
```

**Input Area:**
```css
.prepanda-input {
  background-color: var(--bg-card);
  border: 1px solid var(--border-default);
  border-radius: 9999px;
  padding: 0.75rem 1rem;
  color: var(--text-primary);
  font-size: 0.875rem;
}

.prepanda-input:focus {
  border-color: var(--presearch-blue);
  outline: none;
}
```

---

## File Change Summary

| File | Changes |
|------|---------|
| `/branding/static/index.html` | Replace emoji with Lucide icons, update CSS variables, refine typography/spacing |
| `/brand/tokens.json` | Update color tokens to match PreSuite |
| `/branding/static/prepanda/prepanda.css` | Update chat UI styling |
| `/ai-assistant/css/prepanda.css` | Update chat UI styling |

---

## Visual Comparison

### Before (Current)
- Emoji icons (📝 📊 📽️ 🎨)
- Bright pastel backgrounds (mint, yellow, pink)
- 2.5rem headings, 8rem hero padding
- 16px border-radius everywhere
- No cohesive color system

### After (Proposed)
- Lucide SVG icons (file-text, table, presentation, pen-tool)
- Unified dark card backgrounds (#2E2E2E)
- 2rem headings, 4rem hero padding
- 8-12px border-radius (contextual)
- PreSuite color system (#127FFF primary, #191919 background)

---

## Testing Checklist

- [ ] All Lucide icons render correctly
- [ ] Dark theme colors match PreSuite
- [ ] Typography hierarchy is clear
- [ ] Buttons have proper hover states
- [ ] Modals open/close smoothly
- [ ] PrePanda chat works with new styling
- [ ] Mobile responsive layout maintained
- [ ] Cross-browser compatibility (Chrome, Firefox, Safari)

---

## Rollback Plan

1. Keep backup of current `index.html`
2. Changes are CSS-only (no structural HTML changes beyond icon replacement)
3. Can revert by restoring original CSS block

---

## Notes

- ProximaNova font files need to be copied from PreSuite assets
- Consider creating a shared `presuite-common.css` for future cross-service consistency
- Lucide icons CDN used for simplicity; could bundle locally for production
