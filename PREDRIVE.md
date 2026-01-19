# PreDrive - Cloud Storage Documentation

## Overview

PreDrive is a cloud storage application similar to Google Drive, built as part of the PreSuite ecosystem. It provides file storage, sharing, permissions, and WebDAV access with SSO integration via PreSuite Hub.

**Production URL:** https://predrive.eu
**Server:** `ssh root@76.13.1.110` → `/opt/predrive`
**GitHub Repository:** https://github.com/tijnski/predrive

---

## Technology Stack

### Backend (API)

| Package | Version | Purpose |
|---------|---------|---------|
| Hono | 4.2.0 | Web framework |
| Drizzle ORM | 0.30.0 | Database ORM |
| postgres | 3.4.0 | PostgreSQL driver |
| jose | 5.2.0 | JWT handling |
| bcryptjs | 3.0.3 | Password hashing |
| @aws-sdk/client-s3 | 3.500.0 | S3 storage |
| @aws-sdk/s3-request-presigner | 3.500.0 | Presigned URLs |
| tsx | 4.7.0 | TypeScript execution |
| Vitest | 1.4.0 | Testing |

### Frontend (Web)

| Package | Version | Purpose |
|---------|---------|---------|
| React | 18.2.0 | UI framework |
| Vite | 5.2.0 | Build tool |
| Tailwind CSS | 3.4.0 | Styling |
| Zustand | 4.5.0 | State management |
| React Query | 5.28.0 | Data fetching |
| lucide-react | 0.359.0 | Icons |
| ethers | 6.x | Web3 wallet support |

### Shared Packages

| Package | Version | Purpose |
|---------|---------|---------|
| Zod | 3.23.0 | Schema validation |
| fast-xml-parser | 4.3.0 | WebDAV XML parsing |

### Infrastructure

| Component | Version | Purpose |
|-----------|---------|---------|
| Turbo | 2.0.0 | Monorepo build |
| pnpm | 9.0.0 | Package manager |
| Node.js | >=20.0.0 | Runtime |
| PostgreSQL | 16 | Database |
| Valkey | latest | Cache (Redis-compatible) |
| Caddy | latest | Reverse proxy (auto HTTPS) |

---

## Project Structure

```
PreDrive/
├── apps/
│   ├── api/                      # Backend API (Hono)
│   │   └── src/
│   │       ├── index.ts          # Entry point, route mounting
│   │       ├── config/
│   │       │   └── constants.ts  # Rate limits, file limits
│   │       ├── middleware/
│   │       │   ├── auth.ts       # JWT/Basic auth
│   │       │   └── security-headers.ts
│   │       ├── routes/
│   │       │   ├── auth.ts       # Login, register
│   │       │   ├── nodes.ts      # File/folder CRUD
│   │       │   ├── shares.ts     # Share links
│   │       │   ├── permissions.ts # ACL management
│   │       │   ├── activity.ts   # Audit logs
│   │       │   ├── integrations.ts # PreMail integration
│   │       │   ├── verification.ts # Email verification
│   │       │   └── provision.ts  # Internal provisioning
│   │       └── utils/
│   │           └── sanitize.ts   # Input sanitization
│   │
│   └── web/                      # Frontend (React)
│       └── src/
│           ├── App.tsx
│           ├── api/              # API client
│           │   ├── client.ts     # HTTP client with auth
│           │   ├── nodes.ts      # File operations
│           │   ├── shares.ts     # Share management
│           │   └── activity.ts   # Activity logs
│           ├── components/       # React components
│           ├── hooks/            # Custom hooks
│           ├── store/
│           │   └── index.ts      # Zustand state
│           └── lib/              # Utilities
│
├── packages/
│   ├── db/                       # Database layer
│   │   ├── src/
│   │   │   ├── schema.ts         # Drizzle schema
│   │   │   ├── client.ts         # DB connection
│   │   │   └── migrate.ts        # Migration runner
│   │   └── drizzle/              # SQL migrations
│   │
│   ├── shared/                   # Shared types
│   │   └── src/
│   │       ├── types.ts          # TypeScript interfaces
│   │       ├── errors.ts         # Error definitions
│   │       └── validators.ts     # Zod schemas
│   │
│   ├── storage/                  # S3 abstraction
│   │   └── src/
│   │       ├── s3-provider.ts    # S3 implementation
│   │       └── types.ts          # Storage interfaces
│   │
│   └── webdav/                   # WebDAV protocol
│       └── src/
│           ├── router.ts         # WebDAV router
│           ├── path-resolver.ts  # Path to node conversion
│           ├── lock-manager.ts   # Lock handling
│           ├── xml-utils.ts      # XML generation
│           └── handlers/         # HTTP method handlers
│
├── deploy/
│   ├── Dockerfile                # Production image
│   ├── docker-compose.prod.yml   # Production compose
│   └── Caddyfile                 # Reverse proxy config
│
├── docker/
│   └── docker-compose.yml        # Development compose
│
├── docs/                         # Documentation
├── turbo.json                    # Build orchestration
├── pnpm-workspace.yaml           # Workspace config
└── .env.example                  # Environment template
```

---

## Database Schema

### User Tables

**orgs:**
```sql
id UUID PRIMARY KEY
name VARCHAR(255)
created_at TIMESTAMP
updated_at TIMESTAMP
```

**users:**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id)
email VARCHAR(255) UNIQUE
name VARCHAR(255)
password_hash VARCHAR(255)
wallet_address VARCHAR(42)        -- Web3 support
is_web3 BOOLEAN DEFAULT false     -- Web3 account flag
created_at TIMESTAMP
updated_at TIMESTAMP
```

### File Storage Tables

**nodes (files and folders):**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id) ON DELETE CASCADE
type VARCHAR(10)                  -- 'file' | 'folder'
parent_id UUID REFERENCES nodes(id) ON DELETE CASCADE
name VARCHAR(255)
starred BOOLEAN DEFAULT false
deleted_at TIMESTAMP              -- Soft delete
created_at TIMESTAMP
updated_at TIMESTAMP

CONSTRAINT chk_not_self_parent CHECK (parent_id != id)
```

**files (file metadata):**
```sql
node_id UUID PRIMARY KEY REFERENCES nodes(id) ON DELETE CASCADE
current_version INTEGER DEFAULT 1
mime VARCHAR(255)
size BIGINT DEFAULT 0
checksum VARCHAR(64)              -- SHA-256
created_at TIMESTAMP

CONSTRAINT chk_version_positive CHECK (current_version >= 1)
CONSTRAINT chk_size_non_negative CHECK (size >= 0)
```

**file_versions:**
```sql
id UUID PRIMARY KEY
node_id UUID REFERENCES nodes(id) ON DELETE CASCADE
version INTEGER
storage_key VARCHAR(512)          -- S3 object key
size BIGINT
checksum VARCHAR(64)
created_at TIMESTAMP

UNIQUE(node_id, version)
```

### Sharing & Permissions Tables

**shares:**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id) ON DELETE CASCADE
node_id UUID REFERENCES nodes(id) ON DELETE CASCADE
token VARCHAR(64) UNIQUE          -- 32 bytes, base64url
expires_at TIMESTAMP
password_hash VARCHAR(255)
scope VARCHAR(20)                 -- 'view' | 'download'
org_only BOOLEAN DEFAULT false
created_by UUID REFERENCES users(id) ON DELETE SET NULL
created_at TIMESTAMP
```

**permissions:**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id) ON DELETE CASCADE
node_id UUID REFERENCES nodes(id) ON DELETE CASCADE
principal_type VARCHAR(10)        -- 'user' | 'group'
principal_id UUID
role VARCHAR(20)                  -- 'owner' | 'editor' | 'viewer'
inherited BOOLEAN DEFAULT false
created_at TIMESTAMP

UNIQUE(node_id, principal_type, principal_id)
```

### WebDAV & Upload Tables

**locks:**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id) ON DELETE CASCADE
node_id UUID REFERENCES nodes(id) ON DELETE CASCADE
token VARCHAR(255) UNIQUE
owner VARCHAR(255)
depth VARCHAR(20) DEFAULT 'infinity'
timeout INTEGER DEFAULT 300       -- 5 minutes
expires_at TIMESTAMP
created_at TIMESTAMP
```

**upload_sessions:**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id) ON DELETE CASCADE
user_id UUID REFERENCES users(id) ON DELETE CASCADE
parent_id UUID REFERENCES nodes(id) ON DELETE CASCADE
file_name VARCHAR(255)
storage_key VARCHAR(512)
multipart_id VARCHAR(255)
status VARCHAR(20)                -- 'pending' | 'uploading' | 'completed' | 'failed' | 'expired'
mime VARCHAR(255)
size BIGINT
expires_at TIMESTAMP
created_at TIMESTAMP
updated_at TIMESTAMP
```

### Audit Table

**audit_log:**
```sql
id UUID PRIMARY KEY
org_id UUID REFERENCES orgs(id) ON DELETE CASCADE
actor_id UUID REFERENCES users(id) ON DELETE SET NULL
node_id UUID REFERENCES nodes(id) ON DELETE SET NULL
action VARCHAR(50)
meta JSONB DEFAULT '{}'
ip VARCHAR(45)
user_agent TEXT
created_at TIMESTAMP
```

---

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Email/password login |
| POST | `/api/auth/register` | Create account |
| GET | `/api/me` | Get current user |

### Nodes (Files & Folders)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/nodes` | List nodes (query: parentId, starred, deleted) |
| POST | `/api/nodes/folders` | Create folder |
| GET | `/api/nodes/recent` | List recent files |
| GET | `/api/nodes/starred` | List starred files |
| GET | `/api/nodes/trash` | List deleted files |
| GET | `/api/nodes/storage/usage` | Get storage quota usage |
| GET | `/api/nodes/network/health` | S3 connectivity check |
| PATCH | `/api/nodes/:id` | Rename or move node |
| DELETE | `/api/nodes/:id` | Soft delete (move to trash) |
| DELETE | `/api/nodes/:id/permanent` | Permanent delete |
| POST | `/api/nodes/:id/restore` | Restore from trash |
| POST | `/api/nodes/:id/star` | Toggle star status |

### File Upload/Download

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/nodes/files/upload/start` | Get presigned upload URL |
| POST | `/api/nodes/files/upload/complete` | Finalize upload |
| GET | `/api/nodes/files/:id/download` | Get presigned download URL |

### Shares

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/shares` | List user's shares |
| POST | `/api/shares` | Create share link |
| GET | `/api/shares/:token` | Access shared file (public) |
| DELETE | `/api/shares/:id` | Revoke share |

### Permissions

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/nodes/:id/permissions` | List node permissions |
| POST | `/api/nodes/:id/permissions` | Add permission |
| PATCH | `/api/nodes/:id/permissions/:permId` | Update permission |
| DELETE | `/api/nodes/:id/permissions/:permId` | Remove permission |

### Activity

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/activity` | Get audit log |

### Integrations

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/integrations/premail/attach` | Attach file to PreMail |

### Internal

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/internal/provision` | Provision user (requires INTERNAL_API_KEY) |
| GET | `/health` | Health check |
| GET | `/dev/token` | Dev token (non-production only) |

---

## WebDAV Implementation

**Endpoint:** `/dav/*`

**Supported Methods:**

| Method | Status | Description |
|--------|--------|-------------|
| OPTIONS | ✅ | Returns capabilities |
| PROPFIND | ✅ | List files/properties (depth 0, 1, infinity) |
| GET | ✅ | Download file |
| HEAD | ✅ | File metadata |
| PUT | ✅ | Upload file |
| MKCOL | ✅ | Create folder |
| DELETE | ✅ | Remove file/folder |
| MOVE | ✅ | Move/rename |
| COPY | ✅ | Copy file/folder |
| LOCK | ✅ | Acquire lock (300s default timeout) |
| UNLOCK | ✅ | Release lock |
| PROPPATCH | ⚠️ | Returns 403 (not implemented) |

**Authentication:**
- Basic auth: `email:password` or `email:jwt_token`
- Dev password: Set `WEBDAV_DEV_PASSWORD` env var

**LibreOffice/PreOffice Integration:**
```
dav://predrive.eu/dav/path/to/file.odt
```

---

## Authentication System

### JWT Configuration

| Setting | Value |
|---------|-------|
| Algorithm | HS256 |
| Issuer | `presuite` |
| Expiration | 7 days |
| Secret | Must match PreSuite Hub |

### JWT Payload

```typescript
interface JWTPayload {
  sub: string;      // User ID (UUID)
  org_id: string;   // Organization ID
  email: string;
  name?: string;
  iss: 'presuite';
  iat: number;
  exp: number;
}
```

### Auth Methods

1. **Bearer Token:** `Authorization: Bearer <JWT>`
2. **Basic Auth:** `Authorization: Basic <base64(email:password)>`
3. **URL Token:** `?token=<JWT>` (SSO redirect from PreSuite Hub)

### Password Requirements

- Length: 8-128 characters
- Must contain: uppercase, lowercase, number, special character
- Hashing: bcryptjs with 10 salt rounds

---

## Storage System

### S3 Provider

PreDrive uses S3-compatible storage (Storj in production, MinIO for development).

**Configuration:**
```typescript
interface StorageConfig {
  endpoint: string;           // S3 endpoint URL
  region: string;
  accessKeyId: string;
  secretAccessKey: string;
  bucket: string;
  forcePathStyle?: boolean;   // Required for MinIO/Storj
  publicEndpoint?: string;    // For presigned URLs
}
```

**Storage Key Format:**
```
{orgId}/{fileVersionId}
```

### Upload Flow

1. **Start Upload:** `POST /api/nodes/files/upload/start`
   - Returns presigned URL + session ID
2. **Upload to S3:** Direct browser upload via presigned URL
3. **Complete Upload:** `POST /api/nodes/files/upload/complete`
   - Verifies upload, creates file record

### Features

- Presigned URLs for direct browser upload/download
- Multipart upload for files >5MB
- SHA-256 checksums for integrity
- Version deduplication via S3 copy

---

## Security Configuration

### Rate Limits

| Endpoint | Limit |
|----------|-------|
| Auth | 5 attempts/15 min |
| Registration | 3 attempts/hour |
| API | 100 requests/min |
| Share access | 30/min per IP |
| Upload | 20/min |
| Download | 60/min |

### File Limits

| Limit | Value |
|-------|-------|
| Max file size | 5 GB |
| Max storage quota | 15 GB per org |
| Multipart threshold | 5 MB |
| Max filename length | 255 chars |
| Max path depth | 50 levels |
| Max search query | 100 chars |

### Security Settings

| Setting | Value |
|---------|-------|
| Share token size | 32 bytes (256 bits) |
| Bcrypt salt rounds | 10 |
| Presigned URL expiry (download) | 5 minutes |
| Presigned URL expiry (upload) | 1 hour |
| Upload session expiry | 24 hours |
| Lock timeout | 300 seconds |

### Security Headers

```javascript
{
  'Content-Security-Policy': "default-src 'self'",
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block'
}
```

---

## Environment Variables

```bash
# API Server
PORT=4000
NODE_ENV=development
BASE_URL=http://localhost:4000
CORS_ORIGIN=http://localhost:5170

# Database (PostgreSQL)
DATABASE_URL=postgres://predrive:predrive@localhost:5433/predrive

# S3 Storage
S3_ENDPOINT=http://localhost:9002
S3_REGION=us-east-1
S3_BUCKET=predrive
S3_ACCESS_KEY_ID=minioadmin
S3_SECRET_ACCESS_KEY=minioadmin
S3_FORCE_PATH_STYLE=true
S3_PUBLIC_ENDPOINT=                        # Optional: for presigned URLs

# Cache (Valkey/Redis)
REDIS_URL=redis://localhost:6381

# JWT Authentication
JWT_SECRET=predrive-dev-secret-change-in-production
JWT_ISSUER=presuite

# Download Tokens (PreMail integration)
DOWNLOAD_TOKEN_SECRET=predrive-download-token-secret

# Internal API
INTERNAL_API_KEY=                          # For /internal/* endpoints

# WebDAV Development
WEBDAV_DEV_PASSWORD=                       # Optional: fixed password for WebDAV

# Optional: Typesense Search
# TYPESENSE_API_KEY=predrive-typesense-key
# TYPESENSE_HOST=localhost
# TYPESENSE_PORT=8108
```

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
  lastSelectedNodeId: string | null;  // For range selection

  // Modals
  createFolderModalOpen: boolean;
  deleteConfirmNodeId: string | null;
  renameNodeId: string | null;
  previewFile: PreviewFile | null;
  upgradeModalOpen: boolean;

  // Search
  searchQuery: string;
  searchOpen: boolean;

  // Theme
  darkMode: boolean;  // Persisted to localStorage
}
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `Sidebar.tsx` | Navigation, storage indicator |
| `FileList.tsx` | Grid/list view |
| `FileCard.tsx` | Grid item |
| `FileRow.tsx` | List item |
| `FilePreview.tsx` | Preview modal |
| `UploadButton.tsx` | Upload UI |
| `ContextMenu.tsx` | Right-click menu |
| `CreateFolderModal.tsx` | Create folder |
| `DeleteConfirmModal.tsx` | Delete confirmation |
| `RenameModal.tsx` | Rename dialog |
| `SharesList.tsx` | Manage shares |
| `ActivityFeed.tsx` | Activity log |
| `Breadcrumb.tsx` | Path navigation |
| `DropZone.tsx` | Drag-and-drop |
| `UpgradeModal.tsx` | Storage upgrade |

---

## Deployment

### Production Environment

**Server:** 76.13.1.110
**Directory:** `/opt/predrive`

### Docker Compose Services

```yaml
services:
  api:
    # PreDrive API
    port: 4000

  postgres:
    # PostgreSQL 16
    port: 5432

  valkey:
    # Redis-compatible cache
    port: 6379
```

### Caddy Configuration

```
predrive.eu {
    reverse_proxy localhost:4000
}
```

### Deployment Commands

```bash
# Build locally
pnpm build

# Sync to server
rsync -avz --delete \
  --exclude='.env' \
  --exclude='node_modules' \
  --exclude='.git' \
  . root@76.13.1.110:/opt/predrive/

# On server: rebuild and restart
cd /opt/predrive
docker compose -f deploy/docker-compose.prod.yml build --no-cache api
docker compose -f deploy/docker-compose.prod.yml up -d --force-recreate
```

---

## Development

### Local Setup

```bash
# Install dependencies
pnpm install

# Start services (postgres, valkey, minio)
pnpm docker:up

# Run migrations
pnpm db:migrate

# Seed demo data
pnpm db:seed

# Start dev server
pnpm dev
```

### Development URLs

| Service | URL |
|---------|-----|
| Web | http://localhost:5170 |
| API | http://localhost:4000/api |
| WebDAV | http://localhost:4000/dav |
| Dev Token | http://localhost:4000/dev/token |
| MinIO Console | http://localhost:9001 |

### Database Commands

```bash
# Generate migration
pnpm db:generate

# Run migrations
pnpm db:migrate

# Seed data
pnpm db:seed

# Access database
docker compose exec postgres psql -U predrive -d predrive
```

### Testing

```bash
pnpm test
```

---

## SSO Integration

### Token Pass-through from PreSuite Hub

1. User clicks PreDrive link from PreSuite Hub or PreMail
2. Redirected to `https://predrive.eu?token=<JWT>`
3. Frontend extracts token from URL
4. Validates via `/api/me`
5. Stores token in localStorage
6. Cleans URL (removes token parameter)

### PreMail Sidebar Link

```tsx
// In PreMail AppLayout.tsx
<a href={`https://predrive.eu?token=${auth.token}`}>
  <HardDrive /> PreDrive
</a>
```

---

## Troubleshooting

### JWT Token Invalid

1. Verify `JWT_SECRET` matches PreSuite Hub
2. Check token expiration
3. Verify issuer is "presuite"

### Database Connection Failed

```bash
# Check PostgreSQL is running
docker compose logs postgres

# Reset password if needed
docker compose exec postgres psql -U postgres -c "ALTER USER predrive PASSWORD 'newpassword';"
```

### Storage Errors

1. Verify S3 credentials in `.env`
2. Check bucket exists
3. Test endpoint: `curl -I $S3_ENDPOINT`

### WebDAV Issues

1. Check Basic auth credentials
2. Verify `WEBDAV_DEV_PASSWORD` if using fixed password
3. Check lock conflicts in database

---

## Current Status (January 2026)

### Working

- [x] File/folder CRUD operations
- [x] Presigned upload/download
- [x] WebDAV Class 2 (LOCK/UNLOCK)
- [x] Share links with passwords/expiration
- [x] Permission management (ACL)
- [x] SSO with PreSuite Hub
- [x] PreMail attachment integration
- [x] Audit logging
- [x] Dark mode
- [x] Web3 wallet support (infrastructure)

- [x] BYOK client-side encryption
- [x] Web3 wallet encryption keys
- [x] Real-time collaboration (WebSocket)

### Known Limitations

- WebDAV PROPPATCH returns 403 (not implemented)
- Max file size: 5GB (browser upload limitation)
- Shift+Click range selection partially implemented

---

## Related Documentation

- [architecture/PREDRIVE-ENCRYPTION.md](architecture/PREDRIVE-ENCRYPTION.md) - BYOK encryption architecture
- [PREDRIVE-ENCRYPTION-QUICKSTART.md](PREDRIVE-ENCRYPTION-QUICKSTART.md) - User guide for encryption
- [API-REFERENCE.md](API-REFERENCE.md) - Complete API documentation
- [PRESUITE.md](PRESUITE.md) - PreSuite Hub (identity provider)
- [PREMAIL.md](PREMAIL.md) - PreMail email service
- [PREOFFICE.md](PREOFFICE.md) - PreOffice document editing

---

*Last updated: January 17, 2026*
