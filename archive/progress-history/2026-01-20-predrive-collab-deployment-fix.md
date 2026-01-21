# PreDrive Collaboration Features - Deployment Fix

**Date:** January 20, 2026
**Status:** Deployed Successfully
**Services:** PreDrive

---

## Overview

Fixed TypeScript build errors that prevented deployment of the PreDrive collaboration features (Comments, Advanced Sharing, Real-time Collaboration).

---

## Issues Encountered

### Frontend Components (apps/web/src/components/)

**Problem 1: Missing API Helper**
- Components used `import { api } from '../lib/api'` which didn't exist
- Used patterns like `api.get()`, `api.post()`, `api.delete()`, `api.patch()`

**Solution:**
- Replaced with `import { apiRequest } from '../api/client'`
- Updated all API calls to use `apiRequest(endpoint, options)` pattern
- Removed `.json()` calls since `apiRequest` already returns parsed JSON

**Problem 2: Unused Imports**
- `React`, `useEffect`, `Users`, `Lock`, `queryClient` imported but not used
- TypeScript strict mode flagged these as errors

**Solution:**
- Removed unused imports
- Added back `useEffect` where still used in code

**Problem 3: Missing Interface Property**
- `ExistingShare` interface missing `canInviteOthers` property

**Solution:**
- Added `canInviteOthers: boolean` to interface

**Problem 4: Unused Props**
- `nodeType` prop declared but never used in AdvancedShareModal

**Solution:**
- Made `nodeType` optional in interface: `nodeType?: 'file' | 'folder'`
- Removed from destructuring

---

### Backend API Routes (apps/api/src/routes/)

**Problem 5: Wrong Argument Order**
- `wsManager.broadcastToFolder()` called with wrong argument order
- Code: `(orgId, folderId, userId, message)`
- Correct: `(orgId, folderId, message, excludeUserId)`

**Solution:**
- Fixed argument order in all `wsManager.broadcastToFolder()` calls
- comments.ts: 5 calls fixed
- collaboration.ts: 7 calls fixed

**Problem 6: Wrong Property Name**
- Used `auth.userName` but AuthContext has `name` property

**Solution:**
- Replaced all `auth.userName` with `auth.name`
- Also fixed `owner: auth.userName` in lock creation

**Problem 7: Invalid Folder ID**
- Used `'root'` string for root folder
- Function expects `null` for root

**Solution:**
- Changed `node.parentId || 'root'` to `node.parentId` or `node?.parentId ?? null`

---

## Files Modified

### Frontend (apps/web/src/components/)

| File | Changes |
|------|---------|
| `CommentThread.tsx` | Import fix, API calls, add useEffect |
| `AdvancedShareModal.tsx` | Import fix, API calls, interface fix, unused prop |
| `CollaborationPresence.tsx` | Import fix, API calls, unused imports |

### Backend (apps/api/src/routes/)

| File | Changes |
|------|---------|
| `comments.ts` | Argument order fix (5 calls), auth.name fix |
| `collaboration.ts` | Argument order fix (7 calls), auth.name fix (3 locations) |

---

## Commits

| Hash | Message |
|------|---------|
| `67d8be3` | Fix TypeScript build errors in collaboration components |
| `e19433a` | Fix remaining TypeScript errors |
| `e28568f` | Fix TypeScript errors in comments and collaboration routes |

---

## Deployment

```bash
# Commands executed
ssh root@76.13.1.110 "cd /opt/predrive && git pull origin main && docker compose -f deploy/docker-compose.prod.yml up -d --build"

# Result
✅ Build successful (6/6 tasks)
✅ Container recreated and started
✅ Health check: {"status":"ok"}
```

---

## Verification

```bash
curl -s https://predrive.eu/health
# Output: {"status":"ok"}
```

---

## Technical Details

### apiRequest Function Signature

```typescript
// From apps/web/src/api/client.ts
export async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {},
  retryOnUnauthorized = true
): Promise<T>
```

### wsManager.broadcastToFolder Signature

```typescript
// From apps/api/src/websocket/manager.ts
broadcastToFolder(
  orgId: string,
  folderId: string | null,  // null = root folder
  message: ServerMessage,
  excludeUserId?: string
): void
```

### AuthContext Interface

```typescript
// From packages/shared/src/types.ts
export interface AuthContext {
  userId: string;
  orgId: string;
  email: string | null;
  name: string;           // NOT userName!
  walletAddress?: string;
  isWeb3?: boolean;
}
```

---

## Lessons Learned

1. **Check existing patterns**: The codebase already had `apiRequest` in `api/client.ts` - should have checked before creating new import
2. **TypeScript strict mode**: Helps catch issues early but requires careful attention to unused variables
3. **Function signatures**: Always verify argument order when calling external functions
4. **Interface consistency**: Property names should be consistent across codebase (`name` vs `userName`)

---

## Related Documentation

- [PreDrive Collaboration Features](./2026-01-20-predrive-collab-features.md) - Full implementation details
- [PREDRIVE.md](../PREDRIVE.md) - Service overview
- [IMPLEMENTATION-STATUS.md](../IMPLEMENTATION-STATUS.md) - Overall progress

