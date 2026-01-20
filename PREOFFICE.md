# PreOffice - Document Editing Documentation

## Overview

PreOffice is a web-based document editing service powered by Collabora Online (LibreOffice-based), integrated with PreDrive for cloud storage. It uses the WOPI (Web Application Open Platform Interface) protocol for file operations.

**Production URL:** https://preoffice.site
**Server:** `ssh root@76.13.2.220` → `/opt/preoffice`
**GitHub Repositories:**
- Web: https://github.com/tijnski/preoffice-web (deployed to server)
- Desktop: https://github.com/tijnski/preoffice-desktop (LibreOffice-based)

---

## Technology Stack

### WOPI Server

| Package | Version | Purpose |
|---------|---------|---------|
| Express | 4.18.2 | Web framework |
| jsonwebtoken | 9.0.2 | JWT handling |
| axios | 1.6.2 | HTTP client |
| helmet | 7.1.0 | Security headers |
| cors | 2.8.5 | CORS middleware |
| uuid | 9.0.1 | UUID generation |
| redis | 4.6.11 | Session store |
| morgan | 1.10.0 | Request logging |
| dotenv | 16.3.1 | Environment config |
| nodemon | 3.0.2 | Dev server |
| jest | 29.7.0 | Testing |

### Infrastructure

| Component | Version | Purpose |
|-----------|---------|---------|
| Node.js | 20 (Alpine) | Runtime |
| Collabora Online | latest | Document engine (CODE) |
| Nginx | Alpine | Reverse proxy |
| Redis | Alpine | Session store |

### Landing Page

- HTML5 + vanilla JavaScript (no frameworks)
- Presearch brand colors (`#2D8EFF`)
- Dark mode support with CSS variables
- Web3 support via ethers.js 6 (MetaMask integration)

---

## Project Structure

```
preoffice/
└── presearch/
    └── online/                       # PreOffice Online (web version)
        ├── docker-compose.yml        # Container orchestration
        ├── .env                      # Production config
        ├── .env.example              # Config template
        ├── README.md                 # Documentation
        │
        ├── wopi-server/              # WOPI protocol server
        │   ├── Dockerfile            # Node.js 20 Alpine
        │   ├── package.json
        │   └── src/
        │       ├── index.js          # Main server (1,219 lines)
        │       ├── config/
        │       │   └── constants.js  # Config & validation
        │       ├── middleware/
        │       │   ├── auth.js       # JWT & PreSuite auth
        │       │   ├── security.js   # Headers, CORS, CSP
        │       │   └── rate-limiter.js # DoS protection
        │       └── utils/
        │           └── logger.js     # Secure logging
        │
        ├── nginx/
        │   └── nginx.conf            # Reverse proxy config
        │
        ├── branding/
        │   └── static/
        │       ├── index.html        # Landing page (1,450 lines)
        │       ├── predrive-picker.js # File browser
        │       └── prepanda/         # AI assistant UI
        │
        └── scripts/
            └── start.sh              # Deployment script
```

---

## Docker Services

```yaml
services:
  collabora:
    image: collabora/code:latest
    container_name: preoffice-collabora
    environment:
      - aliasgroup1=https://preoffice.site
      - username=${COLLABORA_ADMIN_USER:-admin}
      - password=${COLLABORA_ADMIN_PASS:-changeme}
      - server_name=preoffice.site
      - extra_params=--o:ssl.enable=false --o:ssl.termination=true
      - dictionaries=en_US,nl_NL,de_DE,fr_FR,es_ES
    volumes:
      - ./branding:/etc/coolwsd/branding:ro
    cap_add:
      - MKNOD

  wopi:
    container_name: preoffice-wopi
    build: ./wopi-server
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=production
      - PORT=8080
      - PREDRIVE_API_URL=https://predrive.eu/api
      - USE_PREDRIVE=true
      - WOPI_BASE_URL=https://preoffice.site/wopi
      - COLLABORA_PUBLIC_URL=https://preoffice.site
      - COLLABORA_URL=http://collabora:9980
      - JWT_SECRET=${JWT_SECRET}
      - STORAGE_DIR=/data/preoffice-files
      - VENICE_API_URL=https://api.venice.ai/api/v1
      - VENICE_API_KEY=${VENICE_API_KEY}
    volumes:
      - wopi-data:/data/preoffice-files

  nginx:
    image: nginx:alpine
    container_name: preoffice-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - ./branding/static:/usr/share/nginx/html:ro

  redis:
    image: redis:alpine
    container_name: preoffice-redis
    volumes:
      - redis-data:/data

volumes:
  redis-data:
  wopi-data:

networks:
  default:
    name: preoffice-network
```

---

## API Endpoints

### Document Operations

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/create` | Create new document | Bearer |
| POST | `/api/edit` | Open file for editing | Bearer |
| GET | `/api/recent` | List recent documents | Bearer |
| GET | `/api/browse` | Browse PreDrive folders | Bearer |
| GET | `/api/search` | Search files | Bearer |
| GET | `/api/user` | Get user info & quota | Bearer |

### PrePanda AI

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/ai/chat` | AI chat completions | Bearer |
| POST | `/api/ai/action` | Quick actions (summarize, translate, etc.) | Bearer |
| GET | `/api/ai/status` | AI service status | None |

### WOPI Protocol

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/wopi/files/:fileId` | CheckFileInfo (metadata) | WOPI Token |
| GET | `/wopi/files/:fileId/contents` | GetFile (download) | WOPI Token |
| POST | `/wopi/files/:fileId/contents` | PutFile (save) | WOPI Token |
| POST | `/wopi/files/:fileId` | Lock operations | WOPI Token |

**Lock Operations (X-WOPI-Override header):**
- `LOCK` - Lock file for editing
- `GET_LOCK` - Check lock status
- `REFRESH_LOCK` - Extend lock duration
- `UNLOCK` - Release lock
- `PUT_RELATIVE` - Save as / copy
- `RENAME_FILE` - Rename file
- `DELETE` - Delete file

### Supporting Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/oauth/token` | OAuth code exchange |
| GET | `/hosting/discovery` | Collabora WOPI discovery |
| GET | `/hosting/capabilities` | Capabilities endpoint |
| GET | `/health` | Health check |

---

## Authentication System

### Two-Tier Authentication

**1. Bearer Token (API Endpoints)**
- Validates JWT from PreSuite Hub
- Calls `https://presuite.eu/api/auth/verify`
- Falls back to local JWT verification
- Sets `req.auth` with user info

**2. WOPI Token (File Operations)**
- Session-based JWT tokens
- Issued on `/api/create` and `/api/edit`
- Stored in in-memory session store
- Token Expiry: **4 hours**

### WOPI Token Payload

```javascript
{
  userId: string,      // User UUID
  fileId: string,      // Base64-encoded file path
  nodeId: string,      // PreDrive node ID
  sessionId: string,   // Session UUID
  iat: number,         // Issued at
  exp: number          // Expiration (4h)
}
```

### JWT Configuration

| Setting | Value |
|---------|-------|
| Algorithm | HS256 |
| Issuer | `presuite` |
| WOPI Token Expiry | 4 hours |
| Session TTL | 4 hours |

---

## Storage Modes

### PreDrive Integration (Production)

When `USE_PREDRIVE=true`:
1. Downloads files from PreDrive API
2. Uploads changes back to PreDrive
3. Falls back to local storage on failure

### Local Fallback (Development)

- In-memory file map (`demoFiles` Map)
- Disk storage at `/data/preoffice-files`
- Demo mode for testing without PreDrive

---

## Security Configuration

### Security Headers

```javascript
{
  'Content-Security-Policy': "default-src 'self'; ...",
  'X-Frame-Options': 'SAMEORIGIN',
  'X-Content-Type-Options': 'nosniff',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()'
}
```

### Rate Limiting

| Endpoint | Limit |
|----------|-------|
| API | 60 req/min |
| Edit | 30 req/min |
| Create | 20 req/min |
| WOPI | 100 req/min |

### Input Validation

- `validateFileId()` - Base64 format, path traversal detection
- `sanitizeFilename()` - Removes dangerous characters
- Maximum filename: 255 characters
- Maximum file upload: 100 MB

### Secure Logging

- Masks sensitive data (tokens, emails, UUIDs)
- Production: JSON structured logs
- Development: Human-readable format
- Log levels: error, warn, info, debug

---

## Environment Variables

```bash
# SECRETS (MUST change in production)
COLLABORA_ADMIN_USER=admin
COLLABORA_ADMIN_PASS=change-this-password
JWT_SECRET=change-this-secret-in-production
OAUTH_CLIENT_SECRET=preoffice-oauth-secret

# SERVICE URLS
PREDRIVE_API_URL=https://predrive.eu/api
WOPI_BASE_URL=https://preoffice.site/wopi
COLLABORA_PUBLIC_URL=https://preoffice.site
COLLABORA_URL=http://collabora:9980

# FEATURES
USE_PREDRIVE=true
DOMAIN=preoffice.site

# AI (PrePanda)
VENICE_API_URL=https://api.venice.ai/api/v1
VENICE_API_KEY=your-venice-api-key

# CORS
CORS_ORIGINS=https://preoffice.site,https://predrive.eu,https://presuite.eu

# STORAGE
STORAGE_DIR=/data/preoffice-files

# LOGGING
LOG_LEVEL=info
NODE_ENV=production
```

---

## Nginx Configuration

### Key Routing

```nginx
server {
    listen 443 ssl http2;
    server_name preoffice.site;

    ssl_certificate /etc/letsencrypt/live/preoffice.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/preoffice.site/privkey.pem;

    # Landing page
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    # Static assets (7-day cache)
    location /static/ {
        root /usr/share/nginx/html;
        expires 7d;
    }

    # WOPI endpoints (long timeout for editing)
    location /wopi/ {
        proxy_pass http://wopi:8080/wopi/;
        proxy_read_timeout 36000s;
    }

    # PreOffice API
    location /api/ {
        proxy_pass http://wopi:8080/api/;
    }

    # Collabora WebSocket (CRITICAL - must be regex)
    location ~ ^/cool/(.*)/ws$ {
        proxy_pass http://collabora:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_read_timeout 36000s;
    }

    # Collabora static files
    location ^~ /browser {
        proxy_pass http://collabora:9980;
    }

    # Collabora main (NO ^~ so WebSocket takes priority)
    location ~ ^/cool {
        proxy_pass http://collabora:9980;
    }

    # Legacy endpoints (backwards compatibility)
    location ~ ^/lool {
        proxy_pass http://collabora:9980;
    }

    # Health check
    location /health {
        proxy_pass http://wopi:8080/health;
    }
}
```

### Nginx Location Priority

1. Exact match `=`
2. Prefix match with `^~`
3. Regex match `~` or `~*`
4. Regular prefix match

**Important:** WebSocket location MUST use regex `~`, and general `/cool` MUST NOT use `^~`.

---

## File Type Support

### Documents
- ODT (OpenDocument Text)
- DOCX (Microsoft Word)
- RTF (Rich Text Format)
- TXT (Plain Text)

### Spreadsheets
- ODS (OpenDocument Spreadsheet)
- XLSX (Microsoft Excel)
- CSV (Comma-Separated Values)

### Presentations
- ODP (OpenDocument Presentation)
- PPTX (Microsoft PowerPoint)

### Other
- ODG (OpenDocument Drawing)
- PDF (View only)

---

## WOPI Protocol Flow

```
1. User clicks "Open in PreOffice" in PreDrive
2. PreDrive calls POST /api/edit with file path and user token
3. WOPI server generates access token and editor URL
4. Browser redirects to Collabora cool.html
5. Collabora calls GET /wopi/files/:fileId (CheckFileInfo)
6. WOPI server returns file metadata
7. Collabora calls GET /wopi/files/:fileId/contents (GetFile)
8. WOPI server downloads file from PreDrive
9. User edits document via WebSocket
10. On save: POST /wopi/files/:fileId/contents (PutFile)
11. WOPI server uploads to PreDrive
```

---

## Landing Page Features

The landing page (`branding/static/index.html`) includes:

- **Authentication:**
  - Email/password login via PreSuite API
  - Web3/MetaMask wallet login
  - OAuth callback handler
  - Token storage in `sessionStorage`

- **Document Creation:**
  - Document type selection (Writer, Calc, Impress, Draw)
  - File name input
  - PreDrive folder browser

- **UI Features:**
  - Dark mode toggle
  - Responsive design
  - Smooth animations
  - App selection cards
  - Features showcase

---

## Deployment

### Production Server

**Server:** 76.13.2.220
**Directory:** `/opt/preoffice/presearch/online`

### Deployment Commands

```bash
# SSH to server
ssh root@76.13.2.220

# Navigate to project
cd /opt/preoffice/presearch/online

# Pull latest code
git pull origin main

# Rebuild and restart
docker compose down
docker compose up -d --build

# View logs
docker compose logs -f

# Check status
docker compose ps
curl https://preoffice.site/health
```

### SSL Certificate Renewal

```bash
# Auto-renewal (configured via certbot timer)
certbot renew

# Manual renewal
certbot certonly --standalone -d preoffice.site
docker compose restart nginx
```

---

## Session Management

- In-memory session store (`sessionStore` Map)
- Session TTL: 4 hours
- Auto-cleanup every 30 minutes
- Stores user tokens for PreDrive API calls

### File Locking

- In-memory lock store (`fileLocks` Map)
- Prevents concurrent edits
- Lock-based concurrency control
- Locks released on UNLOCK or session expiry

---

## Troubleshooting

### WebSocket Connection Failed

1. Check nginx config has proper location priority
2. Verify WebSocket location uses regex `~` not `^~`
3. Check Collabora logs: `docker compose logs collabora`
4. Ensure `aliasgroup1` matches your domain

### WOPI CheckFileInfo 404

1. Check file exists in PreDrive
2. Verify access token is valid
3. Check WOPI_BASE_URL uses correct host
4. For demo mode, files are in-memory only

### SSL Certificate Issues

```bash
# Check certificate
openssl s_client -connect preoffice.site:443 -servername preoffice.site

# Renew certificate
certbot renew
docker compose restart nginx
```

### Collabora Not Starting

1. Check Docker logs: `docker compose logs collabora`
2. Verify memory (needs ~2GB minimum)
3. Check port 9980 not in use
4. Ensure CAP_MKNOD capability

---

## Resource Requirements

| Service | CPU | RAM |
|---------|-----|-----|
| Collabora | 2+ cores | 2+ GB |
| WOPI Server | 1 core | 512 MB |
| Nginx | 1 core | 256 MB |
| Redis | 1 core | 256 MB |

**Storage:** 100 GB+ recommended for document storage

---

## Current Status (January 2026)

### Working

- [x] Document editing (Writer, Calc, Impress, Draw)
- [x] PreDrive integration
- [x] WOPI protocol (CheckFileInfo, GetFile, PutFile)
- [x] File locking (LOCK/UNLOCK)
- [x] PrePanda AI integration
- [x] Web3 wallet login
- [x] Dark mode
- [x] SSL/HTTPS

### Known Limitations

- No real-time collaboration (single editor per file)
- Session store is in-memory (not distributed)
- PDF viewing only (no editing)

---

## Related Documentation

- [API-REFERENCE.md](API-REFERENCE.md) - Complete API documentation
- [PRESUITE.md](PRESUITE.md) - PreSuite Hub (identity provider)
- [PREDRIVE.md](PREDRIVE.md) - PreDrive cloud storage
- [PREMAIL.md](PREMAIL.md) - PreMail email service

---

*Last updated: January 20, 2026*
