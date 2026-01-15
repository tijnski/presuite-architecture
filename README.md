# PreSuite Architecture Repository

Central architecture documentation and integration specifications for the PreSuite ecosystem.

## Overview

PreSuite is a privacy-focused productivity suite built on the Presearch ecosystem. It provides a unified set of applications for email, cloud storage, document editing, and AI-assisted search.

## Services

| Service | URL | Description |
|---------|-----|-------------|
| **PreSuite** | https://presuite.eu | Main landing page and hub |
| **PreDrive** | https://predrive.eu | Cloud storage (Google Drive alternative) |
| **PreMail** | https://premail.site | Privacy-focused email (@premail.site) |
| **PreOffice** | https://preoffice.site | Document editing (LibreOffice/Collabora) |

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │              PreSuite Hub               │
                    │           (presuite.eu)                 │
                    │                                         │
                    │  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
                    │  │ PreGPT  │ │ Search  │ │ Widgets │   │
                    │  └─────────┘ └─────────┘ └─────────┘   │
                    └─────────────────────────────────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
              ┌─────▼─────┐     ┌──────▼──────┐    ┌──────▼──────┐
              │  PreMail  │────▶│  PreDrive   │◀───│ PreOffice   │
              │           │ SSO │             │WOPI│             │
              └───────────┘     └─────────────┘    └─────────────┘
                    │                  │                  │
                    ▼                  ▼                  ▼
              ┌───────────┐     ┌─────────────┐    ┌─────────────┐
              │ Stalwart  │     │    Storj    │    │  Collabora  │
              │   IMAP    │     │  S3 Storage │    │   Online    │
              └───────────┘     └─────────────┘    └─────────────┘
```

## Shared Configuration

### SSO (Single Sign-On)

All services share a common JWT configuration:

```bash
JWT_SECRET=<shared-secret>  # Must match across all services
JWT_ISSUER=presuite         # Common issuer
```

### User Flow

1. User registers on PreMail → creates @premail.site account
2. JWT token issued with user/org claims
3. SSO links pass token to PreDrive/PreOffice
4. Services auto-provision users from JWT claims

## Documentation

- [PreSuite Hub](presuite.md) - Landing page and widget system
- [PreDrive](PREDRIVE.md) - Cloud storage architecture
- [PreMail](Premail.md) - Email service architecture
- [PreOffice](PREOFFICE.md) - Document editing system

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
| PreSuite | Express | - | PM2, Nginx |
| PreDrive | Hono | PostgreSQL | Docker, Caddy |
| PreMail | Hono | PostgreSQL | PM2, Nginx, Stalwart |
| PreOffice | Express (WOPI) | - | Docker, Nginx, Collabora |

## Servers

| IP | Domain | Services |
|----|--------|----------|
| 76.13.2.221 | presuite.eu | PreSuite Hub |
| 76.13.1.110 | predrive.eu | PreDrive |
| 76.13.1.117 | premail.site | PreMail + Stalwart |
| 76.13.2.220 | preoffice.site | PreOffice Online |

## GitHub Repositories

- [presuite](https://github.com/tijnski/presuite) - Main hub
- [predrive](https://github.com/tijnski/predrive) - Cloud storage
- [premail](https://github.com/tijnski/premail) - Email service
- [preoffice](https://github.com/tijnski/preoffice) - Document editing

## Quick Start

### Development Setup

```bash
# Clone all repositories
git clone https://github.com/tijnski/presuite
git clone https://github.com/tijnski/predrive
git clone https://github.com/tijnski/premail
git clone https://github.com/tijnski/preoffice

# Each service has its own setup - see individual docs
```

### Environment Variables (Common)

```bash
# Auth (MUST BE IDENTICAL ACROSS SERVICES)
JWT_SECRET=<your-secret-here>
JWT_ISSUER=presuite

# Service URLs
PRESUITE_URL=https://presuite.eu
PREDRIVE_URL=https://predrive.eu
PREMAIL_URL=https://premail.site
PREOFFICE_URL=https://preoffice.site
```

## License

Part of the Presearch ecosystem. See individual repositories for specific licenses.
