# PreSuite Implementation Versions

This document tracks the implementation status and versions of all PreSuite services.

## Current Version: 2.1.0

**Release Date:** January 17, 2026
**Major Changes:** Web3 Wallet Authentication, PreSocial Integration

---

## Architecture Version History

### v2.1.0 (January 17, 2026) - Web3 & PreSocial
- **Web3 Wallet Authentication** - MetaMask login support
- **PreSocial Service** - Community discussions (Bun + Hono)
- JWT tokens include wallet_address and is_web3 claims
- File-based JSON storage for PreSocial
- PreMail widget fully functional

### v2.0.0 (January 2026) - Centralized Auth
- **PreSuite Hub** becomes the central identity provider
- All services delegate authentication to Hub
- Registration available from any service
- Unified JWT token format
- Cross-service SSO with auto-provisioning

### v1.0.0 (Initial)
- **PreMail** as identity provider
- SSO from PreMail to PreDrive
- WOPI integration with PreOffice
- Independent user databases per service

---

## Service Versions

### PreSuite Hub (presuite.eu)
| Component | Version | Status |
|-----------|---------|--------|
| Auth API | 2.0.0 | ✅ Live |
| PreGPT | 1.0.0 | ✅ Live |
| Search | 1.0.0 | ✅ Live |
| Dashboard | 1.0.0 | ✅ Live |

**Implementation Completed:**
- [x] PostgreSQL database for central user store
- [x] Auth endpoints: register, login, verify, me, logout
- [x] Stalwart integration for mailbox creation
- [x] JWT token issuance with shared secret
- [x] CORS configured for all PreSuite domains

### PreMail (premail.site)
| Component | Version | Status |
|-----------|---------|--------|
| Auth | 2.0.0 | ✅ Live |
| IMAP Client | 1.0.0 | ✅ Live |
| SMTP Client | 1.0.0 | ✅ Live |

**Implementation Completed:**
- [x] Auth routes forward to PreSuite Hub
- [x] Local user sync for IMAP access
- [x] Ecosystem config updated with AUTH_API_URL

### PreDrive (predrive.eu)
| Component | Version | Status |
|-----------|---------|--------|
| Auth | 2.0.0 | ✅ Live |
| Storage API | 1.0.0 | ✅ Live |
| WebDAV | 1.0.0 | ✅ Live |

**Implementation Completed:**
- [x] Auth routes added (/api/auth/*)
- [x] Routes forward to PreSuite Hub
- [x] JWT verification using shared secret

### PreOffice (preoffice.site)
| Component | Version | Status |
|-----------|---------|--------|
| Auth | 2.0.0 | ✅ Live |
| WOPI | 1.0.0 | ✅ Live |
| Collabora | 1.0.0 | ✅ Live |

**Implementation Completed:**
- [x] JWT_SECRET synchronized with Hub
- [x] AUTH_API_URL configured
- [x] Tokens from Hub are now valid

### PreSocial (presocial.presuite.eu)
| Component | Version | Status |
|-----------|---------|--------|
| Auth | 2.1.0 | ✅ Live |
| Communities | 1.0.0 | ✅ Live |
| Posts/Comments | 1.0.0 | ✅ Live |

**Implementation Completed:**
- [x] Bun + Hono backend
- [x] JWT verification from Hub
- [x] File-based JSON storage
- [x] SSO token pass-through

---

## Implementation Progress

### Phase 1: Documentation (Complete)
- [x] Create unified architecture docs
- [x] Define Auth API specification
- [x] Update SSO configuration
- [x] Create integration guide

### Phase 2: PreSuite Hub Auth API (Complete)
- [x] Set up PostgreSQL database
- [x] Implement auth routes
- [x] Stalwart integration
- [x] CORS configuration
- [x] Frontend auth pages (Login & Register)

### Phase 3: Service Updates (Complete)
- [x] Update PreMail
- [x] Update PreDrive
- [x] Update PreOffice

### Phase 4: Testing & Rollout (Complete)
- [x] Test registration from PreSuite Hub
- [x] Test login via PreMail
- [x] Test login via PreDrive
- [x] Verify token validation across services

---

## Shared Configuration

All services now use:

```bash
JWT_SECRET=<256-bit-secret>  # Same across all services (see .env files)
JWT_ISSUER=presuite
AUTH_API_URL=https://presuite.eu/api/auth
```

---

## Rollback Plan

If v2.0.0 fails:

1. Keep PreMail auth as backup
2. Services can fallback to direct PreMail auth
3. JWT_SECRET remains same, tokens are compatible
4. Revert frontend to POST to PreMail

---

## Change Log

### 2026-01-17 (v2.1.0 - Web3 & PreSocial)
- Added Web3 wallet authentication (MetaMask)
- Added wallet_address and is_web3 JWT claims
- PreSocial service integrated (Bun + Hono)
- PreMail widget fully functional
- Comprehensive documentation update

### 2026-01-16 (v2.0.2 - PreMail Widget Fix)
- Fixed PreMail widget IMAP timeout issues
- Implemented labels/tags system in PreMail
- Updated Hub dashboard widgets

### 2026-01-15 (v2.0.1 - Frontend Auth Pages)
- Added Login page (`/login`) to PreSuite Hub frontend
- Added Register page (`/register`) to PreSuite Hub frontend
- Created auth service for API calls
- Added react-router-dom for routing
- Deployed to production (presuite.eu)

### 2026-01-15 (v2.0.0 Release)
- Implemented centralized auth on PreSuite Hub
- Added PostgreSQL database for user storage
- Created auth routes: register, login, verify, me, logout
- Updated PreMail to forward auth to Hub
- Added auth routes to PreDrive
- Synchronized JWT_SECRET across PreOffice
- All services now use shared authentication

### 2026-01-15 (Initial)
- Created architecture repository
- Defined centralized auth architecture
- Created Auth API specification
- Updated SSO configuration
- Created implementation tracking

---

*Last Updated: January 17, 2026*
