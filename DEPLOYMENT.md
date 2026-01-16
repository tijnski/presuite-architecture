# PreSuite Ecosystem - Master Deployment Instructions

This document contains the master instructions for developing and deploying all PreSuite services.

---

## AI Agent Instructions (Claude Code)

**CRITICAL: Always follow this workflow:**

1. **ALWAYS work locally first** - Edit files in the local repo (`~/Documents/Documents-MacBook/presearch/`)
2. **Push to GitHub** - Commit and push changes to the remote repository
3. **Pull on production** - SSH to server and run `git pull` to deploy

**NEVER:**
- Edit code directly on production servers via SSH
- Create files directly on servers
- Modify production configs without going through Git

**The correct flow is:**
```
Local Mac → git push → GitHub → ssh + git pull → Production Server
```

---

## Development Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Local     │ ──▶ │   GitHub    │ ──▶ │ Production  │
│ Development │     │ Repository  │     │   Server    │
└─────────────┘     └─────────────┘     └─────────────┘
     Code            git push            git pull
     Test                                build & run
```

**Golden Rule:** Never edit code directly on production servers. All changes go through GitHub.

---

## Server Overview

| Service | Server IP | Hostname | App Path | GitHub Repo |
|---------|-----------|----------|----------|-------------|
| PreSuite | 76.13.2.221 | srv1273270 | `/var/www/presuite` | tijnski/presuite |
| PreDrive | 76.13.1.110 | srv1270547 | `/opt/predrive` | tijnski/PreDrive |
| PreMail | 76.13.1.117 | srv1270590 | `/opt/premail` | tijnski/premail |
| PreOffice | 76.13.2.220 | srv1273269 | `/opt/preoffice` | tijnski/preoffice |

---

## Quick Deploy Commands

### PreSuite (presuite.eu)

```bash
# Local: Push changes
cd ~/Documents/Documents-MacBook/presearch/presuite
git add -A && git commit -m "Your message" && git push origin main

# Server: Deploy
ssh root@76.13.2.221 "cd /var/www/presuite && git pull origin main && npm install && npm run build"
```

Or use the deploy script:
```bash
ssh root@76.13.2.221 "/var/www/presuite/deploy.sh"
```

### PreDrive (predrive.eu)

```bash
# Local: Push changes
cd ~/Documents/Documents-MacBook/presearch/predrive
git add -A && git commit -m "Your message" && git push origin main

# Server: Deploy (Docker-based)
ssh root@76.13.1.110 "cd /opt/predrive && git pull origin main && cd deploy && docker compose -f docker-compose.prod.yml build --no-cache && docker compose -f docker-compose.prod.yml up -d"
```

### PreMail (premail.site)

```bash
# Local: Push changes
cd ~/Documents/Documents-MacBook/presearch/premail
git add -A && git commit -m "Your message" && git push origin main

# Server: Deploy
ssh root@76.13.1.117 "cd /opt/premail && git pull origin main && npm install && npm run build && pm2 restart all"
```

### PreOffice (preoffice.site)

```bash
# Local: Push changes
cd ~/Documents/Documents-MacBook/presearch/preoffice
git add -A && git commit -m "Your message" && git push origin main

# Server: Deploy
ssh root@76.13.2.220 "cd /opt/preoffice && git pull origin main"
# Then rebuild as needed (Docker/npm based on setup)
```

---

## Detailed Server Configuration

### PreSuite (76.13.2.221)

**Stack:** React + Vite + Express + PM2 + Nginx

**Paths:**
- App: `/var/www/presuite`
- Built files: `/var/www/presuite/dist`
- API: `/var/www/presuite-api`

**Services:**
```bash
pm2 status                    # Check running processes
pm2 restart presuite-api      # Restart API
pm2 logs presuite-api         # View logs
```

**Nginx:** Serves static files from `/var/www/presuite/dist`, proxies `/api/*` to port 3001

---

### PreDrive (76.13.1.110)

**Stack:** React + Hono + PostgreSQL + Valkey + Docker

**Paths:**
- App: `/opt/predrive`
- Docker config: `/opt/predrive/deploy`

**Services:**
```bash
docker ps                                          # Check containers
docker compose -f docker-compose.prod.yml logs -f  # View logs
docker compose -f docker-compose.prod.yml down     # Stop
docker compose -f docker-compose.prod.yml up -d    # Start
```

**Containers:**
- `deploy-api-1` - Main API (port 4000)
- `deploy-postgres-1` - PostgreSQL database
- `deploy-valkey-1` - Valkey (Redis alternative)

---

### PreMail (76.13.1.117)

**Stack:** React + Hono + Stalwart Mail + PM2

**Paths:**
- App: `/opt/premail`
- API: `/opt/premail/apps/api`
- Web: `/opt/premail/apps/web`

**Services:**
```bash
pm2 status                    # Check running processes
pm2 restart all               # Restart all services
pm2 logs                      # View logs
```

**PM2 Processes:**
- `premail-api` - Backend API
- `premail-web` - Frontend server

**Stalwart Mail Server:**
- Handles IMAP/SMTP for @premail.site
- Admin: https://mail.premail.site

---

### PreOffice (76.13.2.220)

**Stack:** LibreOffice Online + Docker + Nginx

**Paths:**
- App: `/opt/preoffice`
- Config: `/opt/preoffice/presearch/online`

**Services:**
```bash
cd /opt/preoffice/presearch/online
docker compose up -d          # Start
docker compose down           # Stop
docker compose logs -f        # View logs
```

---

## SSH Access

All servers are accessible via SSH as root:

```bash
ssh root@76.13.2.221    # PreSuite
ssh root@76.13.1.110    # PreDrive
ssh root@76.13.1.117    # PreMail
ssh root@76.13.2.220    # PreOffice
```

### Deploy Keys (GitHub)

Each server has an SSH key configured for GitHub push/pull:

| Server | Key Name | Access |
|--------|----------|--------|
| PreSuite (76.13.2.221) | presuite-server | Read/Write |
| PreDrive (76.13.1.110) | predrive-server | Read/Write |
| PreMail (76.13.1.117) | premail-server-write | Read/Write |
| PreOffice (76.13.2.220) | preoffice-server | Read/Write |

---

## Local Development Paths

```
~/Documents/Documents-MacBook/presearch/
├── presuite/       # Main hub (presuite.eu)
├── predrive/       # File storage (predrive.eu)
├── premail/        # Email client (premail.site)
├── preoffice/      # Document editing (preoffice.site)
└── ARC/            # Architecture docs & configs
```

---

## Common Operations

### Check Sync Status

```bash
# Compare local vs server commits
echo "=== PreSuite ===" && \
cd ~/Documents/Documents-MacBook/presearch/presuite && git log -1 --format="%H %s" && \
ssh root@76.13.2.221 "cd /var/www/presuite && git log -1 --format='%H %s'"

echo "=== PreDrive ===" && \
cd ~/Documents/Documents-MacBook/presearch/predrive && git log -1 --format="%H %s" && \
ssh root@76.13.1.110 "cd /opt/predrive && git log -1 --format='%H %s'"

echo "=== PreMail ===" && \
cd ~/Documents/Documents-MacBook/presearch/premail && git log -1 --format="%H %s" && \
ssh root@76.13.1.117 "cd /opt/premail && git log -1 --format='%H %s'"

echo "=== PreOffice ===" && \
cd ~/Documents/Documents-MacBook/presearch/preoffice && git log -1 --format="%H %s" && \
ssh root@76.13.2.220 "cd /opt/preoffice && git log -1 --format='%H %s'"
```

### View Server Logs

```bash
# PreSuite
ssh root@76.13.2.221 "pm2 logs presuite-api --lines 50"

# PreDrive
ssh root@76.13.1.110 "cd /opt/predrive/deploy && docker compose -f docker-compose.prod.yml logs --tail 50"

# PreMail
ssh root@76.13.1.117 "pm2 logs --lines 50"

# PreOffice
ssh root@76.13.2.220 "cd /opt/preoffice/presearch/online && docker compose logs --tail 50"
```

### Restart Services

```bash
# PreSuite
ssh root@76.13.2.221 "pm2 restart presuite-api"

# PreDrive
ssh root@76.13.1.110 "cd /opt/predrive/deploy && docker compose -f docker-compose.prod.yml restart"

# PreMail
ssh root@76.13.1.117 "pm2 restart all"

# PreOffice
ssh root@76.13.2.220 "cd /opt/preoffice/presearch/online && docker compose restart"
```

---

## Troubleshooting

### Git Pull Conflicts

If the server has local changes that conflict:

```bash
# Option 1: Stash local changes, pull, then reapply
git stash
git pull origin main
git stash pop

# Option 2: Discard local changes and force sync
git fetch origin
git reset --hard origin/main
```

### Build Failures

1. Check Node.js version: `node -v` (should be 20.x)
2. Clear node_modules: `rm -rf node_modules && npm install`
3. Check disk space: `df -h`
4. Check logs for specific errors

### Docker Issues

```bash
# View container status
docker ps -a

# Rebuild without cache
docker compose -f docker-compose.prod.yml build --no-cache

# Remove all containers and rebuild
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build
```

### PM2 Issues

```bash
# Check process status
pm2 status

# Restart with fresh state
pm2 delete all
pm2 start ecosystem.config.cjs  # or npm start

# Save process list
pm2 save
```

---

## Environment Variables

Environment variables are stored in `.env` files on each server. Never commit these to Git.

| Server | Env File Location |
|--------|-------------------|
| PreSuite | `/var/www/presuite-api/.env` |
| PreDrive | `/opt/predrive/deploy/.env.production` |
| PreMail | `/opt/premail/.env` |
| PreOffice | `/opt/preoffice/presearch/online/.env` |

---

## Related Documentation

- [PRESUITE.md](./PRESUITE.md) - PreSuite Hub details
- [PREDRIVE.md](./PREDRIVE.md) - PreDrive details
- [PREMAIL.md](./PREMAIL.md) - PreMail details
- [PREOFFICE.md](./PREOFFICE.md) - PreOffice details
- [toimplement.md](./toimplement.md) - Pending features

---

*Last Updated: January 15, 2026*
