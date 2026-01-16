# PreSuite Architecture Repository

Central architecture documentation and integration specifications for the PreSuite ecosystem.

> **Start Here:** [`INDEX.md`](INDEX.md) - Navigation hub for all documentation
> **AI Agents:** [`CLAUDE.md`](CLAUDE.md) - Quick reference, SSH commands, common tasks

---

## Overview

PreSuite is a privacy-focused productivity suite built on the Presearch ecosystem. It provides a unified set of applications for email, cloud storage, document editing, and AI-assisted search.

## Services

| Service | URL | Description |
|---------|-----|-------------|
| **PreSuite Hub** | https://presuite.eu | Central hub, identity provider, AI search |
| **PreDrive** | https://predrive.eu | Cloud storage (Google Drive alternative) |
| **PreMail** | https://premail.site | Privacy-focused email (@premail.site) |
| **PreOffice** | https://preoffice.site | Document editing (LibreOffice/Collabora) |
| **PreSocial** | https://presocial.presuite.eu | Community discussions (Lemmy-powered) |

## Architecture

```
                    PreSuite Hub (Identity Provider)
                           presuite.eu
                               │
                         JWT Tokens
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
    ┌─────────┐          ┌─────────┐          ┌─────────┐
    │ PreMail │          │PreDrive │          │PreOffice│
    │         │          │         │          │         │
    │Stalwart │          │  Storj  │          │Collabora│
    │  IMAP   │          │   S3    │          │ Online  │
    └─────────┘          └─────────┘          └─────────┘
```

See [`architecture/`](architecture/README.md) for detailed diagrams.

---

## Repository Structure

```
ARC/
├── INDEX.md                    # Start here - navigation hub
├── README.md                   # Project overview (this file)
├── CLAUDE.md                   # AI agent reference
│
├── Service Documentation
│   ├── PRESUITE.md             # PreSuite Hub
│   ├── PREDRIVE.md             # PreDrive
│   ├── PREMAIL.md              # PreMail
│   ├── PREOFFICE.md            # PreOffice
│   └── PRESOCIAL.md            # PreSocial
│
├── architecture/               # System architecture diagrams (9 files)
│   ├── README.md               # Architecture index
│   ├── OVERVIEW.md             # High-level system design
│   ├── OAUTH-SSO.md            # OAuth flow & tokens
│   ├── PREMAIL.md              # Email service
│   ├── PREDRIVE.md             # Cloud storage
│   ├── PREOFFICE.md            # Document editing
│   ├── INFRASTRUCTURE.md       # Server layout & Docker
│   ├── DATA-FLOWS.md           # Email & collaboration flows
│   └── SECURITY.md             # Security layers
│
├── API & Integration
│   ├── API-REFERENCE.md        # Complete API documentation
│   └── INTEGRATION.md          # Cross-service integration
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
├── IMPLEMENTATION-STATUS.md    # Task tracking (~85% complete)
│
├── config/                     # Environment templates
├── scripts/                    # Deployment & operations
├── monitoring/                 # Logging, metrics, alerting
└── e2e-tests/                  # Playwright E2E tests
```

---

## Documentation

### Core
- [INDEX.md](INDEX.md) - Navigation hub (start here)
- [CLAUDE.md](CLAUDE.md) - AI agent quick reference
- [API-REFERENCE.md](API-REFERENCE.md) - Complete API documentation

### Services
- [PRESUITE.md](PRESUITE.md) - Hub, auth, dashboard
- [PREDRIVE.md](PREDRIVE.md) - Cloud storage
- [PREMAIL.md](PREMAIL.md) - Email service
- [PREOFFICE.md](PREOFFICE.md) - Document editing
- [PRESOCIAL.md](PRESOCIAL.md) - Community discussions

### Architecture
- [architecture/](architecture/README.md) - System diagrams (8 focused files)
- [INTEGRATION.md](INTEGRATION.md) - Service-to-service integration
- [PRESUITE-SSO-IMPLEMENTATION.md](PRESUITE-SSO-IMPLEMENTATION.md) - OAuth SSO details

### Operations
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide
- [MONITORING-INFRASTRUCTURE.md](MONITORING-INFRASTRUCTURE.md) - Logging & alerting
- [TESTING-INFRASTRUCTURE.md](TESTING-INFRASTRUCTURE.md) - Test setup

---

## Technology Stack

| Service | Backend | Database | Infrastructure |
|---------|---------|----------|----------------|
| PreSuite Hub | Express | PostgreSQL | PM2, Nginx |
| PreDrive | Hono | PostgreSQL | Docker, Nginx |
| PreMail | Hono | PostgreSQL | PM2, Stalwart |
| PreOffice | Express (WOPI) | - | Docker, Collabora |
| PreSocial | Hono | Redis | Docker, Lemmy API |

**Common:** React 18+, TypeScript, Vite, Tailwind CSS, JWT (HS256)

---

## Servers

| IP | Domain | Service |
|----|--------|---------|
| 76.13.2.221 | presuite.eu | PreSuite Hub |
| 76.13.1.110 | predrive.eu | PreDrive |
| 76.13.1.117 | premail.site | PreMail |
| 76.13.2.220 | preoffice.site | PreOffice |
| 76.13.2.221 | presocial.presuite.eu | PreSocial |

---

## Quick Start

```bash
# Clone all repositories
git clone https://github.com/tijnski/presuite
git clone https://github.com/tijnski/predrive
git clone https://github.com/tijnski/premail
git clone https://github.com/tijnski/preoffice
git clone https://github.com/tijnski/presocial

# Required environment variables (must be identical across all services)
JWT_SECRET=<your-secret-here>
JWT_ISSUER=presuite
AUTH_API_URL=https://presuite.eu/api/auth
```

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/deploy-all.sh` | Deploy all services |
| `scripts/health-check.sh` | Check service health |
| `scripts/sync-secrets.sh` | Verify JWT secrets match |
| `scripts/init-db.sql` | Database initialization |

---

## GitHub Repositories

- [presuite](https://github.com/tijnski/presuite) - Hub & identity provider
- [predrive](https://github.com/tijnski/predrive) - Cloud storage
- [premail](https://github.com/tijnski/premail) - Email service
- [preoffice](https://github.com/tijnski/preoffice) - Document editing
- [presocial](https://github.com/tijnski/presocial) - Community discussions
- [presuite-architecture](https://github.com/tijnski/presuite-architecture) - This repository
