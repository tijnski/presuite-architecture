# PreDrive: Bring Your Own Encryption Key (BYOK) Implementation Plan

## Overview

Enable users to encrypt their files with their own encryption keys before upload. The server never sees plaintext content or encryption keys, providing true zero-knowledge storage.

**Goal:** Users can optionally enable client-side encryption for individual files or entire folders, with keys derived from a passphrase or Web3 wallet.

---

## Architecture

### Encryption Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         BROWSER                                  │
│                                                                  │
│  User File ──► [Encrypt with DEK] ──► Encrypted File            │
│                      │                      │                    │
│                      ▼                      ▼                    │
│              DEK (Data Key)          Upload to S3               │
│                      │                                          │
│                      ▼                                          │
│         [Wrap DEK with KEK] ──► Wrapped DEK                     │
│                                      │                          │
│                                      ▼                          │
│                              Send to Server                     │
│                              (metadata only)                    │
└─────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                         SERVER                                   │
│                                                                  │
│  Stores:                                                        │
│  • Encrypted file (in S3) - cannot decrypt                      │
│  • Wrapped DEK (in DB) - cannot unwrap without KEK              │
│  • Encryption metadata (algorithm, IV) - public info            │
│                                                                  │
│  Never sees: plaintext file, DEK, or KEK                        │
└─────────────────────────────────────────────────────────────────┘
```

### Key Hierarchy

```
KEK (Key Encryption Key) - User's master key
├── Derived from passphrase (PBKDF2/Argon2)
├── OR derived from Web3 wallet signature
└── Never leaves browser, never sent to server

DEK (Data Encryption Key) - Per-file key
├── Random 256-bit key generated per file
├── Used to encrypt file content (AES-256-GCM)
└── Wrapped with KEK before storing on server
```

---

## Cryptographic Choices

| Component | Algorithm | Rationale |
|-----------|-----------|-----------|
| File Encryption | AES-256-GCM | Authenticated encryption, WebCrypto native |
| Key Derivation (passphrase) | PBKDF2-SHA256 (310,000 iterations) | WebCrypto native, OWASP recommended |
| Key Derivation (Web3) | HKDF-SHA256 from signature | Deterministic from wallet |
| Key Wrapping | AES-KW (RFC 3394) | WebCrypto native, designed for key wrapping |
| Random Generation | crypto.getRandomValues() | CSPRNG |

### Why AES-256-GCM?
- **Authenticated encryption**: Detects tampering
- **WebCrypto support**: Native browser implementation (fast, secure)
- **12-byte nonce**: Standard for GCM, included in metadata
- **16-byte auth tag**: Integrity verification

---

## Database Schema Changes

### New Table: `encryption_keys`

```sql
CREATE TABLE encryption_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  org_id UUID NOT NULL REFERENCES organizations(id),

  -- Key identification
  key_type VARCHAR(20) NOT NULL, -- 'passphrase' | 'web3'
  key_name VARCHAR(255), -- User-friendly name

  -- For passphrase-derived keys
  salt BYTEA, -- PBKDF2 salt (32 bytes)
  iterations INTEGER, -- PBKDF2 iterations

  -- For Web3-derived keys
  wallet_address VARCHAR(42), -- 0x...
  derivation_path VARCHAR(255), -- For future HD wallet support

  -- Key verification (to check if passphrase is correct)
  verification_hash VARCHAR(64), -- SHA-256 of derived key

  -- Metadata
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  last_used_at TIMESTAMPTZ,

  UNIQUE(user_id, key_type, wallet_address)
);
```

### New Table: `file_encryption`

```sql
CREATE TABLE file_encryption (
  node_id UUID PRIMARY KEY REFERENCES nodes(id) ON DELETE CASCADE,

  -- Which key was used
  key_id UUID NOT NULL REFERENCES encryption_keys(id),

  -- Wrapped DEK (encrypted with user's KEK)
  wrapped_dek BYTEA NOT NULL, -- AES-KW wrapped key (~40 bytes)

  -- Encryption parameters
  algorithm VARCHAR(20) NOT NULL DEFAULT 'AES-256-GCM',
  nonce BYTEA NOT NULL, -- 12 bytes for GCM
  auth_tag BYTEA, -- 16 bytes (may be appended to ciphertext)

  -- Original file info (for integrity)
  original_size BIGINT NOT NULL,
  original_checksum VARCHAR(64) NOT NULL, -- SHA-256 of plaintext

  -- Encrypted file info
  encrypted_size BIGINT NOT NULL,
  encrypted_checksum VARCHAR(64) NOT NULL, -- SHA-256 of ciphertext

  created_at TIMESTAMPTZ DEFAULT now()
);
```

### Modify `files` Table

```sql
ALTER TABLE files ADD COLUMN is_encrypted BOOLEAN DEFAULT false;
```

---

## API Endpoints

### Encryption Keys Management

```
POST   /api/encryption/keys              Create encryption key
GET    /api/encryption/keys              List user's keys
DELETE /api/encryption/keys/:id          Delete key (if no files use it)
POST   /api/encryption/keys/:id/verify   Verify passphrase is correct
PATCH  /api/encryption/keys/:id/default  Set as default key
```

### Upload with Encryption

Modify existing endpoints:

```
POST /api/nodes/files/upload/start
  + isEncrypted: boolean
  + encryptionKeyId: string (optional, uses default)
  + originalSize: number (plaintext size)
  + originalChecksum: string (plaintext SHA-256)

POST /api/nodes/files/upload/complete
  + wrappedDek: string (base64)
  + nonce: string (base64)
  + encryptedChecksum: string
```

### Download with Encryption

```
GET /api/nodes/files/:id/download
  Response includes:
  + isEncrypted: boolean
  + wrappedDek: string (if encrypted)
  + nonce: string (if encrypted)
  + keyId: string (which key to use)
```

---

## Frontend Implementation

### New Files

```
apps/web/src/
├── lib/
│   └── crypto/
│       ├── index.ts           # Main encryption API
│       ├── keys.ts            # Key derivation (passphrase, Web3)
│       ├── encrypt.ts         # File encryption
│       ├── decrypt.ts         # File decryption
│       └── streams.ts         # Streaming encryption for large files
├── hooks/
│   ├── useEncryptionKeys.ts   # Manage user's keys
│   └── useEncryptedUpload.ts  # Upload with encryption
├── components/
│   ├── EncryptionSetup.tsx    # First-time key setup wizard
│   ├── EncryptionKeyManager.tsx # Manage keys in settings
│   ├── EncryptToggle.tsx      # Toggle encryption on upload
│   └── DecryptPrompt.tsx      # Prompt for passphrase on download
└── store/
    └── encryption.ts          # Zustand store for encryption state
```

### Key Derivation from Passphrase

```typescript
// lib/crypto/keys.ts

export async function deriveKeyFromPassphrase(
  passphrase: string,
  salt: Uint8Array,
  iterations: number = 310000
): Promise<CryptoKey> {
  // Import passphrase as key material
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(passphrase),
    'PBKDF2',
    false,
    ['deriveKey']
  );

  // Derive AES key
  return crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt,
      iterations,
      hash: 'SHA-256',
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    true, // extractable for wrapping
    ['wrapKey', 'unwrapKey']
  );
}
```

### Key Derivation from Web3 Wallet

```typescript
// lib/crypto/keys.ts

export async function deriveKeyFromWeb3(
  walletAddress: string,
  signMessage: (message: string) => Promise<string>
): Promise<{ key: CryptoKey; salt: Uint8Array }> {
  // Create deterministic message for signing
  const message = `PreDrive Encryption Key\nAddress: ${walletAddress}\nPurpose: File Encryption`;

  // Sign with wallet (MetaMask, etc.)
  const signature = await signMessage(message);

  // Use signature as key material
  const signatureBytes = hexToBytes(signature);

  // Derive key using HKDF
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    signatureBytes,
    'HKDF',
    false,
    ['deriveKey']
  );

  const salt = new Uint8Array(32); // Fixed salt for determinism

  return {
    key: await crypto.subtle.deriveKey(
      {
        name: 'HKDF',
        hash: 'SHA-256',
        salt,
        info: new TextEncoder().encode('predrive-encryption-v1'),
      },
      keyMaterial,
      { name: 'AES-GCM', length: 256 },
      true,
      ['wrapKey', 'unwrapKey']
    ),
    salt,
  };
}
```

### File Encryption

```typescript
// lib/crypto/encrypt.ts

export async function encryptFile(
  file: File,
  kek: CryptoKey,
  onProgress?: (progress: number) => void
): Promise<EncryptedFileResult> {
  // Generate random DEK
  const dek = await crypto.subtle.generateKey(
    { name: 'AES-GCM', length: 256 },
    true,
    ['encrypt']
  );

  // Generate random nonce
  const nonce = crypto.getRandomValues(new Uint8Array(12));

  // Read file
  const plaintext = await file.arrayBuffer();

  // Calculate original checksum
  const originalChecksum = await sha256(plaintext);

  // Encrypt file content
  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv: nonce },
    dek,
    plaintext
  );

  // Wrap DEK with KEK
  const wrappedDek = await crypto.subtle.wrapKey(
    'raw',
    dek,
    kek,
    'AES-KW'
  );

  // Calculate encrypted checksum
  const encryptedChecksum = await sha256(ciphertext);

  return {
    encryptedBlob: new Blob([ciphertext], { type: 'application/octet-stream' }),
    wrappedDek: new Uint8Array(wrappedDek),
    nonce,
    originalSize: file.size,
    originalChecksum,
    encryptedSize: ciphertext.byteLength,
    encryptedChecksum,
  };
}
```

### File Decryption

```typescript
// lib/crypto/decrypt.ts

export async function decryptFile(
  encryptedData: ArrayBuffer,
  wrappedDek: Uint8Array,
  nonce: Uint8Array,
  kek: CryptoKey,
  originalName: string,
  originalMime: string
): Promise<File> {
  // Unwrap DEK
  const dek = await crypto.subtle.unwrapKey(
    'raw',
    wrappedDek,
    kek,
    'AES-KW',
    { name: 'AES-GCM', length: 256 },
    false,
    ['decrypt']
  );

  // Decrypt content
  const plaintext = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: nonce },
    dek,
    encryptedData
  );

  return new File([plaintext], originalName, { type: originalMime });
}
```

### Streaming Encryption (Large Files)

```typescript
// lib/crypto/streams.ts

export function createEncryptionStream(
  dek: CryptoKey,
  nonce: Uint8Array
): TransformStream<Uint8Array, Uint8Array> {
  // Use streaming API for files > 100MB
  // Encrypt in chunks, append auth tag at end
  // ... implementation using Web Streams API
}
```

---

## UI/UX Design

### Encryption Setup (First Time)

```
┌─────────────────────────────────────────────────────────────────┐
│  🔐 Set Up Encryption                                           │
│                                                                  │
│  Protect your files with end-to-end encryption.                 │
│  Only you can decrypt your files.                               │
│                                                                  │
│  Choose how to secure your encryption key:                      │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  🔑 Passphrase                                           │   │
│  │  Create a strong passphrase you'll remember              │   │
│  │  [Enter passphrase...                              ]     │   │
│  │  [Confirm passphrase...                            ]     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  🦊 Web3 Wallet                                          │   │
│  │  Use your connected wallet to derive encryption key      │   │
│  │  Connected: 0x8f8a...b36b                                │   │
│  │  [Sign to Create Key]                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ⚠️ Warning: If you forget your passphrase or lose access to   │
│  your wallet, encrypted files cannot be recovered.              │
│                                                                  │
│                                          [Skip] [Set Up]        │
└─────────────────────────────────────────────────────────────────┘
```

### Upload with Encryption Toggle

```
┌─────────────────────────────────────────────────────────────────┐
│  Upload Files                                           [X]     │
│                                                                  │
│  📄 document.pdf (2.3 MB)                                       │
│  📄 photo.jpg (1.1 MB)                                          │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  🔐 Encrypt files                              [Toggle]  │   │
│  │  Using key: My Passphrase Key                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│                                          [Cancel] [Upload]      │
└─────────────────────────────────────────────────────────────────┘
```

### Encrypted File Indicator

```
┌──────────────────────────────────────┐
│  📄 document.pdf                     │
│  2.3 MB • Modified 2 hours ago       │
│  🔐 Encrypted                        │
└──────────────────────────────────────┘
```

### Decrypt Prompt (on Download/Preview)

```
┌─────────────────────────────────────────────────────────────────┐
│  🔐 Decrypt File                                                │
│                                                                  │
│  This file is encrypted. Enter your passphrase to decrypt.      │
│                                                                  │
│  Key: My Passphrase Key                                         │
│  [Enter passphrase...                                     ]     │
│                                                                  │
│  ☐ Remember for this session                                    │
│                                                                  │
│                                        [Cancel] [Decrypt]       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Crypto Foundation
1. Create `lib/crypto/` with key derivation and encryption functions
2. Add WebCrypto utility functions (SHA-256, random bytes)
3. Unit tests for all crypto operations
4. **Deliverable:** Working encryption/decryption in browser console

### Phase 2: Database & API
1. Add `encryption_keys` and `file_encryption` tables
2. Create encryption key management endpoints
3. Modify upload endpoints to accept encryption metadata
4. Modify download endpoints to return encryption metadata
5. **Deliverable:** API accepts encrypted uploads

### Phase 3: Key Management UI
1. Create `EncryptionSetup.tsx` wizard
2. Create `EncryptionKeyManager.tsx` for settings
3. Add encryption key state to Zustand store
4. **Deliverable:** Users can create/manage encryption keys

### Phase 4: Upload Integration
1. Create `useEncryptedUpload.ts` hook
2. Add `EncryptToggle.tsx` to upload UI
3. Integrate encryption into upload flow
4. Progress tracking for encryption + upload
5. **Deliverable:** Users can upload encrypted files

### Phase 5: Download/Preview Integration
1. Create `DecryptPrompt.tsx` component
2. Modify download flow to decrypt
3. Modify preview flow to decrypt
4. Session key caching (optional)
5. **Deliverable:** Users can download/preview encrypted files

### Phase 6: Polish & Edge Cases
1. Large file streaming encryption
2. Folder-level encryption defaults
3. Share encrypted files (key re-wrapping)
4. Key rotation/recovery options
5. **Deliverable:** Production-ready BYOK

---

## Security Considerations

### Threat Model

| Threat | Mitigation |
|--------|------------|
| Server compromise | Server never has plaintext or keys |
| Database leak | Wrapped DEKs useless without KEK |
| S3 breach | Encrypted blobs are ciphertext |
| MITM attack | HTTPS + client-side encryption |
| Weak passphrase | Enforce minimum strength, show meter |
| Key loss | Clear warnings, optional recovery key |

### What We Protect Against
- ✅ Server operator reading files
- ✅ Database breach exposing content
- ✅ Storage provider accessing data
- ✅ Law enforcement with server access (without user key)

### What We Don't Protect Against
- ❌ Compromised user device
- ❌ User sharing their passphrase
- ❌ Keylogger on user's machine
- ❌ User forgetting passphrase (data loss)

### Security Audit Checklist
- [ ] No plaintext or keys in console logs
- [ ] Keys cleared from memory after use
- [ ] Secure random generation only
- [ ] No key material in URLs
- [ ] HTTPS enforced
- [ ] CSP headers prevent script injection

---

## Files to Create/Modify

### New Files

**Frontend:**
```
apps/web/src/lib/crypto/index.ts
apps/web/src/lib/crypto/keys.ts
apps/web/src/lib/crypto/encrypt.ts
apps/web/src/lib/crypto/decrypt.ts
apps/web/src/lib/crypto/streams.ts
apps/web/src/lib/crypto/utils.ts
apps/web/src/hooks/useEncryptionKeys.ts
apps/web/src/hooks/useEncryptedUpload.ts
apps/web/src/components/EncryptionSetup.tsx
apps/web/src/components/EncryptionKeyManager.tsx
apps/web/src/components/EncryptToggle.tsx
apps/web/src/components/DecryptPrompt.tsx
apps/web/src/api/encryption.ts
```

**Backend:**
```
apps/api/src/routes/encryption.ts
packages/db/src/schema/encryption.ts (or add to schema.ts)
packages/db/drizzle/XXXX_add_encryption.sql
```

### Modified Files

**Frontend:**
```
apps/web/src/hooks/useUpload.ts
apps/web/src/hooks/useNodes.ts
apps/web/src/components/FileList.tsx
apps/web/src/components/FileCard.tsx
apps/web/src/components/UploadModal.tsx (if exists)
apps/web/src/components/FilePreview.tsx
apps/web/src/store/index.ts
```

**Backend:**
```
apps/api/src/index.ts (mount encryption routes)
apps/api/src/routes/nodes.ts (upload/download changes)
packages/db/src/schema.ts (add is_encrypted to files)
```

---

## Testing Strategy

### Unit Tests
- Key derivation produces consistent results
- Encryption → decryption round-trip
- Wrapped key can be unwrapped
- Invalid passphrase fails gracefully

### Integration Tests
- Upload encrypted file → download → decrypt → matches original
- Create key → encrypt → change passphrase → cannot decrypt
- Web3 key derivation produces same key for same wallet

### E2E Tests
- Full encryption setup flow
- Upload encrypted file
- Preview encrypted file
- Download encrypted file
- Share encrypted file (future)

---

## Open Questions

1. **Key Recovery:** Should we offer optional recovery keys (split key, trusted contacts)?
2. **Folder Encryption:** Encrypt all files in a folder by default?
3. **Sharing:** How to share encrypted files? Re-wrap DEK with recipient's key?
4. **Mobile:** How will mobile apps handle encryption?
5. **Performance:** At what file size should we switch to streaming?

---

## References

- [Web Crypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [AES-GCM in WebCrypto](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/encrypt#aes-gcm)
- [Tresorit Security Whitepaper](https://tresorit.com/security) (similar architecture)
