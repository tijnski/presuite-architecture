# PreSuite Roadmap

> **Created:** January 20, 2026
> **Purpose:** Track planned features and improvements for PreSuite coherence

---

## Overview

This roadmap prioritizes features that will make PreSuite a more polished, coherent product suite.

---

## High Priority - Security & Quality

| Task | Service | Description | Status |
|------|---------|-------------|--------|
| Security Audit | All | OWASP security review, penetration testing | ⏳ Planned |
| Integration Tests | All | Cross-service flow testing (login → upload → edit → share) | ⏳ Planned |
| RSA Webhook Verification | PreMail | Verify Postal webhook signatures (currently skipped) | ⏳ Planned |
| Error Handling Consistency | All | Standardize error responses across all APIs | ⏳ Planned |
| Rate Limit Consistency | All | Ensure all services follow API-REFERENCE.md limits | ⏳ Planned |

---

## High Priority - Core Feature Gaps

| Task | Service | Description | Status |
|------|---------|-------------|--------|
| Cloud Upload | PreOffice | Upload to PreDrive from PreOffice (marked "Coming Soon") | ⏳ Planned |
| Document Templates | PreOffice | Template gallery for common document types | ⏳ Planned |
| Real-time Email Sync | PreMail | WebSocket/SSE for live inbox updates | ⏳ Planned |
| Unified Notifications | Hub | Push notifications across all services to Hub | ⏳ Planned |
| Settings Sync | All | Sync preferences (theme, language) across services | ⏳ Planned |

---

## Medium Priority - Cross-Service Coherence

| Task | Service | Description | Status |
|------|---------|-------------|--------|
| Global Search | Hub | Search files, emails, posts from one search bar | ⏳ Planned |
| Unified Activity Feed | Hub | Combined recent activity from all services | ⏳ Planned |
| Keyboard Shortcuts | All | Consistent shortcuts across services (Cmd+K, etc.) | ⏳ Planned |
| Loading States | All | Consistent skeleton loaders and spinners | ⏳ Planned |
| Empty States | All | Consistent empty state illustrations | ⏳ Planned |
| Toast Notifications | All | Consistent toast styling and positioning | ⏳ Planned |

---

## Medium Priority - User Experience

| Task | Service | Description | Status |
|------|---------|-------------|--------|
| Onboarding Flow | Hub | Guided tour for new users | ⏳ Planned |
| Help Center | Hub | In-app help articles and FAQs | ⏳ Planned |
| Keyboard Shortcuts Modal | All | Cmd+? to show available shortcuts | ⏳ Planned |
| PWA Support | All | Installable web apps with offline capability | ⏳ Planned |
| Email Scheduling | PreMail | Send emails at a future time | ⏳ Planned |
| Undo Send | PreMail | Short delay before actually sending | ⏳ Planned |
| Vacation Responder | PreMail | Auto-reply when away | ⏳ Planned |

---

## Medium Priority - PreSocial Features

| Task | Service | Description | Status |
|------|---------|-------------|--------|
| Community Creation | PreSocial | Users can create their own communities | ⏳ Planned |
| Moderation Tools | PreSocial | Report, ban, remove content | ⏳ Planned |
| Cross-posting | PreSocial | Share to multiple communities | ⏳ Planned |
| Notifications | PreSocial | Notify on replies, mentions, votes | ⏳ Planned |

---

## Low Priority - Advanced Features

| Task | Service | Description | Status |
|------|---------|-------------|--------|
| Offline Mode | PreDrive | Work offline, sync when connected | ⏳ Backlog |
| Mobile Apps | All | Native iOS/Android applications | ⏳ Backlog |
| Real-time Co-editing | PreOffice | Multiple users editing same document | ⏳ Backlog |
| Document Signing | PreOffice | Digital signature integration | ⏳ Backlog |
| Email Encryption | PreMail | PGP/GPG support | ⏳ Backlog |
| Import/Export | PreMail | Import from Gmail/Outlook | ⏳ Backlog |
| DeepL Translation | PreOffice | In-document translation | ⏳ Backlog |
| Load Testing | All | Performance benchmarking | ⏳ Backlog |

---

## Documentation Improvements

| Task | Description | Status |
|------|-------------|--------|
| Update USER-GUIDE.md | Add new features (filters, contacts, aliases, encryption) | ⏳ Planned |
| Video Tutorials | Create short videos for key workflows | ⏳ Planned |
| API Examples | Add curl examples for all endpoints | ⏳ Planned |
| Changelog | Maintain public changelog for users | ⏳ Planned |
| Status Page | Public service status page | ⏳ Planned |

---

## Technical Debt

| Task | Service | Description | Status |
|------|---------|-------------|--------|
| TypeScript Migration | Hub | Convert server.js to TypeScript | ⏳ Backlog |
| Monorepo Structure | Hub | Match PreMail/PreDrive monorepo pattern | ⏳ Backlog |
| Component Library | All | Shared React component package | ⏳ Backlog |
| API Client Package | All | Shared TypeScript API clients | ⏳ Backlog |
| E2E Test Coverage | All | Increase Playwright test coverage | ⏳ Planned |

---

## Brand & Design

| Task | Description | Status |
|------|-------------|--------|
| Consistent Icons | Use Lucide icons across all services | ⏳ Planned |
| Dark Mode Sync | Sync dark mode preference across services | ⏳ Planned |
| Mobile Responsive | Audit and fix mobile layouts | ⏳ Planned |
| Accessibility Audit | WCAG 2.1 AA compliance | ⏳ Planned |
| Favicon Consistency | Matching favicons for all services | ⏳ Planned |

---

## Suggested Sprint Plan

### Sprint 1: Security & Polish
1. Security audit preparation
2. Error handling consistency
3. Update USER-GUIDE.md with new features
4. Toast notification consistency

### Sprint 2: Core Gaps
1. PreOffice cloud upload to PreDrive
2. Real-time email sync (WebSocket)
3. Unified notifications to Hub

### Sprint 3: Coherence
1. Global search from Hub
2. Keyboard shortcuts consistency
3. Settings sync across services

### Sprint 4: UX
1. Onboarding flow
2. Help center / FAQ
3. PWA support

---

## Related Documents

- [IMPLEMENTATION-STATUS.md](IMPLEMENTATION-STATUS.md) - Current implementation status
- [plans/PREMAIL-FEATURES.md](plans/PREMAIL-FEATURES.md) - PreMail feature roadmap
- [plans/preoffice-features-implementation.md](plans/preoffice-features-implementation.md) - PreOffice features
- [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) - UI/UX consistency guide

---

*Last updated: January 20, 2026*
