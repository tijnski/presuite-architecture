# PreMail - Privacy-Focused Email Client

## Overview

PreMail is a privacy-focused email client that's part of the Presearch ecosystem. It provides end-to-end encrypted email services with @premail.site addresses, powered by Stalwart Mail Server for IMAP/SMTP functionality.

## Project Structure

```
premail/
├── apps/
│   ├── api/          # Hono-based REST API (TypeScript)
│   └── web/          # React + Vite frontend
├── packages/
│   ├── db/           # Drizzle ORM + PostgreSQL schema
│   ├── shared/       # Shared utilities (formatRelativeTime, etc.)
│   ├── email-engine/ # Legacy EmailEngine integration (deprecated)
│   ├── postal/       # Postal mail server integration (not used)
│   └── search/       # Search functionality
└── .env              # Environment configuration
```

## Technology Stack

### Frontend (apps/web)
- **React 18** with TypeScript
- **Vite** for bundling
- **TailwindCSS** for styling
- **Jotai** for state management (with atomWithStorage for persistence)
- **React Query** (@tanstack/react-query) for data fetching
- **React Router** for navigation
- **Lucide React** for icons

### Backend (apps/api)
- **Hono** - Fast, lightweight web framework
- **Drizzle ORM** for database operations
- **bcryptjs** for password hashing
- **JWT** for authentication
- **ImapFlow** for IMAP operations
- **Nodemailer** for SMTP/sending emails

### Infrastructure
- **Stalwart Mail Server** - Handles IMAP/SMTP for @premail.site accounts
- **PostgreSQL** - Database (runs in Docker container `premail-postgres`)
- **PM2** - Process management on production server
- **Nginx** - Reverse proxy

## Server Configuration

### Production Server
- **IP:** 76.13.1.117
- **Domain:** premail.site
- **API Port:** 4001
- **Web Port:** Served via PM2/Nginx

### Stalwart Mail Server
- **Host:** mail.premail.site
- **IMAP Port:** 993 (TLS)
- **SMTP Port:** 587 (STARTTLS)
- **Admin API:** https://mail.premail.site:443/api

### Database
- **Container:** premail-postgres
- **User:** premail
- **Password:** premail
- **Database:** premail
- **Port:** 5432 (localhost)

## Key Files

### API Routes

#### `/apps/api/src/routes/auth.ts`
Handles authentication:
- `POST /auth/register` - Creates user + Stalwart mailbox for @premail.site
- `POST /auth/login` - Authenticates user, returns JWT
- `POST /auth/reset-password` - Password reset (dev mode, no email verification)
- `GET /auth/me` - Returns current user info

**Important:** When creating Stalwart users, must include ALL IMAP permissions:
```typescript
enabledPermissions: [
  "authenticate", "email-send", "email-receive",
  "imap-authenticate", "imap-list", "imap-lsub", "imap-subscribe",
  "imap-namespace", "imap-fetch", "imap-append", "imap-copy",
  "imap-move", "imap-expunge", "imap-create", "imap-delete",
  "imap-rename", "imap-status", "imap-select", "imap-examine",
  "imap-search", "imap-sort", "imap-thread", "imap-idle",
  "imap-enable", "imap-id", "imap-store"
]
```

#### `/apps/api/src/routes/messages.ts`
Handles email operations:
- `GET /messages` - List messages in folder
- `GET /messages/:id` - Get single message
- `POST /messages/send` - Send email
- `POST /messages/:id/read` - Mark as read/unread
- `POST /messages/:id/star` - Star/unstar message
- `DELETE /messages/:id` - Delete message

**Folder Name Mapping:** Frontend uses lowercase names, Stalwart uses different names:
```typescript
const folderMap = {
  'sent': 'Sent Items',
  'drafts': 'Drafts',
  'trash': 'Deleted Items',
  'spam': 'Junk Mail',
  'junk': 'Junk Mail',
  'archive': 'Archive',
};
```

#### `/apps/api/src/lib/stalwart-mail.ts`
Direct IMAP/SMTP client for Stalwart:
- `listMessages(folder, page, pageSize)` - List messages via IMAP
- `getMessage(folder, messageId)` - Get full message with body
- `sendMessage(options)` - Send via SMTP, save to "Sent Items" via IMAP
- `updateFlags(folder, messageId, flags)` - Mark read/starred
- `deleteMessage(folder, messageId)` - Delete message
- `listFolders()` - List available folders
- `moveMessage(from, messageId, to)` - Move between folders

### Frontend Components

#### `/apps/web/src/layouts/AppLayout.tsx`
Main layout with sidebar navigation. **Important:** Loads accounts on mount via useQuery.

#### `/apps/web/src/pages/InboxPage.tsx`
Email list view. Uses `selectedAccountAtom` from accounts store.

#### `/apps/web/src/pages/RegisterPage.tsx`
Registration page for @premail.site accounts.

#### `/apps/web/src/store/accounts.ts`
Jotai atoms for account management:
- `accountsAtom` - List of email accounts
- `selectedAccountIdAtom` - Persisted in localStorage
- `selectedAccountAtom` - Derived atom, returns selected or first account

#### `/apps/web/src/store/auth.ts`
Authentication state:
- `authAtom` - Stores user and token (persisted)
- `loginAtom` - Action to set auth state
- `logoutAtom` - Action to clear auth state

## Database Schema

### users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

### email_accounts
```sql
CREATE TABLE email_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  engine_account_id VARCHAR(255) UNIQUE NOT NULL,  -- "stalwart:{username}"
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  provider account_provider DEFAULT 'imap',  -- ENUM: imap, gmail, microsoft
  status account_status DEFAULT 'connecting', -- ENUM: connecting, connected, disconnected, error, auth_error
  error_message TEXT,
  mail_password TEXT,  -- Plain password for IMAP/SMTP access
  last_sync_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### orgs
```sql
CREATE TABLE orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

## Environment Variables

```env
# Database
DATABASE_URL=postgresql://premail:premail@localhost:5432/premail

# JWT
JWT_SECRET=your-jwt-secret

# Stalwart Mail Server
STALWART_HOST=mail.premail.site
STALWART_IMAP_PORT=993
STALWART_SMTP_PORT=587
STALWART_API_URL=https://mail.premail.site:443
STALWART_ADMIN_USER=admin
STALWART_ADMIN_PASS=your-admin-password
```

## Deployment

### Build and Deploy
```bash
# SSH to server
ssh root@76.13.1.117

# Navigate to project
cd /opt/premail

# Pull latest changes
git pull

# Install dependencies
pnpm install

# Build
pnpm build

# Restart services
pm2 restart premail-api --update-env
pm2 restart premail-web
```

### Database Migrations
```bash
cd /opt/premail/packages/db
export DATABASE_URL='postgresql://premail:premail@localhost:5432/premail'
pnpm drizzle-kit push:pg
```

## Stalwart User Management

### Create User via API
```bash
PASS=$(grep STALWART_ADMIN_PASS /opt/premail/.env | cut -d= -f2)
HASH=$(python3 -c "import crypt; print(crypt.crypt('UserPassword', crypt.mksalt(crypt.METHOD_SHA512)))")

curl -X POST -u "admin:$PASS" "https://mail.premail.site:443/api/principal" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "individual",
    "name": "username",
    "secrets": ["'$HASH'"],
    "emails": ["username@premail.site"],
    "quota": 1073741824,
    "enabledPermissions": ["authenticate", "email-send", "email-receive", "imap-authenticate", ...]
  }'
```

### Check User
```bash
curl -u "admin:$PASS" "https://mail.premail.site:443/api/principal/username" -k
```

### Delete User
```bash
curl -X DELETE -u "admin:$PASS" "https://mail.premail.site:443/api/principal/username" -k
```

## Common Issues & Solutions

### 1. IMAP Authentication Failed
**Symptom:** `authenticationFailed: true` in logs
**Cause:** Missing IMAP permissions in Stalwart user
**Solution:** Recreate user with full permission list (see auth.ts)

### 2. Folder Not Found
**Symptom:** 500 error when accessing Sent/Trash
**Cause:** Frontend uses "sent", Stalwart uses "Sent Items"
**Solution:** Folder mapping in messages.ts handles this

### 3. Stale Account ID
**Symptom:** Frontend uses old account ID after database reset
**Cause:** localStorage persists `premail_selected_account`
**Solution:** Clear localStorage, log out/in again

### 4. Database Connection Timeout
**Symptom:** `CONNECT_TIMEOUT` errors
**Cause:** Wrong DATABASE_URL or postgres not running
**Solution:** Check `docker ps`, verify DATABASE_URL points to localhost:5432

### 5. Sent Emails Not Appearing
**Symptom:** Emails send but don't show in Sent folder
**Cause:** IMAP append to wrong folder name
**Solution:** Use "Sent Items" not "Sent" for Stalwart

## Stalwart IMAP Folder Structure
- `INBOX` - Incoming mail
- `Sent Items` - Sent mail (NOT "Sent")
- `Drafts` - Draft messages
- `Deleted Items` - Trash (NOT "Trash")
- `Junk Mail` - Spam

**Production URL:** https://predrive.eu
**Production Server:** 76.13.1.117
**SSO Partner:** PreDrive at https://premail.site (server 76.13.1.110)


## GitHub Repository
- **URL:** https://github.com/tijnski/premail
- **Branch:** main

## Related Projects
- **PreDrive** - Cloud storage (shares database/users)
- **Presearch** - Search engine ecosystem
- **PreOffice** - Office suite

## Current Status (January 2026)

### Working
- User registration with @premail.site
- Stalwart mailbox creation
- IMAP message listing
- Email sending via SMTP
- Folder navigation (Inbox, Sent, Drafts, etc.)
- Authentication (JWT)

### Known Limitations
- No real-time badge counts (hardcoded removed)
- No push notifications
- No attachment handling in UI
- No email threading view
- Single account per user (no external IMAP accounts yet)

## Quick Debug Commands

```bash
# Check API logs
pm2 logs premail-api --lines 50

# Check Stalwart logs
docker exec stalwart-mail cat /opt/stalwart/logs/stalwart.log.$(date +%Y-%m-%d) | tail -30

# Test IMAP connection
node -e "
const { ImapFlow } = require('imapflow');
const client = new ImapFlow({
  host: 'mail.premail.site', port: 993, secure: true,
  auth: { user: 'username', pass: 'password' },
  tls: { rejectUnauthorized: false }
});
client.connect().then(() => console.log('OK')).catch(e => console.log('ERR:', e.message));
"

# Check database
docker exec premail-postgres psql -U premail -d premail -c "SELECT * FROM users;"
docker exec premail-postgres psql -U premail -d premail -c "SELECT * FROM email_accounts;"
```
