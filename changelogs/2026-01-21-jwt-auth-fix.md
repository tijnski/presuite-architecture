# JWT Authentication Fix

**Date:** 2026-01-21
**Services:** PreOffice, PreDrive

## Summary

Fixed JWT authentication across PreSuite services so tokens issued by PreSuite Hub work consistently on all services.

## Changes

### PreOffice (preoffice-web)

**Commit:** `7098454` - Fix JWT authentication to match PreSuite Hub issuer

1. **Fixed JWT_ISSUER mismatch** (`wopi-server/src/config/constants.js`)
   - Changed from hardcoded `'preoffice'` to `process.env.JWT_ISSUER || 'presuite'`
   - Now matches PreSuite Hub's issuer

2. **Optimized verification order** (`wopi-server/src/middleware/auth.js`)
   - Changed to try local JWT verification first (faster, no network call)
   - Falls back to remote PreSuite API only if local verification fails
   - Matches pattern used by PreSocial

### PreDrive (database)

**Applied directly to production database**

Added missing columns to `permissions` table to match schema:
- `can_comment`, `can_download`, `can_rename`, `can_delete`, `can_move`
- `can_share`, `can_view_history`, `can_manage_permissions`
- `expires_at`, `granted_by`, `updated_at`

These columns enable granular permission overrides beyond role-based defaults.

## Verification

All services now authenticate successfully with PreSuite Hub tokens:

| Service | Status |
|---------|--------|
| PreSuite Hub | ✅ |
| PreDrive | ✅ |
| PreOffice | ✅ |
| PreSocial | ✅ |

## JWT Configuration (All Services)

```
JWT_SECRET=<shared-secret>
JWT_ISSUER=presuite
```
