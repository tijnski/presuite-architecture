# PreDrive - Architecture Reference Document

## Overview

PreDrive is a cloud storage application similar to Google Drive, built as part of the Presearch/Presuite ecosystem. It provides file storage, sharing, and WebDAV access with SSO integration to PreMail.

**Production URL:** https://predrive.eu
**Production Server:** 76.13.1.110
**SSO Partner:** PreMail at https://premail.site (server 76.13.1.117)

## GitHub Repository
- **URL:** https://github.com/tijnski/predrive
- **Branch:** main

---

## Technology Stack

### Backend
- **Runtime:** Node.js 20+
- **Framework:** Hono (lightweight web framework)
- **Database:** PostgreSQL 16 with Drizzle ORM
- **Storage:** S3-compatible (Storj in production)
- **Cache:** Valkey (Redis-compatible)
- **Auth:** JWT with HS256 symmetric signing

### Frontend
- **Framework:** React 18 with TypeScript
- **Build Tool:** Vite
- **State Management:** Zustand
- **Styling:** Tailwind CSS
- **Icons:** Lucide React

### Infrastructure
- **Package Manager:** pnpm 9 with workspaces
- **Monorepo Tool:** Turborepo
- **Containerization:** Docker with multi-stage builds
- **Reverse Proxy:** Caddy (auto HTTPS)

---

## Project Structure

```
PreDrive/
├── apps/
│   ├── api/                 # Backend API server (Hono)
│   │   └── src/
│   │       ├── index.ts     # Main entry point
│   │       ├── middleware/
│   │       │   └── auth.ts  # JWT/Basic auth middleware
│   │       └── routes/
│   │           ├── nodes.ts        # File/folder CRUD
│   │           ├── shares.ts       # Share link management
│   │           ├── permissions.ts  # ACL management
│   │           ├── verification.ts # File integrity checks
│   │           ├── integrations.ts # External integrations
│   │           └── provision.ts    # Internal provisioning API
│   │
│   └── web/                 # Frontend React app
│       └── src/
│           ├── App.tsx      # Main app component
│           ├── api/         # API client functions
│           ├── components/  # React components
│           ├── hooks/       # Custom React hooks
│           ├── store/       # Zustand state store
│           └── lib/         # Utility functions
│
├── packages/
│   ├── db/                  # Database package
│   │   ├── src/
│   │   │   ├── schema.ts    # Drizzle schema definitions
│   │   │   ├── client.ts    # Database client
│   │   │   └── migrate.ts   # Migration runner
│   │   └── drizzle/         # SQL migrations
│   │
│   ├── shared/              # Shared types and utilities
│   │   └── src/
│   │       ├── types.ts     # TypeScript types
│   │       ├── errors.ts    # Error definitions
│   │       └── validators.ts # Zod validators
│   │
│   ├── storage/             # S3 storage abstraction
│   │   └── src/
│   │       ├── s3-provider.ts # S3 implementation
│   │       └── types.ts       # Storage interfaces
│   │
│   └── webdav/              # WebDAV protocol implementation
│       └── src/
│           ├── router.ts    # WebDAV router
│           ├── handlers/    # HTTP method handlers
│           └── xml-utils.ts # XML parsing utilities
│
├── deploy/
│   ├── Dockerfile           # Production Docker image
│   └── docker-compose.prod.yml # Production compose file
│
└── docker/
    └── docker-compose.yml   # Development compose file
```

---

## Database Schema

### Core Tables

```
orgs
├── id (uuid, PK)
├── name (varchar)
├── created_at, updated_at (timestamp)

users
├── id (uuid, PK)
├── org_id (uuid, FK → orgs)
├── email (varchar, unique)
├── name (varchar)
├── password_hash (varchar, nullable)
├── created_at, updated_at (timestamp)

nodes (files and folders in tree structure)
├── id (uuid, PK)
├── org_id (uuid, FK → orgs)
├── type ('folder' | 'file')
├── parent_id (uuid, self-ref, nullable for root)
├── name (varchar)
├── starred (boolean)
├── deleted_at (timestamp, soft delete)
├── created_at, updated_at (timestamp)

files (metadata for file nodes)
├── node_id (uuid, PK, FK → nodes)
├── current_version (int)
├── mime (varchar)
├── size (bigint)
├── checksum (varchar, sha256)
├── created_at (timestamp)

file_versions
├── id (uuid, PK)
├── node_id (uuid, FK → nodes)
├── version (int)
├── storage_key (varchar, S3 path)
├── size, checksum (bigint, varchar)
├── created_at (timestamp)

shares (public/org share links)
├── id (uuid, PK)
├── org_id, node_id (uuid, FKs)
├── token (varchar, unique)
├── expires_at (timestamp, nullable)
├── password_hash (varchar, nullable)
├── scope ('view' | 'download')
├── org_only (boolean)
├── created_by (uuid, FK → users)
├── created_at (timestamp)

permissions (ACL)
├── id (uuid, PK)
├── org_id, node_id (uuid, FKs)
├── principal_type ('user' | 'group')
├── principal_id (uuid)
├── role ('owner' | 'editor' | 'viewer')
├── inherited (boolean)
├── created_at (timestamp)

locks (WebDAV locking)
├── id (uuid, PK)
├── org_id, node_id (uuid, FKs)
├── token, owner (varchar)
├── depth, timeout (varchar, int)
├── expires_at, created_at (timestamp)

upload_sessions (multipart uploads)
├── id (uuid, PK)
├── org_id, node_id, parent_id (uuid)
├── file_name, key, multipart_id (varchar)
├── status ('pending' | 'uploading' | 'completed' | 'failed')
├── mime, size (varchar, bigint)
├── expires_at, created_at (timestamp)

audit_log
├── id (uuid, PK)
├── org_id, actor_id, node_id (uuid)
├── action (varchar)
├── meta (jsonb)
├── ip (varchar)
├── created_at (timestamp)
```

---

## API Endpoints

### Authentication
- All `/api/*` routes require `Authorization: Bearer <JWT>` or `Basic <base64>`
- WebDAV at `/dav/*` uses Basic auth

### Public Endpoints
```
GET  /health                    # Health check
GET  /api/shares/:token         # Access shared file (public)
GET  /dev/token                 # Get dev token (non-production)
```

### Protected Endpoints
```
GET  /api/me                    # Current user info

# Nodes (files/folders)
GET    /api/nodes               # List nodes (query: parentId, starred, deleted)
POST   /api/nodes/folder        # Create folder
POST   /api/nodes/upload        # Initiate upload
PUT    /api/nodes/:id/upload    # Upload file content
PATCH  /api/nodes/:id           # Update node (rename, star, move)
DELETE /api/nodes/:id           # Soft delete / permanent delete
POST   /api/nodes/:id/restore   # Restore from trash
GET    /api/nodes/:id/download  # Download file

# Storage
GET    /api/storage/usage       # Storage usage stats

# Shares
GET    /api/shares              # List user's shares
POST   /api/shares              # Create share link
DELETE /api/shares/:id          # Delete share

# Verification
GET    /api/verification/status # Last verification status
POST   /api/verification/verify # Trigger integrity check
```

### WebDAV
```
/dav/*  # Full WebDAV Class 2 implementation
        # Supports: PROPFIND, PROPPATCH, MKCOL, GET, PUT, DELETE,
        #           COPY, MOVE, LOCK, UNLOCK
```

---

## Authentication System

### JWT Configuration
```typescript
const JWT_SECRET = process.env.JWT_SECRET;  // Shared with PreMail
const JWT_ISSUER = 'presuite';              // Shared issuer
```

### JWT Payload
```typescript
interface JWTPayload {
  sub: string;      // User ID
  org_id: string;   // Organization ID
  email: string;    // User email
  name?: string;    // User display name
  iss: string;      // 'presuite'
  iat: number;      // Issued at
  exp: number;      // Expiration
}
```

### Auth Flow
1. **SSO from PreMail:** User clicks PreDrive link in PreMail, redirected to `https://predrive.eu?token=JWT`
2. **Token Verification:** PreDrive verifies JWT signature using shared secret
3. **Auto-Provisioning:** If user doesn't exist, creates user and org from JWT claims
4. **Session:** Token stored in localStorage, used for API calls

### Basic Auth (WebDAV)
- Accepts `email:password` where password can be:
  - Bcrypt-hashed password from database
  - `FIXED_PASSWORD` env var (for all users)
  - JWT token (backwards compatibility)

---

## Storage System

### S3 Provider Configuration
```typescript
interface StorageConfig {
  endpoint: string;      // S3 endpoint URL
  publicEndpoint?: string; // For presigned URLs
  region: string;
  accessKeyId: string;
  secretAccessKey: string;
  bucket: string;
  forcePathStyle?: boolean;
}
```

### Environment Variables
```bash
S3_ENDPOINT=https://gateway.eu1.storjshare.io
S3_ACCESS_KEY_ID=...
S3_SECRET_ACCESS_KEY=...
S3_BUCKET=predrive
S3_REGION=eu1
```

### Storage Key Format
```
{orgId}/{fileVersionId}
```

### Features
- Single-part upload for small files
- Multipart upload for large files (>5MB)
- Presigned URLs for direct browser upload/download
- SHA-256 checksums for integrity

---

## Frontend Architecture

### State Management (Zustand)
```typescript
interface UIState {
  // Navigation
  currentFolderId: string | null;
  breadcrumb: BreadcrumbItem[];
  navView: 'home' | 'drive' | 'recent' | 'starred' | 'trash' | 'shares';
  viewMode: 'grid' | 'list';

  // Selection
  selectedNodeId: string | null;
  selectedNodeIds: Set<string>;

  // Modals
  createFolderModalOpen: boolean;
  deleteConfirmNodeId: string | null;
  renameNodeId: string | null;
  previewFile: PreviewFile | null;
  upgradeModalOpen: boolean;

  // Search & Theme
  searchQuery: string;
  darkMode: boolean;
}
```

### Key Components
- `Sidebar.tsx` - Navigation, storage indicator, network health
- `FileList.tsx` / `FileCard.tsx` - File display
- `FileDetails.tsx` - Selected file info panel
- `FilePreview.tsx` - Image/PDF/video preview
- `DropZone.tsx` - Drag-and-drop upload
- `SharesList.tsx` - Manage shared links

### Hooks
- `useAuth()` - Authentication state and login/logout
- `useNodes()` - File/folder CRUD operations
- `useShares()` - Share link management
- `useUpload()` - File upload with progress
- `useVerification()` - Integrity verification status

---

## Deployment

### Production Environment (76.13.1.110)

#### Directory Structure
```
/opt/predrive/
├── .env                 # Production environment
├── apps/
├── packages/
└── deploy/
    └── docker-compose.prod.yml
```

#### Docker Compose Services
```yaml
services:
  api:        # PreDrive API (port 4000)
  postgres:   # PostgreSQL 16 (port 5432)
  valkey:     # Valkey/Redis (port 6379)
```

#### Caddy Configuration
```
/etc/caddy/Caddyfile

predrive.eu {
    reverse_proxy localhost:4000
}
```

### Environment Variables
```bash
# Database
DATABASE_URL=postgres://predrive:PASSWORD@postgres:5432/predrive
POSTGRES_PASSWORD=...

# Auth (MUST match PreMail)
JWT_SECRET=7089fa42b9b38cf6e7d881a18a2534c4c6ff5e04e3ce9250ed7f5b57118acbeb
JWT_ISSUER=presuite

# Storage (Storj)
S3_ENDPOINT=https://gateway.eu1.storjshare.io
S3_ACCESS_KEY_ID=...
S3_SECRET_ACCESS_KEY=...
S3_BUCKET=predrive
S3_REGION=eu1

# App
NODE_ENV=production
PORT=4000
CORS_ORIGIN=https://predrive.eu
```

### Deployment Commands
```bash
# Build and sync
pnpm build
rsync -avz --delete --exclude='.env' --exclude='node_modules' --exclude='.git' \
  . root@76.13.1.110:/opt/predrive/

# On server
cd /opt/predrive
docker compose -f deploy/docker-compose.prod.yml build --no-cache api
docker compose -f deploy/docker-compose.prod.yml up -d --force-recreate
```

---

## SSO Integration with PreMail

### PreMail Configuration (76.13.1.117)

#### ecosystem.config.cjs
```javascript
{
  name: "premail-api",
  env: {
    JWT_SECRET: "7089fa42b9b38cf6e7d881a18a2534c4c6ff5e04e3ce9250ed7f5b57118acbeb",
    JWT_ISSUER: "presuite",
    PREDRIVE_ORG_ID: "00000000-0000-0000-0000-000000000001"
  }
}
```

#### PreMail Sidebar Link
In `/opt/premail/apps/web/src/layouts/AppLayout.tsx`:
```tsx
<a href={`https://predrive.eu?token=${auth.token}`}>
  <HardDrive /> PreDrive
</a>
```

### SSO Flow
1. User logs into PreMail
2. Clicks "PreDrive" in sidebar
3. Redirects to `https://predrive.eu?token=<JWT>`
4. PreDrive frontend extracts token from URL
5. Calls `/api/me` to validate and get user info
6. Auto-provisions user if not exists
7. Stores token in localStorage
8. Cleans URL (removes token param)

---

## Common Operations

### Database Migrations
```bash
# Generate migration from schema changes
pnpm db:generate

# Run migrations
pnpm db:migrate

# Seed demo data
pnpm db:seed
```

### Manual Database Access
```bash
ssh root@76.13.1.110
cd /opt/predrive
docker compose -f deploy/docker-compose.prod.yml exec -T postgres \
  psql -U predrive -d predrive -c "SELECT * FROM users;"
```

### View Logs
```bash
docker compose -f deploy/docker-compose.prod.yml logs api --tail=50 -f
```

### Restart Services
```bash
docker compose -f deploy/docker-compose.prod.yml restart api
# OR full recreate
docker compose -f deploy/docker-compose.prod.yml up -d --force-recreate
```

---

## Troubleshooting

### SSO Token Invalid
1. Check JWT_SECRET matches on both servers
2. Verify PreMail PM2 env: `pm2 env 0 | grep JWT`
3. Check PreMail ecosystem.config.cjs has correct secret
4. Restart PreMail: `pm2 delete all && pm2 start ecosystem.config.cjs`

### Database Connection Failed
1. Check POSTGRES_PASSWORD in .env
2. Verify password matches volume: may need to reset
   ```sql
   ALTER USER predrive PASSWORD 'your_password';
   ```

### Storage Errors
1. Verify S3 credentials and bucket exist
2. Check Storj gateway accessibility
3. Test with: `curl -I https://gateway.eu1.storjshare.io`

### Container Won't Start
1. Check for port conflicts: `netstat -tlnp | grep 4000`
2. Kill stale docker processes if needed
3. `docker compose down && docker compose up -d`

---

## Development

### Local Setup
```bash
# Install dependencies
pnpm install

# Start services (postgres, valkey, minio)
pnpm docker:up

# Run migrations and seed
pnpm db:migrate
pnpm db:seed

# Start dev server
pnpm dev
```

### Dev URLs
- Web: http://localhost:5173
- API: http://localhost:4000/api
- WebDAV: http://localhost:4000/dav
- Dev Token: http://localhost:4000/dev/token

### Testing
```bash
pnpm test
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `apps/api/src/index.ts` | Main API entry, route mounting |
| `apps/api/src/middleware/auth.ts` | JWT verification, auto-provisioning |
| `apps/api/src/routes/nodes.ts` | File/folder CRUD operations |
| `apps/web/src/hooks/useAuth.ts` | SSO token handling |
| `apps/web/src/store/index.ts` | UI state management |
| `packages/db/src/schema.ts` | Database schema definitions |
| `packages/storage/src/s3-provider.ts` | S3 storage implementation |
| `packages/webdav/src/router.ts` | WebDAV protocol router |
| `deploy/docker-compose.prod.yml` | Production Docker config |
| `deploy/Dockerfile` | Production image build |

---

## Security Notes

- JWT secret must be kept synchronized between PreDrive and PreMail
- Never commit `.env` files or expose secrets in logs
- Production uses HTTPS via Caddy auto-TLS
- File checksums (SHA-256) stored for integrity verification
- Soft-delete with 30-day trash retention
- Share links can have passwords and expiration dates

---

*Last Updated: January 2026*
