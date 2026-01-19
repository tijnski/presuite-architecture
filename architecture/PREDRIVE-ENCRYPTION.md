# PreDrive BYOK (Bring Your Own Key) Encryption Architecture

> **Last Updated:** January 19, 2026
> **Status:** Implemented and deployed

---

## Overview

PreDrive implements client-side, zero-knowledge encryption for files. Users control their own encryption keys - the server never sees unencrypted content or key material.

### Key Principles

1. **Zero-Knowledge**: Server never sees plaintext files or raw encryption keys
2. **Client-Side Encryption**: All encryption/decryption happens in the browser
3. **BYOK (Bring Your Own Key)**: Users create and control their own keys
4. **Two-Tier Key Hierarchy**: KEK (Key Encryption Key) wraps per-file DEKs (Data Encryption Keys)
5. **Multiple Key Types**: Supports passphrase-based and Web3 wallet-based keys

---

## Architecture

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
│                            │        AES-256 (in memory)      │  │
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
// Key derivation
const key = await deriveKeyFromPassphrase(passphrase, {
  salt: generateSalt(),        // 32 bytes random
  iterations: 310000           // OWASP recommended
});
```

**Stored on server:**
- `salt`: 32-byte random salt (base64)
- `iterations`: 310000
- `verificationHash`: SHA-256 hash for passphrase verification

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
- `walletAddress`: Ethereum address (0x...)
- `verificationHash`: SHA-256 of signature (for verification)

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
3. Client prompts for passphrase OR wallet signature
4. Client re-derives KEK from passphrase/signature
5. Client downloads encrypted blob from Storj
6. Client unwraps DEK using KEK
7. Client decrypts file using DEK + nonce
8. Client verifies checksum
9. Client triggers browser download
```

### Code Flow

```typescript
// apps/web/src/hooks/useDownload.ts - downloadEncrypted()

// 1. Fetch encrypted file
const encryptedData = await fetch(downloadUrl).then(r => r.arrayBuffer());

// 2. Decrypt (unwraps DEK, decrypts with AES-GCM, verifies checksum)
await decryptAndDownload(encryptedData, {
  wrappedDek: base64ToBytes(encryption.wrappedDek),
  nonce: base64ToBytes(encryption.nonce),
  originalName: fileName,
  originalMime: encryption.originalMime,
  originalChecksum: encryption.originalChecksum,
}, kek);
```

---

## Database Schema

### `encryption_keys` Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `org_id` | UUID | Organization ID (FK) |
| `user_id` | UUID | User ID (FK) |
| `key_type` | ENUM | `'passphrase'` or `'web3'` |
| `key_name` | VARCHAR | User-defined name |
| `salt` | TEXT | PBKDF2 salt (base64, passphrase only) |
| `iterations` | INT | PBKDF2 iterations (passphrase only) |
| `wallet_address` | VARCHAR | Ethereum address (Web3 only) |
| `verification_hash` | VARCHAR | For key verification |
| `is_default` | BOOLEAN | Default key for this user |
| `created_at` | TIMESTAMP | Creation timestamp |

### `file_encryption` Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `node_id` | UUID | File node ID (FK) |
| `key_id` | UUID | Encryption key ID (FK) |
| `wrapped_dek` | TEXT | DEK wrapped with KEK (base64) |
| `algorithm` | VARCHAR | `'AES-256-GCM'` |
| `nonce` | TEXT | Encryption nonce (base64) |
| `original_size` | BIGINT | Original file size |
| `original_checksum` | VARCHAR | SHA-256 of original |
| `encrypted_checksum` | VARCHAR | SHA-256 of encrypted |
| `created_at` | TIMESTAMP | Encryption timestamp |

---

## API Endpoints

### Key Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/keys` | List user's encryption keys |
| `POST` | `/api/keys` | Create new encryption key |
| `GET` | `/api/keys/default` | Get default encryption key |
| `POST` | `/api/keys/:id/default` | Set key as default |
| `DELETE` | `/api/keys/:id` | Delete encryption key |

### File Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/nodes/files/upload/start` | Start upload (includes encryption metadata) |
| `POST` | `/api/nodes/files/upload/complete` | Complete upload (includes wrapped DEK) |
| `GET` | `/api/nodes/files/:id/download` | Get download URL + encryption info |

---

## Security Considerations

### Strengths

1. **Zero-Knowledge**: Server cannot decrypt files
2. **Per-File Keys**: Compromising one DEK doesn't expose other files
3. **Key Wrapping**: DEKs encrypted with AES-KW (no IV reuse issues)
4. **Strong KDF**: PBKDF2 with 310K iterations or HKDF for Web3
5. **Integrity**: SHA-256 checksums for both original and encrypted data
6. **Web3 Option**: No passphrase to remember for wallet users

### Attack Vectors Mitigated

| Attack | Mitigation |
|--------|------------|
| Server compromise | Files encrypted client-side; server has no keys |
| Database leak | Only wrapped DEKs stored; useless without KEK |
| Weak passphrase | Strength meter + PBKDF2 with high iterations |
| Replay attack | Unique nonce per file encryption |
| File tampering | Checksum verification on decrypt |

### User Responsibilities

- **Keep passphrase secure**: Lost passphrase = lost files (no recovery)
- **Protect wallet**: Web3 key tied to wallet security
- **Backup keys**: Consider exporting key metadata for recovery

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
| `keys.ts` | `apps/web/src/lib/crypto/keys.ts` | Key derivation (PBKDF2, HKDF) |
| `encrypt.ts` | `apps/web/src/lib/crypto/encrypt.ts` | File encryption (AES-256-GCM) |
| `decrypt.ts` | `apps/web/src/lib/crypto/decrypt.ts` | File decryption + verification |
| `utils.ts` | `apps/web/src/lib/crypto/utils.ts` | Base64, hex, SHA-256 utilities |

---

## Usage

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
3. Toggle "Encrypt file" checkbox
4. For passphrase key: Enter passphrase
5. For Web3 key: Sign when prompted
6. Click "Upload Encrypted" or "Sign & Upload"

### Downloading Encrypted File

1. Click download on encrypted file
2. Decrypt modal appears
3. For passphrase key: Enter passphrase
4. For Web3 key: Click "Sign & Decrypt"
5. File downloads after decryption

---

## Why Files in Storj Appear Unencrypted

Files in Storj will only be encrypted if:

1. User has created an encryption key
2. User enabled "Encrypt file" toggle during upload
3. For passphrase keys: User entered correct passphrase
4. For Web3 keys: User signed with correct wallet

**Files uploaded without encryption enabled will be stored unencrypted in Storj.** Encryption is opt-in per file, not automatic.

To ensure files are encrypted:
- Create an encryption key (Settings > Encryption)
- Set it as default
- Always enable the "Encrypt file" toggle when uploading sensitive files
