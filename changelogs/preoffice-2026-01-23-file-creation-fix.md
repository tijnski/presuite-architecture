# PreOffice File Creation Fix

**Date:** January 23, 2026
**Service:** PreOffice (preoffice-web)
**Commits:** `4e75f12`, `6600074`

## Problem

Users could edit existing files in PreOffice but could not create new files or use "Save As" functionality. The error displayed was:

> "Document cannot be saved, please check your permissions."

## Root Causes

Three issues were identified:

### 1. WOPI PUT_RELATIVE Handler Blocked File Creation

The `handlePutRelative` function in `wopi-server/src/index.js` returned a `501 Not Implemented` error when PreDrive wasn't configured, blocking all file creation. Even when PreDrive was enabled, it only saved to local storage instead of actually creating files in PreDrive.

### 2. Wrong API Field Name

The WOPI server was sending `fileName` to the PreDrive upload API, but PreDrive expects `name`:

```javascript
// Wrong
{ fileName: 'document.odt', ... }

// Correct
{ name: 'document.odt', ... }
```

### 3. PreDrive Size Validation

PreDrive's `startUploadSchema` requires `size` to be a positive integer (`z.number().int().positive()`), meaning `size > 0`. The code was sending `size: 0` for new empty documents, which failed validation with a 400 error.

### 4. Docker Volume Permissions

The local storage fallback also failed because the Docker volume `/data/preoffice-files` was owned by `root`, but the Node.js process runs as user `nodejs` (uid 1001).

## Fixes Applied

### Fix 1: Updated PUT_RELATIVE Handler

**File:** `wopi-server/src/index.js`

- Removed the `501 Not Implemented` error
- Added proper PreDrive file creation using the 3-step upload flow (start → upload → complete)
- Added fallback to local storage if PreDrive fails
- Handles empty files by using `size: 1` minimum

### Fix 2: Corrected API Field Names

Changed all occurrences of `fileName` to `name` in PreDrive API calls:

```javascript
// Before
const startResponse = await predriveRequest('POST', '/nodes/files/upload/start', userToken, {
  parentId: null,
  fileName,  // Wrong field name
  mime: getMimeType(fileName),
  size: 0    // Invalid: must be > 0
});

// After
const startResponse = await predriveRequest('POST', '/nodes/files/upload/start', userToken, {
  parentId: null,
  name: fileName,  // Correct field name
  mime: getMimeType(fileName),
  size: placeholderContent.length  // Valid: > 0
});
```

### Fix 3: Handle Size > 0 Requirement

For new empty documents, create minimal placeholder content:

```javascript
// For PUT_RELATIVE with empty content
const uploadSize = content.length > 0 ? content.length : 1;

// For /api/create endpoint
const placeholderContent = Buffer.from(' ');
```

### Fix 4: Fixed Docker Volume Permissions

```bash
# Changed ownership from root to nodejs user
chown -R 1001:65533 /var/lib/docker/volumes/preoffice_wopi-data/_data
```

## Files Changed

- `wopi-server/src/index.js` - Fixed PUT_RELATIVE handler and PreDrive API calls

## Deployment

```bash
# Push changes
cd /Users/tijnhoorneman/Documents/Documents-MacBook/presearch/preoffice-web
git push

# Deploy on server
ssh root@76.13.2.220 "cd /opt/preoffice && git pull && docker compose up -d --build wopi"

# Fix volume permissions (one-time)
ssh root@76.13.2.220 "chown -R 1001:65533 /var/lib/docker/volumes/preoffice_wopi-data/_data"
```

## Verification

```bash
# Check health
curl https://preoffice.site/health

# Check logs for errors
ssh root@76.13.2.220 "docker logs preoffice-wopi --tail 50"
```

## Related

- PreDrive upload schema: `packages/shared/src/validators.ts` (`startUploadSchema`)
- WOPI Protocol: https://docs.microsoft.com/en-us/microsoft-365/cloud-storage-partner-program/rest/
