# PreSuite Hub - Project Documentation

## Overview

PreSuite Hub is the central identity provider and dashboard for the PreSuite ecosystem. It provides authentication, OAuth 2.0/OIDC, Web3 wallet authentication, and a macOS Launchpad-inspired landing page for accessing Pre-branded applications.

**Live URL:** https://presuite.eu
**GitHub Repository:** https://github.com/tijnski/presuite
**Server:** `ssh root@76.13.2.221` → `/var/www/presuite`

---

## Tech Stack

### Frontend

| Package | Version | Purpose |
|---------|---------|---------|
| React | 19.2.0 | UI framework |
| Vite | 5.4.21 | Build tool |
| Tailwind CSS | 4.1.18 | Styling |
| Lucide React | 0.562.0 | Icons |
| React Router DOM | 6.30.3 | Client-side routing |
| DOMPurify | 3.3.1 | HTML sanitization |

### Backend

| Package | Version | Purpose |
|---------|---------|---------|
| Express | 5.2.1 | HTTP framework |
| pg | 8.13.1 | PostgreSQL client |
| jsonwebtoken | 9.0.2 | JWT authentication |
| bcrypt | 5.1.1 | Password hashing |
| ethers | 6.16.0 | Web3/wallet verification |
| express-rate-limit | 7.5.0 | Rate limiting |
| cookie-parser | - | Cookie handling |
| cors | - | CORS middleware |

### Infrastructure

- **Runtime:** Node.js 20+
- **Database:** PostgreSQL
- **Process Manager:** PM2
- **Web Server:** Nginx (reverse proxy)
- **SSL:** Let's Encrypt (auto-renewal)
- **AI Integration:** Venice AI API (PreGPT)

---

## Project Structure

```
presuite/
├── dist/                    # Production build output
├── src/
│   ├── assets/
│   │   └── images/          # Logos, mascot SVGs
│   ├── components/
│   │   ├── PreSuiteLaunchpad.jsx   # Main dashboard (500+ lines)
│   │   ├── Login.jsx               # Email + Web3 login (250+ lines)
│   │   ├── Register.jsx            # Registration with Web3 (350+ lines)
│   │   ├── ForgotPassword.jsx      # Password reset flow
│   │   ├── PreGPTChat.jsx          # AI chat modal (600+ lines)
│   │   ├── AppModal.jsx            # Service modals (67KB)
│   │   ├── Settings.jsx            # User settings
│   │   ├── SearchBar.jsx           # Search with autocomplete
│   │   ├── UserProfile.jsx         # Profile panel
│   │   └── Notifications.jsx       # Notification center
│   ├── services/
│   │   ├── authService.js          # Auth API client
│   │   ├── web3Auth.js             # MetaMask authentication
│   │   ├── preGPTService.js        # Venice AI proxy client
│   │   ├── preDriveService.js      # PreDrive integration
│   │   ├── preMailService.js       # PreMail integration
│   │   └── preBalanceService.js    # PRE token balance tracking
│   ├── App.jsx                     # Route definitions
│   ├── main.jsx                    # React entry point
│   └── index.css                   # Tailwind styles
├── config/
│   └── constants.js         # Security config, rate limits, OAuth clients
├── middleware/
│   ├── security.js          # Headers, CORS, input validation
│   └── rate-limiter.js      # Per-endpoint rate limiting
├── utils/
│   └── logger.js            # Secure logging with masking
├── migrations/
│   └── 001_web3_auth.sql    # Web3 auth database schema
├── server.js                # Express backend (2400+ lines)
├── .env.example             # Environment template
├── package.json
├── vite.config.js
└── index.html
```

---

## Authentication System

### JWT Configuration

| Setting | Value |
|---------|-------|
| Algorithm | HS256 |
| Issuer | `presuite` |
| Access Token Expiry | 15 minutes |
| Refresh Token Expiry | 30 days |

### Password Requirements

- Length: 12-128 characters
- Must contain: uppercase, lowercase, number, special character
- Special characters: `!@#$%^&*()_+-=[]{};":\|,.<>/?`
- Hashing: bcrypt with 12 salt rounds

### Token Storage

Frontend stores tokens in localStorage:
- `presuite_token` - JWT access token
- `presuite_user` - User object (JSON)

---

## API Endpoints

### Auth Routes

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Create new account |
| POST | `/api/auth/login` | Email/password login |
| GET | `/api/auth/verify` | Validate JWT token |
| POST | `/api/auth/refresh` | Refresh access token |
| GET | `/api/auth/me` | Get current user |
| PATCH | `/api/auth/me` | Update user profile |
| POST | `/api/auth/logout` | End session |
| POST | `/api/auth/reset-password` | Request password reset |
| POST | `/api/auth/reset-password/confirm` | Complete password reset |
| GET | `/api/auth/sessions` | List active sessions |
| DELETE | `/api/auth/sessions/:id` | Revoke specific session |
| DELETE | `/api/auth/sessions` | Revoke all sessions |
| GET | `/api/auth/health` | Auth service health |

### Web3 Authentication Routes

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/auth/web3/nonce` | Get signing nonce for wallet |
| POST | `/api/auth/web3/verify` | Verify wallet signature |
| POST | `/api/auth/web3/link` | Link wallet to existing account |
| GET | `/api/auth/web3/wallets` | List linked wallets |
| DELETE | `/api/auth/web3/wallets/:address` | Unlink wallet |

**Web3 Authentication Flow:**
1. User clicks "Connect Wallet"
2. Frontend calls `GET /api/auth/web3/nonce?address={address}`
3. Backend validates address, generates UUID nonce, returns signing message
4. User signs message in MetaMask
5. Frontend calls `POST /api/auth/web3/verify` with signature
6. Backend verifies signature with `ethers.verifyMessage()`
7. If new wallet: creates wallet-only account with auto-generated email (`{address}@web3.premail.site`)
8. Returns JWT token + user object

### OAuth 2.0 / OIDC Routes

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/oauth/authorize` | OAuth authorization (redirect flow) |
| POST | `/api/oauth/authorize` | Handle login form submission |
| POST | `/api/oauth/token` | Exchange code for tokens |
| GET | `/api/oauth/userinfo` | Get user info (OIDC) |
| GET | `/api/oauth/.well-known/openid-configuration` | OIDC discovery |

**Registered OAuth Clients:**

| Client | Redirect URI | Scopes |
|--------|--------------|--------|
| premail | `https://premail.site/oauth/callback` | openid, profile, email |
| predrive | `https://predrive.eu/oauth/callback` | openid, profile, email |
| preoffice | `https://preoffice.site/oauth/callback` | openid, profile, email |

### PreGPT Routes

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/pregpt/status` | Health check |
| POST | `/api/pregpt/summary` | Streaming AI summary (SSE) |
| POST | `/api/pregpt/ask` | Follow-up questions |
| POST | `/api/pregpt/related-searches` | Related search suggestions |

**Venice AI Models:**
- Fast: `llama-3.2-3b`
- Balanced/Best: `llama-3.3-70b`

---

## Rate Limiting

| Endpoint | Limit |
|----------|-------|
| `/api/auth/register` | 5 req/hour per IP |
| `/api/auth/login` | 10 req/min per IP |
| `/api/auth/reset-password` | 3 req/hour per IP |
| `/api/auth/web3/*` | 10 req/min per IP |
| `/api/oauth/token` | 30 req/min per IP |
| `/api/pregpt/*` | 20 req/min per IP |
| General API | 100 req/min per IP |

---

## Database Schema

### Core Tables

**users:**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id)
email VARCHAR(255) -- Nullable for Web3-only accounts
password_hash VARCHAR(255)
name VARCHAR(100)
wallet_address VARCHAR(42) -- Ethereum address
is_web3 BOOLEAN DEFAULT false
created_at TIMESTAMP
updated_at TIMESTAMP
```

**sessions:**
```sql
id UUID PRIMARY KEY
user_id UUID REFERENCES users(id)
token_hash VARCHAR(255) UNIQUE
device_info JSONB
expires_at TIMESTAMP
created_at TIMESTAMP
```

**refresh_tokens:**
```sql
id UUID PRIMARY KEY
user_id UUID REFERENCES users(id)
token_hash VARCHAR(255) UNIQUE
device_info JSONB
expires_at TIMESTAMP
revoked_at TIMESTAMP
created_at TIMESTAMP
```

### Web3 Tables

**wallet_nonces:**
```sql
id UUID PRIMARY KEY
address VARCHAR(42)
nonce UUID UNIQUE
created_at TIMESTAMP
expires_at TIMESTAMP  -- 5 minute expiry
used_at TIMESTAMP     -- Prevents replay attacks
```

**user_wallets:**
```sql
id UUID PRIMARY KEY
user_id UUID REFERENCES users(id)
address VARCHAR(42) UNIQUE
chain_id INTEGER DEFAULT 1  -- Ethereum mainnet
is_primary BOOLEAN DEFAULT false
created_at TIMESTAMP
```

**web3_mail_credentials:**
```sql
id UUID PRIMARY KEY
user_id UUID UNIQUE REFERENCES users(id)
email VARCHAR(255)
mail_password_hash VARCHAR(255)
created_at TIMESTAMP
updated_at TIMESTAMP
```

---

## Security Middleware

### Security Headers

```javascript
// Applied to all responses
{
  'X-Frame-Options': 'DENY',
  'X-Content-Type-Options': 'nosniff',
  'X-XSS-Protection': '1; mode=block',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
  'Strict-Transport-Security': 'max-age=31536000' // Production only
}
```

### CORS Allowed Origins

```javascript
[
  'https://presuite.eu',
  'https://predrive.eu',
  'https://premail.site',
  'https://preoffice.site',
  'https://presocial.presuite.eu',
  'http://localhost:5173',  // Development
  'http://localhost:3000'
]
```

### Input Validation

- **Email:** RFC 5322 pattern validation
- **Password:** Length + complexity requirements
- **Name:** Letters, numbers, spaces, apostrophes, hyphens only (max 100 chars)
- **Wallet Address:** ethers.getAddress() checksum validation

### Secure Logging

Sensitive fields automatically masked:
- Passwords, tokens, API keys → `[REDACTED]`
- JWTs → `eyJ***[REDACTED]***`
- Emails → `u***@example.com`
- UUIDs → `12345678-****-****-****-************`

---

## Environment Variables

```bash
# Required
JWT_SECRET=<256-bit-random-secret>           # Min 32 characters
DATABASE_URL=postgresql://presuite:pass@localhost:5432/presuite

# OAuth Client Secrets (one per service)
PREMAIL_CLIENT_SECRET=<32-byte-random-hex>
PREDRIVE_CLIENT_SECRET=<32-byte-random-hex>
PREOFFICE_CLIENT_SECRET=<32-byte-random-hex>

# Stalwart Mail Server
STALWART_API_URL=https://mail.premail.site:443
STALWART_ADMIN_USER=admin
STALWART_ADMIN_PASS=<admin-password>

# Venice AI (PreGPT)
VENICE_API_KEY=<api-key>

# Optional
NODE_ENV=development|production
PORT=3001
LOG_LEVEL=info|debug|warn|error
```

---

## Frontend Services

### authService.js

```javascript
// Authentication API client
export async function register({ email, password, name })
export async function login(email, password)
export async function logout()
export async function verifyToken()
export async function getMe()
export async function updateProfile(updates)
export async function changePassword(currentPassword, newPassword)
export async function requestPasswordReset(email)
export async function confirmPasswordReset(token, password)
export async function getSessions()
export async function revokeSession(sessionId)
export async function logoutAll()
```

### web3Auth.js

```javascript
// MetaMask authentication
export function isWeb3Available(): boolean
export async function connectWallet(): Promise<address>
export async function getNonce(address): Promise<{message, nonce}>
export async function signMessage(message): Promise<signature>
export async function verifySignature(address, signature, message): Promise<{user, token}>
export async function web3Login(): Promise<{user, token, isNewUser}>
```

### preBalanceService.js

```javascript
// PRE token balance tracking
export async function getPreBalance()         // Multi-source aggregation
export async function getPreStats()           // Price, market cap from CoinGecko
export async function getPresearchSettings()  // Node API key, wallet address
export async function validateNodeApiKey(apiKey)
export async function validateWalletAddress(address)

// Data sources:
// - Presearch Node API: https://nodes.presearch.com/api/nodes/status/{apiKey}
// - Etherscan: PRE token contract 0xEC213F83defB583af3A000B1c0ada660b1902A0F
// - CoinGecko: https://api.coingecko.com/api/v3/simple/price?ids=presearch
```

---

## Frontend Components

### PreSuiteLaunchpad.jsx

Main dashboard featuring:
- App icon grid (PreMail, PreDrive, PreOffice, etc.)
- Recent files from PreDrive API
- PRE balance card with real data
- Storage usage indicator
- Notifications dropdown
- User profile panel
- Dark mode toggle

### Login.jsx

Dual authentication:
- Email/password form
- Web3 "Connect Wallet" button (MetaMask)
- Glassmorphism dark theme design
- Error handling and loading states

### Register.jsx

Registration with:
- Email or username input (username → @premail.site)
- Password requirements checker (visual feedback)
- Web3 wallet signup option
- Automatic mailbox provisioning

### PreGPTChat.jsx

AI chat interface:
- Streaming responses (Server-Sent Events)
- Message history persistence (localStorage)
- Related searches chips
- Sources dropdown
- Markdown rendering
- Chat history management

---

## Completed Features

### Core
- [x] macOS Launchpad-inspired dashboard
- [x] Glassmorphism dark theme
- [x] Responsive design
- [x] Dark mode toggle
- [x] Keyboard shortcuts (Cmd+K for search)

### Authentication
- [x] Email/password registration and login
- [x] Web3 wallet authentication (MetaMask)
- [x] JWT tokens with refresh token rotation
- [x] Session management
- [x] Password reset flow (UI only)
- [x] OAuth 2.0 / OIDC provider

### Services Integration
- [x] PreMail modal with real API data
- [x] PreDrive modal with real API data
- [x] PreGPT AI chat with Venice AI
- [x] PRE balance from multiple sources
- [x] Stalwart mailbox provisioning

### Security
- [x] Rate limiting per endpoint
- [x] Security headers (CSP, HSTS, etc.)
- [x] Input validation and sanitization
- [x] Secure password hashing (bcrypt)
- [x] Nonce-based Web3 auth (replay protection)
- [x] Secure logging with data masking

---

## Pending Features

- [ ] Email verification for new accounts
- [ ] Password reset email sending (endpoint exists but no email)
- [ ] TOTP/2FA support
- [ ] Redis for auth codes (currently in-memory)
- [ ] Audit logging table
- [ ] Full OIDC compliance (JWKS endpoint)

---

## Server Configuration

### Nginx Config (`/etc/nginx/sites-available/presuite`)

```nginx
server {
    listen 443 ssl;
    server_name presuite.eu www.presuite.eu;

    ssl_certificate /etc/letsencrypt/live/presuite.eu/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/presuite.eu/privkey.pem;

    root /var/www/presuite/dist;
    index index.html;

    # API proxy to Express backend
    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_read_timeout 120s;
        proxy_buffering off;  # Required for SSE streaming
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static asset caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

### PM2 Commands

```bash
# Check status
pm2 status

# Restart backend
pm2 restart presuite

# View logs
pm2 logs presuite

# Start with ecosystem file
pm2 start ecosystem.config.cjs
```

---

## Development Commands

```bash
# Install dependencies
npm install

# Start development (frontend + backend)
npm start

# Frontend only
npm run dev

# Backend only
npm run server

# Build for production
npm run build
```

---

## Deployment Workflow

### Local → GitHub → Server

```bash
# 1. Commit locally
git add -A && git commit -m "Your changes"
git push origin main

# 2. Deploy to server
ssh root@76.13.2.221 "cd /var/www/presuite && git pull && npm install && npm run build && pm2 restart presuite"
```

### Quick Deploy Script

```bash
#!/bin/bash
# /var/www/presuite/deploy.sh
cd /var/www/presuite
git pull origin main
npm install
npm run build
pm2 restart presuite
echo "Deployed successfully"
```

---

## Design Specifications

### Color Palette

```javascript
// Official Presearch colors
const colors = {
  primary: '#0190FF',      // Presearch Azure
  primaryHover: '#0177D6',
  lightTint: '#E6F4FF',

  // Dark theme
  darkBg: '#1E1E1E',
  darkSurface: '#323232',
  dark900: '#191919',

  // Accents
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
};
```

### Glassmorphism

```css
/* Light mode */
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(20px);
border: 1px solid rgba(255, 255, 255, 0.1);

/* Dark mode */
background: rgba(30, 30, 30, 0.8);
backdrop-filter: blur(20px);
border: 1px solid rgba(255, 255, 255, 0.1);
```

---

## Related Documentation

- [API-REFERENCE.md](API-REFERENCE.md) - Complete API documentation
- [PREDRIVE.md](PREDRIVE.md) - PreDrive cloud storage
- [PREMAIL.md](PREMAIL.md) - PreMail email service
- [PREOFFICE.md](PREOFFICE.md) - PreOffice document editing
- [PRESOCIAL.md](PRESOCIAL.md) - PreSocial community

---

*Last updated: January 17, 2026*
