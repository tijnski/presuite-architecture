# PreSuite Integration Guide

This document describes how all PreSuite services integrate and communicate with each other.

## Authentication Flow

### JWT Token Structure

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

### Token Creation (PreMail)

```javascript
// In PreMail auth.ts
import jwt from 'jsonwebtoken';

const token = jwt.sign(
  {
    sub: user.id,
    org_id: user.org_id,
    email: user.email,
    name: user.name
  },
  process.env.JWT_SECRET,  // Shared secret
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

## Service-to-Service Integration

### 1. PreMail → PreDrive (SSO)

**Flow:**
1. User logs into PreMail
2. User clicks "PreDrive" in sidebar
3. PreMail redirects to `https://predrive.eu?token=<JWT>`
4. PreDrive validates token and auto-provisions user

**PreMail Sidebar Implementation:**
```tsx
// apps/web/src/layouts/AppLayout.tsx
<a href={`https://predrive.eu?token=${auth.token}`}>
  <HardDrive /> PreDrive
</a>
```

**PreDrive Token Handler:**
```typescript
// apps/web/src/hooks/useAuth.ts
useEffect(() => {
  const params = new URLSearchParams(window.location.search);
  const token = params.get('token');

  if (token) {
    // Validate token
    fetch('/api/me', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    .then(res => res.json())
    .then(user => {
      localStorage.setItem('token', token);
      // Clean URL
      window.history.replaceState({}, '', '/');
    });
  }
}, []);
```

### 2. PreDrive → PreOffice (WOPI)

**Flow:**
1. User clicks "Open in PreOffice" on a document in PreDrive
2. PreDrive calls PreOffice API with file info
3. PreOffice generates editor URL with access token
4. User is redirected to Collabora editor
5. Collabora uses WOPI to fetch/save via PreDrive API

**PreDrive Edit Button:**
```typescript
// apps/web/src/components/FileActions.tsx
const openInPreOffice = async (file: Node) => {
  const response = await fetch('https://preoffice.site/api/edit', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      fileId: file.id,
      fileName: file.name,
      userToken: token
    })
  });

  const { editorUrl } = await response.json();
  window.location.href = editorUrl;
};
```

**PreOffice WOPI Edit Endpoint:**
```javascript
// wopi-server/src/index.js
app.post('/api/edit', async (req, res) => {
  const { fileId, fileName, userToken } = req.body;

  // Generate WOPI access token
  const accessToken = jwt.sign(
    {
      userId: decoded.sub,
      fileId: fileId,
      userToken: userToken  // Pass through for PreDrive API calls
    },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );

  // Build editor URL
  const wopiSrc = encodeURIComponent(
    `${WOPI_BASE_URL}/files/${fileId}`
  );
  const editorUrl =
    `${COLLABORA_PUBLIC_URL}/browser/dist/cool.html` +
    `?WOPISrc=${wopiSrc}&access_token=${accessToken}`;

  res.json({ editorUrl });
});
```

### 3. PreSuite Hub → All Services

**Integration Points:**
- PreGPT AI via Venice AI API
- Quick links to all services
- Storage/balance widgets (currently mock data)

**Future Integration:**
```typescript
// Unified dashboard API
interface PreSuiteDashboard {
  // From PreDrive
  storage: {
    used: number;
    total: number;
    recentFiles: File[];
  };

  // From PreMail
  email: {
    unreadCount: number;
    recentEmails: Email[];
  };

  // From PreWallet (future)
  wallet: {
    balance: number;
    recentTransactions: Transaction[];
  };
}
```

---

## Auto-Provisioning

When a user from PreMail accesses PreDrive for the first time:

```typescript
// apps/api/src/middleware/auth.ts (PreDrive)
async function autoProvision(payload: PreSuiteJWT) {
  // Check if org exists
  let org = await db.query.orgs.findFirst({
    where: eq(orgs.id, payload.org_id)
  });

  if (!org) {
    // Create org
    [org] = await db.insert(orgs).values({
      id: payload.org_id,
      name: `${payload.email.split('@')[0]}'s Organization`
    }).returning();

    // Create root folder
    await db.insert(nodes).values({
      orgId: org.id,
      type: 'folder',
      name: 'My Drive',
      parentId: null
    });
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
  }

  return user;
}
```

---

## Shared Database Schema

### Common Tables

All services that share users maintain compatible schemas:

```sql
-- Organizations (shared concept)
CREATE TABLE orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users (shared format)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),  -- Only in PreMail
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### ID Synchronization

- User IDs and Org IDs are UUIDs generated by PreMail at registration
- These IDs are embedded in JWT tokens
- Other services use the same IDs for consistency

---

## API Gateway Pattern (Future)

For unified API access:

```
                  ┌─────────────────┐
                  │   API Gateway   │
                  │ api.presuite.eu │
                  └────────┬────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   /mail/*            /drive/*          /office/*
   → PreMail          → PreDrive        → PreOffice
```

**Gateway Routes:**
```nginx
# Future gateway configuration
location /mail/ {
    proxy_pass https://premail.site/api/;
}

location /drive/ {
    proxy_pass https://predrive.eu/api/;
}

location /office/ {
    proxy_pass https://preoffice.site/api/;
}
```

---

## Environment Variable Template

```bash
# === SHARED (MUST MATCH EVERYWHERE) ===
JWT_SECRET=your-shared-jwt-secret
JWT_ISSUER=presuite

# === PreMail (76.13.1.117) ===
PREMAIL_DATABASE_URL=postgresql://premail:password@localhost:5432/premail
STALWART_HOST=mail.premail.site
STALWART_ADMIN_PASS=your-stalwart-admin-password
PREDRIVE_URL=https://predrive.eu

# === PreDrive (76.13.1.110) ===
PREDRIVE_DATABASE_URL=postgres://predrive:password@postgres:5432/predrive
S3_ENDPOINT=https://gateway.eu1.storjshare.io
S3_ACCESS_KEY_ID=your-storj-access-key
S3_SECRET_ACCESS_KEY=your-storj-secret-key
S3_BUCKET=predrive
PREMAIL_URL=https://premail.site
PREOFFICE_URL=https://preoffice.site

# === PreOffice (76.13.2.220) ===
PREDRIVE_API_URL=https://predrive.eu/api
WOPI_BASE_URL=https://preoffice.site/wopi
COLLABORA_PUBLIC_URL=https://preoffice.site
COLLABORA_ADMIN_USER=admin
COLLABORA_ADMIN_PASS=your-collabora-admin-password

# === PreSuite (76.13.2.221) ===
VENICE_API_KEY=your-venice-api-key
```

---

## Cross-Origin Configuration

Each service needs CORS headers for cross-service communication:

```typescript
// Common CORS config
const corsOptions = {
  origin: [
    'https://presuite.eu',
    'https://predrive.eu',
    'https://premail.site',
    'https://preoffice.site',
    /\.presearch\.org$/  // Future subdomain pattern
  ],
  credentials: true
};
```

---

## Health Checks

Each service exposes health endpoints:

| Service | Endpoint | Port |
|---------|----------|------|
| PreSuite | `/api/pregpt/status` | 3001 |
| PreDrive | `/health` | 4000 |
| PreMail | `/health` | 4001 |
| PreOffice | `/health` | 8080 |

**Unified Health Check Script:**
```bash
#!/bin/bash
services=(
  "presuite:https://presuite.eu/api/pregpt/status"
  "predrive:https://predrive.eu/health"
  "premail:https://premail.site/health"
  "preoffice:https://preoffice.site/health"
)

for service in "${services[@]}"; do
  name="${service%%:*}"
  url="${service#*:}"
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$name: $status"
done
```

---

## Deployment Coordination

When updating shared infrastructure:

1. **JWT Secret Rotation:**
   - Update all services simultaneously
   - Use rolling restart to minimize downtime
   - Clear all active sessions

2. **Database Migrations:**
   - Coordinate if schema changes affect shared tables
   - PreMail owns `users` table definition
   - Other services should follow

3. **SSL Certificate Renewal:**
   - Each service handles its own SSL via Let's Encrypt/Certbot
   - Monitor expiration dates across all domains

---

*Last Updated: January 2026*
