# PreSuite Integration Guide

How all PreSuite services integrate and communicate with each other.

> **Last Updated:** January 16, 2026

---

## Current Integration Status

| Integration | Status | Notes |
|-------------|--------|-------|
| PreSuite Hub → PreDrive Widget | ✅ Working | Real-time file sync on presuite.eu |
| PreSuite Hub → PreMail Widget | 🔴 Not Working | CORS configured, but PreMail API returns errors |
| SSO Token Pass-through | ✅ Working | Token appended to cross-service links |
| Cross-Origin CORS | ✅ Configured | presuite.eu allowed on both services |

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [SSO Authentication Flow](#sso-authentication-flow)
3. [JWT Token Specification](#jwt-token-specification)
4. [Database Architecture](#database-architecture)
5. [Service Integration Patterns](#service-integration-patterns)
6. [Auto-Provisioning](#auto-provisioning)
7. [Environment Variables](#environment-variables)
8. [Security Considerations](#security-considerations)

---

## Architecture Overview

PreSuite uses a **centralized Single Sign-On (SSO)** architecture where PreSuite Hub acts as the Identity Provider (IdP) for all services.

```
┌─────────────────────────────────────────────────────────────────────┐
│                 PRESUITE HUB (Identity Provider)                     │
│                      https://presuite.eu                             │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                     Authentication Service                      │ │
│  │                                                                 │ │
│  │  • User Registration (creates user + provisions services)      │ │
│  │  • Login / Logout (issues & invalidates JWT tokens)            │ │
│  │  • Password Reset (secure token-based flow)                    │ │
│  │  • OAuth 2.0 Provider (authorization code + PKCE)              │ │
│  │  • Session Management (track active sessions)                  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Database: presuite (PostgreSQL)                                     │
│  └── users, orgs, sessions, oauth_clients, auth_events              │
└─────────────────────────────────────────────────────────────────────┘
                                │
                    JWT Token (HS256)
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│    PreMail    │       │   PreDrive    │       │   PreOffice   │
│premail.site   │       │ predrive.eu   │       │preoffice.site │
│               │       │               │       │               │
│ JWT Verify    │       │ JWT Verify    │       │ JWT Verify    │
│ Auto-Provision│       │ Auto-Provision│       │ WOPI Token    │
│               │       │               │       │               │
│ DB: premail   │       │ DB: predrive  │       │ (Stateless)   │
└───────────────┘       └───────────────┘       └───────────────┘
```

### Key Principles

1. **Single Source of Truth**: User accounts exist only in PreSuite Hub
2. **Stateless Authentication**: Services validate JWT tokens locally using shared secret
3. **Auto-Provisioning**: Services create local user cache on first token validation
4. **Consistent User IDs**: Same UUID across all services for the same user

---

## SSO Authentication Flow

### Registration (From Any Service)

Users can register from any service. All requests go to PreSuite Hub.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   User Browser  │     │  Service (e.g.  │     │  PreSuite Hub   │
│                 │     │    PreMail)     │     │                 │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         │  1. Submit Form       │                       │
         │  {email, password,    │                       │
         │   name}               │                       │
         │──────────────────────▶│                       │
         │                       │                       │
         │                       │  2. POST /api/auth/register
         │                       │  {email, password, name,
         │                       │   source: "premail"}  │
         │                       │──────────────────────▶│
         │                       │                       │
         │                       │                       │ 3. Create user in DB
         │                       │                       │ 4. Create Stalwart mailbox
         │                       │                       │ 5. Issue JWT token
         │                       │                       │
         │                       │  6. {token, user}     │
         │                       │◀──────────────────────│
         │                       │                       │
         │  7. Store token       │                       │
         │  Redirect to app      │                       │
         │◀──────────────────────│                       │
         │                       │                       │
```

### Login Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   User Browser  │     │     Service     │     │  PreSuite Hub   │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         │  1. POST /login       │                       │
         │  {email, password}    │                       │
         │──────────────────────▶│                       │
         │                       │                       │
         │                       │  2. POST /api/auth/login
         │                       │  {email, password}    │
         │                       │──────────────────────▶│
         │                       │                       │
         │                       │                       │ 3. Verify credentials
         │                       │                       │ 4. Create session
         │                       │                       │ 5. Issue JWT token
         │                       │                       │
         │                       │  6. {token, user}     │
         │                       │◀──────────────────────│
         │                       │                       │
         │  7. Set token in      │                       │
         │     localStorage      │                       │
         │◀──────────────────────│                       │
```

### Cross-Service Navigation

When a user navigates between services, the token is passed via URL or header:

```
User on PreMail → clicks "PreDrive" → https://predrive.eu?token=<JWT>
                                              │
                                              ▼
                                    PreDrive extracts token
                                              │
                                              ▼
                                    Validates JWT signature
                                              │
                                              ▼
                                    Auto-provisions user if needed
                                              │
                                              ▼
                                    User is logged in
```

### OAuth 2.0 Flow (For Third-Party Integrations)

```
1. Client redirects to:
   https://presuite.eu/api/oauth/authorize?
     client_id=premail&
     redirect_uri=https://premail.site/oauth/callback&
     response_type=code&
     scope=openid+profile+email&
     state=<random>&
     code_challenge=<sha256>&      # PKCE
     code_challenge_method=S256

2. User authenticates on PreSuite Hub

3. Hub redirects back with authorization code:
   https://premail.site/oauth/callback?code=<auth_code>&state=<random>

4. Service exchanges code for token:
   POST https://presuite.eu/api/oauth/token
   {
     grant_type: "authorization_code",
     code: "<auth_code>",
     redirect_uri: "https://premail.site/oauth/callback",
     client_id: "premail",
     client_secret: "<secret>",
     code_verifier: "<original_verifier>"   # PKCE
   }

5. Hub returns JWT token
```

---

## JWT Token Specification

### Token Structure

```typescript
interface PreSuiteJWT {
  // Standard Claims
  sub: string;      // User ID (UUID) - PRIMARY IDENTIFIER
  iss: "presuite";  // Issuer - always "presuite"
  iat: number;      // Issued at (Unix timestamp)
  exp: number;      // Expiration (Unix timestamp)

  // Custom Claims
  org_id: string;   // Organization ID (UUID)
  email: string;    // User email address
  name?: string;    // Display name (optional)
}
```

### Token Configuration

| Setting | Value | Notes |
|---------|-------|-------|
| Algorithm | HS256 | HMAC-SHA256 symmetric signing |
| Expiration | 7 days | Configurable via `JWT_EXPIRES_IN` |
| Issuer | `presuite` | Must be verified on all services |

### Example Token Payload

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "org_id": "660e8400-e29b-41d4-a716-446655440001",
  "email": "user@premail.site",
  "name": "John Doe",
  "iss": "presuite",
  "iat": 1737043200,
  "exp": 1737648000
}
```

### Token Validation (All Services)

```typescript
import jwt from 'jsonwebtoken';

function validateToken(token: string): PreSuiteJWT {
  return jwt.verify(token, process.env.JWT_SECRET, {
    issuer: 'presuite',
    algorithms: ['HS256']
  }) as PreSuiteJWT;
}
```

---

## Database Architecture

### Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PRESUITE DATABASE (Source of Truth)               │
│                                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐ │
│  │   orgs   │  │  users   │  │ sessions │  │ registration_sources │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────────┘ │
│                                                                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │ oauth_clients    │  │ oauth_codes      │  │ auth_events      │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                      │
│  ┌─────────────────────────┐  ┌──────────────────────────────────┐  │
│  │ password_reset_tokens   │  │ email_verification_tokens        │  │
│  └─────────────────────────┘  └──────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    PREMAIL DATABASE (Service-Specific)               │
│                                                                      │
│  ┌───────────────────────────────────────┐                          │
│  │  orgs / users (CACHE from presuite)   │  ← Auto-synced from JWT  │
│  └───────────────────────────────────────┘                          │
│                                                                      │
│  ┌────────────────┐  ┌───────────────┐  ┌──────────────────────┐    │
│  │ email_accounts │  │ email_folders │  │ email_signatures     │    │
│  └────────────────┘  └───────────────┘  └──────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    PREDRIVE DATABASE (Service-Specific)              │
│                                                                      │
│  ┌───────────────────────────────────────┐                          │
│  │  orgs / users (CACHE from presuite)   │  ← Auto-synced from JWT  │
│  └───────────────────────────────────────┘                          │
│                                                                      │
│  ┌───────┐  ┌───────┐  ┌───────────────┐  ┌─────────────────────┐   │
│  │ nodes │  │ files │  │ file_versions │  │ groups/group_members│   │
│  └───────┘  └───────┘  └───────────────┘  └─────────────────────┘   │
│                                                                      │
│  ┌────────┐  ┌─────────────┐  ┌───────┐  ┌─────────────────────┐    │
│  │ shares │  │ permissions │  │ locks │  │ upload_sessions     │    │
│  └────────┘  └─────────────┘  └───────┘  └─────────────────────┘    │
│                                                                      │
│  ┌───────────┐                                                       │
│  │ audit_log │                                                       │
│  └───────────┘                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Points

1. **PreSuite Hub** is the only service with `password_hash` in users table
2. **PreMail/PreDrive** cache user data locally (no passwords)
3. **User IDs are consistent** - same UUID across all databases
4. **Org IDs are consistent** - same UUID across all databases

### Database Initialization

Run the unified init script:

```bash
psql -U postgres -f scripts/init-db.sql
```

This creates all three databases with proper schemas and relationships.

---

## Service Integration Patterns

### Pattern 1: Embedded Auth Forms

Services embed login/register forms that POST directly to PreSuite Hub:

```tsx
// PreMail Registration
async function handleRegister(data: RegisterForm) {
  const response = await fetch('https://presuite.eu/api/auth/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: data.email,
      password: data.password,
      name: data.name,
      source: 'premail'  // Track registration source
    })
  });

  const { token, user } = await response.json();
  localStorage.setItem('token', token);
  navigate('/inbox');
}
```

### Pattern 2: Token Pass-Through

When navigating between services, pass the token:

```tsx
// Link to PreDrive from PreMail
<a href={`https://predrive.eu?token=${auth.token}`}>
  Open PreDrive
</a>
```

### Pattern 3: Service-to-Service API

Services communicate with each other using internal tokens:

```typescript
// PreSuite Hub → PreDrive: Initialize storage
async function initializeUserStorage(user: User) {
  await fetch('https://predrive.eu/api/internal/provision', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${INTERNAL_SERVICE_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      userId: user.id,
      orgId: user.org_id,
      quota: 5 * 1024 * 1024 * 1024  // 5GB
    })
  });
}
```

### Pattern 4: PreDrive → PreOffice (WOPI)

```typescript
// Open document in PreOffice
async function openInEditor(file: FileNode) {
  const response = await fetch('https://preoffice.site/api/edit', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      fileId: file.id,
      fileName: file.name
    })
  });

  const { editorUrl } = await response.json();
  window.open(editorUrl, '_blank');
}
```

---

## Auto-Provisioning

When a user accesses a service for the first time, the service automatically creates local records from JWT claims.

### Auto-Provision Middleware

```typescript
// apps/api/src/middleware/auth.ts
async function authMiddleware(c: Context, next: Next) {
  const token = extractToken(c.req);
  const payload = validateToken(token);

  // Check if org exists locally
  let org = await db.query.orgs.findFirst({
    where: eq(orgs.id, payload.org_id)
  });

  if (!org) {
    // Create org from JWT claims
    [org] = await db.insert(orgs).values({
      id: payload.org_id,
      name: `${payload.email.split('@')[0]}'s Organization`
    }).returning();
  }

  // Check if user exists locally
  let user = await db.query.users.findFirst({
    where: eq(users.id, payload.sub)
  });

  if (!user) {
    // Create user from JWT claims
    [user] = await db.insert(users).values({
      id: payload.sub,
      orgId: payload.org_id,
      email: payload.email,
      name: payload.name || payload.email
    }).returning();

    // Service-specific initialization
    await initializeUserResources(user);
  }

  c.set('user', user);
  c.set('org', org);
  await next();
}
```

### Service-Specific Initialization

**PreDrive:**
```typescript
async function initializeUserResources(user: User) {
  // Create root folder
  await db.insert(nodes).values({
    orgId: user.orgId,
    type: 'folder',
    name: 'My Drive',
    createdBy: user.id
  });
}
```

**PreMail:**
```typescript
async function initializeUserResources(user: User) {
  // Create default email account linked to Stalwart
  await db.insert(emailAccounts).values({
    userId: user.id,
    engineAccountId: `stalwart:${user.email.split('@')[0]}`,
    displayName: user.name,
    email: user.email,
    provider: 'stalwart',
    status: 'connected'
  });
}
```

---

## Environment Variables

### PreSuite Hub (Identity Provider)

```bash
# Server
PORT=3000
NODE_ENV=production

# Database
DATABASE_URL=postgresql://presuite_user:password@localhost:5432/presuite

# JWT (CRITICAL - must match all services)
JWT_SECRET=<256-bit-random-secret>
JWT_ISSUER=presuite
JWT_EXPIRES_IN=7d

# Stalwart Mail (for mailbox provisioning)
STALWART_API_URL=https://mail.premail.site:443
STALWART_ADMIN_USER=admin
STALWART_ADMIN_PASS=<password>

# OAuth Client Secrets
PREMAIL_CLIENT_SECRET=<random-secret>
PREDRIVE_CLIENT_SECRET=<random-secret>
PREOFFICE_CLIENT_SECRET=<random-secret>

# Service URLs
PREDRIVE_URL=https://predrive.eu
PREMAIL_URL=https://premail.site
PREOFFICE_URL=https://preoffice.site
```

### PreMail / PreDrive / PreOffice (Service Providers)

```bash
# Server
PORT=3001
NODE_ENV=production

# Database (service-specific)
DATABASE_URL=postgresql://premail_user:password@localhost:5432/premail

# JWT (CRITICAL - must match Hub)
JWT_SECRET=<same-256-bit-secret-as-hub>
JWT_ISSUER=presuite

# Auth API (Hub endpoint)
AUTH_API_URL=https://presuite.eu/api/auth

# OAuth (for OAuth flow)
OAUTH_CLIENT_ID=premail
OAUTH_CLIENT_SECRET=<matching-secret>
OAUTH_REDIRECT_URI=https://premail.site/oauth/callback
```

### Critical Requirements

| Variable | Requirement |
|----------|-------------|
| `JWT_SECRET` | **MUST be identical** across all services |
| `JWT_ISSUER` | Must be `presuite` on all services |
| `AUTH_API_URL` | All services must point to PreSuite Hub |

---

## Security Considerations

### Token Security

1. **HTTPS Only**: All endpoints require HTTPS
2. **Short-lived Tokens**: 7-day expiration with session tracking
3. **Secure Storage**: Tokens stored in localStorage (consider httpOnly cookies)
4. **Token Rotation**: Consider implementing refresh tokens

### Password Security

1. **Bcrypt**: Cost factor 12 for password hashing
2. **Reset Tokens**: Single-use, time-limited (1 hour)
3. **Rate Limiting**: 5 registrations/hour, 10 logins/minute per IP

### Cross-Service Security

1. **CORS**: Restricted to PreSuite domains only
2. **Service Tokens**: Internal API calls use separate service tokens
3. **PKCE**: OAuth flow requires code challenge

### Audit Trail

PreSuite Hub logs all authentication events:

```sql
-- auth_events table
SELECT event_type, success, ip_address, created_at
FROM auth_events
WHERE user_id = '<user-id>'
ORDER BY created_at DESC;
```

### Session Management

```sql
-- Active sessions
SELECT device_info, last_active_at, expires_at
FROM sessions
WHERE user_id = '<user-id>'
  AND expires_at > NOW();

-- Invalidate all sessions (logout everywhere)
DELETE FROM sessions WHERE user_id = '<user-id>';
```

---

## API Quick Reference

### PreSuite Hub Auth API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Create account |
| POST | `/api/auth/login` | Authenticate |
| GET | `/api/auth/verify` | Validate token |
| GET | `/api/auth/me` | Get current user |
| PATCH | `/api/auth/me` | Update profile |
| POST | `/api/auth/logout` | Invalidate session |
| POST | `/api/auth/reset-password` | Request reset |
| POST | `/api/auth/reset-password/confirm` | Complete reset |
| POST | `/api/auth/me/password` | Change password |

### OAuth Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/oauth/authorize` | Start OAuth flow |
| POST | `/api/oauth/token` | Exchange code for token |
| GET | `/api/oauth/userinfo` | Get user info |
| GET | `/.well-known/openid-configuration` | OIDC discovery |

---

## Troubleshooting

### "Invalid Token" Error

1. Check `JWT_SECRET` matches across services
2. Verify token hasn't expired
3. Confirm issuer is `presuite`

### User Not Found After Login

1. Auto-provisioning may have failed
2. Check service database connectivity
3. Verify JWT payload contains required claims

### CORS Errors

1. Ensure origin is in allowed list
2. Check preflight (OPTIONS) handling
3. Verify credentials mode matches

---

*See also: [API-REFERENCE.md](API-REFERENCE.md) for complete API documentation*
