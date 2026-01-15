# PreSuite - To Implement / Improvements List

This document tracks all pending features, improvements, and technical debt across the PreSuite ecosystem.

*Generated from: presuite.md, Premail.md, PREDRIVE.md, PREOFFICE.md, VERSION.md, AUTH-API.md, INTEGRATION.md, README.md*

---

## High Priority

### PreSuite Hub (presuite.eu)

| Item | Description | Status |
|------|-------------|--------|
| Real Recent Files | Replace hardcoded Recent files with actual data from PreDrive/PreMail | Pending |
| Real Storage Tracking | Currently shows mock "4.2 GB / 30 GB" - connect to actual storage calculation | Pending |
| PRE Balance Integration | Connect PRE Balance widget to real Presearch wallet/blockchain data | Pending |
| Move Venice API Key | Venice AI key is hardcoded in server.js - move to environment variables | ✅ Done |

### PreMail (premail.site)

| Item | Description | Status |
|------|-------------|--------|
| Attachment Handling | Add attachment upload/download support in email UI | Pending |
| Email Threading | Implement threaded conversation view (like Gmail) | Pending |
| Real-time Badge Counts | Show actual unread counts instead of hardcoded/removed badges | Pending |

### Security & Infrastructure

| Item | Description | Status |
|------|-------------|--------|
| Rate Limiting Verification | Verify rate limiting is actually implemented per AUTH-API.md spec | ✅ Done |
| Health Check Scripts | Create/verify `scripts/health-check.sh` mentioned in README | ✅ Done |
| Secrets Sync Script | Create/verify `scripts/sync-secrets.sh` mentioned in README | ✅ Done |
| Deploy All Script | Create/verify `scripts/deploy-all.sh` mentioned in README | ✅ Done |

---

## Medium Priority

### PreSuite Hub (presuite.eu)

| Item | Description | Status |
|------|-------------|--------|
| Settings Panel | Implement Settings functionality (theme preferences, notifications, account, privacy) | Pending |
| Notifications System | Add real-time notifications with preferences and bell icon badge | Pending |
| PreGPT Chat History | Persist chat history across sessions (localStorage or backend) | ✅ Done |

### PreMail (premail.site)

| Item | Description | Status |
|------|-------------|--------|
| Push Notifications | Implement push notifications for new emails | Pending |
| External IMAP Accounts | Allow users to add external email accounts (not just @premail.site) | Pending |

### PreOffice (preoffice.site)

| Item | Description | Status |
|------|-------------|--------|
| Persistent Demo Storage | Demo mode stores files in memory - add persistent storage option | Pending |
| Full PreDrive Integration | Complete WOPI integration with PreDrive for real file editing | Pending |

### Cross-Service

| Item | Description | Status |
|------|-------------|--------|
| OAuth-Style SSO | Implement optional OAuth redirect flow for more traditional SSO experience | Pending |
| Unified User Profile | Single profile page accessible from all services to update name/settings | Pending |

---

## Future Enhancements

### PreSuite Hub App Modals

Currently, all app modals in PreSuite Hub are UI placeholders with demo data. These need to be connected to real backends:

| Modal | Required Integration |
|-------|---------------------|
| PreMail | Connect to PreMail API for real inbox data |
| PreDrive | Connect to PreDrive API for real file browser |
| PreDocs | Connect to PreOffice for real document list |
| PreSheets | Connect to PreOffice for spreadsheet functionality |
| PreSlides | Connect to PreOffice for presentations |
| PreCalendar | Implement calendar backend and sync |
| PreWallet | Integrate with Presearch blockchain for real transactions |

### PreMail Enhancements

| Feature | Description |
|---------|-------------|
| Search Functionality | Full-text email search across all folders |
| Labels/Tags | Custom labels for email organization |
| Filters & Rules | Automatic email filtering and sorting |
| Rich Text Compose | Full WYSIWYG email composer |
| Contact Management | Address book with contact sync |
| Calendar Integration | Email-calendar integration for events |

### PreDrive Enhancements

| Feature | Description |
|---------|-------------|
| Real-time Collaboration | Multiple users editing same document |
| Comments & Annotations | File commenting system |
| Activity Feed | Show recent activity on shared files |
| Advanced Sharing | More granular permission controls |
| Offline Mode | Download files for offline access |
| Mobile App | Native mobile applications |

### PreOffice Enhancements

| Feature | Description |
|---------|-------------|
| PrePanda AI | Complete AI assistant sidebar integration |
| Template Gallery | Pre-made document templates |
| Real-time Co-editing | Multiple users editing same document live |
| Export Formats | Export to PDF, DOCX, ODT, etc. |
| Print Preview | Enhanced print preview functionality |

---

## Technical Debt

| Item | Location | Description |
|------|----------|-------------|
| ~~Hardcoded Credentials~~ | ~~server.js (PreSuite)~~ | ~~Venice API key should be in .env~~ ✅ Fixed |
| Folder Name Mapping | PreMail API | Frontend/Stalwart folder name mismatch (sent vs "Sent Items") |
| localStorage Persistence | PreMail | Selected account ID persists even after DB reset |
| Demo Mode Files | PreOffice WOPI | In-memory storage not persistent |
| Password Storage | PreMail | `mail_password` stored in plain text for IMAP access |

---

## Documentation Improvements

| Item | Description |
|------|-------------|
| API Documentation | Add OpenAPI/Swagger specs for all services |
| User Guide | Create end-user documentation for all services |
| Deployment Guide | Consolidate deployment instructions |
| Troubleshooting Guide | Expand troubleshooting sections |
| Architecture Diagrams | Add more visual diagrams for data flows |

---

## Testing & Quality

| Item | Description |
|------|-------------|
| Unit Tests | Add comprehensive unit tests for all services |
| Integration Tests | Test cross-service functionality |
| E2E Tests | End-to-end user flow testing |
| Load Testing | Performance testing under load |
| Security Audit | Third-party security review |

---

## Monitoring & Operations

| Item | Description |
|------|-------------|
| Centralized Logging | Aggregate logs from all services |
| Metrics Dashboard | Grafana/similar for service metrics |
| Alerting | Set up alerts for service failures |
| Backup Strategy | Automated backups for all databases |
| Disaster Recovery | Document DR procedures |

---

## Priority Legend

- **High Priority**: Core functionality gaps, security issues, or blocking user experience
- **Medium Priority**: Important features for better UX but not blocking
- **Future**: Nice-to-have features for complete product vision
- **Technical Debt**: Code quality improvements and maintenance items

---

*Last Updated: January 15, 2026*
