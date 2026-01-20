# PreDrive Development Progress

## Recent Updates (January 2026)

### Public Share Links - Fixed ✅
**Date:** January 19, 2026

**Issues Fixed:**
1. **Public share links required sign-in** - SPA was blocking unauthenticated access to `/shares/:token` URLs
2. **API routing mismatch** - Public endpoints weren't properly mounted, returning 404
3. **Anonymous audit logging failed** - UUID validation error when logging anonymous share access
4. **Password validation UX** - No indication that passwords need 4+ characters

**Changes Made:**

**Backend (`apps/api`):**
- `src/index.ts` - Properly mounted public shares router at `/api/public/shares`
- `src/routes/shares.ts` - Added `/view` endpoint for file preview, fixed audit logging for anonymous users

**Frontend (`apps/web`):**
- `src/App.tsx` - Added share URL detection to bypass auth for public shares
- `src/api/client.ts` - Exported `API_BASE_URL` for public share requests
- `src/api/shares.ts` - Added `getPublicShareInfo`, `getPublicShareDownloadUrl`, `getPublicShareViewUrl` functions
- `src/components/PublicShareView.tsx` - New component for viewing public shares
- `src/components/ShareModal.tsx` - Added password validation UX (min 4 chars indicator)

**Features Working:**
- ✅ Public share links accessible without sign-in
- ✅ Password-protected shares
- ✅ Org-only restricted shares
- ✅ Expiring share links
- ✅ View-only vs download permissions
- ✅ File preview (images, PDFs, text, video, audio)
- ✅ Zoom/rotate controls for image preview

---

### Real-Time Collaboration - Complete ✅
**Date:** January 2026

WebSocket-based real-time updates for folder synchronization across browser windows.

**Features:**
- ✅ Live file/folder creation, rename, delete sync
- ✅ Presence indicators (who's viewing same folder)
- ✅ Activity feed updates
- ✅ Share creation/revocation events
- ✅ Automatic reconnection with exponential backoff

---

### BYOK Encryption - Phase 1 Complete ✅
**Date:** January 19, 2026

Implemented client-side encryption foundation using Web Crypto API.

**New Files (`apps/web/src/lib/crypto/`):**
- `utils.ts` - Cryptographic utilities (SHA-256, random bytes, hex/base64 conversion)
- `keys.ts` - Key derivation from passphrase (PBKDF2) and Web3 wallet (HKDF)
- `encrypt.ts` - File encryption with AES-256-GCM
- `decrypt.ts` - File decryption with checksum verification
- `types.ts` - TypeScript interfaces for encryption
- `index.ts` - Public API with documentation

**Security Features:**
- ✅ AES-256-GCM authenticated encryption
- ✅ PBKDF2-SHA256 key derivation (310,000 iterations)
- ✅ Web3 wallet key derivation via HKDF
- ✅ Per-file DEKs wrapped with user KEK (AES-KW)
- ✅ Passphrase strength checker
- ✅ Checksum verification on decrypt

**Remaining Phases:**
- Phase 2: Database schema & API endpoints
- Phase 3: Key management UI
- Phase 4: Upload integration
- Phase 5: Download/preview integration
- Phase 6: Polish (streaming, sharing encrypted files)

See: [BYOK Implementation Plan](./predrive-byok-plan.md)

---

## Planned Features

---

## Architecture Notes

### API Endpoints

**Authenticated endpoints:** `/api/*` (requires JWT)
**Public endpoints:** `/api/public/*` (no auth required)

### Share Link Flow
```
1. User creates share → POST /api/shares → returns token
2. Share URL: https://predrive.eu/shares/{token}
3. Frontend detects /shares/* path → renders PublicShareView
4. PublicShareView calls GET /api/public/shares/{token}
5. If password required → prompts user
6. View: GET /api/public/shares/{token}/view → presigned URL
7. Download: GET /api/public/shares/{token}/download → presigned URL
```

### File Preview Support
| Type | MIME Patterns | Features |
|------|--------------|----------|
| Images | image/* | Zoom, rotate, pan |
| PDFs | application/pdf | Embedded viewer |
| Text | text/*, application/json | Syntax highlighting |
| Video | video/* | Native player |
| Audio | audio/* | Native player |
