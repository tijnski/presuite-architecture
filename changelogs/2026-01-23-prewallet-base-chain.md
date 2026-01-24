# Session Changelog - January 23, 2026

**Date:** January 23, 2026
**Services:** PreSuite Hub, PreSocial, PreMail (Stalwart)
**Status:** Completed

---

## Summary

- Added Base chain support to PreWallet for fetching PRE token balances
- Fixed email verification system (SMTP configuration for Stalwart)
- Auto-verify @premail.site email addresses on registration
- Renamed PreSocial "Feed" to "Home"

---

## Changes Made

### 1. Base Chain Support for PRE Token Balance

**Files Modified:**
- `presuite/src/services/preBalanceService.js`
- `presuite/src/components/AppModal.jsx`

**Changes:**
- Added PRE token contract address for Base chain: `0x57a777C82a9D5E827e781d583D34bfBa2b5D5B33`
- Created `fetchBaseBalance()` function to fetch PRE balance from Basescan API
- Updated `fetchWalletBalance()` to fetch from both Ethereum and Base in parallel
- Combined balances from both chains into total balance
- Added `ethereumBalance` and `baseBalance` fields to track per-chain balances

**UI Updates:**
- Updated wallet address label from "Ethereum Wallet Address" to "Wallet Address"
- Updated helper text to mention "Ethereum & Base"
- Added chain breakdown display showing Ethereum and Base balances separately with chain icons

### 2. Connection Status Fix

**Issue:** Wallet was not showing as "linked" when API calls to Etherscan/Basescan failed (rate limiting)

**Fix:**
- Modified `getPreBalance()` to set `isLinked = true` immediately when settings exist, regardless of API response
- This ensures the UI shows connected state even if balance APIs are temporarily unavailable

### 3. Debugging & Error Handling Improvements

**Added console logging throughout the flow:**
- `getPresearchSettings()` - logs retrieved settings
- `savePresearchSettings()` - logs save attempts and results
- `getPreBalance()` - logs user/settings state and linked status
- `handleLinkAccount()` - logs validation and save steps

**Other improvements:**
- Added `trim()` to wallet address input to prevent whitespace issues
- Improved error handling with try/catch blocks
- Direct balance state update after linking instead of through refreshData()

---

## Technical Details

### PRE Token Contract Addresses
| Chain | Contract Address |
|-------|------------------|
| Ethereum | `0xEC213F83defB583af3A000B1c0ada660b1902A0F` |
| Base | `0x3816dD4bd44c8830c2FA020A5605bAC72FA3De7A` |

### API Endpoints Used
- Etherscan: `https://api.etherscan.io/api?module=account&action=tokenbalance`
- Basescan: `https://api.basescan.org/api?module=account&action=tokenbalance`

### Data Flow
```
User enters wallet → validateWalletAddress() → savePresearchSettings()
                                                      ↓
                                              localStorage.setItem()
                                                      ↓
                                              refreshBalance()
                                                      ↓
                                    fetchEthereumBalance() + fetchBaseBalance()
                                                      ↓
                                              setBalance() state update
```

---

## Email Verification Fix

**Issue:** Verification emails from `noreply@premail.site` were not being delivered.

**Root Cause:**
1. The `noreply@premail.site` account in Stalwart was missing `email-send` permission
2. PreSuite was configured with wrong SMTP credentials (`admin/adminpass123` instead of the noreply account credentials)

**Fixes Applied:**
1. Added `email-send`, `email-receive`, and `authenticate` permissions to `noreply@premail.site` in Stalwart:
   ```bash
   curl -X PATCH -u admin:adminpass123 'http://localhost:8080/api/principal/noreply' \
     -H 'Content-Type: application/json' \
     -d '[{"action":"set","field":"enabledPermissions","value":["email-send","email-receive","authenticate"]}]'
   ```

2. Updated PreSuite `.env` on server (76.13.2.221):
   ```
   SMTP_USER=noreply@premail.site
   SMTP_PASS=noreplypass123
   ```

3. Restarted PreSuite with `pm2 restart presuite --update-env`

**Additional SMTP Configuration Fixes:**
- Changed SMTP port from 465 to 587 (STARTTLS)
- Changed SMTP_USER from `noreply@premail.site` to `noreply` (Stalwart expects username without domain)
- Added noreply user secret to Stalwart config.toml
- Added PreSuite server IP (76.13.2.221) to Stalwart fail2ban allowed-addresses

**Final working configuration:**
```
SMTP_HOST=mail.premail.site
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=noreply
SMTP_PASS=PreSuite2026
VERIFICATION_EMAIL_FROM=noreply@premail.site
```

### Auto-verify @premail.site Addresses

**Commit:** `4b125f3`

**Change:** Users registering with @premail.site or @web3.premail.site email addresses are now automatically verified on registration (no verification email popup).

**Logic:**
- Check if email ends with `@premail.site` or `@web3.premail.site`
- If yes: set `email_verified=true` in database, skip verification email
- If no: continue normal verification flow

---

## Other Changes This Session

### PreSocial: Rename "Feed" to "Home"

**File Modified:** `presocial/apps/web/src/components/Header.jsx`

**Change:** Renamed the "Feed" navigation button to "Home" in both desktop and mobile navigation.

**Commit:** `6e93d75` - Rename Feed button to Home in navigation

---

## Commits

### PreSuite
1. `b6af0f6` - Add Base chain support to PreWallet
2. `7caded1` - Fix PreWallet isLinked status when API calls fail
3. `2363db2` - Add debugging to PreWallet connection flow
4. `4b125f3` - Auto-verify @premail.site email addresses on registration

### PreSocial
1. `6e93d75` - Rename Feed button to Home in navigation

---

## Server Configuration Changes

### Stalwart Mail Server (76.13.1.117)

1. Created `noreply` account with password `PreSuite2026`
2. Added to `/opt/stalwart/etc/config.toml`:
   ```toml
   directory.internal.users.noreply.email = "noreply@premail.site"
   directory.internal.users.noreply.name = "noreply"
   directory.internal.users.noreply.secret = "PreSuite2026"
   ```
3. Updated fail2ban allowed addresses to include PreSuite server:
   ```toml
   server.fail2ban.permanent.authentication.allowed-addresses = ["172.19.0.0/16", "76.13.2.221", "76.13.0.0/16"]
   ```

### PreSuite Hub (76.13.2.221)

Updated `/var/www/presuite/.env`:
```
SMTP_HOST=mail.premail.site
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=noreply
SMTP_PASS=PreSuite2026
VERIFICATION_EMAIL_FROM=noreply@premail.site
```

---

## Known Issues / TODO

- [x] ~~Verify correct PRE token contract address on Base~~ - Fixed (Jan 24): Updated to `0x3816dD4bd44c8830c2FA020A5605bAC72FA3De7A`
- [x] ~~Add API keys for Etherscan/Basescan~~ - Fixed (Jan 24): Added backend proxy with server-side API keys
- [x] ~~Email verification not working~~ - Fixed
- [x] ~~@premail.site users seeing verification popup~~ - Fixed (auto-verified)

---

## API Keys Update (January 24, 2026)

### Changes Made
1. Added backend proxy endpoint `/api/presearch/balance/:walletAddress`
2. API keys stored securely server-side (not exposed to frontend)
3. Frontend now uses backend proxy instead of direct Etherscan/Basescan calls

### Files Modified
- `config/constants.js` - Added ETHERSCAN_API_KEY, BASESCAN_API_KEY, PRE contract addresses
- `server.js` - Added balance proxy endpoint with `fetchTokenBalance()` helper
- `src/services/preBalanceService.js` - Updated to use backend proxy

### Environment Variables Required
Add to `/var/www/presuite/.env` on production server:
```
ETHERSCAN_API_KEY=your_etherscan_api_key
BASESCAN_API_KEY=your_basescan_api_key
```

Get free API keys from:
- Etherscan: https://etherscan.io/apis
- Basescan: https://basescan.org/apis

---

## Testing

### Email Verification
- Register with external email → Should receive verification email from noreply@premail.site
- Register with @premail.site email → Should be auto-verified, no popup

### PreWallet
To debug wallet connection issues:
1. Open browser Developer Tools (F12)
2. Go to Console tab
3. Try connecting wallet
4. Look for `[PreWallet` log messages showing the flow
