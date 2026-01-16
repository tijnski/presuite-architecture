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
| See what's left to build | [toimplement.md](toimplement.md) |

---

## Documentation Map

### Core Documentation

| File | Purpose | Audience |
|------|---------|----------|
| [README.md](README.md) | Project overview, architecture summary, quick start | Everyone |
| [CLAUDE.md](CLAUDE.md) | AI agent/developer quick reference, SSH commands, servers | Developers |
| [VERSION.md](VERSION.md) | Version history versus implementation milestones | Project managers |
| [USER-GUIDE.md](USER-GUIDE.md) | End-user documentation, features, troubleshooting | End users |

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
| [ARCHITECTURE-DIAGRAMS.md](ARCHITECTURE-DIAGRAMS.md) | Visual system diagrams (high-level, OAuth, data flow, security) |
| [INTEGRATION.md](INTEGRATION.md) | Cross-service communication, auth flows, federation |
| [PRESUITE-SSO-IMPLEMENTATION.md](PRESUITE-SSO-IMPLEMENTATION.md) | OAuth SSO implementation details |

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
| [toimplement.md](toimplement.md) | Task tracker (YAML format) | ~73% complete |
| [TODO-REMAINING-WORK.md](TODO-REMAINING-WORK.md) | Prioritized remaining work | ~85% complete |

---

### Configuration & Scripts

| Path | Purpose |
|------|---------|
| [config/env.template](config/env.template) | Environment variables template |
| [config/sso.config.ts](config/sso.config.ts) | OAuth SSO TypeScript configuration |
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
3. [ARCHITECTURE-DIAGRAMS.md](ARCHITECTURE-DIAGRAMS.md) - System design
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

| Category | Files | Total Size |
|----------|-------|------------|
| Core docs | 4 | ~60K |
| Service docs | 5 | ~86K |
| UI docs | 2 | ~31K |
| API docs | 1 | ~18K |
| Operations | 4 | ~34K |
| Tracking | 2 | ~16K |
| **Total Markdown** | **21** | **~245K** |

---

## Contributing

When adding new documentation:
1. Use UPPERCASE for top-level docs (e.g., `NEWFEATURE.md`)
2. Add entry to this INDEX.md
3. Cross-link from related documents
4. Include "Last Updated" date in header
