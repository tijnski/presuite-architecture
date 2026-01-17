# PreMail - Privacy-Focused Email Client

## Overview

PreMail is a privacy-focused email client that's part of the Presearch ecosystem. It provides email services with @premail.site addresses, using Stalwart Mail Server for IMAP reading and Postal for outbound email delivery.

**Production URL:** https://premail.site
**Production Server:** 76.13.1.117
**GitHub:** https://github.com/tijnski/premail

## Project Structure

```
premail/
├── apps/
│   ├── api/          # Hono-based REST API (TypeScript)
│   │   ├── src/
│   │   │   ├── config/       # Environment & constants
│   │   │   ├── lib/          # Core libraries (IMAP, encryption, etc.)
│   │   │   ├── middleware/   # Auth, rate-limiter, error handling
│   │   │   ├── routes/       # API route handlers
│   │   │   └── services/     # Business logic
│   │   └── dist/             # Compiled output
│   └── web/          # React + Vite frontend
│       └── src/
│           ├── components/   # UI components
│           ├── hooks/        # Custom React hooks
│           ├── layouts/      # Page layouts
│           ├── lib/          # API client, Web3 auth
│           ├── pages/        # Route pages
│           └── store/        # Jotai state atoms
├── packages/
│   ├── db/           # Drizzle ORM + PostgreSQL schema
│   ├── shared/       # Shared utilities and validators
│   ├── postal/       # Postal mail server client
│   ├── search/       # Typesense search client
│   └── email-engine/ # Legacy EmailEngine integration (deprecated)
├── docker/           # Docker Compose configuration
└── .env              # Environment configuration
```

## Technology Stack

### Frontend (apps/web)

| Package | Version | Purpose |
|---------|---------|---------|
| React | 18.2.0 | UI framework |
| Vite | 5.0.0 | Build tool |
| TypeScript | 5.3.0 | Type safety |
| TailwindCSS | 3.4.0 | Styling |
| @tailwindcss/typography | 0.5.19 | Prose styling |
| Jotai | 2.6.0 | State management |
| @tanstack/react-query | 5.17.0 | Data fetching |
| React Router | 6.21.0 | Navigation |
| Lucide React | 0.309.0 | Icons |
| **Tiptap** | 3.15.3 | Rich text editor |
| dompurify | 3.3.1 | HTML sanitization |
| ethers | 6.x | Web3 integration |

### Backend (apps/api)

| Package | Purpose |
|---------|---------|
| Hono | Fast, lightweight web framework |
| Drizzle ORM | Database operations |
| bcryptjs | Password hashing |
| jsonwebtoken | JWT authentication |
| ImapFlow | IMAP operations (Stalwart) |
| Nodemailer | SMTP sending |
| zod | Schema validation |

### Infrastructure (Docker)

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| PostgreSQL | postgres:16-alpine | 5432 | Primary database |
| Redis | redis:7-alpine | 6380 | Caching & sessions |
| Typesense | typesense:0.25.2 | 8108 | Full-text search |
| Mailpit | axllent/mailpit | 1025, 8025 | Dev email testing |
| **Postal** | postalserver/postal | 2525, 2587, 5050 | Outbound email |
| MariaDB | mariadb:10.11 | 3306 | Postal database |
| RabbitMQ | rabbitmq:3.12 | 5672, 15672 | Postal message queue |

### Third-Party Licensing

| Component | License | Notes |
|-----------|---------|-------|
| Stalwart Mail Server | AGPLv3 | IMAP reading for @premail.site |
| Postal | MIT | Outbound email delivery |
| PostgreSQL | PostgreSQL License | Permissive |
| Typesense | GPL-3.0 | Search engine |

---

## Server Configuration

### Production Server
- **IP:** 76.13.1.117
- **Domain:** premail.site
- **API Port:** 4000 (default)
- **Web Port:** 5173 (dev) / served via Nginx (prod)

### Stalwart Mail Server (IMAP Reading)
- **Host:** mail.premail.site
- **IMAP Port:** 993 (TLS)
- **SMTP Port:** 587 (STARTTLS)

### Postal Mail Server (Outbound)
- **Web UI:** http://localhost:5050
- **SMTP Port:** 2525 (port 25), 2587 (port 587)
- **Requires:** MariaDB, RabbitMQ

### Database
- **Container:** premail-postgres
- **User:** premail
- **Database:** premail
- **Port:** 5432

---

## API Routes

All API routes are mounted at `/api/v1/`.

### Authentication (`/api/v1/auth`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Create user + Stalwart mailbox |
| POST | `/auth/login` | Authenticate, returns JWT |
| POST | `/auth/reset-password` | Password reset |
| GET | `/auth/me` | Get current user info |

### Accounts (`/api/v1/accounts`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/accounts` | List user's email accounts |
| GET | `/accounts/:id` | Get account details |
| POST | `/accounts` | Add external email account |
| DELETE | `/accounts/:id` | Remove account |
| GET | `/accounts/:id/folders` | List account folders |
| POST | `/accounts/:id/sync` | Trigger sync |

### Messages (`/api/v1/messages`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/messages` | List messages in folder |
| GET | `/messages/:id` | Get single message |
| POST | `/messages/send` | Send email |
| POST | `/messages/:id/read` | Mark as read/unread |
| POST | `/messages/:id/star` | Star/unstar message |
| POST | `/messages/:id/move` | Move to folder |
| DELETE | `/messages/:id` | Delete message |
| GET | `/messages/threads` | List threaded messages |
| GET | `/messages/:id/thread` | Get full thread |

### Labels (`/api/v1/labels`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/labels` | List user's labels |
| POST | `/labels` | Create label |
| PATCH | `/labels/:id` | Update label |
| DELETE | `/labels/:id` | Delete label |
| POST | `/labels/:id/messages` | Add messages to label |

### Calendar (`/api/v1/calendar`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/calendar/events` | List events (date range filter) |
| POST | `/calendar/events` | Create event |
| PATCH | `/calendar/events/:id` | Update event |
| DELETE | `/calendar/events/:id` | Delete event |
| POST | `/calendar/reminders` | Set event reminder |

### Search (`/api/v1/search`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/search` | Search messages with filters |

### Notifications (`/api/v1/notifications`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications/config` | Get push notification config |
| POST | `/notifications/subscribe` | Subscribe to push |
| POST | `/notifications/unsubscribe` | Unsubscribe |

### Attachments (`/api/v1/attachments`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/attachments/:id` | Download attachment |
| POST | `/attachments/upload` | Upload attachment |

### PreDrive Integration (`/api/v1/predrive`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/predrive/files` | List PreDrive files |
| POST | `/predrive/attach` | Attach PreDrive file |

### Webhooks (`/webhooks`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/webhooks/postal` | Postal delivery events |

---

## Frontend Pages

| Page | Path | Description |
|------|------|-------------|
| LoginPage | `/login` | User login |
| RegisterPage | `/register` | Account registration |
| ForgotPasswordPage | `/forgot-password` | Password recovery |
| InboxPage | `/inbox` | Email inbox view |
| MessagePage | `/message/:id` | Single message view |
| ComposePage | `/compose` | Email composition |
| AccountsPage | `/accounts` | Manage email accounts |
| CalendarPage | `/calendar` | Calendar view |
| SettingsPage | `/settings` | User settings |
| SSOCallbackPage | `/sso/callback` | SSO authentication |
| OAuthCallbackPage | `/oauth/callback` | OAuth callback |

## Frontend Components

### Core Components
- `RichTextEditor.tsx` - Tiptap-based email composer
- `EditorToolbar.tsx` - Rich text formatting toolbar
- `LabelManager.tsx` - Create/manage labels
- `LabelPicker.tsx` - Label selection UI
- `SearchFilters.tsx` - Advanced search options
- `PreDriveFilePicker.tsx` - Attach files from PreDrive
- `Logo.tsx` - Brand logo

### Layouts
- `AppLayout.tsx` - Main app layout with sidebar
- `AuthLayout.tsx` - Login/register layout

### State Management (Jotai)

```typescript
// accounts.ts
accountsAtom         // List of email accounts
selectedAccountIdAtom // Persisted selected account
selectedAccountAtom  // Derived: selected or first account

// auth.ts
authAtom            // User and token (persisted)
loginAtom           // Set auth state
logoutAtom          // Clear auth state

// labels.ts
labelsAtom          // User's labels
selectedLabelIdAtom // Currently selected label

// search.ts
searchQueryAtom     // Current search query
searchFiltersAtom   // Active filters
searchSuggestionsAtom // Autocomplete suggestions
hasActiveFiltersAtom // Boolean: filters active
```

---

## Database Schema

PreMail uses PostgreSQL with Drizzle ORM. The schema is defined in `packages/db/src/schema/index.ts`.

### Enums

```sql
CREATE TYPE account_status AS ENUM (
  'connecting', 'connected', 'disconnected', 'error', 'auth_error'
);

CREATE TYPE account_provider AS ENUM (
  'imap', 'gmail', 'microsoft'
);

CREATE TYPE message_status AS ENUM (
  'pending', 'sent', 'delivered', 'failed', 'bounced', 'held', 'delayed'
);

CREATE TYPE alert_severity AS ENUM (
  'info', 'warning', 'error', 'critical'
);

CREATE TYPE event_recurrence AS ENUM (
  'none', 'daily', 'weekly', 'biweekly', 'monthly', 'yearly'
);

CREATE TYPE reminder_type AS ENUM (
  'email', 'notification', 'both'
);
```

### Tables

#### `orgs` (cached from PreSuite Hub)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| name | varchar(255) | Organization name |
| created_at | timestamp | |
| updated_at | timestamp | |

#### `users` (cached from PreSuite Hub)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (matches presuite.users) |
| org_id | uuid | FK to orgs |
| email | varchar(255) | Unique email |
| name | varchar(255) | Display name |
| password_hash | varchar(255) | Nullable (SSO users don't have local password) |
| created_at | timestamp | |
| updated_at | timestamp | |

#### `email_accounts`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | FK to users (CASCADE) |
| engine_account_id | varchar(255) | Unique, e.g., "stalwart:{username}" |
| **name** | varchar(255) | Display name |
| email | varchar(255) | Email address |
| provider | account_provider | 'imap', 'gmail', 'microsoft' |
| status | account_status | Connection status |
| error_message | text | Nullable error details |
| mail_password | text | Encrypted IMAP/SMTP password |
| last_sync_at | timestamptz | Last sync time |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `sessions` (refresh tokens)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | FK to users (CASCADE) |
| refresh_token | text | Unique, hashed |
| user_agent | text | Browser/client info |
| ip_address | varchar(45) | Client IP |
| expires_at | timestamptz | Expiration time |
| created_at | timestamptz | |

#### `user_preferences`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | Unique FK to users (CASCADE) |
| theme | varchar(20) | 'system', 'light', 'dark' |
| default_account_id | uuid | FK to email_accounts |
| signature_html | text | HTML signature |
| signature_plain | text | Plain text signature |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `labels` (user-defined email labels)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | FK to users (CASCADE) |
| name | varchar(50) | Label name |
| color | varchar(7) | Hex color (default: #0190FF) |
| created_at | timestamptz | |

#### `message_labels` (junction table)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| label_id | uuid | FK to labels (CASCADE) |
| account_id | uuid | FK to email_accounts (CASCADE) |
| message_id | varchar(255) | IMAP message ID |
| created_at | timestamptz | |

#### `calendar_events`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | FK to users (CASCADE) |
| title | varchar(255) | Event title |
| description | text | Event description |
| location | varchar(500) | Event location |
| start_time | timestamptz | Start datetime |
| end_time | timestamptz | End datetime |
| is_all_day | boolean | All-day event flag |
| recurrence | event_recurrence | Recurrence pattern |
| recurrence_end_date | timestamptz | End of recurrence |
| color | varchar(7) | Hex color (default: #3b82f6) |
| is_private | boolean | Private event flag |
| metadata | text | JSON extra data |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `event_reminders`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| event_id | uuid | FK to calendar_events (CASCADE) |
| reminder_type | reminder_type | 'email', 'notification', 'both' |
| minutes_before | integer | Minutes before event |
| is_sent | boolean | Reminder sent flag |
| sent_at | timestamptz | When sent |
| created_at | timestamptz | |

#### `outbound_messages` (Postal tracking)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| account_id | uuid | FK to email_accounts (CASCADE) |
| postal_message_id | integer | Postal message ID |
| postal_token | varchar(255) | Postal token |
| message_id | varchar(255) | RFC 2822 Message-ID |
| recipient | varchar(255) | Recipient email |
| sender | varchar(255) | Sender email |
| subject | varchar(500) | Email subject |
| status | message_status | Delivery status |
| last_status_update | timestamptz | Last status change |
| delivery_details | text | Delivery info |
| failure_reason | text | Failure reason |
| sent_at | timestamptz | When sent |
| delivered_at | timestamptz | When delivered |
| created_at | timestamptz | |

#### `invalid_recipients` (bounce tracking)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| account_id | uuid | FK to email_accounts (CASCADE) |
| email | varchar(255) | Invalid email address |
| reason | text | Bounce reason |
| bounce_type | varchar(50) | 'hard', 'soft' |
| first_bounced_at | timestamptz | First bounce time |
| last_bounced_at | timestamptz | Last bounce time |
| bounce_count | integer | Number of bounces |
| is_active | boolean | Active suppression |

#### `message_events` (delivery events)
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| outbound_message_id | uuid | FK to outbound_messages (CASCADE) |
| postal_message_id | integer | Postal message ID |
| event_type | varchar(50) | Event type |
| event_data | text | JSON event details |
| postal_timestamp | bigint | Postal timestamp |
| created_at | timestamptz | |

#### `admin_alerts`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| severity | alert_severity | Alert severity |
| type | varchar(100) | Alert type |
| title | varchar(255) | Alert title |
| message | text | Alert message |
| metadata | text | JSON context |
| is_read | boolean | Read flag |
| is_resolved | boolean | Resolved flag |
| resolved_at | timestamptz | Resolution time |
| resolved_by | uuid | FK to users |
| created_at | timestamptz | |

#### `feature_flags`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| key | varchar(100) | Unique flag key |
| enabled | boolean | Enabled flag |
| description | text | Flag description |
| created_at | timestamptz | |
| updated_at | timestamptz | |

---

## Environment Variables

```env
# =============================================================================
# CRITICAL SECURITY (required in production)
# =============================================================================

# Encryption key for mail passwords (32 bytes = 64 hex chars)
# Generate with: openssl rand -hex 32
ENCRYPTION_KEY=

# JWT Secret (minimum 32 characters, must match PreSuite Hub)
# Generate with: openssl rand -hex 32
JWT_SECRET=

# =============================================================================
# DATABASE
# =============================================================================

DATABASE_URL=postgresql://premail:password@localhost:5432/premail
REDIS_URL=redis://localhost:6379

# =============================================================================
# EMAIL SERVICES
# =============================================================================

# EmailEngine API (legacy)
EMAIL_ENGINE_URL=http://localhost:3000
EMAIL_ENGINE_ACCESS_TOKEN=your-token

# Stalwart Mail Server (IMAP reading)
STALWART_HOST=mail.premail.site
STALWART_IMAP_PORT=993
STALWART_SMTP_PORT=587
TLS_REJECT_UNAUTHORIZED=true  # Set to "false" for self-signed certs

# Postal (outbound email)
POSTAL_URL=http://localhost:5050
POSTAL_API_KEY=your-postal-api-key
POSTAL_FROM_ADDRESS=noreply@premail.site

# =============================================================================
# SEARCH
# =============================================================================

TYPESENSE_HOST=localhost
TYPESENSE_PORT=8108
TYPESENSE_PROTOCOL=http
TYPESENSE_API_KEY=your-typesense-key

# =============================================================================
# AUTH & SSO
# =============================================================================

JWT_ISSUER=presuite
JWT_EXPIRES_IN=7d

# =============================================================================
# PREDRIVE INTEGRATION
# =============================================================================

PREDRIVE_URL=http://localhost:4000
PREDRIVE_INTERNAL_API_KEY=your-predrive-key
PREDRIVE_ORG_ID=

# =============================================================================
# APPLICATION
# =============================================================================

NODE_ENV=development
API_PORT=4000
CORS_ORIGIN=http://localhost:5173

# =============================================================================
# FEATURE FLAGS
# =============================================================================

FEATURE_AI_ENABLED=false
FEATURE_SEARCH_ENABLED=true
```

---

## Authentication

PreMail uses **PreSuite Hub** (`presuite.eu`) as the central identity provider. Users register and login via PreSuite Hub, and PreMail validates JWT tokens using a shared secret.

See `INTEGRATION.md` for the complete SSO flow.

---

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

# Restart services (using PM2)
pm2 restart premail-api --update-env
pm2 restart premail-web
```

### Database Migrations

```bash
cd /opt/premail/packages/db
export DATABASE_URL='postgresql://premail:password@localhost:5432/premail'
pnpm drizzle-kit push:pg
```

### Docker Development

```bash
# Start all services
cd /opt/premail/docker
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

---

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

---

## Stalwart IMAP Folder Structure

| IMAP Folder | Frontend Name |
|-------------|---------------|
| `INBOX` | inbox |
| `Sent Items` | sent |
| `Drafts` | drafts |
| `Deleted Items` | trash |
| `Junk Mail` | spam, junk |
| `Archive` | archive |

**Folder Name Mapping** (in messages route):
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

---

## Common Issues & Solutions

### 1. IMAP Authentication Failed
**Symptom:** `authenticationFailed: true` in logs
**Cause:** Missing IMAP permissions in Stalwart user
**Solution:** Recreate user with full permission list

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
**Solution:** Check `docker ps`, verify DATABASE_URL

### 5. Encryption Key Missing
**Symptom:** Mail password encryption fails
**Cause:** ENCRYPTION_KEY not set
**Solution:** Generate with `openssl rand -hex 32`

---

## Current Status (January 2026)

### Working
- User registration with @premail.site
- Stalwart mailbox creation
- IMAP message listing and reading
- Email sending via Postal
- Folder navigation (Inbox, Sent, Drafts, etc.)
- Authentication (JWT via PreSuite Hub)
- SSO Token Pass-through
- **Labels/Tags system**
- **Full-text search (Typesense)**
- **Rich text email composition (Tiptap)**
- **Calendar events and reminders**
- **Push notifications**
- **Attachment handling**
- **PreDrive file integration**

### Known Limitations
- No real-time sync (pull-based)
- No contact management/address book
- Single @premail.site account per user (external IMAP accounts supported)
- No email threading view (planned)

---

## Quick Debug Commands

```bash
# Check API logs
pm2 logs premail-api --lines 50

# Check Docker services
docker compose -f /opt/premail/docker/docker-compose.yml ps

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

# Check Postal
curl http://localhost:5050/health

# Check Typesense
curl http://localhost:8108/health
```

---

## Related Documentation

- [INTEGRATION.md](INTEGRATION.md) - SSO and cross-service integration
- [API-REFERENCE.md](API-REFERENCE.md) - Complete API documentation
- [architecture/PREMAIL.md](architecture/PREMAIL.md) - Architecture details
- [POSTAL_MIGRATION_PROGRESS.md](../premail/POSTAL_MIGRATION_PROGRESS.md) - Postal setup notes
