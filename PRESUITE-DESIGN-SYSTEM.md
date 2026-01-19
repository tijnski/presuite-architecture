# PreSuite Design System

> **Purpose**: Unified design system for all PreSuite applications
> **Based on**: Presearch.com design language (January 2026)
> **Apply to**: PreMail, PreDrive, PreOffice, PreSocial, PreSuite Hub

---

## Quick Reference

| Element | Value | Usage |
|---------|-------|-------|
| Primary Blue | `#127FFF` | Buttons, links, active states |
| Hover Blue | `#2D8EFF` | Hover states, toggle active |
| Background | `#202020` | Main page background |
| Card/Surface | `#2E2E2E` | Cards, inputs, elevated surfaces |
| Panel | `#212224` | Side panels, settings, modals |
| Text Primary | `#FFFFFF` | Headings, important text |
| Text Secondary | `#E5E7EB` | Body text |
| Text Muted | `#6B7280` | Helper text, disabled |
| Border | `#383838` | Card borders, dividers |

---

## CSS Variables

Copy these to your app's `index.css` or main stylesheet:

```css
:root {
  /* Primary Colors */
  --presearch-blue: #127FFF;
  --presearch-blue-light: #2D8EFF;
  --presearch-blue-hover: #0066CC;

  /* Backgrounds (Dark Theme) */
  --bg-base: #202020;
  --bg-darker: #191919;
  --bg-card: #2E2E2E;
  --bg-panel: #212224;
  --bg-elevated: #383838;
  --bg-hover: rgba(255, 255, 255, 0.05);

  /* Text Colors */
  --text-primary: #FFFFFF;
  --text-secondary: #E5E7EB;
  --text-muted: #6B7280;
  --text-subtle: #4B5563;
  --text-link: #C9C9C9;

  /* Borders */
  --border-default: #383838;
  --border-subtle: #2E2E2E;
  --border-light: #E5E7EB;

  /* Toggle States */
  --toggle-active: #2D8EFF;
  --toggle-inactive: #6B7280;
  --toggle-knob: #FFFFFF;

  /* Status Colors */
  --success: #10B981;
  --warning: #F59E0B;
  --error: #EF4444;
  --info: #3B82F6;

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
  --radius-xl: 16px;
  --radius-full: 9999px;

  /* Typography */
  --font-sans: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  --text-xs: 12px;
  --text-sm: 14px;
  --text-base: 16px;
  --text-lg: 20px;
  --text-xl: 24px;
  --text-2xl: 30px;
  --text-3xl: 36px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.2);
  --shadow-md: 0 2px 8px rgba(0, 0, 0, 0.15);
  --shadow-lg: 0 4px 16px rgba(0, 0, 0, 0.2);
  --shadow-xl: 0 8px 32px rgba(0, 0, 0, 0.3);
}
```

---

## Components

### Toggle Switch (48x24px)

The standard Presearch toggle switch:

```jsx
function Toggle({ enabled, onChange }) {
  return (
    <button
      onClick={() => onChange(!enabled)}
      className="relative w-12 h-6 rounded-full transition-colors duration-150 cursor-pointer flex-shrink-0"
      style={{
        backgroundColor: enabled ? '#2D8EFF' : '#6B7280',
      }}
    >
      <span
        className="absolute top-1 w-4 h-4 rounded-full bg-white transition-all duration-150"
        style={{
          left: enabled ? '28px' : '4px',
          boxShadow: '0 1px 3px rgba(0, 0, 0, 0.3)',
        }}
      />
    </button>
  );
}
```

**CSS version:**
```css
.toggle {
  position: relative;
  width: 48px;
  height: 24px;
  border-radius: 9999px;
  background-color: var(--toggle-inactive);
  cursor: pointer;
  transition: background-color 150ms;
}

.toggle.active {
  background-color: var(--toggle-active);
}

.toggle-knob {
  position: absolute;
  top: 4px;
  left: 4px;
  width: 16px;
  height: 16px;
  border-radius: 9999px;
  background-color: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
  transition: left 150ms;
}

.toggle.active .toggle-knob {
  left: 28px;
}
```

---

### Theme Toggle (Pill Buttons)

Dark/Light mode selector:

```jsx
function ThemeToggle({ isDark, onChange }) {
  return (
    <div className="flex">
      <button
        onClick={() => onChange('dark')}
        className="px-3 py-1 text-sm rounded-full border transition-colors"
        style={{
          backgroundColor: isDark ? '#E5E7EB' : 'transparent',
          color: isDark ? '#2E2E2E' : '#FFFFFF',
          borderColor: '#E5E7EB',
        }}
      >
        Dark
      </button>
      <button
        onClick={() => onChange('light')}
        className="px-3 py-1 text-sm rounded-full border transition-colors -ml-px"
        style={{
          backgroundColor: !isDark ? '#E5E7EB' : 'transparent',
          color: !isDark ? '#2E2E2E' : '#FFFFFF',
          borderColor: '#E5E7EB',
        }}
      >
        Light
      </button>
    </div>
  );
}
```

---

### Primary Button

```jsx
<button
  className="px-4 py-2 rounded-full text-sm font-semibold text-white transition-colors hover:opacity-90"
  style={{ backgroundColor: '#127FFF' }}
>
  Button Text
</button>
```

**CSS:**
```css
.btn-primary {
  background-color: var(--presearch-blue);
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

---

### Secondary Button (Outlined)

```jsx
<button
  className="px-4 py-2 rounded-full text-sm font-medium border transition-colors"
  style={{
    backgroundColor: 'transparent',
    color: '#E5E7EB',
    borderColor: '#E5E7EB',
  }}
>
  Button Text
</button>
```

---

### Card Component

```jsx
function Card({ children, className = '' }) {
  return (
    <div
      className={`rounded-xl p-4 ${className}`}
      style={{
        backgroundColor: '#2E2E2E',
        border: '1px solid #383838',
        boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
      }}
    >
      {children}
    </div>
  );
}
```

---

### Settings Panel (Side Slide-Out)

```jsx
function SettingsPanel({ isOpen, onClose, children }) {
  if (!isOpen) return null;

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 z-40"
        style={{ backgroundColor: 'rgba(0, 0, 0, 0.5)' }}
        onClick={onClose}
      />

      {/* Panel */}
      <div
        className="fixed top-0 right-0 h-full w-[400px] z-50 overflow-y-auto"
        style={{ backgroundColor: '#212224' }}
      >
        {/* Header */}
        <div
          className="sticky top-0 flex items-center justify-between p-4"
          style={{
            backgroundColor: '#212224',
            borderBottom: '1px solid #383838',
          }}
        >
          <h2 className="text-lg font-semibold text-white">Settings</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white">
            <XIcon className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4">
          {children}
        </div>
      </div>
    </>
  );
}
```

---

### Settings Item Row

```jsx
function SettingsItem({ title, description, children }) {
  return (
    <div className="flex items-center justify-between py-4">
      <div className="flex-1 min-w-0 mr-4">
        <p className="text-sm font-medium text-white">{title}</p>
        {description && (
          <p className="text-xs text-gray-400 mt-0.5">{description}</p>
        )}
      </div>
      {children}
    </div>
  );
}
```

---

### Section Header

```jsx
function SectionHeader({ children }) {
  return (
    <h3
      className="text-base font-semibold text-white mt-6 mb-4"
      style={{ color: '#FFFFFF' }}
    >
      {children}
    </h3>
  );
}
```

---

### Search Bar

```jsx
function SearchBar({ value, onChange, placeholder }) {
  return (
    <div
      className="flex items-center h-12 rounded-full overflow-hidden"
      style={{
        backgroundColor: '#2E2E2E',
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
      }}
    >
      <SearchIcon className="w-5 h-5 ml-4" style={{ color: '#127FFF' }} />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="flex-1 h-full px-3 bg-transparent border-none outline-none text-sm text-white"
        style={{ color: '#FFFFFF' }}
      />
    </div>
  );
}
```

---

### Dropdown Button

```jsx
function DropdownButton({ label, value, options, onChange }) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-3 py-1 rounded-full border text-sm"
        style={{
          backgroundColor: 'transparent',
          color: '#E5E7EB',
          borderColor: '#E5E7EB',
        }}
      >
        {value}
        <ChevronDownIcon className="w-3 h-3" />
      </button>

      {isOpen && (
        <div
          className="absolute top-full mt-1 right-0 rounded-lg overflow-hidden z-10"
          style={{
            backgroundColor: '#2E2E2E',
            border: '1px solid #383838',
          }}
        >
          {options.map((option) => (
            <button
              key={option}
              onClick={() => { onChange(option); setIsOpen(false); }}
              className="w-full px-4 py-2 text-sm text-left hover:bg-white/5 text-gray-200"
            >
              {option}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
```

---

### External Link Item

```jsx
function ExternalLinkItem({ icon: Icon, label, href }) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="flex items-center justify-between py-4 cursor-pointer hover:opacity-70 transition-opacity"
    >
      <div className="flex items-center gap-3">
        <Icon className="w-5 h-5" style={{ color: '#9CA3AF' }} />
        <span className="text-sm text-gray-200">{label}</span>
      </div>
      <ExternalLinkIcon className="w-4 h-4" style={{ color: '#6B7280' }} />
    </a>
  );
}
```

---

## Typography

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| H1 | 30px | 700 | `#FFFFFF` |
| H2 | 24px | 600 | `#FFFFFF` |
| H3 | 20px | 600 | `#FFFFFF` |
| Body | 14px | 400 | `#E5E7EB` |
| Small | 12px | 400 | `#6B7280` |
| Section Header | 16px | 600 | `#FFFFFF` |

---

## Tailwind Config Extension

If using Tailwind CSS, add these to `tailwind.config.js`:

```javascript
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
        border: {
          default: '#383838',
          subtle: '#2E2E2E',
        },
      },
      borderRadius: {
        'full': '9999px',
      },
      fontFamily: {
        sans: ['ui-sans-serif', 'system-ui', '-apple-system', 'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', 'sans-serif'],
      },
    },
  },
}
```

---

## Implementation Checklist

When applying to a new PreSuite app:

### Required
- [ ] Add CSS variables to main stylesheet
- [ ] Set page background to `#202020`
- [ ] Update primary buttons to use `#127FFF`
- [ ] Replace toggles with 48x24px pill style
- [ ] Use correct text colors (white primary, gray secondary)

### Recommended
- [ ] Add settings panel (right slide-out, 400px)
- [ ] Use card component for elevated surfaces
- [ ] Implement Dark/Light theme toggle
- [ ] Match search bar styling (rounded pill, blue icon)
- [ ] Use consistent spacing (16px sections, 24px between sections)

### Nice to Have
- [ ] Add hover states with `#2D8EFF`
- [ ] Implement dropdown buttons
- [ ] Add subtle shadows to elevated elements
- [ ] Match icon stroke weights (1.5-2px)

---

## Apps Using This System

| App | Status | Notes |
|-----|--------|-------|
| PreSuite Hub | Applied | Full implementation |
| PreMail | Pending | Apply to web app |
| PreDrive | Pending | Apply to web app |
| PreOffice | Pending | Landing page only |
| PreSocial | Pending | Lemmy integration |

---

*Created: January 19, 2026*
*Version: 1.0*
