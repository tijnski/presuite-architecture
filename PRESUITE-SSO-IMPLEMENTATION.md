# PreSuite OAuth SSO Implementation

> **Date:** January 15, 2026
> **Author:** Claude Opus 4.5
> **Status:** Completed and Deployed

---

## Overview

This document details the implementation of OAuth 2.0 Single Sign-On (SSO) across all PreSuite services, enabling users to authenticate once and access all applications seamlessly.

### Services Integrated

| Service | URL | Role |
|---------|-----|------|
| PreSuite Hub | https://presuite.eu | Identity Provider (IdP) |
| PreMail | https://premail.site | Service Provider |
| PreDrive | https://predrive.eu | Service Provider |
| PreOffice | https://preoffice.site | Service Provider |

---

## Architecture

### OAuth 2.0 Authorization Code Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Browser   │     │  PreSuite   │     │   Service   │
│   (User)    │     │  Hub (IdP)  │     │  (PreMail)  │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │ 1. Click "Sign in with PreSuite"      │
       │──────────────────────────────────────>│
       │                   │                   │
       │ 2. Redirect to /api/oauth/authorize   │
       │<──────────────────────────────────────│
       │                   │                   │
       │ 3. User authenticates                 │
       │──────────────────>│                   │
       │                   │                   │
       │ 4. Redirect with authorization code   │
       │<──────────────────│                   │
       │                   │                   │
       │ 5. Send code to /oauth/callback       │
       │──────────────────────────────────────>│
       │                   │                   │
       │                   │ 6. Exchange code  │
       │                   │    for tokens     │
       │                   │<──────────────────│
       │                   │                   │
       │                   │ 7. Return tokens  │
       │                   │──────────────────>│
       │                   │                   │
       │ 8. Set session, redirect to app       │
       │<──────────────────────────────────────│
       │                   │                   │
```

### Token Structure

**ID Token (JWT) Claims:**
```json
{
  "sub": "user-uuid",
  "org_id": "org-uuid",
  "email": "user@example.com",
  "name": "User Name",
  "iss": "presuite",
  "aud": "premail",
  "iat": 1736956800,
  "exp": 1736960400
}
```

---

## Implementation Details

### 1. PreSuite Hub - Identity Provider

**File:** `presuite/server.js`

**OAuth Endpoints:**
- `GET /api/oauth/authorize` - Authorization endpoint
- `POST /api/oauth/token` - Token exchange endpoint
- `GET /api/oauth/userinfo` - User info endpoint
- `GET /.well-known/openid-configuration` - OIDC Discovery

**Pre-configured OAuth Clients:**
```javascript
const OAUTH_CLIENTS = {
  premail: {
    client_id: "premail",
    client_secret: process.env.PREMAIL_CLIENT_SECRET || "premail_secret_2026",
    redirect_uris: [
      "https://premail.site/oauth/callback",
      "http://localhost:5173/oauth/callback"
    ],
    scopes: ["openid", "profile", "email"],
  },
  predrive: {
    client_id: "predrive",
    client_secret: process.env.PREDRIVE_CLIENT_SECRET || "predrive_secret_2026",
    redirect_uris: [
      "https://predrive.eu/oauth/callback",
      "http://localhost:5174/oauth/callback"
    ],
    scopes: ["openid", "profile", "email"],
  },
  preoffice: {
    client_id: "preoffice",
    client_secret: process.env.PREOFFICE_CLIENT_SECRET || "preoffice_secret_2026",
    redirect_uris: [
      "https://preoffice.site/oauth/callback",
      "http://localhost:3000/oauth/callback"
    ],
    scopes: ["openid", "profile", "email"],
  },
};
```

**Server:** 76.13.2.221

---

### 2. PreMail - Email Client

**Files Modified:**
- `apps/web/src/pages/OAuthCallbackPage.tsx` (NEW)
- `apps/web/src/pages/LoginPage.tsx`
- `apps/web/src/App.tsx`

**OAuth Callback Handler:**
```typescript
// apps/web/src/pages/OAuthCallbackPage.tsx
const PRESUITE_TOKEN_URL = "https://presuite.eu/api/oauth/token";
const CLIENT_ID = "premail";
const CLIENT_SECRET = "premail_secret_2026";

async function exchangeCodeForToken(code: string) {
  const response = await fetch(PRESUITE_TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "authorization_code",
      code,
      redirect_uri: window.location.origin + "/oauth/callback",
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
    }),
  });

  const data = await response.json();
  // Decode ID token and set auth state
  const payload = JSON.parse(atob(data.id_token.split(".")[1]));

  localStorage.setItem("auth", JSON.stringify({
    token: data.access_token,
    user: {
      id: payload.sub,
      email: payload.email,
      name: payload.name,
      orgId: payload.org_id,
    },
  }));
}
```

**Login Page SSO Button:**
```typescript
// apps/web/src/pages/LoginPage.tsx
function initiateOAuthLogin() {
  const state = crypto.randomUUID();
  sessionStorage.setItem("oauth_state", state);

  const params = new URLSearchParams({
    client_id: "premail",
    redirect_uri: window.location.origin + "/oauth/callback",
    response_type: "code",
    scope: "openid profile email",
    state,
  });

  window.location.href = `https://presuite.eu/api/oauth/authorize?${params}`;
}
```

**Server:** 76.13.1.117

---

### 3. PreDrive - Cloud Storage

**Files Modified:**
- `apps/web/src/hooks/useAuth.ts`
- `apps/web/src/App.tsx`
- `apps/api/src/middleware/auth.ts`

**OAuth Code Exchange:**
```typescript
// apps/web/src/hooks/useAuth.ts
const PRESUITE_TOKEN_URL = 'https://presuite.eu/api/oauth/token';
const OAUTH_CLIENT_ID = 'predrive';
const OAUTH_CLIENT_SECRET = 'predrive_secret_2026';

async function exchangeOAuthCode(code: string): Promise<{ token: string; user: User }> {
  const response = await fetch(PRESUITE_TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: window.location.origin + '/oauth/callback',
      client_id: OAUTH_CLIENT_ID,
      client_secret: OAUTH_CLIENT_SECRET,
    }),
  });

  const data = await response.json();
  const payload = JSON.parse(atob(data.id_token.split('.')[1]));

  return {
    token: data.id_token, // Use ID token for API auth
    user: {
      id: payload.sub,
      email: payload.email,
      name: payload.name,
      orgId: payload.org_id,
    },
  };
}
```

**Auto-Provision Root Folder for SSO Users:**
```typescript
// apps/api/src/middleware/auth.ts
// Always check if root folder exists for this org, create if not
const existingRoot = await db
  .select()
  .from(nodes)
  .where(
    and(
      eq(nodes.orgId, jwtPayload.org_id),
      isNull(nodes.parentId),
      eq(nodes.type, 'folder')
    )
  )
  .limit(1);

if (existingRoot.length === 0) {
  const rootFolderId = randomUUID();
  await db.insert(nodes).values({
    id: rootFolderId,
    orgId: jwtPayload.org_id,
    type: 'folder',
    parentId: null,
    name: 'My Drive',
  });

  // Grant owner permission on root folder
  await db.insert(permissions).values({
    orgId: jwtPayload.org_id,
    nodeId: rootFolderId,
    principalType: 'user',
    principalId: jwtPayload.sub,
    role: 'owner',
    inherited: false,
  });
}
```

**Server:** 76.13.1.110 (Docker)

---

### 4. PreOffice - Document Editor

**Files Modified:**
- `presearch/online/branding/static/index.html`
- `presearch/online/nginx/nginx.conf`

**Landing Page OAuth Handler:**
```javascript
// branding/static/index.html
function initiateOAuthLogin() {
  const state = crypto.randomUUID();
  sessionStorage.setItem('oauth_state', state);

  const params = new URLSearchParams({
    client_id: 'preoffice',
    redirect_uri: window.location.origin + '/oauth/callback',
    response_type: 'code',
    scope: 'openid profile email',
    state: state
  });

  window.location.href = 'https://presuite.eu/api/oauth/authorize?' + params;
}

async function exchangeOAuthCode(code) {
  const response = await fetch('https://presuite.eu/api/oauth/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: window.location.origin + '/oauth/callback',
      client_id: 'preoffice',
      client_secret: 'preoffice_secret_2026'
    })
  });

  const data = await response.json();
  const payload = JSON.parse(atob(data.id_token.split('.')[1]));

  localStorage.setItem('preoffice_auth', JSON.stringify({
    token: data.access_token,
    idToken: data.id_token,
    user: {
      id: payload.sub,
      email: payload.email,
      name: payload.name,
      orgId: payload.org_id
    }
  }));
}
```

**Nginx OAuth Callback Route:**
```nginx
# nginx/nginx.conf
location = /oauth/callback {
    root /var/www/static;
    try_files /index.html =404;
}
```

**Server:** 76.13.2.220 (Docker)

---

## Security Considerations

### CSRF Protection
- State parameter generated with `crypto.randomUUID()`
- State stored in `sessionStorage` before redirect
- State validated on callback before token exchange

### Token Security
- JWT tokens signed with HS256
- Tokens expire after 7 days (configurable via `JWT_EXPIRES_IN`)
- Session sync for coordinated logout planned

### Client Secrets
- Stored in environment variables in production
- Default development secrets for local testing

---

## Deployment

### PreSuite Hub
```bash
ssh root@76.13.2.221 "cd /opt/presuite && git pull && pm2 restart presuite"
```

### PreMail
```bash
cd premail && pnpm run build
rsync -avz apps/web/dist/ root@76.13.1.117:/var/www/premail-web/
```

### PreDrive
```bash
cd PreDrive && pnpm run build
rsync -avz . root@76.13.1.110:/opt/predrive/
ssh root@76.13.1.110 "cd /opt/predrive && docker compose up -d --build"
```

### PreOffice
```bash
rsync -avz preoffice/presearch/online/ root@76.13.2.220:/opt/preoffice/
ssh root@76.13.2.220 "cd /opt/preoffice && docker compose restart nginx"
```

---

## Testing the SSO Flow

1. Navigate to any service (e.g., https://premail.site)
2. Click "Sign in with PreSuite"
3. Authenticate at PreSuite Hub
4. Get redirected back with authorization code
5. Token exchange happens automatically
6. User session created, redirected to app

---

## Known Issues & Future Improvements

### Current Limitations
- Refresh tokens not implemented
- Session sync across services not implemented
- Single logout not implemented

### Planned Improvements
1. **Refresh Token Support** - Automatic token renewal
2. **Session Sync** - Logout from one service logs out all
3. **PKCE** - Enhanced security for public clients
4. **MFA** - Multi-factor authentication at IdP level

---

## Related Documentation

- [PREMAIL.md](PREMAIL.md) - PreMail service documentation
- [API-REFERENCE.md](API-REFERENCE.md) - PreSuite API documentation
- [architecture/](architecture/README.md) - Architecture diagrams
