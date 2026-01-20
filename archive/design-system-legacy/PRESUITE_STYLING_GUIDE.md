# PreSuite Styling Transformation Guide

> **Goal**: Make PreSuite feel like a native part of Presearch-Web instead of a "cheap knockoff"

---

## Executive Summary: What's Wrong

PreSuite currently feels disconnected from Presearch-Web because of these key differences:

| Aspect | Presearch-Web (Correct) | PreSuite (Current) | Impact |
|--------|------------------------|-------------------|--------|
| **Primary Blue** | `#2D8EFF` | `#2196f3` | Colors look off-brand |
| **Dark Backgrounds** | Neutral grays (`#191919`) | Blue-tinted (`#0a1628`) | Jarring transition |
| **Buttons** | Flat color + opacity hover | Gradient + scale transform | Feels "gimmicky" |
| **Search Bar** | Solid white/dark, pill shape | Glassmorphism with blur | Inconsistent with main site |
| **Login Modal** | Blue-black gradient bg | Glassmorphism card | Different visual language |
| **Font** | ProximaNova | Inter | Typography mismatch |
| **Hover Effects** | Subtle opacity changes | Scale transforms | Over-animated |

---

## Part 1: Color System Overhaul

### Current PreSuite Colors (WRONG)

```css
/* presuite/src/index.css - CURRENT (INCORRECT) */
--presearch-primary: #2196f3;
--presearch-primary-hover: #1976d2;
--dark-900: #0a1628;  /* Blue-tinted - WRONG */
--dark-800: #0d1929;  /* Blue-tinted - WRONG */
```

### Correct Presearch-Web Colors

```css
/* presearch-web/tailwind.config.js - CORRECT COLORS */

/* Primary Presearch Blue */
--presearch-default: #2D8EFF;      /* Main brand blue */
--presearch-alternative: #127FFF;  /* Buttons, CTAs */
--presearch-dark: #80BAFF;         /* Dark mode accent */
--background-presearch: #0079DA;   /* Blue backgrounds */

/* Primary Scale */
--primary-100: #EBF4FF;
--primary-200: #CDE4FE;
--primary-300: #AED3FE;
--primary-400: #72B2FD;
--primary-500: #3591FC;  /* Primary */
--primary-600: #3083E3;
--primary-700: #205797;
--primary-800: #184171;
--primary-900: #102C4C;

/* Dark Mode Backgrounds (NEUTRAL GRAYS, NOT BLUE-TINTED) */
--dark-900: #191919;
--dark-800: #1e1e1e;
--dark-700: #2e2e2e;
--dark-600: #383838;
--dark-500: #5f5f5f;

/* Background Colors */
--background-light100: #F4F4F4;
--background-light200: #EDF1F4;
--background-light300: #E5E5E5;

--background-dark100: #2E2E2E;
--background-dark200: #2e2e2e;
--background-dark300: #383838;
--background-dark400: #212224;
--background-dark500: #191919;

/* Results/UI Colors */
--results-link: #6E849F;
--results-header-dark: #292929;
--results-background-dark: #202020;
--visited-dark: #B9C4D0;
--visited-light: #91A2B7;
```

### File to Edit: `/presuite/src/index.css`

Replace lines 8-91 with the correct color variables:

```css
:root {
  /* ============================================
     PRESEARCH BRAND COLORS (from presearch-web)
     ============================================ */

  /* Primary Presearch Blues */
  --presearch-default: #2D8EFF;
  --presearch-alternative: #127FFF;
  --presearch-dark: #80BAFF;
  --background-presearch: #0079DA;

  /* Primary Scale */
  --primary-100: #EBF4FF;
  --primary-200: #CDE4FE;
  --primary-300: #AED3FE;
  --primary-400: #72B2FD;
  --primary-500: #3591FC;
  --primary-600: #3083E3;
  --primary-700: #205797;
  --primary-800: #184171;
  --primary-900: #102C4C;

  /* ============================================
     DARK MODE - NEUTRAL GRAYS (NOT blue-tinted!)
     ============================================ */
  --dark-900: #191919;
  --dark-800: #1e1e1e;
  --dark-700: #2e2e2e;
  --dark-600: #383838;
  --dark-500: #5f5f5f;

  /* ============================================
     BACKGROUND COLORS
     ============================================ */
  --background-light100: #F4F4F4;
  --background-light200: #EDF1F4;
  --background-light300: #E5E5E5;

  --background-dark100: #2E2E2E;
  --background-dark200: #2e2e2e;
  --background-dark300: #383838;
  --background-dark400: #212224;
  --background-dark500: #191919;

  /* ============================================
     UI/RESULTS COLORS
     ============================================ */
  --results-link: #6E849F;
  --results-report: #9F6E7D;
  --results-report-dark: #DB6F90;
  --results-text-light: #707070;
  --results-header-dark: #292929;
  --results-background-dark: #202020;
  --visited-dark: #B9C4D0;
  --visited-light: #91A2B7;

  /* Shadows - Keep Presearch themed */
  --shadow-primary: 0 4px 14px rgba(45, 142, 255, 0.25);
  --shadow-primary-hover: 0 6px 20px rgba(45, 142, 255, 0.35);
  --shadow-card: 0 8px 32px rgba(45, 142, 255, 0.08);
}
```

---

## Part 2: Typography - Add ProximaNova Font

### Current PreSuite (WRONG)
```css
font-family: Inter, system-ui, ...;
```

### Correct Presearch-Web Font
```css
font-family: 'ProximaNova', Inter, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial;
```

### Steps to Fix

1. **Copy font files from presearch-web:**
   ```
   presearch-web/src/assets/ProximaNova-Regular.woff2
   presearch-web/src/assets/ProximaNova-Regular.otf
   ```
   To:
   ```
   presuite/public/assets/
   ```

2. **Add font-face to `presuite/src/index.css`:**

```css
@font-face {
  font-family: 'ProximaNova';
  src: url('/assets/ProximaNova-Regular.woff2') format('woff2'),
       url('/assets/ProximaNova-Regular.otf') format('opentype');
  font-weight: normal;
  font-style: normal;
  font-display: block;
}

body {
  font-family: 'ProximaNova', Inter, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Apple Color Emoji", "Segoe UI Emoji";
}
```

---

## Part 3: Button Styling

### Current PreSuite Buttons (WRONG)

```css
/* Gradient background + scale transform = feels cheap */
.btn-primary {
  background: linear-gradient(135deg, var(--presearch-primary) 0%, var(--presearch-primary-hover) 100%);
  transition: all 0.2s ease;
}
.btn-primary:hover {
  transform: scale(1.05);  /* REMOVE THIS */
}
```

### Correct Presearch-Web Button Style

```css
/* Flat color + subtle opacity hover = professional */
.btn-primary {
  background-color: #127FFF;  /* presearch-alternative */
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;  /* rounded-md = 6px */
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.15s ease;
}

.btn-primary:hover {
  opacity: 0.6;  /* Key difference: opacity, not scale */
}

/* Full-width variant (login/signup) */
.btn-primary-full {
  background-color: #F3F4F6;  /* gray-100 */
  color: black;
  font-weight: 600;
  font-size: 0.875rem;
  width: 100%;
  justify-content: center;
  padding: 0.5rem;
  border-radius: 0.375rem;
  display: flex;
  align-items: center;
  transition: opacity 0.15s ease;
}

.btn-primary-full:hover {
  opacity: 0.6;
}
```

### Component Changes

**File: `presuite/src/components/Login.jsx` and `Register.jsx`**

Replace button styling from:
```jsx
className="w-full py-3 rounded-xl font-semibold text-white hover:scale-[1.02]"
style={{
  background: 'linear-gradient(135deg, #2196f3 0%, #1976d2 100%)',
}}
```

To:
```jsx
className="w-full py-3 rounded-md font-semibold text-white hover:opacity-60 transition-opacity"
style={{
  backgroundColor: '#127FFF',
}}
```

---

## Part 4: Search Bar Styling

### Current PreSuite (WRONG - Too much glassmorphism)

```jsx
style={{
  backgroundColor: 'rgba(255, 255, 255, 0.1)',
  border: '1px solid rgba(255, 255, 255, 0.18)',
  backdropFilter: 'blur(12px)',
  boxShadow: '0 8px 32px rgba(0, 0, 0, 0.2)',
}}
```

### Correct Presearch-Web Search Bar

**File: `presuite/src/components/SearchBar.jsx`**

Replace the search bar container styling:

```jsx
// Light mode
const lightModeStyle = {
  backgroundColor: 'white',
  // No blur, no fancy shadows
};

// Dark mode
const darkModeStyle = {
  backgroundColor: '#2e2e2e',  // background-dark200
  // Clean, solid background
};

// Container classes
className="relative flex items-center h-12 overflow-hidden bg-white rounded-full dark:bg-[#2e2e2e]"
```

**Search Input styling:**
```jsx
className="w-full h-12 pl-0 font-light pr-24 focus:outline-none md:pl-2 md:pr-30 text-base"
```

**Search button:**
```jsx
className="p-2 transition-opacity text-[#3591FC] hover:opacity-70"
```

**Divider in search bar:**
```jsx
<span className="w-px h-6 ml-1 mr-2 bg-gray-200 dark:bg-gray-600" />
```

---

## Part 5: Login/Register Modal

### Current PreSuite (WRONG - Glassmorphism card)

```jsx
style={{
  backgroundColor: isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(255, 255, 255, 0.92)',
  backdropFilter: 'blur(16px)',
}}
className="w-full max-w-md p-6 rounded-2xl"
```

### Correct Presearch-Web Modal

The signup modal should have a **blue-black gradient background**, not glassmorphism.

**File: `presuite/src/components/Login.jsx` and `Register.jsx`**

Replace the modal wrapper:

```jsx
// Modal container
<div
  className="bg-blue-black-gradient p-8 rounded text-white space-y-6 h-full sm:h-auto w-full sm:w-auto"
  style={{
    background: 'linear-gradient(45deg, #023d87, #001021)',
  }}
>
  {/* Logo top-left */}
  <div className="flex justify-between items-start">
    <img src="/logo.svg" alt="Presearch" className="w-10 h-10" />
    <button
      onClick={onClose}
      className="text-white w-5 h-5 cursor-pointer hover:opacity-60 transition-opacity"
    >
      <XIcon />
    </button>
  </div>

  {/* Title */}
  <h2 className="text-5xl font-semibold text-white">
    Your Privacy.<br />Our Priority.
  </h2>

  {/* Form content */}
  ...
</div>
```

**Form inputs in modal:**
```jsx
<label className="block mb-1 text-xs text-white">Email</label>
<input
  type="email"
  className="bg-gray-100 text-black w-full p-2 px-3 rounded"
  placeholder="Enter your email"
/>
```

**Error messages:**
```jsx
<div className="text-xs text-red-500">{error}</div>
```

**Links in modal:**
```jsx
<a className="text-[#127FFF] font-semibold underline hover:opacity-60 transition-opacity">
  Terms of Service
</a>
```

---

## Part 6: Dark Mode Background

### Current PreSuite (WRONG - Blue gradient background)

```css
--bg-gradient: linear-gradient(135deg, #0a1628 0%, #1a237e 50%, #0d47a1 100%);
```

### Correct Presearch-Web Dark Background

The main dark background should be **solid neutral gray**, not a blue gradient.

**File: `presuite/src/index.css`**

```css
/* Remove the blue gradient, use solid dark background */
.dark body,
body.dark {
  background-color: #191919;  /* dark-900 */
}

/* For the launchpad/main page, keep it simple */
.presearch-bg {
  background-color: #191919;
  min-height: 100vh;
}
```

**File: `presuite/src/components/PreSuiteLaunchpad.jsx`**

Replace the gradient background:

```jsx
// FROM:
style={{
  background: 'linear-gradient(135deg, #0a1628 0%, #1a237e 50%, #0d47a1 100%)',
}}

// TO:
style={{
  backgroundColor: isDark ? '#191919' : '#F4F4F4',
}}
```

---

## Part 7: Hover Effects - Tone It Down

### Current PreSuite (WRONG - Over-animated)

```jsx
className="hover:scale-[1.02] hover:shadow-lg"
className="group-hover:-translate-y-1 group-hover:scale-105"
```

### Correct Presearch-Web Hover Style

Presearch-Web uses **subtle opacity changes**, not scale/transform animations.

**Replace all scale hovers with opacity:**

```jsx
// FROM:
className="hover:scale-[1.02]"
className="group-hover:scale-105"

// TO:
className="hover:opacity-60 transition-opacity"
className="hover:opacity-70"
```

**For cards/links that need visual feedback:**
```jsx
// Simple opacity hover
className="cursor-pointer hover:opacity-60 transition-opacity"

// Or slight opacity for links
className="hover:opacity-70 transition-opacity"
```

---

## Part 8: Settings Panel

### Correct Presearch-Web Settings Panel

**File: `presuite/src/components/Settings.jsx`**

The settings panel should slide in from the right with proper styling:

```jsx
<div
  className="fixed top-0 right-0 flex flex-col flex-1 w-full h-full max-w-full min-h-full overflow-y-auto shadow-lg z-50 sm:w-[27rem]"
  style={{
    backgroundColor: isDark ? '#2E2E2E' : '#F4F4F4',  // background-light100 / dark100
  }}
>
```

**Settings toggle button (pill shape):**
```jsx
<button
  className="px-2 py-1.5 h-8 flex items-center rounded-full text-white"
  style={{
    backgroundColor: isOpen ? '#127FFF' : '#0079DA',
  }}
>
```

---

## Part 9: Tab Navigation

### Correct Presearch-Web Tab Style

**Tab container:**
```jsx
className="flex items-start flex-1 h-full pt-3 ml-2 overflow-auto lg:ml-0 lg:pt-0 lg:items-end overflow-hidden custom-scrollbar"
```

**Tab items:**
```jsx
// Base classes
const tabBase = "block flex mx-1 px-1.5 md:px-2 pb-2.5 md:pb-3.5 border-transparent text-sm border-b-2 relative";

// Active tab
const tabActive = "text-[#3591FC] border-[#3591FC] dark:text-[#80BAFF] dark:border-[#80BAFF]";

// Inactive tab
const tabInactive = "dark:text-white text-gray-700 border-transparent hover:opacity-70";
```

---

## Part 10: Glassmorphism - When to Use It

### Presearch-Web Glassmorphism (Used Sparingly)

Presearch-Web only uses glassmorphism for the **dark-glass theme** in specific components like PreGPT chat, not for general UI.

**When to use glassmorphism:**
- AI/Chat interfaces (PreGPT)
- Floating overlays/tooltips

**When NOT to use glassmorphism:**
- Login/Register modals (use gradient background instead)
- Search bar (use solid background)
- Cards (use solid background with subtle shadow)
- Settings panel (solid background)

**Correct dark-glass variables:**
```css
[data-theme='dark-glass'] {
  --dg-border: rgba(255, 255, 255, 0.12);
  --dg-bg: rgba(13, 15, 18, 0.55);
  --dg-text: #e9e9e9;
  --dg-placeholder: #838383;
}

[data-theme='dark-glass'] .dg-search-panel {
  background: var(--dg-bg);
  border: 1px solid var(--dg-border);
  border-radius: 10px;
  height: 56px;
  backdrop-filter: blur(16px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
}
```

---

## Part 11: iOS-Style Toggle (Correct)

PreSuite already has the toggle correct, but make sure it uses the right blue:

```css
.dg-toggle.on {
  background: #2D8EFF;  /* Use presearch-default, not #2266ff */
}
```

---

## Part 12: Custom Scrollbar

Both are correct, but ensure the color matches:

```css
.custom-scrollbar {
  scrollbar-color: #2D8EFF transparent;  /* presearch-default */
  scrollbar-width: thin;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 5px;
  background-color: #2D8EFF;  /* presearch-default */
}
```

---

## Summary: Key Files to Modify

### 1. `/presuite/src/index.css`
- [ ] Replace all color variables with presearch-web values
- [ ] Add ProximaNova font-face
- [ ] Update body font-family
- [ ] Remove blue-tinted dark backgrounds
- [ ] Update button styles (remove scale, use opacity)
- [ ] Fix toggle color to `#2D8EFF`

### 2. `/presuite/src/components/SearchBar.jsx`
- [ ] Remove glassmorphism (backdrop-filter, blur)
- [ ] Use solid backgrounds (white / #2e2e2e)
- [ ] Simplify to pill-shape with basic styling

### 3. `/presuite/src/components/Login.jsx`
- [ ] Replace glassmorphism card with gradient background
- [ ] Use `linear-gradient(45deg, #023d87, #001021)`
- [ ] Update input styling to match presearch-web
- [ ] Remove scale hover effects

### 4. `/presuite/src/components/Register.jsx`
- [ ] Same changes as Login.jsx

### 5. `/presuite/src/components/PreSuiteLaunchpad.jsx`
- [ ] Remove blue gradient background
- [ ] Use solid dark/light backgrounds
- [ ] Remove scale hover effects on app icons
- [ ] Use opacity hover effects instead

### 6. `/presuite/src/components/Settings.jsx`
- [ ] Update background colors
- [ ] Fix button styling

### 7. Font files to copy:
- [ ] Copy `presearch-web/src/assets/ProximaNova-Regular.woff2` to `presuite/public/assets/`
- [ ] Copy `presearch-web/src/assets/ProximaNova-Regular.otf` to `presuite/public/assets/`

---

## Quick Reference: Presearch-Web Color Cheatsheet

| Use Case | Color | Hex |
|----------|-------|-----|
| Primary brand blue | `presearch-default` | `#2D8EFF` |
| Button backgrounds | `presearch-alternative` | `#127FFF` |
| Dark mode accent | `presearch-dark` | `#80BAFF` |
| Blue background | `background-presearch` | `#0079DA` |
| Primary (UI) | `primary-500` | `#3591FC` |
| Dark background | `dark-900` | `#191919` |
| Dark card | `dark-800` | `#1e1e1e` |
| Dark surface | `dark-700` | `#2e2e2e` |
| Light background | `background-light100` | `#F4F4F4` |
| Light surface | `background-light200` | `#EDF1F4` |
| Gray input bg | `gray-100` | `#F3F4F6` |
| Error | red-500 | `#EF4444` |
| Success | green-500 | `#10B981` |

---

## The "Vibe" Difference

**Presearch-Web feels:**
- Professional and clean
- Subtle and refined
- Consistent with established design language
- Trustworthy (important for a privacy-focused search engine)

**PreSuite currently feels:**
- Over-designed with too many effects
- Blue-heavy and disconnected
- "Modern" in a generic way
- Like a different product entirely

**The fix:**
1. **Flatten** - Remove gradients from buttons, remove glassmorphism from forms
2. **Neutralize** - Use neutral grays for dark mode, not blue-tinted
3. **Simplify** - Use opacity hovers instead of scale transforms
4. **Match** - Use exact presearch-web color values
5. **Unify** - Use ProximaNova font throughout

After these changes, PreSuite will feel like a natural extension of Presearch-Web, not a knockoff.
