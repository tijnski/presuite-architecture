# CLAUDE.md - AI Agent Reference for PreSuite

> **Purpose:** Primary reference document for AI agents working on the PreSuite ecosystem.
> **Last Updated:** January 15, 2026

---

## QUICK REFERENCE

### Servers (SSH Access)

| Service | IP | SSH Command | Code Path |
|---------|-----|-------------|-----------|
| PreSuite Hub | `76.13.2.221` | `ssh root@76.13.2.221` | `/var/www/presuite` |
| PreDrive | `76.13.1.110` | `ssh root@76.13.1.110` | `/opt/predrive` |
| PreMail | `76.13.1.117` | `ssh root@76.13.1.117` | `/opt/premail` |
| PreOffice | `76.13.2.220` | `ssh root@76.13.2.220` | `/opt/preoffice` |

### Production URLs

| Service | URL | Purpose |
|---------|-----|---------|
| PreSuite Hub | `https://presuite.eu` | Identity provider, dashboard |
| PreDrive | `https://predrive.eu` | Cloud storage |
| PreMail | `https://premail.site` | Email (@premail.site) |
| PreOffice | `https://preoffice.site` | Document editing |

### GitHub Repositories

```
https://github.com/tijnski/presuite          # Hub & Identity
https://github.com/tijnski/predrive          # Cloud Storage
https://github.com/tijnski/premail           # Email Service
https://github.com/tijnski/preoffice         # Document Editor
https://github.com/tijnski/presuite-architecture  # This repo
```

---

## ARCHITECTURE OVERVIEW

```
IDENTITY PROVIDER: PreSuite Hub (presuite.eu)
├── Auth API: /api/auth/* (register, login, verify, logout)
├── JWT Issuer: "presuite" (HS256)
└── Shared secret: JWT_SECRET (must be identical across all services)

SERVICES (all authenticate via PreSuite Hub):
├── PreMail (premail.site)
│   ├── Backend: Hono + PostgreSQL
│   ├── Mail Server: Stalwart IMAP/SMTP
│   └── Domain: @premail.site
├── PreDrive (predrive.eu)
│   ├── Backend: Hono + PostgreSQL
│   ├── Storage: Storj S3-compatible
│   └── Features: Files, folders, sharing
└── PreOffice (preoffice.site)
    ├── Backend: Express WOPI Server
    ├── Editor: Collabora Online (CODE)
    └── Integration: PreDrive file storage
```

---

## SERVICE DETAILS

### PreSuite Hub (Identity Provider)

**Location:** `ssh root@76.13.2.221` → `/var/www/presuite`

**Stack:**
- Frontend: React 19 + Vite + Tailwind CSS 4
- Backend: Express 5 (server.js)
- Process: PM2

**Key Files:**
```
src/components/
├── PreSuiteLaunchpad.jsx   # Main dashboard
├── PreGPTChat.jsx          # AI chat (Venice API)
├── Login.jsx               # Auth pages
├── Register.jsx
├── Settings.jsx
├── SearchBar.jsx
└── AppModal.jsx            # Service modals

src/services/
├── authService.js          # Auth API client
├── preDriveService.js      # PreDrive API client
├── preMailService.js       # PreMail API client
└── preGPTService.js        # Venice AI client

server.js                   # Express backend (AI proxy)
```

**Commands:**
```bash
# Deploy
cd /var/www/presuite && npm run build && pm2 restart presuite

# Logs
pm2 logs presuite

# Status
pm2 status
```

---

### PreDrive (Cloud Storage)

**Location:** `ssh root@76.13.1.110` → `/opt/predrive`

**Stack:**
- Frontend: React 18 + TypeScript + Vite + Tailwind
- Backend: Hono (apps/api)
- Database: PostgreSQL
- Storage: Storj S3

**Key Files:**
```
apps/
├── api/src/
│   ├── index.ts            # API entry point
│   ├── routes/             # API routes
│   └── services/           # Business logic
└── web/src/
    ├── components/
    │   ├── Sidebar.tsx
    │   ├── FileList.tsx
    │   ├── FileCard.tsx
    │   └── ...
    └── index.css           # CSS variables
```

**Commands:**
```bash
# Build & Deploy
cd /opt/predrive && pnpm build
docker compose -f deploy/docker-compose.prod.yml up -d --build

# Logs
docker compose logs -f

# Database
docker exec -it predrive-db psql -U predrive
```

---

### PreMail (Email Service)

**Location:** `ssh root@76.13.1.117` → `/opt/premail`

**Stack:**
- Frontend: React 18 + TypeScript + Vite + Tailwind
- Backend: Hono (apps/api)
- Database: PostgreSQL
- Mail Server: Stalwart (IMAP/SMTP)

**Key Files:**
```
apps/
├── api/src/
│   ├── routes/auth.ts      # Auth routes (proxy to PreSuite)
│   ├── routes/mail.ts      # Email operations
│   └── config/env.ts       # Environment config
└── web/src/
    ├── pages/
    │   ├── InboxPage.tsx
    │   ├── LoginPage.tsx
    │   └── RegisterPage.tsx
    └── layouts/AppLayout.tsx
```

**Commands:**
```bash
# Build & Deploy
cd /opt/premail && pnpm build
pm2 restart premail-api premail-web

# Logs
pm2 logs premail-api

# Stalwart Mail
systemctl status stalwart-mail
journalctl -u stalwart-mail -f
```

---

### PreOffice (Document Editing)

**Location:** `ssh root@76.13.2.220` → `/opt/preoffice`

**Stack:**
- Landing: Static HTML/CSS
- WOPI Server: Node.js + Express
- Editor: Collabora Online (Docker)
- Proxy: Nginx

**Key Files:**
```
presearch/
├── online/
│   ├── docker-compose.yml      # Container orchestration
│   ├── wopi-server/src/index.js # WOPI protocol
│   ├── nginx/nginx.conf        # Reverse proxy
│   └── branding/static/index.html # Landing page
└── brand/
    └── tokens.json             # Design tokens
```

**Commands:**
```bash
# Deploy
cd /opt/preoffice/presearch/online
docker compose down && docker compose up -d --build

# Logs
docker compose logs -f collabora
docker compose logs -f wopi

# Health check
curl https://preoffice.site/health
```

---

## AUTH API REFERENCE

**Base URL:** `https://presuite.eu/api/auth`

### Endpoints

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/register` | `{email, password, name}` | `{token, user}` |
| POST | `/login` | `{email, password}` | `{token, user}` |
| POST | `/logout` | - | `{success}` |
| GET | `/verify` | Header: `Authorization: Bearer <token>` | `{valid, user}` |
| GET | `/me` | Header: `Authorization: Bearer <token>` | `{user}` |

### JWT Token Format

```json
{
  "sub": "user-uuid",
  "org_id": "org-uuid",
  "email": "user@premail.site",
  "name": "Display Name",
  "iss": "presuite",
  "iat": 1234567890,
  "exp": 1234567890
}
```

### Environment Variables (Required on ALL services)

```bash
JWT_SECRET=<must-be-identical-across-all-services>
JWT_ISSUER=presuite
AUTH_API_URL=https://presuite.eu/api/auth
```

---

## BRAND COLORS

### Official Presearch (from Brandfetch)
**Primary:** `#0190FF` (Presearch Azure)
**Hover:** `#0177D6`
**Light Tint:** `#E6F4FF`
**Dark Background:** `#1E1E1E`
**Dark Surface:** `#323232` (Mine Shaft)

### presearch-web Colors (for reference)
**Primary:** `#3591FC` / `#2D8EFF`
**Dark Glass BG:** `rgba(13, 15, 18, 0.55)`
**Toggle Active:** `#2266ff`
**Dark-900:** `#191919`
**Dark-800:** `#1e1e1e`

> Note: Use official Presearch colors (`#0190FF`) for PreSuite services. See `UIPatterns-PresearchWeb.md` for complete presearch-web patterns.

---

## COMMON TASKS

### Deploy All Services

```bash
# PreSuite Hub
ssh root@76.13.2.221 "cd /var/www/presuite && git pull && npm run build && pm2 restart presuite"

# PreDrive
ssh root@76.13.1.110 "cd /opt/predrive && git pull && pnpm build && docker compose -f deploy/docker-compose.prod.yml up -d --build"

# PreMail
ssh root@76.13.1.117 "cd /opt/premail && git pull && pnpm build && pm2 restart premail-api premail-web"

# PreOffice
ssh root@76.13.2.220 "cd /opt/preoffice && git pull && cd presearch/online && docker compose up -d --build"
```

### Check Service Health

```bash
curl -s https://presuite.eu/api/health | jq
curl -s https://predrive.eu/health | jq
curl -s https://premail.site/health | jq
curl -s https://preoffice.site/health | jq
```

### View Logs

```bash
# PreSuite
ssh root@76.13.2.221 "pm2 logs presuite --lines 50"

# PreDrive
ssh root@76.13.1.110 "cd /opt/predrive && docker compose logs --tail 50"

# PreMail
ssh root@76.13.1.117 "pm2 logs premail-api --lines 50"

# PreOffice
ssh root@76.13.2.220 "cd /opt/preoffice/presearch/online && docker compose logs --tail 50"
```

### Create Git Branch on All Services

```bash
BRANCH="feature/my-feature"
ssh root@76.13.2.221 "cd /var/www/presuite && git checkout -b $BRANCH"
ssh root@76.13.1.110 "cd /opt/predrive && git checkout -b $BRANCH"
ssh root@76.13.1.117 "cd /opt/premail && git checkout -b $BRANCH"
ssh root@76.13.2.220 "cd /opt/preoffice && git checkout -b $BRANCH"
```

---

## FILE REFERENCES

### This Repository (ARC)

| File | Purpose |
|------|---------|
| `CLAUDE.md` | AI agent reference (this file) |
| `README.md` | Project overview |
| `presuite.md` | PreSuite Hub documentation |
| `PREDRIVE.md` | PreDrive documentation |
| `Premail.md` | PreMail documentation |
| `PREOFFICE.md` | PreOffice documentation |
| `INTEGRATION.md` | Cross-service integration |
| `AUTH-API.md` | Authentication API spec |
| `toimplement.md` | Task tracking |
| `UIimplement.md` | UI design system |
| `NewUI-*.md` | Service-specific UI guides |

---

## TROUBLESHOOTING

### JWT Token Invalid

1. Verify `JWT_SECRET` is identical across all services
2. Check token expiration
3. Verify issuer is "presuite"

### Service Not Responding

```bash
# Check if process is running
ssh root@<server> "pm2 status"  # For PM2 services
ssh root@<server> "docker ps"   # For Docker services

# Check nginx
ssh root@<server> "nginx -t && systemctl status nginx"

# Check ports
ssh root@<server> "netstat -tlnp | grep <port>"
```

### Database Connection Failed

```bash
# PreDrive/PreMail (PostgreSQL in Docker)
ssh root@<server> "docker exec -it <service>-db psql -U <service> -c '\l'"

# Check connection string in .env
ssh root@<server> "cat /opt/<service>/.env | grep DATABASE"
```

### SSL Certificate Issues

```bash
# Renew certificates
ssh root@<server> "certbot renew"

# Check certificate
ssh root@<server> "openssl s_client -connect <domain>:443 -servername <domain>"
```

---

## RULES FOR AI AGENTS

1. **Always SSH to modify code** - Don't try to modify files locally unless explicitly in this repo
2. **Use branch workflow** - Create feature branches, don't commit directly to main
3. **Verify before deploy** - Check syntax/build before restarting services
4. **Keep JWT_SECRET synced** - Never change on one service without others
5. **Backup before DB changes** - Always backup PostgreSQL before migrations
6. **Check logs after deploy** - Verify no errors after any deployment
7. **Use brand colors** - Primary: `#0190FF`, not `#2D8EFF` or `#3591FC`

---

## RELATED DOCUMENTS

- Detailed service docs: See individual `*.md` files
- UI implementation: `UIimplement.md`, `NewUI-*.md`
- **presearch-web UI patterns: `UIPatterns-PresearchWeb.md`** (Dark Glass theme, toggles, animations)
- Task tracking: `toimplement.md`
- API specs: `AUTH-API.md`
