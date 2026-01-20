# UIPatterns-PresearchWeb - UI/UX Patterns from presearch-web

Comprehensive guide of UI/UX patterns extracted from the official **presearch-web** repository to implement in PreSuite services.

**Source Repository:** presearch-web
**Last Extracted:** January 15, 2026

---

## Color Palette (tailwind.config.js)

### Primary Colors

```css
/* Primary Blue Scale */
--primary-100: #EBF4FF;
--primary-200: #CDE4FE;
--primary-300: #AED3FE;
--primary-400: #72B2FD;
--primary-500: #3591FC;  /* Main primary */
--primary-600: #3083E3;  /* Hover state */
--primary-700: #205797;
--primary-800: #184171;
--primary-900: #102C4C;

/* Presearch Brand */
--presearch-default: #2D8EFF;
--presearch-alternative: #127FFF;
--presearch-dark: #80BAFF;  /* For dark backgrounds */
--presearch-bg: #0079DA;
```

### Dark Mode Colors

```css
/* Dark Mode Backgrounds */
--dark-900: #191919;  /* Darkest */
--dark-800: #1e1e1e;  /* Main background */
--dark-700: #2e2e2e;  /* Elevated surfaces */
--dark-600: #383838;  /* Higher elevation */
--dark-500: #5f5f5f;  /* Muted elements */

/* Background Variants */
--background-light100: #F4F4F4;
--background-light200: #EDF1F4;
--background-light300: #E5E5E5;
--background-dark100: #2E2E2E;
--background-dark200: #2e2e2e;
--background-dark300: #383838;
--background-dark400: #212224;
--background-dark500: #191919;
```

### Utility Colors

```css
/* Results/Links */
--results-link: #6E849F;
--results-report: #9F6E7D;
--results-report-dark: #DB6F90;
--results-text-light: #707070;
--results-header-dark: #292929;
--results-background-dark: #202020;

/* Visited Links */
--visited-dark: #B9C4D0;
--visited-light: #91A2B7;

/* Light Gray */
--light-c9c: #C9C9C9;

/* Black */
--black-100: #111111;
```

---

## Typography

### Font Family

```css
/* Primary Font - ProximaNova */
@font-face {
  font-family: 'ProximaNova';
  src: url('/assets/ProximaNova-Regular.woff2') format('woff2'),
       url('/assets/ProximaNova-Regular.otf') format('opentype');
  font-weight: normal;
  font-style: normal;
  font-display: block;
}

/* Fallback Stack (for Dark Glass components) */
font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Apple Color Emoji", "Segoe UI Emoji";
```

### Font Sizes

```css
/* Extended Font Sizes */
.text-2xs { font-size: 0.625rem; }  /* 10px */
.text-xxs { font-size: 10px; line-height: 1.2; }
.text-xxxs { font-size: 8px; line-height: 1.1; }
.text-24 { font-size: 1.5rem; }
.text-32 { font-size: 2rem; }
.text-64 { font-size: 4rem; }
.text-72 { font-size: 4.5rem; }
```

---

## Dark Glass Theme

The signature Presearch dark theme with glassmorphism effects.

### CSS Variables

```css
[data-theme='dark-glass'] {
  --dg-border: rgba(255, 255, 255, 0.12);
  --dg-bg: rgba(13, 15, 18, 0.55);
  --dg-text: #e9e9e9;
  --dg-placeholder: #838383;
}
```

### Search Panel

```css
[data-theme='dark-glass'] .dg-search-panel {
  background: var(--dg-bg);
  border: 1px solid var(--dg-border);
  border-radius: 10px;
  height: 56px;
  backdrop-filter: blur(16px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
}
```

### Popover/Dropdown

```css
[data-theme='dark-glass'] .dg-popover {
  width: 320px;
  border-radius: 12px;
  box-shadow: 0 0 12px rgba(0, 0, 0, 0.6);
  background: rgba(26, 26, 26, 0.92);
  border: 1px solid rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(16px);
  color: var(--dg-text);
  padding: 16px;
  transform: scale(0.96);
  opacity: 0;
  transition: transform 160ms ease-out, opacity 160ms ease-out;
}

[data-theme='dark-glass'] .dg-popover.dg-open {
  transform: scale(1);
  opacity: 1;
}

/* Caret/Arrow */
[data-theme='dark-glass'] .dg-popover::before {
  content: "";
  position: absolute;
  right: 22px;
  top: -8px;
  width: 16px;
  height: 16px;
  background: rgba(26, 26, 26, 0.92);
  border-left: 1px solid rgba(255, 255, 255, 0.12);
  border-top: 1px solid rgba(255, 255, 255, 0.12);
  transform: rotate(45deg);
  z-index: 1;
}
```

### Input Styling

```css
[data-theme='dark-glass'] .dg-input {
  color: var(--dg-text);
}

[data-theme='dark-glass'] .dg-input::placeholder {
  color: var(--dg-placeholder);
}
```

---

## Components

### Toggle Switch (iOS-style)

```css
.dg-toggle {
  width: 40px;
  height: 20px;
  border-radius: 999px;
  background: #454545;
  position: relative;
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.12);
  transition: background-color 150ms ease-out, box-shadow 150ms ease-out;
  display: inline-block;
  vertical-align: middle;
}

.dg-toggle:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px rgba(52, 120, 246, 0.4);
}

.dg-toggle::after {
  content: "";
  position: absolute;
  width: 16px;
  height: 16px;
  top: 2px;
  left: 2px;
  border-radius: 999px;
  background: #fff;
  transition: left 150ms ease-out, box-shadow 150ms ease-out;
}

/* Active State */
.dg-toggle.on {
  background: #2266ff;
}

.dg-toggle.on::after {
  left: 22px;
  box-shadow: 0 0 0 2px rgba(52, 120, 246, 0.4);
}
```

### Card Component

```css
.dg-card {
  width: 64px;
  height: 64px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid #BFBFBF;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 150ms ease-out, transform 150ms ease-out, box-shadow 150ms ease-out;
  cursor: pointer;
  margin-bottom: 12px;
}

.dg-card img,
.dg-card svg,
.dg-card div {
  max-width: 28px;
  max-height: 28px;
}

.dg-card:hover {
  background: #2A2A2A;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
}

.dg-label {
  font-size: 12px;
  color: #B0B0B0;
  margin-top: 4px;
  text-align: center;
}
```

### Icon with Hover

```css
.dg-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.12s ease, box-shadow 0.12s ease;
}

[data-theme='dark-glass'] .dg-icon:hover {
  transform: scale(1.07);
  box-shadow: 0 0 0 2px rgba(255, 255, 255, 0.20) inset;
}
```

### Plus Button

```css
[data-theme='dark-glass'] .dg-plus {
  width: 32px;
  height: 32px;
  border-radius: 6px;
}

[data-theme='dark-glass'] .dg-plus:hover {
  background: rgba(255, 255, 255, 0.08);
}
```

### Section Headers & Dividers

```css
.dg-section-title {
  font-weight: 600;
  color: #E6E6E6;
  font-size: 14px;
  line-height: 18px;
  margin: 16px 0 8px 0;
}

.dg-divider {
  height: 1px;
  background: #3A3A3A;
  margin: 12px 0;
}
```

### Grid Layout

```css
.dg-grid-3 {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 16px;
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

/* PreGPT Scrollbar */
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

---

## Animations

### Slide In Animations

```css
@keyframes slideInRight {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideInTop {
  from {
    transform: translateY(-100%);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-10px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}
```

### Loading Dots Animation

```css
.pregpt-loading-dot {
  animation: bounce 1.4s infinite ease-in-out both;
}

.pregpt-loading-dot:nth-child(1) { animation-delay: -0.32s; }
.pregpt-loading-dot:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}
```

### Ellipsis Loading

```css
.lds-ellipsis {
  display: inline-block;
  position: relative;
  width: 80px;
  height: 80px;
}

.lds-ellipsis div {
  position: absolute;
  top: 33px;
  width: 13px;
  height: 13px;
  border-radius: 50%;
  background: #1f2937;
  animation-timing-function: cubic-bezier(0, 1, 1, 0);
}

.dark .lds-ellipsis div { background: #fff; }
.lds-ellipsis div.white { background: #fff; }

.lds-ellipsis div:nth-child(1) { left: 8px; animation: lds-ellipsis1 0.6s infinite; }
.lds-ellipsis div:nth-child(2) { left: 8px; animation: lds-ellipsis2 0.6s infinite; }
.lds-ellipsis div:nth-child(3) { left: 32px; animation: lds-ellipsis2 0.6s infinite; }
.lds-ellipsis div:nth-child(4) { left: 56px; animation: lds-ellipsis3 0.6s infinite; }

@keyframes lds-ellipsis1 {
  0% { transform: scale(0); }
  100% { transform: scale(1); }
}

@keyframes lds-ellipsis2 {
  0% { transform: translate(0, 0); }
  100% { transform: translate(24px, 0); }
}

@keyframes lds-ellipsis3 {
  0% { transform: scale(1); }
  100% { transform: scale(0); }
}
```

### Flip Spin Animation

```css
@keyframes flip-spin {
  0% { transform: perspective(120px) rotateX(0deg) rotateY(0deg); }
  25% { transform: perspective(120px) rotateX(-180deg) rotateY(0deg); }
  50% { transform: perspective(120px) rotateX(-180deg) rotateY(-180deg); }
  75% { transform: perspective(120px) rotateX(0deg) rotateY(-180deg); }
  100% { transform: perspective(120px) rotateX(0deg) rotateY(0deg); }
}
```

---

## Buttons

### Learn More Button

```css
.learn-more-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1.5px solid #fff;
  background-color: transparent;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.25s ease;
  color: #fff;
}

.learn-more-btn:hover {
  transform: translateY(3px);
  border-color: #2d8eff;
  color: #2d8eff;
}

.learn-more-btn svg {
  width: 22px;
  height: 22px;
}

/* Light Version */
.learn-more-btn-light {
  border: 2px solid #000;
  color: #000;
}
```

---

## Shadows

### Drop Shadows

```css
/* Tailwind Extended Shadows */
.drop-shadow-light { filter: drop-shadow(1px 1px 0.5px #000); }
.drop-shadow-dark { filter: drop-shadow(1px 1px 0.5px #EDF1F4); }

/* PreGPT Launcher Shadow */
.pregpt-launcher-shadow {
  box-shadow: 0 14px 34px rgba(0, 0, 0, 0.22), 0 10px 18px rgba(0, 0, 0, 0.12);
}
```

---

## Links

### Link Colors

```css
.link-tilt a {
  color: #127fff;
  transition: opacity 0.15s;
}

.dark .link-tilt a {
  color: #80baff;
}

.link-tilt a:hover {
  opacity: 0.5;
}
```

---

## Background Gradients

```css
/* Blue-Black Gradient */
.bg-blue-black-gradient {
  background: linear-gradient(45deg, #023d87, #001021);
}

/* Dark Shadow Gradient */
.bgshadow {
  background: linear-gradient(
    90deg,
    rgba(30, 30, 30, 1) 0%,
    rgba(30, 30, 30, 1) 100%,
    rgba(30, 30, 30, 0) 100%,
    rgba(30, 30, 30, 0) 100%
  );
  max-width: 54rem;
}

/* Light Shadow Gradient */
.bgshadowlight {
  background: linear-gradient(
    90deg,
    rgba(237, 241, 244, 1) 0%,
    rgba(237, 241, 244, 1) 100%,
    rgba(237, 241, 244, 0) 100%,
    rgba(237, 241, 244, 0) 100%
  );
  max-width: 54rem;
}
```

---

## Responsive Breakpoints

```css
/* Custom Breakpoints */
@media (min-width: 370px) { /* 3xs */ }
@media (min-width: 440px) { /* 2xs */ }
@media (min-width: 560px) { /* xs */ }
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 912px) { /* 2md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1160px) { /* 2lg */ }
@media (min-width: 1280px) { /* xl */ }
@media (min-width: 1360px) { /* 1360px */ }
@media (min-width: 1536px) { /* 2xl */ }
```

---

## Mobile Considerations

### iOS Zoom Prevention

```css
@media screen and (max-width: 767px) {
  select:active,
  select:focus,
  input:active,
  input:focus,
  .search-input {
    font-size: 16px;  /* Prevents iOS auto-zoom */
  }
}
```

### PreGPT Mobile Input

```css
.pregpt-mobile-input {
  font-size: 12px !important;
  min-height: 32px;

  @media (max-width: 768px) {
    font-size: 12px !important;
    transform: scale(1) !important;
    zoom: 1 !important;
    -webkit-text-size-adjust: 100% !important;
    -webkit-appearance: none !important;
    border-radius: 6px !important;
  }
}
```

### PreGPT Chat Component Sizing

```css
.pregpt-chat-component {
  width: min(600px, 90vw);
  max-width: min(600px, 90vw);
  height: min(600px, 85vh);
  max-height: min(600px, 85vh);

  @media (max-width: 768px) {
    width: min(95vw, 600px);
    max-width: min(95vw, 600px);
    height: min(80vh, 600px);
    max-height: min(80vh, 600px);
  }
}
```

---

## Utility Classes

### Text Truncation

```css
.line-clamp-2 {
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
}

.line-clamp-4 {
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 4;
  line-clamp: 4;
  -webkit-box-orient: vertical;
}

.description-clamp {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
  overflow: hidden;
  margin-bottom: 10px;
}
```

### Transitions

```css
.pregpt-transition {
  transition: all 0.2s ease-in-out;
}

/* Smooth transitions for interactive elements */
button, a, input, select {
  transition: all 0.2s ease;
}
```

---

## Implementation Checklist for PreSuite Services

### Phase 1: Core Styling

- [ ] Add ProximaNova font (or use system font fallback)
- [ ] Implement Dark Glass CSS variables
- [ ] Update color palette to match presearch-web
- [ ] Add custom scrollbar styling

### Phase 2: Components

- [ ] Implement iOS-style toggle switches
- [ ] Add card hover effects with `transform: translateY(-2px)`
- [ ] Implement popover/dropdown with glassmorphism
- [ ] Add loading animations (dots, ellipsis)

### Phase 3: Animations

- [ ] Add slide-in animations for panels
- [ ] Implement bounce loading animation
- [ ] Add smooth fade transitions

### Phase 4: Responsive

- [ ] Add custom breakpoints (3xs, 2xs, 2md, 2lg)
- [ ] Implement iOS zoom prevention
- [ ] Add mobile-optimized scrollbar hiding

---

## Files to Copy/Reference

| Pattern | Source File | Target |
|---------|-------------|--------|
| Dark Glass Theme | `src/css/main.scss` | All services |
| Toggle Component | `src/css/main.scss` | PreSuite, Settings |
| PreGPT Animations | `src/css/pregpt.scss` | PreSuite Hub |
| Custom Scrollbar | `src/css/main.scss` | All services |
| Color Palette | `tailwind.config.js` | All services |

---

*Extracted from presearch-web repository - January 15, 2026*
