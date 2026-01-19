# PreDrive Updates - January 19, 2026

## Summary

Multiple UI/UX improvements and feature additions to PreDrive file sharing and collaboration capabilities.

---

## Changes

### 1. Edit Share Scope for Files and Folders

**Commit:** `30aeee1`, `3792aea`

Added a third share option "Can edit" that allows collaborative editing:

- **Database**: Added `'edit'` to the share scope enum (`'view' | 'download' | 'edit'`)
- **Backend API**: Updated download endpoint to allow edit scope
- **ShareModal**: Added "Can edit" button for both files and folders
- **PublicShareView**:
  - Added Edit icon and badge for edit scope shares
  - Added "Edit in PreOffice" button for supported document types
  - Folder shares now show scope-specific messaging and sign-in buttons

**Editable file types in PreOffice:**
- Word documents (.docx, .doc, .odt)
- Excel spreadsheets (.xlsx, .xls, .ods)
- PowerPoint presentations (.pptx, .ppt, .odp)

---

### 2. Decrypt Popup for Sharing Encrypted Files

**Commit:** `7ebb7b2`

When sharing an encrypted file, the ShareModal now shows a decrypt step first:

- Detects if file is encrypted and fetches encryption info
- Shows passphrase input or Web3 wallet signing UI (same as download flow)
- Decrypts the file client-side
- Uploads a decrypted copy for sharing
- Creates the share link for the decrypted copy

This ensures shared files can be accessed by recipients without requiring them to have the encryption key.

**Files modified:**
- `apps/web/src/components/ShareModal.tsx` - Complete rewrite with decrypt flow
- `apps/web/src/components/FileDetails.tsx` - Pass `isEncrypted` prop

---

### 3. Share Option in Context Menu

**Commit:** `3405e0d`

Added "Share" option to the right-click/3-dots context menu:

- Available for both files and folders
- Works with encryption support (shows decrypt popup for encrypted files)
- Appears after Download and before Star options

**Files modified:**
- `apps/web/src/components/FileRow.tsx` - Added Share2 icon and onShare prop
- `apps/web/src/components/FileCard.tsx` - Added Share2 icon and onShare prop
- `apps/web/src/components/FileList.tsx` - Added share state, handler, and ShareModal

---

### 4. Removed Verified Badge and Network Health Display

**Commit:** `c79f439`

Removed decorative/placeholder UI elements:

- **VerificationBadge**: Removed from FileCard (showed "Verified" on all files)
- **NetworkHealth**: Removed from Sidebar (showed "Network Healthy - 12 nodes - 4 regions")

**Files modified:**
- `apps/web/src/components/FileCard.tsx` - Removed VerificationBadge component
- `apps/web/src/components/Sidebar.tsx` - Removed NetworkHealth component and import

---

### 5. Fixed Storage Usage Not Updating

**Commit:** `e32c54d`

Storage indicator in sidebar now updates correctly:

- Added `refetchInterval: 60000` for automatic refresh every minute
- Added storage invalidation after delete operations
- Added storage invalidation after permanent delete from trash

**Files modified:**
- `apps/web/src/hooks/useNodes.ts`
  - `useStorageUsage`: Added refetchInterval
  - `useDeleteNode`: Added storage invalidation
  - `usePermanentDeleteNode`: Added storage invalidation
  - Removed unused `useNetworkHealth` hook

---

## Deployment

All changes deployed to production at `https://predrive.eu`

**Server:** `76.13.1.110`
**Deployment method:** Docker Compose with `--no-cache` rebuild

---

## Testing Checklist

- [ ] Share file with "View only" scope
- [ ] Share file with "Download" scope
- [ ] Share file with "Can edit" scope - verify PreOffice button appears
- [ ] Share folder with "Can edit" scope - verify collaboration message
- [ ] Share encrypted file - verify decrypt popup appears
- [ ] Right-click file → Share from context menu
- [ ] Upload file → verify storage updates
- [ ] Delete file → verify storage updates
- [ ] Permanently delete from trash → verify storage updates
- [ ] Verify no "Verified" badge on file cards
- [ ] Verify no "Network Healthy" in sidebar
