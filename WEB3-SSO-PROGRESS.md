# Web3 SSO Implementation Progress

> **Last Updated:** January 17, 2026
> **Status:** Fully Functional

---

## Overview

Web3 SSO allows users to authenticate across all PreSuite services using their Ethereum wallet (MetaMask or compatible). Users sign a message with their wallet, and the system provisions them with:
- A PreSuite account
- An email address (`{wallet}@web3.premail.site`)
- Access to PreDrive cloud storage

---

## Test Results (January 17, 2026)

### Full Flow Test

```
=== Web3 SSO Test ===
Wallet: 0x5105d95caF647dcEf1245a3C6288363fFB7B9045

1. Nonce obtained: a30174f1...
2. Message signed
3. Verification successful
   - User ID: 7c131964-c0b1-4952-b1be-88e23d38a3bf
   - Email: 0x5105d95caf647dcef1245a3c6288363ffb7b9045@web3.premail.site
   - is_web3: true

4. Mail credentials provisioned:
   - Email: 0x5105d95caf647dcef1245a3c6288363ffb7b9045@web3.premail.site
   - Password: ucg1yZi7gGPKIvn3QIGM1neYkgVgXhgP
```

### Service Integration Tests

| Service | Endpoint | Status | Response |
|---------|----------|--------|----------|
| PreSuite Hub | `/api/auth/web3/nonce` | ✅ Pass | Returns nonce + message |
| PreSuite Hub | `/api/auth/web3/verify` | ✅ Pass | Returns JWT + credentials |
| PreMail | `/api/v1/accounts` | ✅ Pass | Auto-provisioned account with `status: connected` |
| PreMail | `/api/v1/labels` | ✅ Pass | Empty list (new user) |
| PreMail | `/api/v1/predrive/files` | ✅ Pass | Proxies to PreDrive successfully |
| PreDrive | `/api/nodes` | ✅ Pass | Auto-provisioned user + root folder |
| Stalwart | Mailbox creation | ✅ Pass | Mailbox ID 46 created |

### Database Verification

**PreSuite Hub (presuite-postgres):**
```sql
SELECT email, wallet_address, is_web3 FROM users WHERE wallet_address LIKE '0x5105%';
-- Returns: 0x5105...@web3.premail.site | 0x5105d95caF647dcEf1245a3C6288363fFB7B9045 | true
```

**PreMail (premail-postgres):**
```sql
SELECT email, status FROM email_accounts WHERE email LIKE '0x5105%';
-- Returns: 0x5105...@web3.premail.site | connected
```

**PreDrive (deploy-postgres-1):**
```sql
SELECT email, wallet_address, is_web3 FROM users WHERE wallet_address LIKE '0x5105%';
-- Returns: 0x5105...@web3.premail.site | 0x5105d95caF647dcEf1245a3C6288363fFB7B9045 | true
```

---

## Architecture

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         WEB3 SSO FLOW                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1. USER CONNECTS WALLET                                                 │
│     └─> MetaMask popup → User approves connection                        │
│                                                                          │
│  2. GET SIGNING CHALLENGE                                                │
│     └─> GET /api/auth/web3/nonce?address=0x...                          │
│     └─> Returns: nonce + message (expires 5 min)                        │
│                                                                          │
│  3. USER SIGNS MESSAGE                                                   │
│     └─> MetaMask popup → User signs challenge                            │
│                                                                          │
│  4. VERIFY & AUTHENTICATE                                                │
│     └─> POST /api/auth/web3/verify {address, signature, message}        │
│     └─> Backend: ethers.verifyMessage() + nonce validation              │
│                                                                          │
│  5. ACCOUNT PROVISIONING (new users)                                     │
│     ├─> Create user in PreSuite Hub (wallet_address, is_web3=true)     │
│     ├─> Create org                                                       │
│     ├─> Provision email: {wallet}@web3.premail.site                     │
│     └─> Create Stalwart mailbox with random password                    │
│                                                                          │
│  6. RETURN TOKENS                                                        │
│     └─> JWT token + refreshToken + mailCredentials (one-time)           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### JWT Token Structure

```json
{
  "sub": "user-uuid",
  "org_id": "org-uuid",
  "email": "0x...@web3.premail.site",
  "name": "Wallet 0x...xxxx",
  "wallet_address": "0x...",
  "is_web3": true,
  "iss": "presuite",
  "iat": 1234567890,
  "exp": 1234567890
}
```

### Service Auto-Provisioning

| Service | What Gets Created | Trigger |
|---------|-------------------|---------|
| PreSuite Hub | User, Org, web3_mail_credentials | Web3 login |
| Stalwart | Mailbox with IMAP/SMTP access | Web3 login |
| PreMail | User, Org, email_account (status: connected) | First API call |
| PreDrive | User, Org, Root folder, Permissions | First API call |

---

## API Endpoints

### PreSuite Hub - Web3 Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/auth/web3/nonce?address={wallet}` | Get signing challenge |
| POST | `/api/auth/web3/verify` | Verify signature & authenticate |
| POST | `/api/auth/web3/link` | Link wallet to existing account |
| GET | `/api/auth/web3/wallets` | Get user's linked wallets |
| DELETE | `/api/auth/web3/wallets/:address` | Unlink a wallet |
| GET | `/api/auth/web3/mail` | Get Web3 mail account info |
| POST | `/api/auth/web3/mail/reset-password` | Regenerate mail password |

### Request/Response Examples

**Get Nonce:**
```bash
curl "https://presuite.eu/api/auth/web3/nonce?address=0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
```
```json
{
  "success": true,
  "message": "PreSuite Authentication\nNonce: f213e05b-...\nAddress: 0x...\nTimestamp: ...",
  "nonce": "f213e05b-7e64-4756-bfea-d8c636fc366b",
  "expiresAt": "2026-01-17T12:22:49.578Z"
}
```

**Verify Signature:**
```bash
curl -X POST "https://presuite.eu/api/auth/web3/verify" \
  -H "Content-Type: application/json" \
  -d '{"address":"0x...","signature":"0x...","message":"..."}'
```
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "0x...@web3.premail.site",
    "wallet_address": "0x...",
    "is_web3": true
  },
  "token": "eyJ...",
  "refreshToken": "...",
  "isNewUser": true,
  "mailCredentials": {
    "email": "0x...@web3.premail.site",
    "password": "one-time-password",
    "imapServer": "mail.premail.site",
    "smtpServer": "mail.premail.site"
  }
}
```

---

## DNS Configuration

### web3.premail.site Records

| Type | Name | Value | Status |
|------|------|-------|--------|
| MX | web3.premail.site | 10 mail.premail.site | ✅ Configured |
| TXT (SPF) | web3.premail.site | v=spf1 ip4:76.13.1.117 ~all | ✅ Configured |
| TXT (DMARC) | _dmarc.web3.premail.site | v=DMARC1; p=reject; rua=mailto:postmaster@web3.premail.site | ✅ Configured |

---

## Database Tables

### PreSuite Hub

**wallet_nonces** - Nonce tracking for replay protection
```sql
CREATE TABLE wallet_nonces (
  id UUID PRIMARY KEY,
  address VARCHAR(42) NOT NULL,
  nonce VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**user_wallets** - Multi-wallet support
```sql
CREATE TABLE user_wallets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  wallet_address VARCHAR(42) NOT NULL,
  is_primary BOOLEAN DEFAULT false,
  linked_at TIMESTAMPTZ DEFAULT NOW()
);
```

**web3_mail_credentials** - Encrypted mail passwords
```sql
CREATE TABLE web3_mail_credentials (
  id UUID PRIMARY KEY,
  user_id UUID UNIQUE REFERENCES users(id),
  email VARCHAR(255) NOT NULL,
  mail_password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Key Files

| Component | File | Purpose |
|-----------|------|---------|
| Frontend | `presuite/src/services/web3Auth.js` | Web3 auth flow |
| Backend | `presuite/server.js` (lines 1575-2087) | Web3 API endpoints |
| PreMail Auth | `premail/apps/api/src/middleware/auth.ts` | JWT validation + auto-provision |
| PreDrive Auth | `PreDrive/apps/api/src/middleware/auth.ts` | JWT validation + auto-provision |
| Shared Types | `PreDrive/packages/shared/src/types.ts` | JWTPayload, AuthContext interfaces |

---

## Fixes Applied (January 17, 2026)

| Issue | Fix | Location |
|-------|-----|----------|
| Stalwart admin password mismatch | Changed to `adminpass123` | `/var/www/presuite/.env` |
| web3.premail.site not in Stalwart | Added domain via API | Stalwart (domain id: 39) |
| PreMail not handling `@web3.premail.site` | Updated `isPreMailDomain()` helper | `premail/apps/api/src/middleware/auth.ts` |
| PreMail Web3 accounts had wrong status | Set `status: connected` for Web3 users | `premail/apps/api/src/middleware/auth.ts` |
| PreDrive missing Web3 columns | Added `wallet_address`, `is_web3` | `deploy-postgres-1` |
| PreDrive error message incorrect | Updated to generic message | `PreDriveFilePicker.tsx` |
| Stalwart password pre-hashing | Changed to plain text (Stalwart hashes internally) | `presuite/server.js` |

---

## Security Features

| Feature | Implementation |
|---------|----------------|
| Nonce-based replay protection | Single-use nonces with 5-minute expiry |
| Signature verification | `ethers.verifyMessage()` with recovered address validation |
| EIP-55 checksum | Address validation via `ethers.getAddress()` |
| Rate limiting | `web3Limiter` applied to all Web3 endpoints |
| Password encryption | bcrypt for Stalwart and stored credentials |
| JWT signing | HS256 with shared secret |

---

## Remaining Work

| Priority | Task | Status |
|----------|------|--------|
| P2 | Frontend wallet management UI | Pending |
| P2 | Mail password recovery UI | Pending |
| P3 | In-memory nonce storage → Redis | Pending |
| P3 | CSRF protection on Web3 endpoints | Pending |
| P3 | Session notification when wallet linked | Pending |

---

## Testing Commands

### Get Fresh Web3 Token
```bash
ssh root@76.13.2.221 'cd /var/www/presuite && node << "EOF"
const { ethers } = require("ethers");
async function getToken() {
  const wallet = ethers.Wallet.createRandom();
  const nonceResp = await fetch(`http://localhost:3001/api/auth/web3/nonce?address=${wallet.address}`);
  const { message } = await nonceResp.json();
  const signature = await wallet.signMessage(message);
  const verifyResp = await fetch("http://localhost:3001/api/auth/web3/verify", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ address: wallet.address, signature, message })
  });
  const data = await verifyResp.json();
  console.log(data.token);
}
getToken();
EOF'
```

### Test PreMail with Token
```bash
curl -H "Authorization: Bearer {TOKEN}" "https://premail.site/api/v1/accounts" | jq .
```

### Test PreDrive with Token
```bash
curl -H "Authorization: Bearer {TOKEN}" "https://predrive.eu/api/nodes" | jq .
```

### Check Stalwart Mailboxes
```bash
ssh root@76.13.1.117 "curl -s -u admin:adminpass123 'http://localhost:8080/api/principal?types=individual&limit=50'" | jq '.data.items | map(select(.emails[]? | contains("web3")))'
```

---

## Email Send/Receive Test (January 17, 2026)

### Test Account
```
Email: 0x8f361be9e3fbb1978fd489e972b113a0ed5413a4@web3.premail.site
Password: 6HnyS_xEGHku0UE_J2FOFTZBwNIG-AT8
```

### SMTP Send Test
```
✓ SMTP Authentication: Pass (use username only, not full email)
✓ TLS Connection: Pass (port 587)
✓ Send Email: Pass
```

**Important:** For SMTP authentication, use the username (wallet address) only, not the full email address:
- ✅ Correct: `0x8f361be9e3fbb1978fd489e972b113a0ed5413a4`
- ❌ Wrong: `0x8f361be9e3fbb1978fd489e972b113a0ed5413a4@web3.premail.site`

### IMAP Receive Test
```
✓ IMAP Authentication: Pass (username only)
✓ TLS Connection: Pass (port 993)
✓ Receive Email: Pass
✓ Self-test delivery: Pass (1 message in INBOX)
```

### Email Configuration for Web3 Users

| Setting | Value |
|---------|-------|
| SMTP Server | mail.premail.site |
| SMTP Port | 587 (STARTTLS) |
| IMAP Server | mail.premail.site |
| IMAP Port | 993 (SSL/TLS) |
| Username | Wallet address (lowercase, no @domain) |
| Password | One-time password from registration |

---

## Conclusion

Web3 SSO is fully functional across all PreSuite services. Users can:

1. ✅ Login with MetaMask wallet
2. ✅ Get automatic email address at `@web3.premail.site`
3. ✅ Access PreMail with auto-provisioned account
4. ✅ Access PreDrive with auto-provisioned storage
5. ✅ Send emails from their wallet address (SMTP)
6. ✅ Receive emails at their wallet address (IMAP)
7. ✅ Use single JWT token across all services

The implementation follows security best practices with nonce-based replay protection, signature verification, and rate limiting.
