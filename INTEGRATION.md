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

### Utility Functions (All Databases)

All PreSuite databases include a trigger function for auto-updating timestamps:

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Central User Store (PreSuite Hub)

PreSuite Hub (`presuite.eu`) maintains the authoritative user database:

```
orgs
├── id (uuid, PK)
├── name (varchar)
├── created_at (timestamptz)
└── Trigger: trg_orgs_updated_at

users
├── id (uuid, PK)
├── org_id (uuid, FK → orgs, CASCADE)
├── email (varchar, unique)
├── name (varchar)
├── password_hash (varchar)
├── email_verified (boolean, default FALSE)
├── created_at, updated_at (timestamptz)
└── Trigger: trg_users_updated_at

sessions
├── id (uuid, PK)
├── user_id (uuid, FK → users, CASCADE)
├── token_hash (varchar)
├── expires_at (timestamptz)
├── created_at (timestamptz)
└── Index: idx_sessions_user_id, idx_sessions_expires

registration_sources
├── user_id (uuid, PK, FK → users, CASCADE)
├── source (varchar) -- presuite, premail, predrive, preoffice
└── created_at (timestamptz)
```

#### PreSuite Hub Indexes

| Table | Index | Purpose |
|-------|-------|---------|
| users | `idx_users_email` | Email lookups for auth |
| users | `idx_users_org_id` | Filter users by org |
| sessions | `idx_sessions_user_id` | List user sessions |
| sessions | `idx_sessions_expires` | Cleanup expired sessions |

### Service-Local User Cache

Each service (PreDrive, PreMail) maintains a local cache of user data, synced from JWT claims during auto-provisioning:

```
orgs (cached)
├── id (uuid, PK) -- Same ID as PreSuite Hub
├── name (varchar)
├── created_at, updated_at (timestamptz)
└── Trigger: trg_orgs_updated_at

users (cached)
├── id (uuid, PK) -- Same ID as PreSuite Hub
├── org_id (uuid, FK → orgs, CASCADE)
├── email (varchar, unique)
├── name (varchar)
├── created_at, updated_at (timestamptz)
└── Trigger: trg_users_updated_at
```

**Note:** Service-local user tables do NOT store `password_hash` since authentication is handled centrally by PreSuite Hub. The exception is PreMail which stores `password_hash` for users who registered directly there before migration.

### Service-Specific Tables

Each service extends the base schema with its own tables:

#### PreMail Additions
- `email_accounts` - IMAP/SMTP account connections to Stalwart

#### PreDrive Additions
- `groups`, `group_members` - Permission group management
- `nodes`, `files`, `file_versions` - File storage tree
- `shares`, `permissions` - Sharing and ACL
- `locks` - WebDAV locking
- `upload_sessions` - Multipart upload tracking
- `audit_log` - Activity logging

See `PREDRIVE.md` and `Premail.md` for complete service-specific schemas.

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
