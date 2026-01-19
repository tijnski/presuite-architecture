# PreDrive Encryption Quick Start Guide

> **Your files, your keys, your privacy.**

---

## What is BYOK Encryption?

PreDrive uses **Bring Your Own Key (BYOK)** encryption:

- **You control the keys** - We never see your encryption key
- **Client-side encryption** - Files are encrypted in your browser before upload
- **Zero-knowledge** - Even we can't decrypt your files

**Important:** If you lose your passphrase or wallet access, encrypted files **cannot be recovered**. There is no "forgot password" for encryption.

---

## Two Ways to Create Encryption Keys

### Option 1: Passphrase Key

Best for: Users who prefer traditional password-based security

| Pros | Cons |
|------|------|
| Works on any device | Must remember passphrase |
| No wallet needed | Vulnerable to weak passphrases |

**How it works:**
1. You enter a strong passphrase
2. Browser derives encryption key using PBKDF2 (310,000 iterations)
3. Key never leaves your browser

### Option 2: Web3 Wallet Key

Best for: Users who already use MetaMask or similar wallets

| Pros | Cons |
|------|------|
| No passphrase to remember | Requires MetaMask or compatible wallet |
| Tied to your wallet security | Must have wallet on device to decrypt |
| Deterministic - same wallet always produces same key | |

**How it works:**
1. You sign a message with your wallet (no transaction, no gas fees)
2. Browser derives encryption key using HKDF
3. Key never leaves your browser

---

## Quick Start

### Step 1: Create an Encryption Key

1. Open PreDrive at https://predrive.eu
2. Click the **Key icon** in the header (or go to Settings)
3. Click **"Create New Key"**
4. Choose **Passphrase** or **Web3 Wallet**

**For Passphrase:**
```
1. Enter a strong passphrase (12+ characters recommended)
2. Use mixed case, numbers, and symbols
3. Re-enter to confirm
4. Click "Create Key"
```

**For Web3 Wallet:**
```
1. Click "Connect Wallet"
2. Approve connection in MetaMask
3. Click "Sign & Create Key"
4. Sign the message in your wallet (no transaction cost)
```

### Step 2: Upload Encrypted Files

1. Click the **Upload** button
2. Select your file
3. Ensure **"Encrypt file"** checkbox is ON (enabled by default when you have a key)
4. **For passphrase key:** Enter your passphrase
5. **For Web3 key:** Sign when prompted by your wallet
6. Click **"Upload Encrypted"** or **"Sign & Upload"**

### Step 3: Download Encrypted Files

1. Click the download icon on an encrypted file (marked with a lock icon)
2. The **Decrypt Modal** will appear automatically
3. **For passphrase key:** Enter your passphrase
4. **For Web3 key:** Click "Sign & Decrypt" and sign in your wallet
5. File will decrypt and download to your computer

---

## File Encryption Indicators

| Icon | Meaning |
|------|---------|
| 🔒 Lock icon | File is encrypted |
| No lock icon | File is NOT encrypted |

Encrypted files show a lock icon in the file list. Only encrypted files will prompt for decryption when downloading.

---

## FAQ

### Q: Can I encrypt existing files?
**A:** Not yet. Currently encryption only works during upload. To encrypt existing files, download them and re-upload with encryption enabled.

### Q: What if I forget my passphrase?
**A:** Your files **cannot be recovered**. There is no reset or recovery option. We recommend testing decryption with a non-critical file first.

### Q: What if I lose access to my wallet?
**A:** If you recover your wallet using your seed phrase, you can still decrypt files. The encryption key is derived deterministically from your wallet signature.

### Q: Is my passphrase sent to the server?
**A:** No. Your passphrase **never leaves your browser**. We only store metadata needed to re-derive the key (salt, iteration count).

### Q: Can I have multiple encryption keys?
**A:** Yes. You can create multiple keys and set one as default. Files are encrypted with the key that was active during upload.

### Q: Can I share encrypted files?
**A:** Not directly. The recipient would need your passphrase or wallet access to decrypt. For sharing, either:
- Upload the file without encryption
- Share the passphrase through a secure channel (not recommended for sensitive data)

### Q: What encryption algorithm is used?
**A:** AES-256-GCM via the Web Crypto API. Each file gets a unique random Data Encryption Key (DEK) which is wrapped with your master Key Encryption Key (KEK).

### Q: Why doesn't the decrypt modal appear?
**A:** The decrypt modal only appears for files that were uploaded with encryption. If you uploaded a file without enabling encryption, it won't prompt for decryption.

---

## Security Best Practices

1. **Use strong passphrases** - 12+ characters with mixed case, numbers, and symbols
2. **Don't reuse passphrases** - Use a unique passphrase for PreDrive
3. **Back up your wallet seed phrase** - For Web3 keys, your seed phrase IS your backup
4. **Test decryption first** - Upload a test file and verify you can decrypt it before uploading sensitive data
5. **Keep browser updated** - Encryption relies on the Web Crypto API

---

## Technical Specifications

| Parameter | Value |
|-----------|-------|
| KEK Algorithm | AES-256 (Key Wrap) |
| DEK Algorithm | AES-256-GCM |
| Passphrase KDF | PBKDF2-SHA256 |
| Web3 KDF | HKDF-SHA256 |
| PBKDF2 Iterations | 310,000 (OWASP recommended) |
| Salt Size | 32 bytes |
| Nonce Size | 12 bytes |
| Checksum | SHA-256 |

---

## Troubleshooting

### "No encryption keys" warning
Create an encryption key first by clicking the Key icon in the header.

### Decrypt modal doesn't appear
The file was uploaded without encryption. Re-upload the file with encryption enabled.

### "Invalid passphrase" error
You entered the wrong passphrase. The passphrase must match exactly what you used when creating the key.

### "Please connect wallet..." error
Connect the same wallet address that was used to create the encryption key.

---

## More Information

- **Technical Architecture:** [architecture/PREDRIVE-ENCRYPTION.md](architecture/PREDRIVE-ENCRYPTION.md)
- **Report Issues:** [GitHub Issues](https://github.com/tijnski/predrive/issues)
- **Support:** presuite.eu
