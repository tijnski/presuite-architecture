# PreSuite Development Progress

Tracking development progress across all PreSuite services.

## Services Overview

| Service | URL | Server |
|---------|-----|--------|
| PreSuite Hub | https://presuite.eu | - |
| PreDrive | https://predrive.eu | 76.13.1.110 |
| PreMail | https://premail.site | 76.13.1.117 |
| PreOffice | https://preoffice.site | - |
| PreSocial | https://presocial.presuite.eu | - |

---

## Completed Tasks

### PreOffice
- [x] **Presearch Styling Alignment** (2026-01-16)
  - Updated PrePanda CSS to match Presearch styling guide
  - Fixed dark mode backgrounds to neutral grays (#191919, #1e1e1e, #2e2e2e)
  - Replaced scale transforms with opacity hover effects
  - Updated scrollbar to use Presearch blue (#2D8EFF)
  - Commit: `c588925`

### PreMail
- [x] **Postal Server Migration** (2026-01-16)
  - Migrated outbound email from EmailEngine to Postal Server
  - Created `@premail/postal` package with full API client
  - Hybrid approach: Postal for outbound, EmailEngine for inbound
  - Production configured with API key and verified domain
  - Webhook handler for delivery status tracking
  - Commit: See `POSTAL_MIGRATION_PROGRESS.md`

### PreDrive
- [x] **WebDAV Recursive Folder Copy** (2026-01-16)
  - Implemented `copyFolderContents()` recursive helper
  - Handles files (copies storage blob, creates node/file/version records)
  - Handles folders (creates folder node, recurses)
  - Sets owner permissions on all copied nodes
  - Commit: `ca032dc`

- [x] **File Range Selection** (2026-01-16)
  - Added Shift+Click range selection for files and folders
  - Works in both grid and list views
  - Added `lastSelectedNodeId` as anchor point
  - Added `selectNodeRange` action to store
  - Commit: `16bd0a4`

---

## Pending Tasks

### High Priority

#### PreSuite Hub
- [ ] **Fix PreMail Widget Integration** *(in progress - another agent)*
  - Widget not displaying correctly on hub dashboard
  - Need to investigate API connectivity

#### PreSocial
- [ ] **Configure Lemmy Bot Account**
  - Set up automated posting bot
  - Configure API credentials
  - Define posting schedule/triggers

### PreOffice
- [x] **Add Cloud Upload to PreDrive** (2026-01-16)
  - Created PreDrive file picker component (`predrive-picker.js`)
  - Added browse API endpoint to WOPI server
  - Added search API endpoint for file search
  - Supports folder navigation and file selection

- [x] **PrePanda AI Sidebar for Web** (2026-01-16)
  - Added Venice.ai API proxy in WOPI server (keeps API key server-side)
  - Created web-specific PrePanda component (`prepanda-web.js`)
  - Added Collabora Online integration script
  - Supports quick actions: summarize, improve, translate, explain
  - Chat interface with markdown rendering

### PreMail
- [ ] **Add Full-Text Email Search**
  - Integrate with Typesense
  - Index email content, subjects, recipients
  - Add advanced search filters

- [ ] **Add Labels/Tags System**
  - Create label management UI
  - Allow multiple labels per email
  - Add label filtering in sidebar

### SSO/Authentication
- [ ] **Add Refresh Token Support**
  - Implement refresh token rotation
  - Add token refresh endpoint
  - Update client-side token handling

- [ ] **Implement PKCE Flow**
  - Add code challenge/verifier
  - Update OAuth endpoints
  - Secure public clients

- [ ] **Add Multi-Factor Authentication (MFA)**
  - TOTP support (Google Authenticator, etc.)
  - Backup codes
  - MFA enrollment flow

---

## Architecture Notes

### PreDrive
- **Stack:** Hono, Drizzle ORM, PostgreSQL, S3/MinIO, Valkey
- **WebDAV:** Full RFC 4918 compliance for LibreOffice/PreOffice
- **Storage:** S3-compatible with versioning support

### PreMail
- **Stack:** Hono, Drizzle ORM, PostgreSQL, Redis, Typesense
- **Inbound:** EmailEngine (IMAP, OAuth)
- **Outbound:** Postal Server (SMTP, delivery tracking)

### PreOffice
- **Base:** LibreOffice Online (CODE)
- **AI:** PrePanda sidebar for AI assistance
- **Integration:** WebDAV to PreDrive

---

## Recent Sessions

### 2026-01-16
- Completed PreOffice styling alignment
- Completed Postal Server migration for PreMail
- Implemented WebDAV recursive folder copy for PreDrive
- Implemented file range selection for PreDrive
- Added PrePanda AI assistant to PreOffice web version
- Added PreDrive file picker to PreOffice web version

---

*Last updated: 2026-01-16*
