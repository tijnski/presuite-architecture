# Web3 SMTP Fix Plan

## Problem Summary

Web3 user accounts created before permissions were properly configured are missing the `enabledPermissions` field in Stalwart. This causes:

1. **SMTP 550 error**: "Your account is not authorized to use this service" when trying to send email
2. **IMAP connection errors**: "Connection not available" when fetching messages

## Root Cause

When provisioning Web3 accounts in Stalwart, the `enabledPermissions` array was not being set, resulting in accounts with no permissions to authenticate or send/receive email.

## Affected Users

All Web3 accounts that were created via the bulk fix script or the `provisionWeb3Email` function before permissions were added.

## Fix Steps

### Step 1: Identify Affected Accounts

```bash
# On PreMail server (76.13.1.117)
# List all principals and find those without enabledPermissions
ssh root@76.13.1.117 'curl -s -u admin:adminpass123 "http://localhost:8080/api/principal?limit=100" | jq ".data.items[] | select(.name | startswith(\"0x\")) | select(.enabledPermissions == null or (.enabledPermissions | length < 10)) | .name"'
```

### Step 2: Fix Each Affected Account

For each account missing permissions, run:

```bash
curl -s -X PATCH "http://localhost:8080/api/principal/<USERNAME>" \
  -u admin:adminpass123 \
  -H "Content-Type: application/json" \
  -d '[{"action": "set", "field": "enabledPermissions", "value": ["authenticate", "email-send", "email-receive", "imap-authenticate", "imap-list", "imap-fetch", "imap-search", "imap-status", "imap-select", "imap-examine", "imap-idle", "imap-store", "imap-copy", "imap-move", "imap-delete", "imap-create", "imap-rename", "imap-expunge", "imap-append", "imap-subscribe", "imap-lsub", "imap-enable", "imap-sort", "imap-thread", "imap-namespace", "imap-id"]}]'
```

### Step 3: Sync Passwords Between Stalwart and PreMail

For any accounts where password sync failed:

1. Generate a new password
2. Update Stalwart principal with new password using PATCH API
3. Update PreMail via internal API with encrypted password

### Step 4: Update Provisioning Code

Ensure the `provisionWeb3Email` function in `presuite/server.js` includes `enabledPermissions` when creating Stalwart accounts.

### Step 5: Test

1. Test SMTP send from affected accounts
2. Test IMAP fetch from affected accounts
3. Verify in PreMail UI that email compose and inbox work

## Prevention

Update the Stalwart account creation in `presuite/server.js` to always include the full permission set when creating new accounts.

## Code Changes Required

1. `presuite/server.js` - Add enabledPermissions to Stalwart API call
2. `fix_web3_permissions.sh` - Bulk fix script for existing accounts
