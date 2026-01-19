# PreDrive Encryption Quick Start Guide

> **Your files, your keys, your privacy.**

---

## What is BYOK Encryption?

PreDrive uses **Bring Your Own Key (BYOK)** encryption. This means:

- **You control the keys** - We never see your encryption key
- **Client-side encryption** - Files are encrypted in your browser before upload
- **Zero-knowledge** - Even we can't decrypt your files

**Important:** If you lose your passphrase or wallet access, encrypted files **cannot be recovered**. There is no "forgot password" for encryption.

---

## Two Ways to Create Encryption Keys

### Option 1: Passphrase Key

Best for: Users who prefer traditional password-based security

**How it works:**
1. You enter a strong passphrase
2. Browser derives encryption key from passphrase (PBKDF2)
3. Key never leaves your browser

**Pros:**
- Works on any device
- No wallet needed

**Cons:**
- Must remember passphrase
- Can be vulnerable to weak passphrases

### Option 2: Web3 Wallet Key

Best for: Users who already use MetaMask or similar wallets

**How it works:**
1. You sign a message with your wallet (no transaction)
2. Browser derives encryption key from signature (HKDF)
3. Key never leaves your browser

**Pros:**
- No passphrase to remember
- Tied to your wallet security
- Deterministic - same wallet always produces same key

**Cons:**
- Requires MetaMask or compatible wallet
- Must have wallet on device to decrypt

---

## Quick Start

### Step 1: Create an Encryption Key

1. Open PreDrive (https://predrive.eu)
2. Click the **Key icon** in the header
3. Click **"Create New Key"**
4. Choose **Passphrase** or **Web3 Wallet**

**For Passphrase:**
- Enter a strong passphrase (12+ characters)
- Use mixed case, numbers, and symbols
- Click **"Create Key"**

**For Web3:**
- Click **"Connect Wallet"**
- Approve connection in MetaMask
- Click **"Sign & Create Key"**
- Sign the message (no transaction cost)

### Step 2: Upload Encrypted Files

1. Click **Upload** button
2. Select your file
3. Toggle **"Encrypt file"** checkbox ON
4. Enter passphrase or sign with wallet
5. Click **"Upload Encrypted"**

### Step 3: Download Encrypted Files

1. Click download on an encrypted file
2. A decrypt modal will appear
3. Enter your passphrase or sign with wallet
4. File will decrypt and download

---

## File Encryption Indicators

| Indicator | Meaning |
|-----------|---------|
| 🔒 Lock icon | File is encrypted |
| 🔓 No lock | File is NOT encrypted |

---

## FAQ

### Q: Can I encrypt existing files?
**A:** Not yet. Currently encryption only works during upload. Re-upload files to encrypt them.

### Q: What if I forget my passphrase?
**A:** Your files cannot be recovered. There is no reset or recovery option for encryption keys.

### Q: What if I lose access to my wallet?
**A:** If you recover your wallet with your seed phrase, you can still decrypt files. The key is derived from your signature, which is deterministic.

### Q: Is my passphrase sent to the server?
**A:** No. Your passphrase never leaves your browser. We only store metadata needed to re-derive the same key (salt, iteration count).

### Q: Can I have multiple encryption keys?
**A:** Yes. You can create multiple keys and set a default. Files are encrypted with whichever key was active during upload.

### Q: Can I share encrypted files?
**A:** Not directly. The recipient would need your passphrase or wallet access to decrypt. For sharing, upload unencrypted or share credentials separately (not recommended).

### Q: What encryption algorithm is used?
**A:** AES-256-GCM via Web Crypto API. Each file gets a unique random key (DEK) which is wrapped with your master key (KEK).

---

## Security Best Practices

1. **Use strong passphrases** - 12+ characters, mixed case, numbers, symbols
2. **Don't reuse passphrases** - Use unique passphrase for PreDrive
3. **Back up your wallet seed phrase** - For Web3 keys, your seed phrase IS your backup
4. **Test decryption** - Upload a test file and verify you can decrypt it
5. **Keep browser updated** - Encryption uses Web Crypto API

---

## Technical Details

For full technical architecture, see:
- [architecture/PREDRIVE-ENCRYPTION.md](architecture/PREDRIVE-ENCRYPTION.md)

### Key Specifications

| Parameter | Value |
|-----------|-------|
| KEK Algorithm | AES-256 |
| DEK Algorithm | AES-256-GCM |
| Passphrase KDF | PBKDF2-SHA256 |
| Web3 KDF | HKDF-SHA256 |
| PBKDF2 Iterations | 310,000 |
| Salt Size | 32 bytes |
| Nonce Size | 12 bytes |

---

## Need Help?

- **Issues:** Report bugs at [GitHub Issues](https://github.com/tijnski/predrive/issues)
- **Questions:** Contact support at presuite.eu
