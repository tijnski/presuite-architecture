# PreDrive Web3 Encryption v2 Architecture

> **Implemented:** January 20, 2026
> **Status:** Deployed to production
> **Commits:** `5c7a540`, `8638f31`, `6382dfb`

---

## Overview

PreDrive v2 encryption implements a validated wallet-based encryption architecture with enhanced security features following cryptographic best practices. The implementation addresses signature determinism risks, cross-wallet compatibility, and provides defense-in-depth through multiple security layers.

---

## Security Features

### 1. Signature Normalization (EIP-2 Compliance)

ECDSA signatures have a malleability issue: for every valid signature `(r, s)`, there exists another valid signature `(r, n-s)`. Different wallets may produce either form, leading to different derived keys.

**Implementation:**
- `normalizeSignature()` function in `apps/web/src/lib/crypto/keys.ts`
- Converts high-s signatures to low-s form
- Uses secp256k1 curve constants for proper normalization

```typescript
// If s > n/2, normalize to s' = n - s
if (sBigInt > SECP256K1_N_HALF) {
  const sNormalized = SECP256K1_N - sBigInt;
  s = bigIntToBytes32(sNormalized);
}
```

### 2. r||s HKDF Input (64 bytes)

The `v` value in ECDSA signatures can vary across wallet implementations (27/28 vs 0/1). Using only `r||s` ensures consistent key derivation.

**Implementation:**
- `deriveKeyFromWeb3SignatureV2()` extracts and uses only r||s
- 64 bytes of high-entropy input for HKDF-SHA256

### 3. Random Per-KEK Salts

Each encryption key gets a unique random 32-byte salt, providing additional defense if signature determinism fails.

**Implementation:**
- `prepareWeb3KeyCreation()` generates random salt
- Salt stored in database `key_salt` column (hex-encoded)
- Used as HKDF salt parameter

### 4. EIP-712 Typed Data Signing

Structured signing provides better UX and security than `personal_sign`:
- Human-readable signing requests
- Domain separation via chain ID
- Resistance to signature reuse

**Implementation:**
- `buildEncryptionKeyTypedData()` creates typed data structure
- Domain includes: name, version, chainId, verifyingContract

```typescript
const typedData = {
  types: ENCRYPTION_KEY_TYPES,
  primaryType: 'EncryptionKeyDerivation',
  domain: { name: 'PreDrive Encryption', version: '2', chainId, ... },
  message: { wallet, purpose, keyId, timestamp, nonce }
};
```

### 5. Determinism Verification

Before creating a v2 key, the system verifies the wallet produces deterministic signatures.

**Implementation:**
- `verifyWalletDeterminism()` signs twice and compares
- User-friendly warning if wallet is non-deterministic
- Blocks v2 key creation for incompatible wallets

### 6. Comprehensive Domain Separation

HKDF info parameter includes:
- Chain ID (prevents cross-chain signature reuse)
- Wallet address (user-specific)
- Key ID (unique per encryption key)

```
info = "predrive-encryption-v2:{chainId}:{walletAddress}:{keyId}"
```

---

## Architecture

### Key Derivation Flow (v2)

```
┌─────────────────────────────────────────────────────────────────┐
│                     User's Wallet                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                    EIP-712 signTypedData
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              Signature (65 bytes: r || s || v)                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                    normalizeSignature()
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              Normalized r||s (64 bytes, low-s)                   │
└─────────────────────────────────────────────────────────────────┘
                              │
            HKDF-SHA256 with random salt + domain info
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    KEK (AES-256 Key Wrap)                        │
│                    + verificationHash                            │
└─────────────────────────────────────────────────────────────────┘
```

### Database Schema

```sql
-- encryption_keys table (v2 additions)
ALTER TABLE encryption_keys ADD COLUMN chain_id integer;
ALTER TABLE encryption_keys ADD COLUMN key_salt text;      -- hex-encoded 32 bytes
ALTER TABLE encryption_keys ADD COLUMN key_version varchar(10);  -- 'v1' or 'v2'
CREATE INDEX encryption_keys_chain_idx ON encryption_keys (chain_id);
```

### Key Types

| Version | Signing Method | Input | Salt | Domain |
|---------|---------------|-------|------|--------|
| v1 (legacy) | personal_sign | Full signature (65 bytes) | Fixed constant | walletAddress only |
| v2 (enhanced) | EIP-712 signTypedData | r\|\|s (64 bytes, normalized) | Random 32 bytes | chainId + walletAddress + keyId |

---

## API Changes

### Create Key Endpoint

```typescript
POST /api/encryption/keys
{
  keyType: 'web3',
  keyName: 'My Wallet (Ethereum)',
  walletAddress: '0x...',
  verificationHash: '...',
  // v2 specific fields
  chainId: 1,
  keySalt: '...',  // 64 hex chars
  keyVersion: 'v2'
}
```

### Response

```typescript
{
  id: 'uuid',
  keyType: 'web3',
  keyName: 'My Wallet (Ethereum)',
  isDefault: true,
  createdAt: '2026-01-20T...',
  keyVersion: 'v2',
  chainId: 1
}
```

---

## UI Components

### EncryptionKeyManager

Updated to support v2 key creation:

1. **Version Selector**: Users choose between Enhanced (v2) or Legacy (v1)
2. **Determinism Check Step**: Verifies wallet compatibility before v2 creation
3. **Chain Display**: Shows connected network (Ethereum, Polygon, etc.)
4. **Key Cards**: Display version badge and chain info

### User Flow (v2)

```
1. Click "Create Web3 Key"
2. Select "Enhanced (v2)" [recommended]
3. Connect wallet
4. System verifies determinism (signs test message twice)
5. If compatible: Sign EIP-712 typed data
6. Key created with random salt + chain binding
```

---

## File Changes

### Core Crypto (`apps/web/src/lib/crypto/`)

| File | Changes |
|------|---------|
| `keys.ts` | +388 lines: normalizeSignature, verifyWalletDeterminism, deriveKeyFromWeb3SignatureV2, prepareWeb3KeyCreation |
| `types.ts` | +178 lines: EIP712 types, NormalizedSignature, Web3DerivedKey, secp256k1 constants |
| `index.ts` | +28 lines: Export new functions and types |

### API (`apps/api/src/routes/`)

| File | Changes |
|------|---------|
| `encryption.ts` | +106 lines: v2 validation schema, chain name helper, updated endpoints |

### Database (`packages/db/src/`)

| File | Changes |
|------|---------|
| `schema.ts` | +16 lines: chainId, keySalt, keyVersion columns + index |

### UI (`apps/web/src/components/`)

| File | Changes |
|------|---------|
| `EncryptionKeyManager.tsx` | +334 lines: Version selector, determinism check, chain display |

### API Client (`apps/web/src/api/`)

| File | Changes |
|------|---------|
| `client.ts` | +12 lines: v2 fields in interfaces |

---

## Backward Compatibility

- Existing v1 keys continue to work unchanged
- v1 keys automatically marked with `keyVersion = 'v1'`
- Users can create both v1 and v2 keys
- File encryption/decryption works with either key type

---

## Security Considerations

### Addressed Risks

| Risk | Mitigation |
|------|------------|
| Signature malleability | Low-s normalization (EIP-2) |
| v value inconsistency | Use only r\|\|s for derivation |
| Wallet non-determinism | Determinism verification step |
| Cross-chain replay | Chain ID in domain separation |
| Single point of failure | Random per-KEK salt |

### Remaining Considerations

- **Lost wallet = lost data**: No recovery mechanism (by design for zero-knowledge)
- **Smart contract wallets**: ERC-1271 wallets not supported (no ECDSA signatures)
- **Hardware wallet UX**: EIP-712 signing may require firmware updates

---

## Testing

### Manual Testing Checklist

- [ ] Create v2 key with MetaMask
- [ ] Create v2 key with different chain (Polygon, Arbitrum)
- [ ] Verify determinism check blocks non-deterministic wallets
- [ ] Encrypt file with v2 key
- [ ] Decrypt file with v2 key (re-derive from signature)
- [ ] Verify v1 keys still work
- [ ] Verify UI shows correct version badges

---

## Future Enhancements

1. **Lit Protocol Integration**: Consider as alternative for cross-wallet compatibility
2. **Dual-factor Model**: Wallet + password for additional security
3. **Key Rotation**: Re-wrap DEKs with new KEK
4. **Session Caching**: Cache derived KEK in memory with expiry

---

## References

- [EIP-712: Typed structured data hashing and signing](https://eips.ethereum.org/EIPS/eip-712)
- [EIP-2: Homestead hard-fork changes](https://eips.ethereum.org/EIPS/eip-2)
- [RFC 5869: HKDF](https://tools.ietf.org/html/rfc5869)
- [RFC 3394: AES Key Wrap](https://tools.ietf.org/html/rfc3394)

---

*Last updated: January 20, 2026*
