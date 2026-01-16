# PreSuite Deployment Summary

> **Date:** January 16, 2026
> **Author:** Claude Opus 4.5
> **Status:** Production Deployed

---

## Infrastructure Overview

### Production Servers

| Service | Server IP | Domain | Status |
|---------|-----------|--------|--------|
| PreSuite Hub | 76.13.2.221 | https://presuite.eu | ✅ Online |
| PreDrive | 76.13.1.110 | https://predrive.eu | ✅ Online |
| PreMail | 76.13.1.117 | https://premail.site | ✅ Online |
| PreOffice | 76.13.2.220 | https://preoffice.site | ✅ Online |

### Server Technologies

| Server | Web Server | Runtime | Database |
|--------|------------|---------|----------|
| PreSuite Hub | Nginx | Node.js (PM2) | PostgreSQL |
| PreDrive | Caddy | Docker (Node.js) | PostgreSQL |
| PreMail | Nginx | Node.js (PM2) | PostgreSQL (Stalwart) |
| PreOffice | Nginx | Docker (Collabora) | - |

---

## Deployed Components

### 1. OAuth SSO System

**Location:** All servers

**Files:**
- PreSuite Hub: `/opt/presuite/server.js` (Identity Provider)
- PreMail: `/var/www/premail-web/` (Service Provider)
- PreDrive: `/opt/predrive/` (Service Provider)
- PreOffice: `/opt/preoffice/` (Service Provider)

**OAuth Endpoints:**
```
Authorization: https://presuite.eu/api/oauth/authorize
Token:         https://presuite.eu/api/oauth/token
User Info:     https://presuite.eu/api/oauth/userinfo
```

**OAuth Clients:**
| Client | Redirect URI |
|--------|--------------|
| premail | https://premail.site/oauth/callback |
| predrive | https://predrive.eu/oauth/callback |
| preoffice | https://preoffice.site/oauth/callback |

---

### 2. Monitoring Infrastructure

**Location:** `/opt/presuite/monitoring/` on all servers

**Components:**

| Component | File | Purpose |
|-----------|------|---------|
| Logging | `logging/logger.ts` | Centralized structured logging |
| Metrics | `metrics/metrics.ts` | Prometheus-compatible metrics |
| Health Checks | `health/health-check.ts` | Service health monitoring |
| Alerting | `alerting/alerting.ts` | Webhook alerts (Slack/Discord) |
| Backups | `backups/backup.sh` | Database & file backups |
| Restore | `backups/restore.sh` | Backup restoration |

**Directory Structure:**
```
/opt/presuite/monitoring/
├── alerting/
│   └── alerting.ts
├── backups/
│   ├── backup.sh
│   ├── restore.sh
│   └── crontab.example
├── health/
│   └── health-check.ts
├── logging/
│   └── logger.ts
├── metrics/
│   └── metrics.ts
├── index.ts
├── package.json
└── tsconfig.json

/opt/presuite-backups/
├── databases/
├── files/
└── logs/
```

---

### 3. Backup System

**Primary Backup Server:** PreSuite Hub (76.13.2.221)

**Cron Schedule:**
```cron
0 2 * * * /opt/presuite/monitoring/backups/backup.sh >> /var/log/presuite-backup.log 2>&1
```

**Backup Contents:**

| Service | Type | Backup Location |
|---------|------|-----------------|
| PreSuite Hub | PostgreSQL | `/opt/presuite-backups/databases/presuite/` |
| PreDrive | PostgreSQL | `/opt/presuite-backups/databases/predrive/` |
| PreDrive | Files | `/opt/presuite-backups/files/predrive/` |
| PreMail | PostgreSQL | `/opt/presuite-backups/databases/premail/` |

**Retention:** 30 days (configurable via `RETENTION_DAYS`)

---

### 4. Testing Infrastructure

**Location:** Local development (`ARC/e2e-tests/`)

**Test Suites:**

| Suite | Framework | Location |
|-------|-----------|----------|
| Unit Tests (PreSuite) | Vitest | `presuite/src/__tests__/` |
| Unit Tests (PreDrive) | Vitest | `PreDrive/apps/api/__tests__/` |
| E2E Tests | Playwright | `ARC/e2e-tests/tests/` |

**Test Commands:**
```bash
# PreSuite Unit Tests
cd presuite && npm test

# PreDrive Unit Tests
cd PreDrive && npx vitest run

# E2E Tests
cd ARC/e2e-tests && npm test
```

---

## Service Configuration

### PreSuite Hub (76.13.2.221)

**Process Manager:** PM2
```bash
pm2 list                    # View processes
pm2 restart presuite        # Restart service
pm2 logs presuite           # View logs
```

**Nginx Config:** `/etc/nginx/sites-enabled/presuite`
**App Directory:** `/opt/presuite/`
**Web Root:** `/var/www/presuite/dist/`

---

### PreDrive (76.13.1.110)

**Process Manager:** Docker Compose
```bash
cd /opt/predrive
docker compose ps           # View containers
docker compose restart      # Restart all
docker compose logs -f api  # View API logs
```

**Caddy Config:** `/etc/caddy/Caddyfile`
**App Directory:** `/opt/predrive/`

**Docker Containers:**
- `deploy-api-1` - Node.js API (port 4000)
- `deploy-postgres-1` - PostgreSQL database
- `deploy-valkey-1` - Valkey (Redis) cache

---

### PreMail (76.13.1.117)

**Process Manager:** PM2
```bash
pm2 list
pm2 restart premail-api
pm2 logs premail-api
```

**Nginx Config:** `/etc/nginx/sites-enabled/premail`
**API Directory:** `/opt/premail/`
**Web Root:** `/var/www/premail-web/`

---

### PreOffice (76.13.2.220)

**Process Manager:** Docker Compose
```bash
cd /opt/preoffice
docker compose ps
docker compose restart
docker compose logs -f nginx
```

**Nginx Config:** Inside Docker container
**App Directory:** `/opt/preoffice/`

---

## Deployment Commands

### Quick Deployment Reference

```bash
# PreSuite Hub
ssh root@76.13.2.221 "cd /opt/presuite && git pull && npm run build"
rsync -avz presuite/dist/ root@76.13.2.221:/var/www/presuite/dist/
ssh root@76.13.2.221 "pm2 restart presuite"

# PreDrive
rsync -avz PreDrive/ root@76.13.1.110:/opt/predrive/
ssh root@76.13.1.110 "cd /opt/predrive && docker compose up -d --build"

# PreMail
cd premail && pnpm run build
rsync -avz apps/web/dist/ root@76.13.1.117:/var/www/premail-web/
ssh root@76.13.1.117 "pm2 restart premail-api"

# PreOffice
rsync -avz preoffice/presearch/online/ root@76.13.2.220:/opt/preoffice/
ssh root@76.13.2.220 "cd /opt/preoffice && docker compose restart"

# Monitoring (all servers)
rsync -avz ARC/monitoring/ root@SERVER_IP:/opt/presuite/monitoring/
```

---

## Environment Variables

### Required for Backups

```bash
# Database credentials
export PRESUITE_DB_HOST=localhost
export PRESUITE_DB_NAME=presuite
export PRESUITE_DB_USER=presuite
export PRESUITE_DB_PASSWORD=<password>

export PREDRIVE_DB_HOST=localhost
export PREDRIVE_DB_NAME=predrive
export PREDRIVE_DB_USER=predrive
export PREDRIVE_DB_PASSWORD=<password>
export PREDRIVE_STORAGE_PATH=/opt/predrive/storage

export PREMAIL_DB_HOST=localhost
export PREMAIL_DB_NAME=stalwart
export PREMAIL_DB_USER=stalwart
export PREMAIL_DB_PASSWORD=<password>

# Backup settings
export BACKUP_ROOT=/opt/presuite-backups
export RETENTION_DAYS=30

# Optional: S3 remote backup
export S3_BUCKET=presuite-backups
export S3_ENDPOINT=https://s3.example.com
export AWS_ACCESS_KEY_ID=<key>
export AWS_SECRET_ACCESS_KEY=<secret>

# Optional: Alert webhook
export ALERT_WEBHOOK_URL=https://hooks.slack.com/services/xxx
```

---

## Health Check URLs

| Service | Health Endpoint | Expected Response |
|---------|-----------------|-------------------|
| PreSuite Hub | https://presuite.eu/api/health | `{ "status": "ok" }` |
| PreDrive | https://predrive.eu/health | `{ "status": "ok" }` |
| PreMail | https://premail.site/api/health | `{ "status": "ok" }` |
| PreOffice | https://preoffice.site/health | `200 OK` |

---

## Troubleshooting

### Service Not Responding

```bash
# Check if service is running
ssh root@SERVER_IP "systemctl status nginx"  # or caddy
ssh root@SERVER_IP "pm2 list"                # or docker ps

# Check logs
ssh root@SERVER_IP "pm2 logs SERVICE_NAME"
ssh root@SERVER_IP "docker compose logs SERVICE_NAME"
ssh root@SERVER_IP "tail -f /var/log/nginx/error.log"

# Restart service
ssh root@SERVER_IP "pm2 restart SERVICE_NAME"
ssh root@SERVER_IP "docker compose restart"
ssh root@SERVER_IP "systemctl restart nginx"
```

### Database Issues

```bash
# Check PostgreSQL
ssh root@SERVER_IP "systemctl status postgresql"
ssh root@SERVER_IP "docker exec -it CONTAINER psql -U USER -d DATABASE"

# Check connections
ssh root@SERVER_IP "ss -tlnp | grep 5432"
```

### SSL Certificate Issues

```bash
# PreSuite Hub / PreMail (Nginx + Certbot)
ssh root@SERVER_IP "certbot renew --dry-run"
ssh root@SERVER_IP "certbot certificates"

# PreDrive / PreOffice (Caddy - auto-manages certs)
ssh root@SERVER_IP "systemctl status caddy"
ssh root@SERVER_IP "caddy validate --config /etc/caddy/Caddyfile"
```

### Backup Issues

```bash
# Manual backup
ssh root@76.13.2.221 "/opt/presuite/monitoring/backups/backup.sh"

# Check backup logs
ssh root@76.13.2.221 "cat /var/log/presuite-backup.log"

# List backups
ssh root@76.13.2.221 "/opt/presuite/monitoring/backups/restore.sh list"
```

---

## Security Notes

1. **SSH Access:** All servers use key-based authentication
2. **Firewalls:** UFW enabled, only ports 22, 80, 443 open
3. **SSL:** All domains use HTTPS with auto-renewed certificates
4. **Secrets:** Database passwords stored in environment variables
5. **OAuth:** Client secrets configurable via environment variables

---

## Documentation Index

| Document | Location | Description |
|----------|----------|-------------|
| SSO Implementation | `ARC/PRESUITE-SSO-IMPLEMENTATION.md` | OAuth 2.0 SSO details |
| Architecture Diagrams | `ARC/architecture/` | System architecture (split into focused files) |
| User Guide | `ARC/USER-GUIDE.md` | End-user documentation |
| Testing Infrastructure | `ARC/TESTING-INFRASTRUCTURE.md` | Test setup guide |
| Monitoring Infrastructure | `ARC/MONITORING-INFRASTRUCTURE.md` | Monitoring details |
| This Document | `ARC/DEPLOYMENT-SUMMARY.md` | Deployment overview |

---

## Contact & Support

- **Infrastructure Issues:** Check server logs and this document
- **Application Bugs:** See testing documentation
- **Security Concerns:** Review security notes and SSO implementation

---

*Last Updated: January 16, 2026*
