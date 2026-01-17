# CLAUDE.md - AI Agent Reference for PreSuite

> **Purpose:** Primary reference document for AI agents working on the PreSuite ecosystem.
> **Last Updated:** January 17, 2026
> **Start Here:** [INDEX.md](INDEX.md) for full documentation navigation

---

## QUICK REFERENCE

### Servers (SSH Access)

| Service | IP | SSH Command | Code Path |
|---------|-----|-------------|-----------|
| PreSuite Hub | `76.13.2.221` | `ssh root@76.13.2.221` | `/var/www/presuite` |
| PreDrive | `76.13.1.110` | `ssh root@76.13.1.110` | `/opt/predrive` |
| PreMail | `76.13.1.117` | `ssh root@76.13.1.117` | `/opt/premail` |
| PreOffice | `76.13.2.220` | `ssh root@76.13.2.220` | `/opt/preoffice` |
| PreSocial | `76.13.2.221` | `ssh root@76.13.2.221` | `/opt/presocial` |

### Production URLs

| Service | URL | Purpose |
|---------|-----|---------|
| PreSuite Hub | `https://presuite.eu` | Identity provider, dashboard |
| PreDrive | `https://predrive.eu` | Cloud storage |
| PreMail | `https://premail.site` | Email (@premail.site) |
| PreOffice | `https://preoffice.site` | Document editing |
| PreSocial | `https://presocial.presuite.eu` | Community discussions (Lemmy) |

### GitHub Repositories

```
https://github.com/tijnski/presuite          # Hub & Identity
https://github.com/tijnski/predrive          # Cloud Storage
https://github.com/tijnski/premail           # Email Service
https://github.com/tijnski/preoffice         # Document Editor
https://github.com/tijnski/presocial         # Social Layer (Lemmy)
https://github.com/tijnski/presuite-architecture  # This repo
```

---

## ARCHITECTURE OVERVIEW

```
IDENTITY PROVIDER: PreSuite Hub (presuite.eu)
├── Auth API: /api/auth/* (register, login, verify, logout)
├── Web3 Auth: /api/auth/web3/* (nonce, verify, link wallets)
├── JWT Issuer: "presuite" (HS256)
└── Shared secret: JWT_SECRET (must be identical across all services)

SERVICES (all authenticate via PreSuite Hub):
├── PreMail (premail.site)
│   ├── Backend: Hono + PostgreSQL
│   ├── Mail Server: Stalwart IMAP/SMTP
│   └── Domain: @premail.site, @web3.premail.site
├── PreDrive (predrive.eu)
│   ├── Backend: Hono + PostgreSQL
│   ├── Storage: Storj S3-compatible
│   └── Features: Files, folders, sharing
├── PreOffice (preoffice.site)
│   ├── Backend: Express WOPI Server
│   ├── Editor: Collabora Online (CODE)
│   └── Integration: PreDrive file storage
└── PreSocial (presocial.presuite.eu)
    ├── Backend: Bun + Hono
    ├── Frontend: Lemmy integration
    └── Features: Communities, posts, comments
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
├── web3Auth.js             # Web3 wallet authentication
├── preDriveService.js      # PreDrive API client
├── preMailService.js       # PreMail API client
└── preGPTService.js        # Venice AI client

server.js                   # Express backend (Auth, OAuth, AI proxy)
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
- Database: PostgreSQL (Drizzle ORM)
- Mail Server: Stalwart (IMAP/SMTP)
- Search: Typesense

**Key Files:**
```
apps/
├── api/src/
│   ├── index.ts            # API entry point
│   ├── routes/
│   │   ├── auth.ts         # Auth routes (proxy to PreSuite)
│   │   ├── accounts.ts     # Email account management
│   │   ├── messages.ts     # Email operations
│   │   ├── labels.ts       # Labels/tags system
│   │   ├── calendar.ts     # Calendar events
│   │   ├── notifications.ts # Push notifications
│   │   └── webhooks.ts     # Postal webhooks
│   └── config/env.ts       # Environment config
└── web/src/
    ├── pages/
    │   ├── InboxPage.tsx
    │   ├── LoginPage.tsx
    │   └── RegisterPage.tsx
    └── layouts/AppLayout.tsx

packages/db/src/
└── schema/index.ts         # Database schema (13 tables)
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

### PreSocial (Community Platform)

**Location:** `ssh root@76.13.2.221` → `/opt/presocial`

**Stack:**
- Runtime: Bun (not Node.js)
- Backend: Hono
- Frontend: Lemmy integration
- Storage: File-based persistence (JSON)

**Key Files:**
```
src/
├── index.ts                # Main entry point
├── routes/
│   ├── communities.ts      # Community endpoints
│   ├── posts.ts            # Post operations
│   ├── comments.ts         # Comment operations
│   ├── votes.ts            # Voting system
│   ├── bookmarks.ts        # Bookmark management
│   └── users.ts            # User profiles
├── services/
│   ├── lemmy.ts            # Lemmy API client
│   └── storage.ts          # Persistent storage service
└── middleware/
    └── auth.ts             # JWT authentication

data/                       # Persistent storage
├── votes.json              # User votes
└── bookmarks.json          # User bookmarks
```

**Commands:**
```bash
# Deploy
cd /opt/presocial && git pull && bun install && pm2 restart presocial

# Logs
pm2 logs presocial

# Health check
curl https://presocial.presuite.eu/health
```

---

## SSO & DATABASE ARCHITECTURE

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│              PRESUITE HUB (Identity Provider)                │
│                    presuite.eu                               │
│                                                              │
│  Database: presuite                                          │
│  └── users, orgs, sessions, oauth_clients, auth_events      │
│                                                              │
│  Auth: /api/auth/* (register, login, verify, logout)        │
│  OAuth: /api/oauth/* (authorize, token, userinfo)           │
└─────────────────────────────────────────────────────────────┘
                            │
                   JWT Token (HS256)
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
   ┌─────────┐        ┌─────────┐        ┌─────────┐
   │ PreMail │        │PreDrive │        │PreOffice│
   │         │        │         │        │         │
   │ DB:     │        │ DB:     │        │(No DB)  │
   │ premail │        │ predrive│        │         │
   └─────────┘        └─────────┘        └─────────┘
```

### Databases

| Database | Purpose | Key Tables |
|----------|---------|------------|
| `presuite` | Identity provider (source of truth) | users, sessions, refresh_tokens, wallet_nonces, oauth_clients |
| `premail` | Email service | users, email_accounts, messages, threads, labels, calendar_events |
| `predrive` | Cloud storage | users, nodes, shares, permissions, activity_logs |

**Initialize all databases:**
```bash
psql -U postgres -f scripts/init-db.sql
```

---

## AUTH API REFERENCE

**Base URL:** `https://presuite.eu/api/auth`

### Standard Authentication

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/register` | `{email, password, name, source?}` | `{token, user}` |
| POST | `/login` | `{email, password}` | `{token, user}` |
| POST | `/logout` | - | `{success}` |
| GET | `/verify` | Header: `Authorization: Bearer <token>` | `{valid, user}` |
| GET | `/me` | Header: `Authorization: Bearer <token>` | `{user}` |
| PATCH | `/me` | `{name?}` | `{user}` |
| POST | `/reset-password` | `{email}` | `{success}` |
| POST | `/reset-password/confirm` | `{token, password}` | `{success}` |
| POST | `/me/password` | `{current_password, new_password}` | `{success}` |

### Web3 Authentication

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| GET | `/web3/nonce` | Query: `address` | `{nonce, message}` |
| POST | `/web3/verify` | `{address, signature}` | `{token, user, mailCredentials?}` |
| POST | `/web3/link` | `{address, signature}` | `{success}` |
| GET | `/web3/wallets` | - | `{wallets: [...]}` |
| DELETE | `/web3/wallets/:address` | - | `{success}` |
| GET | `/web3/mail` | - | `{email, imapServer, smtpServer}` |
| POST | `/web3/mail/reset-password` | - | `{password}` |

### JWT Token Format

```json
{
  "sub": "user-uuid",
  "org_id": "org-uuid",
  "email": "user@premail.site",
  "name": "Display Name",
  "wallet_address": "0x...",    // If Web3 user
  "is_web3": true,              // If Web3 user
  "iss": "presuite",
  "iat": 1234567890,
  "exp": 1234567890
}
```

**Token Expiration:** 7 days (configurable via `JWT_EXPIRES_IN`)

### Environment Variables (Required on ALL services)

```bash
# CRITICAL: Must be identical across all services
JWT_SECRET=<256-bit-random-secret>
JWT_ISSUER=presuite

# Points to PreSuite Hub
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

# PreSocial
ssh root@76.13.2.221 "cd /opt/presocial && git pull && bun install && pm2 restart presocial"
```

### Check Service Health

```bash
curl -s https://presuite.eu/api/health | jq
curl -s https://predrive.eu/health | jq
curl -s https://premail.site/health | jq
curl -s https://preoffice.site/health | jq
curl -s https://presocial.presuite.eu/health | jq
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

# PreSocial
ssh root@76.13.2.221 "pm2 logs presocial --lines 50"
```

### Create Git Branch on All Services

```bash
BRANCH="feature/my-feature"
ssh root@76.13.2.221 "cd /var/www/presuite && git checkout -b $BRANCH"
ssh root@76.13.1.110 "cd /opt/predrive && git checkout -b $BRANCH"
ssh root@76.13.1.117 "cd /opt/premail && git checkout -b $BRANCH"
ssh root@76.13.2.220 "cd /opt/preoffice && git checkout -b $BRANCH"
ssh root@76.13.2.221 "cd /opt/presocial && git checkout -b $BRANCH"
```

---

## FILE REFERENCES

### This Repository (ARC)

```
ARC/
├── INDEX.md                    # Navigation hub (start here)
├── README.md                   # Project overview
├── CLAUDE.md                   # AI agent reference (this file)
│
├── Service Documentation
│   ├── PRESUITE.md             # PreSuite Hub
│   ├── PREDRIVE.md             # PreDrive (cloud storage)
│   ├── PREMAIL.md              # PreMail (email)
│   ├── PREOFFICE.md            # PreOffice (documents)
│   └── PRESOCIAL.md            # PreSocial (Lemmy)
│
├── API & Integration
│   ├── API-REFERENCE.md        # Complete API documentation
│   └── INTEGRATION.md          # Cross-service integration
│
├── Architecture (architecture/)
│   ├── README.md               # Architecture index
│   ├── OVERVIEW.md             # High-level system design
│   ├── OAUTH-SSO.md            # OAuth 2.0 flow & tokens
│   ├── PREMAIL.md              # Email service architecture
│   ├── PREDRIVE.md             # Cloud storage architecture
│   ├── PREOFFICE.md            # Document editing (WOPI)
│   ├── INFRASTRUCTURE.md       # Server layout & Docker
│   ├── DATA-FLOWS.md           # Email & collaboration flows
│   └── SECURITY.md             # Security layers
│
├── UI/UX
│   ├── UIimplement.md          # Design system
│   └── UIPatterns-PresearchWeb.md  # Dark Glass theme
│
├── Operations
│   ├── DEPLOYMENT.md           # Deployment guide
│   ├── DEPLOYMENT-SUMMARY.md   # Production status
│   ├── MONITORING-INFRASTRUCTURE.md
│   └── TESTING-INFRASTRUCTURE.md
│
├── Status
│   ├── IMPLEMENTATION-STATUS.md  # Task tracking (~90%)
│   └── VERSION.md              # Version history
│
└── Infrastructure
    ├── config/                 # env.template, sso.config.ts
    ├── scripts/                # deploy, health, sync
    ├── monitoring/             # logging, metrics, alerting
    └── e2e-tests/              # Playwright tests
```

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

1. **Always work locally first** - Edit code in local repos (`~/Documents/Documents-MacBook/presearch/`), never directly on servers
2. **Git workflow** - Local → git push → GitHub → ssh + git pull → Production
3. **Never edit on servers** - All changes must go through Git, no direct server edits
4. **Use branch workflow** - Create feature branches, don't commit directly to main
5. **Verify before deploy** - Check syntax/build before restarting services
6. **Keep JWT_SECRET synced** - Never change on one service without others
7. **Backup before DB changes** - Always backup PostgreSQL before migrations
8. **Check logs after deploy** - Verify no errors after any deployment
9. **Use brand colors** - Primary: `#0190FF`, not `#2D8EFF` or `#3591FC`

---

## RELATED DOCUMENTS

| Document | Purpose |
|----------|---------|
| **[INDEX.md](INDEX.md)** | Navigation hub - start here |
| [API-REFERENCE.md](API-REFERENCE.md) | Complete API documentation |
| [IMPLEMENTATION-STATUS.md](IMPLEMENTATION-STATUS.md) | Task tracking (~90% complete) |
| [architecture/](architecture/README.md) | System architecture diagrams |
| [UIimplement.md](UIimplement.md) | Design system |
| [UIPatterns-PresearchWeb.md](UIPatterns-PresearchWeb.md) | Dark Glass theme patterns |
