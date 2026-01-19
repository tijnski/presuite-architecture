# PreDrive BYOK Encryption Architecture

> **Last Updated:** January 19, 2026
> **Status:** Implemented and deployed to production

---

## Overview

PreDrive implements client-side, zero-knowledge encryption for files. Users control their own encryption keys - the server never sees unencrypted content or key material.

### Key Principles

1. **Zero-Knowledge** - Server never sees plaintext files or raw encryption keys
2. **Client-Side Encryption** - All encryption/decryption happens in the browser
3. **BYOK (Bring Your Own Key)** - Users create and control their own keys
4. **Two-Tier Key Hierarchy** - KEK (Key Encryption Key) wraps per-file DEKs (Data Encryption Keys)
5. **Multiple Key Types** - Supports passphrase-based and Web3 wallet-based keys

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT (Browser)                         │
│                                                                  │
│  ┌─────────────────┐       ┌─────────────────────────────────┐  │
│  │  Passphrase or  │       │         Key Derivation          │  │
│  │ Web3 Signature  │──────▶│  PBKDF2 (passphrase) or         │  │
│  └─────────────────┘       │  HKDF (Web3 signature)          │  │
│                            └────────────┬────────────────────┘  │
│                                         │                        │
│                                         ▼                        │
│                            ┌─────────────────────────────────┐  │
│                            │     KEK (Key Encryption Key)    │  │
│                            │      AES-256-KW (in memory)     │  │
│                            └────────────┬────────────────────┘  │
│                                         │                        │
│            ┌────────────────────────────┼─────────────────────┐ │
│            │                            │                     │ │
│            ▼                            ▼                     ▼ │
│  ┌─────────────────┐         ┌─────────────────┐   ┌──────────┐│
│  │    File 1       │         │    File 2       │   │  File N  ││
│  │  Random DEK ────┤         │  Random DEK ────┤   │  DEK ... ││
│  │  AES-256-GCM    │         │  AES-256-GCM    │   │          ││
│  └─────────────────┘         └─────────────────┘   └──────────┘│
│            │                            │                     │ │
│            ▼                            ▼                     ▼ │
│  ┌─────────────────┐         ┌─────────────────┐              │ │
│  │ Encrypted File  │         │ Encrypted File  │              │ │
│  │ + Wrapped DEK   │         │ + Wrapped DEK   │              │ │
│  └─────────────────┘         └─────────────────┘              │ │
└─────────────────────────────────────────────────────────────────┘
                 │                           │
                 ▼                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                         SERVER / STORJ                           │
│                                                                  │
│  Stores:                                                         │
│  - Encrypted file blobs (ciphertext only)                       │
│  - Wrapped DEKs (encrypted with user's KEK)                     │
│  - Key metadata (salt, iterations, wallet address)              │
│  - Nonces, checksums                                             │
│                                                                  │
│  NEVER stores:                                                   │
│  - Raw KEKs                                                      │
│  - Passphrases                                                   │
│  - Web3 signatures                                               │
│  - Plaintext files                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Types

### 1. Passphrase-Based Keys

Uses PBKDF2-SHA256 with 310,000 iterations (OWASP recommended minimum).

```typescript
// Key derivation (apps/web/src/lib/crypto/keys.ts)
const key = await deriveKeyFromPassphrase(passphrase, {
  salt: generateSalt(),        // 32 bytes random
  iterations: 310000           // OWASP recommended
});

// Returns:
// - key: CryptoKey (AES-KW for wrapping/unwrapping)
// - salt: Uint8Array
// - verificationHash: string (for passphrase verification)
// - iterations: number
```

**Stored on server:**
- `salt` - 32-byte random salt (base64)
- `iterations` - 310,000
- `verification_hash` - SHA-256 hash for passphrase verification

**NOT stored:**
- Passphrase
- Raw KEK

### 2. Web3 Wallet-Based Keys

Uses HKDF-SHA256 to derive keys from wallet signatures.

```typescript
// Deterministic message signed by wallet
const message = `PreDrive Encryption Key Derivation

This signature will be used to derive your encryption key.
Your files will be encrypted with a key only you control.

Wallet: ${walletAddress.toLowerCase()}
Purpose: File Encryption
Version: 1

This signature does not authorize any blockchain transaction.`;

// User signs with MetaMask, then:
const key = await deriveKeyFromWeb3Signature(walletAddress, signature);
```

**Stored on server:**
- `wallet_address` - Ethereum address (0x...)
- `verification_hash` - SHA-256 of signature (for verification)

**NOT stored:**
- Signature
- Raw KEK

---

## Encryption Flow (Upload)

```
1. User selects file and enables encryption
2. Client prompts for passphrase OR wallet signature
3. Client derives KEK from passphrase/signature
4. Client generates random DEK (AES-256)
5. Client encrypts file with DEK (AES-256-GCM)
6. Client wraps DEK with KEK (AES-KW)
7. Client computes checksums (original + encrypted)
8. Client uploads encrypted blob to Storj
9. Server stores metadata (wrapped DEK, nonce, checksums, key ID)
```

### Code Flow

```typescript
// apps/web/src/api/nodes.ts - uploadEncryptedFile()

// 1. Compute original checksum
const originalChecksum = await sha256(originalBuffer);

// 2. Encrypt file (generates random DEK, encrypts with AES-GCM)
const encrypted = await encryptFile(file, kek);
// Returns: { encryptedBlob, wrappedDek, nonce }

// 3. Compute encrypted checksum
const encryptedChecksum = await sha256(encryptedBuffer);

// 4. Upload to Storj via presigned URL
await uploadToPresignedUrl(uploadUrl, encrypted.encryptedBlob);

// 5. Complete upload with encryption metadata
await completeUpload({
  sessionId,
  encryption: {
    wrappedDek: bytesToBase64(encrypted.wrappedDek),
    nonce: bytesToBase64(encrypted.nonce),
    encryptedChecksum,
  },
});
```

---

## Decryption Flow (Download)

```
1. User requests file download
2. Server returns download URL + encryption metadata
3. Client shows DecryptModal, prompts for passphrase OR wallet signature
4. Client re-derives KEK from passphrase/signature
5. Client downloads encrypted blob from Storj
6. Client unwraps DEK using KEK (AES-KW)
7. Client decrypts file using DEK + nonce (AES-GCM)
8. Client verifies checksum
9. Client triggers browser download
```

### Code Flow

```typescript
// apps/web/src/hooks/useDownload.ts

// 1. Prepare download - checks if file is encrypted
const downloadInfo = await getDownloadUrl(nodeId);

if (downloadInfo.isEncrypted) {
  // 2. Fetch key info and show DecryptModal
  const keyResponse = await getEncryptionKey(downloadInfo.encryption.keyId);
  setDownloadState({ ... }); // Triggers DecryptModal render
}

// 3. After user provides passphrase/signature:
await downloadEncrypted(downloadInfo, kek, fileName);

// apps/web/src/lib/crypto/decrypt.ts - decryptAndDownload()
// - Fetches encrypted blob
// - Unwraps DEK with KEK
// - Decrypts with AES-GCM
// - Verifies checksum
// - Triggers browser download
```

---

## Database Schema

### `encryption_keys` Table

Stores user's master key metadata (KEK parameters).

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | User ID (FK to users) |
| `org_id` | UUID | Organization ID (FK to orgs) |
| `key_type` | VARCHAR(20) | `'passphrase'` or `'web3'` |
| `key_name` | VARCHAR(255) | User-defined name |
| `salt` | TEXT | PBKDF2 salt (base64, passphrase only) |
| `iterations` | INT | PBKDF2 iterations (passphrase only) |
| `wallet_address` | VARCHAR(42) | Ethereum address (Web3 only) |
| `verification_hash` | VARCHAR(64) | For key verification |
| `is_default` | BOOLEAN | Default key for this user |
| `created_at` | TIMESTAMP | Creation timestamp |
| `last_used_at` | TIMESTAMP | Last usage timestamp |

**Indexes:**
- `encryption_keys_user_idx` on `user_id`
- `encryption_keys_org_idx` on `org_id`
- `encryption_keys_wallet_idx` on `wallet_address`
- `encryption_keys_user_wallet_idx` (unique) on `(user_id, key_type, wallet_address)`

### `file_encryption` Table

Stores per-file encryption metadata.

| Column | Type | Description |
|--------|------|-------------|
| `node_id` | UUID | Primary key (FK to nodes, CASCADE delete) |
| `key_id` | UUID | Encryption key ID (FK to encryption_keys) |
| `wrapped_dek` | TEXT | DEK wrapped with KEK (base64) |
| `algorithm` | VARCHAR(20) | `'AES-256-GCM'` |
| `nonce` | TEXT | Encryption nonce (base64, 12 bytes) |
| `original_size` | BIGINT | Original file size in bytes |
| `original_checksum` | VARCHAR(64) | SHA-256 of original file |
| `original_mime` | VARCHAR(255) | Original MIME type |
| `encrypted_size` | BIGINT | Encrypted file size in bytes |
| `encrypted_checksum` | VARCHAR(64) | SHA-256 of encrypted file |
| `created_at` | TIMESTAMP | Encryption timestamp |

**Indexes:**
- `file_encryption_key_idx` on `key_id`

### `files` Table (Modified)

| Column | Type | Description |
|--------|------|-------------|
| `is_encrypted` | BOOLEAN | Whether file is encrypted (default: false) |

### `upload_sessions` Table (Modified)

| Column | Type | Description |
|--------|------|-------------|
| `is_encrypted` | BOOLEAN | Whether upload is encrypted |
| `encryption_key_id` | UUID | Key to use for encryption |
| `original_size` | BIGINT | Original file size before encryption |
| `original_checksum` | VARCHAR(64) | Original file checksum |
| `original_mime` | VARCHAR(255) | Original MIME type |

---

## API Endpoints

### Key Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/encryption/keys` | List user's encryption keys |
| `POST` | `/api/encryption/keys` | Create new encryption key |
| `GET` | `/api/encryption/keys/default` | Get user's default encryption key |
| `GET` | `/api/encryption/keys/:id` | Get specific key metadata |
| `PATCH` | `/api/encryption/keys/:id` | Update key (name, default status) |
| `DELETE` | `/api/encryption/keys/:id` | Delete encryption key |
| `POST` | `/api/encryption/keys/:id/verify` | Verify key passphrase/signature |

### File Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/nodes/files/upload/start` | Start upload (includes encryption metadata) |
| `POST` | `/api/nodes/files/upload/complete` | Complete upload (includes wrapped DEK) |
| `GET` | `/api/nodes/files/:id/download` | Get download URL + encryption info |
| `GET` | `/api/encryption/files/:nodeId` | Get file's encryption details |

### Request/Response Examples

**Create Passphrase Key:**
```json
POST /api/encryption/keys
{
  "keyType": "passphrase",
  "keyName": "My Encryption Key",
  "salt": "base64-encoded-32-bytes",
  "iterations": 310000,
  "verificationHash": "64-char-hex-string",
  "setAsDefault": true
}
```

**Create Web3 Key:**
```json
POST /api/encryption/keys
{
  "keyType": "web3",
  "keyName": "MetaMask Key",
  "walletAddress": "0x1234...abcd",
  "verificationHash": "64-char-hex-string",
  "setAsDefault": true
}
```

**Download Response (Encrypted File):**
```json
GET /api/nodes/files/:id/download
{
  "downloadUrl": "https://storj.io/presigned-url...",
  "isEncrypted": true,
  "encryption": {
    "keyId": "uuid-of-encryption-key",
    "wrappedDek": "base64-encoded-wrapped-dek",
    "algorithm": "AES-256-GCM",
    "nonce": "base64-encoded-12-byte-nonce",
    "originalSize": 1234567,
    "originalChecksum": "sha256-hex",
    "originalMime": "image/png"
  }
}
```

---

## Security Considerations

### Strengths

1. **Zero-Knowledge** - Server cannot decrypt files
2. **Per-File Keys** - Compromising one DEK doesn't expose other files
3. **Key Wrapping** - DEKs encrypted with AES-KW (no IV reuse issues)
4. **Strong KDF** - PBKDF2 with 310K iterations or HKDF for Web3
5. **Integrity** - SHA-256 checksums for both original and encrypted data
6. **Web3 Option** - No passphrase to remember for wallet users

### Attack Vectors Mitigated

| Attack | Mitigation |
|--------|------------|
| Server compromise | Files encrypted client-side; server has no keys |
| Database leak | Only wrapped DEKs stored; useless without KEK |
| Weak passphrase | Strength meter + PBKDF2 with high iterations |
| Replay attack | Unique nonce per file encryption |
| File tampering | Checksum verification on decrypt |
| Key reuse | Each file gets unique random DEK |

### User Responsibilities

- **Keep passphrase secure** - Lost passphrase = lost files (no recovery)
- **Protect wallet** - Web3 key tied to wallet security
- **Test decryption** - Verify you can decrypt before uploading sensitive files

---

## Frontend Components

| Component | Path | Purpose |
|-----------|------|---------|
| `EncryptionKeyManager` | `apps/web/src/components/EncryptionKeyManager.tsx` | Create/manage encryption keys |
| `UploadModal` | `apps/web/src/components/UploadModal.tsx` | Upload with optional encryption |
| `DecryptModal` | `apps/web/src/components/DecryptModal.tsx` | Enter passphrase/sign to decrypt |

## Crypto Library

| File | Path | Purpose |
|------|------|---------|
| `keys.ts` | `apps/web/src/lib/crypto/keys.ts` | Key derivation (PBKDF2, HKDF, AES-KW) |
| `encrypt.ts` | `apps/web/src/lib/crypto/encrypt.ts` | File encryption (AES-256-GCM) |
| `decrypt.ts` | `apps/web/src/lib/crypto/decrypt.ts` | File decryption + verification |
| `utils.ts` | `apps/web/src/lib/crypto/utils.ts` | Base64, hex, SHA-256 utilities |

---

## Deployment

### Database Migration

The encryption feature requires these database tables:
- `encryption_keys`
- `file_encryption`
- Additional columns on `files` and `upload_sessions`

**Migration file:** `packages/db/drizzle/0003_byok_encryption.sql`

**To apply manually:**
```bash
ssh root@76.13.1.110 "docker exec predrive-postgres-1 psql -U predrive -f /path/to/0003_byok_encryption.sql"
```

Or run the migration SQL directly (see migration file for full SQL).

### Verification

```bash
# Check tables exist
docker exec predrive-postgres-1 psql -U predrive -c "\dt" | grep encryption

# Should show:
# public | encryption_keys  | table | predrive
# public | file_encryption  | table | predrive
```

---

## Usage Guide

### Creating a Passphrase Key

1. Click the Key icon in header
2. Click "Create New Key"
3. Select "Passphrase"
4. Enter strong passphrase (12+ chars, mixed case, numbers, symbols)
5. Re-enter to confirm
6. Click "Create Key"

### Creating a Web3 Key

1. Click the Key icon in header
2. Click "Create New Key"
3. Select "Web3 Wallet"
4. Click "Connect Wallet" (MetaMask)
5. Click "Sign & Create Key"
6. Sign the message in MetaMask (no transaction)

### Uploading Encrypted File

1. Click Upload button
2. Select file
3. Ensure "Encrypt file" checkbox is ON (default when key exists)
4. For passphrase key: Enter passphrase
5. For Web3 key: Sign when prompted
6. Click "Upload Encrypted" or "Sign & Upload"

### Downloading Encrypted File

1. Click download on encrypted file (shows lock icon)
2. Decrypt modal appears automatically
3. For passphrase key: Enter passphrase
4. For Web3 key: Click "Sign & Decrypt"
5. File downloads after decryption

---

## Troubleshooting

### Decrypt modal doesn't appear

**Cause:** The `file_encryption` table was missing in production, so encryption metadata wasn't stored.

**Fix:** Run the database migration to create `encryption_keys` and `file_encryption` tables.

### "key.algorithm does not match that of operation"

**Cause:** KEK was derived with wrong algorithm (AES-GCM instead of AES-KW).

**Fix:** KEK must use `AES-KW` algorithm for `wrapKey`/`unwrapKey` operations:
```typescript
{ name: 'AES-KW', length: 256 }  // Correct
{ name: 'AES-GCM', length: 256 } // Wrong
```

### Files in Storj appear unencrypted

**Cause:** Encryption is opt-in. Files uploaded without the "Encrypt file" toggle are stored unencrypted.

**Fix:** Always enable the "Encrypt file" toggle when uploading sensitive files. Create an encryption key first if you haven't already.
