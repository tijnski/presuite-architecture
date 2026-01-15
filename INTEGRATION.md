# PreSuite Integration Guide

This document describes how all PreSuite services integrate and communicate with each other.

## Authentication Architecture

### Overview

**PreSuite Hub** (`presuite.eu`) is the central identity provider for the entire ecosystem. Users can register and login from any service, but all authentication requests are processed by PreSuite Hub.

```
┌─────────────────────────────────────────────────────────────────┐
│                     PreSuite Hub (Identity Provider)             │
│                         presuite.eu                              │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Auth Service                           │   │
│  │  • User Registration    • JWT Token Issuance             │   │
│  │  • Login/Logout         • Password Reset                 │   │
│  │  • Session Management   • Account Verification           │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │ PreMail │          │PreDrive │          │PreOffice│
   │         │          │         │          │         │
   │Register │          │Register │          │Register │
   │ Login   │          │ Login   │          │ Login   │
   └─────────┘          └─────────┘          └─────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Shared Users   │
                    │   & Sessions    │
                    └─────────────────┘
```

### Registration Flow (From Any Service)

Users can create an account from PreSuite Hub, PreMail, PreDrive, or PreOffice. All registration requests are forwarded to PreSuite Hub's Auth API.

```
User clicks "Sign Up" on any service
            │
            ▼
┌─────────────────────────────┐
│   Service Registration UI   │
│  (PreMail/PreDrive/etc.)    │
└─────────────────────────────┘
            │
            │ POST /api/auth/register
            │ { email, password, name, source: "premail" }
            ▼
┌─────────────────────────────┐
│   PreSuite Hub Auth API     │
│   auth.presuite.eu          │
└─────────────────────────────┘
            │
            ├── Create user in central DB
            ├── Create @premail.site mailbox (Stalwart)
            ├── Initialize PreDrive storage
            └── Issue JWT token
            │
            ▼
┌─────────────────────────────┐
│   Return JWT + Redirect     │
│   to originating service    │
└─────────────────────────────┘
```

### Login Flow (From Any Service)

```
User clicks "Login" on any service
            │
            ▼
┌─────────────────────────────┐
│     Service Login UI        │
└─────────────────────────────┘
            │
            │ POST /api/auth/login
            │ { email, password }
            ▼
┌─────────────────────────────┐
│   PreSuite Hub Auth API     │
└─────────────────────────────┘
            │
            ├── Verify credentials
            ├── Generate JWT token
            └── Return token + user info
            │
            ▼
┌─────────────────────────────┐
│   Service stores token      │
│   User is logged in         │
└─────────────────────────────┘
```

---

## PreSuite Auth API

**Base URL:** `https://presuite.eu/api/auth` (or `https://auth.presuite.eu`)

### Endpoints

#### Registration
```http
POST /api/auth/register

Request:
{
  "email": "user@example.com",      // Or just "username" for @premail.site
  "password": "securepassword",
  "name": "Display Name",
  "source": "presuite"              // Which service initiated: presuite|premail|predrive|preoffice
}

Response:
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@premail.site",
    "name": "Display Name",
    "org_id": "uuid"
  },
  "token": "jwt-token",
  "redirect": "https://presuite.eu"  // Or back to source service
}
```

#### Login
```http
POST /api/auth/login

Request:
{
  "email": "user@premail.site",
  "password": "password"
}

Response:
{
  "success": true,
  "user": { ... },
  "token": "jwt-token"
}
```

#### Token Verification
```http
GET /api/auth/verify

Headers:
  Authorization: Bearer <token>

Response:
{
  "valid": true,
  "user": { ... }
}
```

#### Password Reset
```http
POST /api/auth/reset-password

Request:
{
  "email": "user@premail.site"
}

Response:
{
  "success": true,
  "message": "Reset link sent to email"
}
```

#### Logout
```http
POST /api/auth/logout

Headers:
  Authorization: Bearer <token>

Response:
{
  "success": true
}
```

---

## JWT Token Structure

All services use the same JWT payload format:

```typescript
interface PreSuiteJWT {
  sub: string;       // User ID (UUID)
  org_id: string;    // Organization ID (UUID)
  email: string;     // User email (e.g., user@premail.site)
  name?: string;     // Display name
  iss: string;       // Issuer: "presuite"
  iat: number;       // Issued at timestamp
  exp: number;       // Expiration timestamp
}
```

### Token Creation (PreSuite Hub Only)

```javascript
// In PreSuite Hub auth service
import jwt from 'jsonwebtoken';

const token = jwt.sign(
  {
    sub: user.id,
    org_id: user.org_id,
    email: user.email,
    name: user.name
  },
  process.env.JWT_SECRET,
  {
    issuer: 'presuite',
    expiresIn: '7d'
  }
);
```

### Token Verification (All Services)

```javascript
import jwt from 'jsonwebtoken';

const verifyToken = (token: string) => {
  return jwt.verify(token, process.env.JWT_SECRET, {
    issuer: 'presuite'
  });
};
```

---

## Service Integration Patterns

### 1. Embedded Auth Forms

Each service can embed registration/login forms that POST to PreSuite Hub:

```tsx
// PreMail Registration Page
const RegisterPage = () => {
  const handleSubmit = async (data) => {
    const response = await fetch('https://presuite.eu/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...data,
        source: 'premail'  // Track registration source
      })
    });

    const { token, user } = await response.json();

    // Store token locally
    localStorage.setItem('token', token);

    // User is now logged in to PreMail
    navigate('/inbox');
  };

  return <RegistrationForm onSubmit={handleSubmit} />;
};
```

### 2. OAuth-Style Redirect (Optional)

For a more traditional SSO experience:

```
1. User clicks "Login" on PreDrive
2. Redirect to: https://presuite.eu/login?redirect=https://predrive.eu/callback
3. User logs in on PreSuite Hub
4. Redirect back: https://predrive.eu/callback?token=<JWT>
5. PreDrive stores token and logs user in
```

### 3. Cross-Service Navigation

Once logged in, users can navigate between services with their token:

```tsx
// PreMail Sidebar
<a href={`https://predrive.eu?token=${auth.token}`}>
  <HardDrive /> PreDrive
</a>

<a href={`https://preoffice.site?token=${auth.token}`}>
  <FileText /> PreOffice
</a>
```

---

## Service-to-Service Integration

### PreDrive → PreOffice (WOPI)

When editing documents, PreDrive passes the user's token to PreOffice:

```typescript
const openInPreOffice = async (file: Node) => {
  const response = await fetch('https://preoffice.site/api/edit', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      fileId: file.id,
      fileName: file.name
    })
  });

  const { editorUrl } = await response.json();
  window.location.href = editorUrl;
};
```

### PreSuite Hub → PreMail (Mailbox Provisioning)

When a user registers, PreSuite Hub creates their email account:

```javascript
// In PreSuite Hub registration handler
async function createMailbox(user) {
  // Create Stalwart mailbox via API
  await fetch(`${STALWART_API_URL}/api/principal`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${Buffer.from(`admin:${STALWART_ADMIN_PASS}`).toString('base64')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      type: 'individual',
      name: user.email.split('@')[0],
      secrets: [hashedPassword],
      emails: [user.email],
      quota: 1073741824,  // 1GB
      enabledPermissions: [
        'authenticate', 'email-send', 'email-receive',
        'imap-authenticate', 'imap-list', 'imap-fetch', // ... etc
      ]
    })
  });
}
```

### PreSuite Hub → PreDrive (Storage Provisioning)

On registration, PreSuite Hub initializes the user's drive:

```javascript
async function initializeDrive(user) {
  // PreDrive auto-provisions from JWT on first access
  // But we can also explicitly create via API
  await fetch('https://predrive.eu/api/provision', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${internalServiceToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      userId: user.id,
      orgId: user.org_id,
      email: user.email,
      quota: 5 * 1024 * 1024 * 1024  // 5GB
    })
  });
}
```

---

## Auto-Provisioning (Fallback)

If a user somehow accesses a service without being provisioned, services should auto-provision from JWT claims:

```typescript
// apps/api/src/middleware/auth.ts (PreDrive/PreMail)
async function autoProvision(payload: PreSuiteJWT) {
  // Check if org exists
  let org = await db.query.orgs.findFirst({
    where: eq(orgs.id, payload.org_id)
  });

  if (!org) {
    [org] = await db.insert(orgs).values({
      id: payload.org_id,
      name: `${payload.email.split('@')[0]}'s Organization`
    }).returning();
  }

  // Check if user exists
  let user = await db.query.users.findFirst({
    where: eq(users.id, payload.sub)
  });

  if (!user) {
    [user] = await db.insert(users).values({
      id: payload.sub,
      orgId: payload.org_id,
      email: payload.email,
      name: payload.name || payload.email
    }).returning();

    // Service-specific initialization
    await initializeUserResources(user);
  }

  return user;
}
```

---

## Database Architecture

### Central User Store (PreSuite Hub)

PreSuite Hub maintains the authoritative user database:

```sql
-- PreSuite Hub Database

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE registration_sources (
  user_id UUID NOT NULL REFERENCES users(id),
  source VARCHAR(50) NOT NULL,  -- presuite, premail, predrive, preoffice
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id)
);
```

### Service-Local User Cache

Each service maintains a local cache of user data (synced from JWT claims):

```sql
-- PreDrive/PreMail local tables
CREATE TABLE users (
  id UUID PRIMARY KEY,  -- Same ID as PreSuite Hub
  org_id UUID NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  -- No password_hash - auth handled by Hub
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Environment Variables

### PreSuite Hub (Identity Provider)

```bash
# Database (central user store)
DATABASE_URL=postgresql://presuite:password@localhost:5432/presuite

# Auth
JWT_SECRET=<shared-secret>
JWT_ISSUER=presuite

# Stalwart (for mailbox provisioning)
STALWART_API_URL=https://mail.premail.site:443
STALWART_ADMIN_USER=admin
STALWART_ADMIN_PASS=<password>

# Service URLs (for redirects)
PREDRIVE_URL=https://predrive.eu
PREMAIL_URL=https://premail.site
PREOFFICE_URL=https://preoffice.site
```

### Other Services

```bash
# Auth (points to Hub)
AUTH_API_URL=https://presuite.eu/api/auth
JWT_SECRET=<same-shared-secret>
JWT_ISSUER=presuite

# Service-specific config
DATABASE_URL=...
```

---

## CORS Configuration

PreSuite Hub must accept requests from all services:

```typescript
// PreSuite Hub CORS config
const corsOptions = {
  origin: [
    'https://presuite.eu',
    'https://predrive.eu',
    'https://premail.site',
    'https://preoffice.site',
    // Development
    'http://localhost:3000',
    'http://localhost:5173',
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
};
```

---

## Health Checks

| Service | Endpoint |
|---------|----------|
| PreSuite Hub Auth | `https://presuite.eu/api/auth/health` |
| PreSuite Hub | `https://presuite.eu/api/pregpt/status` |
| PreDrive | `https://predrive.eu/health` |
| PreMail | `https://premail.site/health` |
| PreOffice | `https://preoffice.site/health` |

---

## Migration from Current Architecture

If migrating from PreMail as identity provider:

1. **Export users from PreMail database**
2. **Import to PreSuite Hub database**
3. **Update PreMail to use Hub for auth**
4. **Update other services to use Hub**
5. **Keep JWT_SECRET the same** (tokens remain valid)

---

*Last Updated: January 2026*
