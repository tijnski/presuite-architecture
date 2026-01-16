# PreSuite Architecture Repository

Central architecture documentation and integration specifications for the PreSuite ecosystem.

> **AI Agents:** Start with [`CLAUDE.md`](CLAUDE.md) for quick reference, SSH commands, and common tasks.

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
┌─────────────────────────────────────────────────────────────────────────┐
│                    PreSuite Hub (Identity Provider)                      │
│                           presuite.eu                                    │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Auth API    │  │   PreGPT     │  │   Search     │  │   Widgets    │ │
│  │              │  │   (Venice)   │  │  (Presearch) │  │   Dashboard  │ │
│  │ • Register   │  │              │  │              │  │              │ │
│  │ • Login      │  │              │  │              │  │              │ │
│  │ • JWT Issue  │  │              │  │              │  │              │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
         │              JWT Tokens                 │
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│    PreMail      │  │    PreDrive     │  │   PreOffice     │
│                 │  │                 │  │                 │
│  📧 Email       │  │  📁 Storage     │  │  📄 Documents   │
│  @premail.site  │  │  Files/Folders  │  │  Spreadsheets   │
│                 │  │                 │  │  Presentations  │
│  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │
│  │ Register  │──┼──┼─▶│ Register  │──┼──┼─▶│ Register  │  │
│  │ Login     │  │  │  │ Login     │  │  │  │ Login     │  │
│  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │
│        │        │  │        │        │  │        │        │
│        ▼        │  │        ▼        │  │        ▼        │
│   ┌─────────┐   │  │   ┌─────────┐   │  │   ┌─────────┐   │
│   │Stalwart │   │  │   │  Storj  │   │  │   │Collabora│   │
│   │  IMAP   │   │  │   │   S3    │   │  │   │ Online  │   │
│   └─────────┘   │  │   └─────────┘   │  │   └─────────┘   │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                    │                    │
         └────────────────────┴────────────────────┘
                              │
                    All auth requests go to
                      PreSuite Hub API
```

## Authentication

### Centralized Identity Provider

**PreSuite Hub** is the central identity provider. Users can register and login from **any service** (PreSuite, PreMail, PreDrive, or PreOffice), but all authentication is handled by PreSuite Hub.

### Registration (From Any Service)

```
User on PreDrive → clicks "Sign Up"
                          ↓
              POST to presuite.eu/api/auth/register
                          ↓
              PreSuite Hub creates:
                • User account
                • @premail.site mailbox
                • PreDrive storage
                          ↓
              Returns JWT token
                          ↓
              User logged in on PreDrive
```

### Auth API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/register` | POST | Create new account |
| `/api/auth/login` | POST | Authenticate user |
| `/api/auth/logout` | POST | End session |
| `/api/auth/verify` | GET | Validate token |
| `/api/auth/reset-password` | POST | Password reset |

### JWT Token

All services share the same JWT format:

```javascript
{
  sub: "user-uuid",           // User ID
  org_id: "org-uuid",         // Organization ID
  email: "user@premail.site", // Email address
  name: "Display Name",       // User name
  iss: "presuite",            // Issuer (always "presuite")
  iat: 1234567890,            // Issued at
  exp: 1234567890             // Expiration
}
```

## Documentation

- [Integration Guide](INTEGRATION.md) - Service-to-service integration
- [PreSuite Hub](presuite.md) - Landing page, auth, and widgets
- [PreDrive](PREDRIVE.md) - Cloud storage architecture
- [PreMail](Premail.md) - Email service architecture
- [PreOffice](PREOFFICE.md) - Document editing system
- [PreSocial](PRESOCIAL.md) - Community discussions (Lemmy integration)

## Technology Stack

### Common Technologies
- **Runtime:** Node.js 20+
- **Package Manager:** pnpm with workspaces
- **Build Tool:** Vite
- **Frontend:** React 18+, TypeScript, Tailwind CSS
- **Auth:** JWT with HS256 signing
- **Containerization:** Docker

### Per-Service Stack

| Service | Backend | Database | Infrastructure |
|---------|---------|----------|----------------|
| PreSuite Hub | Express | PostgreSQL | PM2, Nginx |
| PreDrive | Hono | PostgreSQL | Docker, Caddy |
| PreMail | Hono | PostgreSQL | PM2, Nginx, Stalwart |
| PreOffice | Express (WOPI) | - | Docker, Nginx, Collabora |
| PreSocial | Hono | Redis (cache) | Docker, Lemmy API |

## Servers

| IP | Domain | Services |
|----|--------|----------|
| 76.13.2.221 | presuite.eu | PreSuite Hub (Identity Provider) |
| 76.13.1.110 | predrive.eu | PreDrive |
| 76.13.1.117 | premail.site | PreMail + Stalwart Mail Server |
| 76.13.2.220 | preoffice.site | PreOffice Online |

## GitHub Repositories

- [presuite](https://github.com/tijnski/presuite) - Main hub & identity provider
- [predrive](https://github.com/tijnski/predrive) - Cloud storage
- [premail](https://github.com/tijnski/premail) - Email service
- [preoffice](https://github.com/tijnski/preoffice) - Document editing
- [presuite-architecture](https://github.com/tijnski/presuite-architecture) - This repository

## Quick Start

### Development Setup

```bash
# Clone all repositories
git clone https://github.com/tijnski/presuite
git clone https://github.com/tijnski/predrive
git clone https://github.com/tijnski/premail
git clone https://github.com/tijnski/preoffice

# Start local infrastructure
cd presuite-architecture
docker compose -f docker-compose.dev.yml up -d

# Each service has its own setup - see individual docs
```

### Environment Variables

```bash
# Auth (MUST BE IDENTICAL ACROSS ALL SERVICES)
JWT_SECRET=<your-secret-here>
JWT_ISSUER=presuite

# Auth API (for PreMail, PreDrive, PreOffice)
AUTH_API_URL=https://presuite.eu/api/auth

# Service URLs
PRESUITE_URL=https://presuite.eu
PREDRIVE_URL=https://predrive.eu
PREMAIL_URL=https://premail.site
PREOFFICE_URL=https://preoffice.site
```

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/health-check.sh` | Check all services health |
| `scripts/sync-secrets.sh` | Verify JWT secrets match |
| `scripts/deploy-all.sh` | Deploy services to production |

## License

Part of the Presearch ecosystem. See individual repositories for specific licenses.
