# PreSuite Documentation Index

> **Navigation hub for all PreSuite architecture documentation**
> Last Updated: January 16, 2026

---

## Quick Links

| Need to... | Go to |
|------------|-------|
| Start developing | [CLAUDE.md](CLAUDE.md) |
| Understand the project | [README.md](README.md) |
| Use PreSuite as a user | [USER-GUIDE.md](USER-GUIDE.md) |
| Deploy services | [DEPLOYMENT.md](DEPLOYMENT.md) |
| Check API endpoints | [API-REFERENCE.md](API-REFERENCE.md) |
| See what's left to build | [IMPLEMENTATION-STATUS.md](IMPLEMENTATION-STATUS.md) |

---

## Documentation Map

### Core Documentation

| File | Purpose | Audience |
|------|---------|----------|
| [README.md](README.md) | Project overview, architecture summary, quick start | Everyone |
| [CLAUDE.md](CLAUDE.md) | AI agent/developer quick reference, SSH commands, servers | Developers |
| [VERSION.md](VERSION.md) | Version history versus implementation milestones | Project managers |
| [USER-GUIDE.md](USER-GUIDE.md) | End-user documentation, features, troubleshooting | End users |
| [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md) | Third-party software licenses (AGPLv3, MPL, etc.) | Legal/Compliance |

---

### Service Documentation

| Service | Documentation | Status |
|---------|---------------|--------|
| **PreSuite Hub** | [PRESUITE.md](PRESUITE.md) | Production |
| **PreDrive** | [PREDRIVE.md](PREDRIVE.md) | Production |
| **PreMail** | [PREMAIL.md](PREMAIL.md) | Production |
| **PreOffice** | [PREOFFICE.md](PREOFFICE.md) | Production |
| **PreSocial** | [PRESOCIAL.md](PRESOCIAL.md) | Production |

---

### Architecture & Integration

| File | Purpose |
|------|---------|
| [architecture/](architecture/README.md) | Architecture diagrams (split into focused files) |
| [INTEGRATION.md](INTEGRATION.md) | Cross-service communication, auth flows, federation |
| [PRESUITE-SSO-IMPLEMENTATION.md](PRESUITE-SSO-IMPLEMENTATION.md) | OAuth SSO implementation details |

**Architecture Directory:**
- [OVERVIEW.md](architecture/OVERVIEW.md) - High-level system architecture
- [OAUTH-SSO.md](architecture/OAUTH-SSO.md) - OAuth 2.0 flow and token structure
- [PREMAIL.md](architecture/PREMAIL.md) - Email service architecture
- [PREDRIVE.md](architecture/PREDRIVE.md) - Cloud storage architecture
- [PREOFFICE.md](architecture/PREOFFICE.md) - Document editing (WOPI/Collabora)
- [INFRASTRUCTURE.md](architecture/INFRASTRUCTURE.md) - Server layout and Docker
- [DATA-FLOWS.md](architecture/DATA-FLOWS.md) - Email and collaboration flows
- [SECURITY.md](architecture/SECURITY.md) - Security layers and measures

---

### API Reference

| File | Purpose |
|------|---------|
| [API-REFERENCE.md](API-REFERENCE.md) | Complete API documentation (auth, PreDrive, PreMail, PreOffice) |

---

### UI/UX Design

| File | Purpose |
|------|---------|
| [UIimplement.md](UIimplement.md) | Master design system, colors, typography, components |
| [UIPatterns-PresearchWeb.md](UIPatterns-PresearchWeb.md) | Presearch web UI patterns (dark glass theme) |

---

### Operations & Deployment

| File | Purpose |
|------|---------|
| [DEPLOYMENT.md](DEPLOYMENT.md) | Master deployment guide, AI agent workflow |
| [DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md) | Current production status, OAuth configuration |
| [MONITORING-INFRASTRUCTURE.md](MONITORING-INFRASTRUCTURE.md) | Logging, metrics, alerting, backup procedures |
| [TESTING-INFRASTRUCTURE.md](TESTING-INFRASTRUCTURE.md) | Unit/E2E/integration test setup |

---

### Implementation Tracking

| File | Purpose | Status |
|------|---------|--------|
| [IMPLEMENTATION-STATUS.md](IMPLEMENTATION-STATUS.md) | Task tracker and remaining work | ~85% complete |

---

### Configuration & Scripts

| Path | Purpose |
|------|---------|
| [config/env.template](config/env.template) | Environment variables template |
| [config/sso.config.ts](config/sso.config.ts) | OAuth SSO TypeScript configuration |
| [config/STORJ-SETUP.md](config/STORJ-SETUP.md) | Storj S3 storage configuration |
| [scripts/deploy-all.sh](scripts/deploy-all.sh) | Deploy all services to production |
| [scripts/health-check.sh](scripts/health-check.sh) | Monitor service health |
| [scripts/sync-secrets.sh](scripts/sync-secrets.sh) | Verify JWT secrets match across services |
| [scripts/init-db.sql](scripts/init-db.sql) | Database initialization script |

---

### Infrastructure Code

| Directory | Purpose |
|-----------|---------|
| [monitoring/](monitoring/) | Logging, metrics, health checks, alerting, backups |
| [e2e-tests/](e2e-tests/) | Playwright end-to-end tests |

---

## Server Quick Reference

| Service | Server | SSH | URL |
|---------|--------|-----|-----|
| PreSuite Hub | 76.13.2.221 | `ssh root@76.13.2.221` | https://presuite.eu |
| PreDrive | 76.13.1.110 | `ssh root@76.13.1.110` | https://predrive.eu |
| PreMail | 76.13.1.117 | `ssh root@76.13.1.117` | https://premail.site |
| PreOffice | 76.13.2.220 | `ssh root@76.13.2.220` | https://preoffice.site |
| PreSocial | 76.13.2.221 | `ssh root@76.13.2.221` | https://presocial.presuite.eu |

---

## Reading Paths

### For New Developers
1. [README.md](README.md) - Understand the project
2. [CLAUDE.md](CLAUDE.md) - Developer quick reference
3. [architecture/](architecture/README.md) - System design diagrams
4. Service doc for your area (e.g., [PREDRIVE.md](PREDRIVE.md))

### For UI/Frontend Work
1. [UIimplement.md](UIimplement.md) - Design system
2. [UIPatterns-PresearchWeb.md](UIPatterns-PresearchWeb.md) - Component patterns

### For Backend/API Work
1. [API-REFERENCE.md](API-REFERENCE.md) - All endpoints and authentication
2. [INTEGRATION.md](INTEGRATION.md) - Service communication

### For DevOps/Deployment
1. [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment procedures
2. [MONITORING-INFRASTRUCTURE.md](MONITORING-INFRASTRUCTURE.md) - Observability
3. [scripts/](scripts/) - Automation scripts

---

## File Statistics

| Category | Files | Description |
|----------|-------|-------------|
| Core docs | 6 | README, CLAUDE, INDEX, USER-GUIDE, VERSION, THIRD-PARTY-LICENSES |
| Service docs | 5 | PRESUITE, PREDRIVE, PREMAIL, PREOFFICE, PRESOCIAL |
| Architecture | 9 | architecture/ directory |
| Integration | 2 | API-REFERENCE, INTEGRATION |
| UI docs | 2 | UIimplement, UIPatterns-PresearchWeb |
| Operations | 4 | DEPLOYMENT, DEPLOYMENT-SUMMARY, MONITORING, TESTING |
| Config | 1 | config/STORJ-SETUP.md |
| Other | 2 | PRESUITE-SSO-IMPLEMENTATION, IMPLEMENTATION-STATUS |
| **Total Markdown** | **31** | |

---

## Contributing

When adding new documentation:
1. Use UPPERCASE for top-level docs (e.g., `NEWFEATURE.md`)
2. Add entry to this INDEX.md
3. Cross-link from related documents
4. Include "Last Updated" date in header
