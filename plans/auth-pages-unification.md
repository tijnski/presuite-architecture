# Auth Pages Unification Plan

> Unify Login and Register pages across PreMail, PreDrive, and PreSocial to match PreSuite Hub's implementation.

**Date:** January 23, 2026
**Status:** Completed

---

## Overview

PreSuite Hub has the canonical login (`/login`) and register (`/register`) pages. PreMail, PreDrive, and PreSocial should match these exactly for consistent user experience across the ecosystem.

### Services Updated
| Service | Login Page | Register Page | Header Button | Status |
|---------|------------|---------------|---------------|--------|
| PreSuite Hub | ✅ Canonical | ✅ Canonical | ✅ "Login" | Source |
| PreMail | ✅ Updated | ✅ Updated | N/A | Deployed |
| PreDrive | ✅ Updated | ✅ Created | N/A | Deployed |
| PreSocial | ✅ Updated | N/A (uses PreSuite) | ✅ "Login" | Deployed |

---

## PreSuite Source (Canonical Implementation)

### Files
- **Login:** `/presearch/presuite/src/components/Login.jsx`
- **Register:** `/presearch/presuite/src/components/Register.jsx`

### Design Specifications

#### Background
```jsx
<div className="min-h-screen relative overflow-hidden flex items-center justify-center bg-[#0a0f1a]">
  {/* Background gradient effects */}
  <div className="absolute inset-0 overflow-hidden pointer-events-none">
    <div
      className="absolute -top-40 -right-40 w-[700px] h-[700px] rounded-full"
      style={{
        background: 'radial-gradient(circle, rgba(2, 61, 135, 0.4) 0%, transparent 60%)',
        filter: 'blur(60px)',
      }}
    />
    <div
      className="absolute -bottom-40 -left-40 w-[600px] h-[600px] rounded-full"
      style={{
        background: 'radial-gradient(circle, rgba(0, 16, 33, 0.6) 0%, transparent 60%)',
        filter: 'blur(60px)',
      }}
    />
  </div>
```

#### Card
```jsx
<div
  className="relative z-10 w-full max-w-sm mx-4 p-8 rounded-lg"
  style={{
    background: 'linear-gradient(45deg, #023d87, #001021)',
  }}
>
```

#### Colors
| Element | Color |
|---------|-------|
| Background | `#0a0f1a` |
| Card gradient | `linear-gradient(45deg, #023d87, #001021)` |
| Primary blue | `#127FFF` |
| Text white | `text-white` |
| Text muted | `text-gray-300`, `text-gray-400` |
| Error background | `bg-red-500/15 border border-red-500/30` |
| Error text | `text-red-400` |
| Input background | `bg-gray-100` |
| Input text | `text-black placeholder-gray-400` |

#### Password Requirements (PreSuite Standard)
```javascript
const passwordRules = [
  { test: (p) => p.length >= 12, label: 'At least 12 characters' },
  { test: (p) => /[A-Z]/.test(p), label: 'One uppercase letter' },
  { test: (p) => /[a-z]/.test(p), label: 'One lowercase letter' },
  { test: (p) => /[0-9]/.test(p), label: 'One number' },
  { test: (p) => /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(p), label: 'One special character' },
];
```

---

## Task 1: PreMail Updates

### Files to Modify
- `premail/apps/web/src/pages/LoginPage.tsx`
- `premail/apps/web/src/pages/RegisterPage.tsx`

### LoginPage.tsx Changes

#### 1.1 Add MFA Support
PreSuite has full MFA (2FA) verification. Add:
- `mfaRequired` state
- `mfaUserId` state
- `mfaCode` state
- `useBackupCode` state
- MFA verification form UI
- `handleMfaVerify` function

#### 1.2 Fix Blue Color
Change from `#0190FF` to `#127FFF`:
```tsx
// Find and replace all instances:
#0190FF -> #127FFF
```

#### 1.3 Add Missing Icons
```tsx
import { Shield as ShieldIcon, KeyRound as KeyIcon } from 'lucide-react';
```

#### 1.4 Update Footer Text
```tsx
// Current
<span className="text-sm text-gray-500">Privacy-first email service</span>

// Change to
<span className="text-sm text-gray-500">Privacy-first authentication</span>
```

#### 1.5 Add MFA Verification Form
Add after email login form, before footer:
```tsx
{/* MFA Verification Form */}
{mfaRequired && (
  <form onSubmit={handleMfaVerify} className="space-y-4">
    <div className="flex justify-center mb-4">
      <div className="w-16 h-16 rounded-full bg-[#127FFF]/20 flex items-center justify-center">
        <ShieldIcon className="w-8 h-8 text-[#127FFF]" />
      </div>
    </div>
    {/* ... full MFA form from PreSuite */}
  </form>
)}
```

### RegisterPage.tsx Changes

#### 2.1 Add Full Page Background
Currently missing outer container. Wrap entire component:
```tsx
return (
  <div className="min-h-screen relative overflow-hidden flex items-center justify-center bg-[#0a0f1a] py-8">
    {/* Background gradient effects */}
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {/* ... gradient divs ... */}
    </div>

    {/* Existing card content */}
    <div className="relative z-10 w-full max-w-sm mx-4">
      {/* ... */}
    </div>

    {/* Footer */}
    <footer className="fixed bottom-0 left-0 right-0 py-4 text-center">
      <div className="flex items-center justify-center gap-2">
        <Lock className="w-4 h-4 text-gray-500" />
        <span className="text-sm text-gray-500">Your data stays yours. Always.</span>
      </div>
    </footer>
  </div>
);
```

#### 2.2 Update Password Requirements
Change from 8 characters to 12, add special character rule:
```tsx
const passwordRequirements = [
  { label: "At least 12 characters", test: (p: string) => p.length >= 12 },
  { label: "One uppercase letter", test: (p: string) => /[A-Z]/.test(p) },
  { label: "One lowercase letter", test: (p: string) => /[a-z]/.test(p) },
  { label: "One number", test: (p: string) => /[0-9]/.test(p) },
  { label: "One special character", test: (p: string) => /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(p) },
];
```

#### 2.3 Add Web3 Registration
Add Web3 sign up button in method selection:
```tsx
{/* Web3 Register Button */}
<button
  onClick={handleWeb3Register}
  disabled={loading}
  className="bg-gray-100 font-semibold text-sm text-black w-full justify-center p-2.5 rounded-md flex items-center hover:opacity-60 transition-opacity disabled:opacity-50 disabled:cursor-not-allowed"
>
  {loading ? (
    <>
      <Loader2 className="mr-2 w-5 h-5 animate-spin" />
      <span>Connecting wallet...</span>
    </>
  ) : (
    <>
      <Wallet className="mr-2 w-5 h-5" />
      <span>Sign up with Web3</span>
    </>
  )}
</button>
```

#### 2.4 Match Button Order
PreSuite order:
1. Get @premail.site (primary blue)
2. Sign up with existing Email (gray)
3. Sign up with Web3 (gray)
4. Divider: "Already have an account?"
5. Login link

#### 2.5 Fix Blue Color
```tsx
#0190FF -> #127FFF
```

#### 2.6 Add Show/Hide Password Toggle
PreSuite has eye icons for password visibility:
```tsx
<div className="relative">
  <input
    type={showPassword ? 'text' : 'password'}
    // ...
  />
  <button
    type="button"
    onClick={() => setShowPassword(!showPassword)}
    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
  >
    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
  </button>
</div>
```

---

## Task 2: PreDrive Updates

### Files to Modify
- `predrive/apps/web/src/App.tsx` (extract LoginPage to separate file)
- Create `predrive/apps/web/src/pages/LoginPage.tsx` (new)
- Create `predrive/apps/web/src/pages/RegisterPage.tsx` (new)

### Current State
- LoginPage is embedded in App.tsx (lines 68-341)
- No RegisterPage exists (redirects to presuite.eu/register)

### 3.1 Extract LoginPage to Separate File
Create `predrive/apps/web/src/pages/LoginPage.tsx`:
- Copy LoginPage function from App.tsx
- Match PreSuite structure exactly
- Add MFA support
- Fix blue color: `#0190FF` -> `#127FFF`

### 3.2 Create RegisterPage
Create `predrive/apps/web/src/pages/RegisterPage.tsx`:
- Copy structure from PreSuite Register.jsx
- Adapt to TypeScript
- Use PreDrive's auth hooks (`useAuth`)
- Keep "Get @premail.site" as primary action
- Include all three registration methods: PreMail, Email, Web3

### 3.3 Update App.tsx
- Remove embedded LoginPage function
- Import from pages folder
- Add routing for /register

### 3.4 Add Router (if not present)
PreDrive may need react-router-dom setup:
```tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// In App component:
<BrowserRouter>
  <Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route path="/register" element={<RegisterPage />} />
    <Route path="/*" element={<MainApp />} />
  </Routes>
</BrowserRouter>
```

---

## Task 3: PreSocial Updates

### Files Modified
- `presocial/apps/web/src/pages/LoginPage.jsx`
- `presocial/apps/web/src/components/Header.jsx`

### LoginPage.jsx Changes

#### 3.1 Replace Chat Bubble Logo with Presearch Logo
Added PresearchLogo SVG component:
```jsx
function PresearchLogo({ className }) {
  return (
    <svg viewBox="0 0 370 370" className={className} fill="currentColor">
      <path d="M135.17,225.38h32.71a63,63,0,0,0,27.06-6..."/>
      <path d="M9.44,30.1V339.9A20.1,20.1,0,0,0,29.54,360h309.8..."/>
      <rect x="159.8" y="250.02" width="128.83" height="39.58"/>
    </svg>
  );
}
```

Replaced:
```jsx
// Before
<div className="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center">
  <MessageCircle className="w-6 h-6 text-white" />
</div>

// After
<div className="w-10 h-10">
  <PresearchLogo className="w-full h-full text-[#127FFF]" />
</div>
```

#### 3.2 Fix Blue Color
Changed all instances of `#0190FF` to `#127FFF` for consistency.

### Header.jsx Changes

#### 3.3 Update Sign In Button to Login
Desktop version:
```jsx
// Before
<Link
  to="/login"
  className="flex items-center gap-2 px-3 py-2 rounded-lg bg-gradient-to-r from-social to-presearch text-white text-sm font-medium hover:opacity-90 transition-opacity"
>
  <LogIn className="w-4 h-4" />
  <span className="hidden sm:inline">Sign In</span>
</Link>

// After
<Link
  to="/login"
  className="flex items-center gap-2 px-4 py-2 rounded-full bg-[#127FFF] text-white text-sm font-medium hover:opacity-90 transition-opacity"
>
  <LogIn className="w-4 h-4" />
  <span className="hidden sm:inline">Login</span>
</Link>
```

Mobile version also updated with same styling.

### Deployment
```bash
# Local
cd ~/Documents/Documents-MacBook/presearch/presocial
git add .
git commit -m "Update auth pages to match PreSuite"
git push origin main

# Server
ssh root@76.13.2.221 "cd /opt/presocial && git pull && cd apps/web && npm run build && pm2 restart presocial-api"
```

---

## Implementation Checklist

### PreMail ✅ Completed
- [x] LoginPage.tsx: Add MFA states and handlers
- [x] LoginPage.tsx: Add MFA verification form UI
- [x] LoginPage.tsx: Change `#0190FF` to `#127FFF`
- [x] LoginPage.tsx: Add Shield, KeyRound icons
- [x] LoginPage.tsx: Update footer text
- [x] RegisterPage.tsx: Add full page background wrapper
- [x] RegisterPage.tsx: Add footer with lock icon
- [x] RegisterPage.tsx: Update password requirements (12 chars, special char)
- [x] RegisterPage.tsx: Add Web3 registration option
- [x] RegisterPage.tsx: Add show/hide password toggles
- [x] RegisterPage.tsx: Change `#0190FF` to `#127FFF`
- [x] RegisterPage.tsx: Match button order to PreSuite
- [x] AuthLayout.tsx: Simplified to just render Outlet (no wrapper styling)
- [x] Deployed to production

### PreDrive ✅ Completed
- [x] Create pages directory if not exists
- [x] Create LoginPage.tsx from PreSuite Login.jsx
- [x] Create RegisterPage.tsx from PreSuite Register.jsx
- [x] Convert JSX to TypeScript
- [x] Integrate with useAuth hook
- [x] Update App.tsx to import new pages
- [x] Add routing based on window.location.pathname
- [x] Remove embedded LoginPage from App.tsx
- [x] Update "Get @premail.site" links
- [x] Add register function to useAuth.ts
- [x] Deployed to production via Docker

### PreSocial ✅ Completed
- [x] LoginPage.jsx: Replace chat bubble logo with Presearch logo
- [x] LoginPage.jsx: Change `#0190FF` to `#127FFF`
- [x] Header.jsx: Change "Sign In" button to "Login"
- [x] Header.jsx: Update button style to solid blue (#127FFF) pill shape
- [x] Header.jsx: Update both desktop and mobile versions
- [x] Deployed to production

---

## API Endpoints Required

Both services need these auth endpoints (proxied through PreSuite Hub):

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/auth/login` | POST | Email/password login |
| `/api/auth/register` | POST | Account registration |
| `/api/auth/verify-mfa` | POST | MFA code verification |
| `/api/auth/web3/nonce` | GET | Get Web3 nonce |
| `/api/auth/web3/verify` | POST | Verify Web3 signature |

---

## Deployment Steps

### PreMail
```bash
# Local
cd ~/Documents/Documents-MacBook/presearch/premail
git add .
git commit -m "Unify login/register pages with PreSuite"
git push origin main

# Server
ssh root@76.13.1.117 "cd /opt/premail && git pull && pnpm build && pm2 restart premail-web"
```

### PreDrive
```bash
# Local
cd ~/Documents/Documents-MacBook/presearch/predrive
git add .
git commit -m "Add unified login/register pages matching PreSuite"
git push origin main

# Server
ssh root@76.13.1.110 "cd /opt/predrive && git pull && pnpm build && docker compose -f deploy/docker-compose.prod.yml up -d --build"
```

---

## Notes

1. **MFA Integration:** PreMail and PreDrive need to support MFA verification through PreSuite Hub's API. Ensure the auth proxy passes MFA-related requests correctly.

2. **Web3 Integration:** Both services already have web3Auth libraries. Ensure they're using the same version and configuration as PreSuite Hub.

3. **Color Consistency:** The canonical blue is `#127FFF` (not `#0190FF`). This matches presearch-web design system.

4. **Password Policy:** All services must enforce the same 12-character minimum with special character requirement. Backend validation must match.

5. **Session Handling:** After successful login/register, ensure JWT tokens are stored consistently and work across all PreSuite services.
