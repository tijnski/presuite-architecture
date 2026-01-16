# Storj Configuration Guide

> **Purpose:** Setup and configuration for Storj S3-compatible storage in PreSuite
> **Last Updated:** January 16, 2026

---

## Overview

PreSuite uses [Storj](https://www.storj.io/) for decentralized, encrypted cloud storage. Storj provides S3-compatible APIs, allowing seamless integration with existing S3 tooling.

**Gateway:** `https://gateway.eu1.storjshare.io` (EU region)

---

## Current Configuration

### Bucket Structure

```
Storj Account
└── predrive (bucket)
    ├── {userId-1}/
    │   ├── file1.pdf
    │   ├── file2.docx
    │   └── folder1/
    │       └── file3.txt
    ├── {userId-2}/
    │   └── ...
    └── {userId-n}/
        └── ...
```

**Pattern:** Each user gets a folder named with their `userId` (UUID). All PreDrive files are stored within that folder.

### Environment Variables

```bash
# Storj S3-Compatible Gateway
S3_ENDPOINT=https://gateway.eu1.storjshare.io
S3_ACCESS_KEY_ID=<your-access-key>
S3_SECRET_ACCESS_KEY=<your-secret-key>
S3_BUCKET=predrive
S3_REGION=eu1
```

---

## Storj Account Setup

### 1. Create Storj Account

1. Go to [storj.io](https://www.storj.io/)
2. Sign up for an account
3. Select region (EU1 for Europe)

### 2. Create Project

1. In Storj dashboard, create a new project
2. Name it `presuite` or similar

### 3. Create Bucket

```bash
# Using Storj CLI or Dashboard
# Create bucket named "predrive"
```

Or via Dashboard:
1. Go to Buckets → Create Bucket
2. Name: `predrive`
3. Enable versioning (optional but recommended)

### 4. Generate S3 Credentials

1. Go to Access → Create S3 Credentials
2. Name: `predrive-production`
3. Permissions: Read, Write, List, Delete
4. Bucket: `predrive` (or all buckets)
5. Save the Access Key and Secret Key

### 5. Configure CORS (if needed for direct uploads)

```json
{
  "CORSRules": [
    {
      "AllowedOrigins": [
        "https://predrive.eu",
        "https://presuite.eu"
      ],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"],
      "MaxAgeSeconds": 3600
    }
  ]
}
```

---

## Storage Key Format

Files are stored with the following key pattern:

```
{userId}/{nodeId}/{version}
```

Example:
```
a1b2c3d4-e5f6-7890-abcd-ef1234567890/  # userId
  f9e8d7c6-b5a4-3210-fedc-ba0987654321/  # nodeId (file)
    1  # version 1
    2  # version 2 (if versioned)
```

---

## TODO: PreMail Bucket

### Planned Structure

```
Storj Account
├── predrive (bucket) - EXISTING
│   └── {userId}/
│       └── [PreDrive files]
│
└── premail (bucket) - TO BE CREATED
    ├── {userId-1}/
    │   ├── attachments/
    │   │   ├── {messageId-1}/
    │   │   │   ├── attachment1.pdf
    │   │   │   └── attachment2.jpg
    │   │   └── {messageId-2}/
    │   │       └── ...
    │   └── exports/
    │       └── [email exports, backups]
    ├── {userId-2}/
    │   └── ...
    └── {userId-n}/
        └── ...
```

### Implementation Steps

- [ ] Create `premail` bucket in Storj dashboard
- [ ] Generate S3 credentials for PreMail service
- [ ] Add environment variables to PreMail:
  ```bash
  PREMAIL_S3_ENDPOINT=https://gateway.eu1.storjshare.io
  PREMAIL_S3_ACCESS_KEY_ID=<premail-access-key>
  PREMAIL_S3_SECRET_ACCESS_KEY=<premail-secret-key>
  PREMAIL_S3_BUCKET=premail
  ```
- [ ] Implement storage service in PreMail API
- [ ] Create user folder on first attachment upload
- [ ] Store attachments at `{userId}/attachments/{messageId}/{filename}`
- [ ] Update PreMail documentation

### Use Cases for PreMail Storage

| Use Case | Storage Path |
|----------|--------------|
| Email attachments | `{userId}/attachments/{messageId}/{filename}` |
| Large attachments (>25MB) | `{userId}/large/{messageId}/{filename}` |
| Email exports/backups | `{userId}/exports/{date}-export.mbox` |
| Signature images | `{userId}/signatures/{signatureId}.png` |

---

## Presigned URLs

PreDrive uses presigned URLs for direct browser uploads/downloads:

```typescript
// Generate upload URL (5 min expiry)
const uploadUrl = await s3.getSignedUrl('putObject', {
  Bucket: 'predrive',
  Key: `${userId}/${nodeId}/${version}`,
  Expires: 300,
  ContentType: mimeType,
});

// Generate download URL (1 hour expiry)
const downloadUrl = await s3.getSignedUrl('getObject', {
  Bucket: 'predrive',
  Key: `${userId}/${nodeId}/${version}`,
  Expires: 3600,
});
```

---

## Security Considerations

1. **Encryption:** Storj encrypts all data client-side before upload
2. **Access Control:** Each service has separate S3 credentials
3. **User Isolation:** Users can only access their own `{userId}/` folder
4. **No Public Access:** Buckets are private, access via presigned URLs only
5. **Credential Rotation:** Rotate S3 credentials periodically

---

## Troubleshooting

### Connection Issues

```bash
# Test Storj gateway connectivity
curl -I https://gateway.eu1.storjshare.io

# Test credentials (requires AWS CLI configured)
aws s3 ls s3://predrive --endpoint-url https://gateway.eu1.storjshare.io
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `AccessDenied` | Invalid credentials | Check S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY |
| `NoSuchBucket` | Bucket doesn't exist | Create bucket in Storj dashboard |
| `SignatureDoesNotMatch` | Clock skew | Sync server time with NTP |
| `SlowDown` | Rate limiting | Implement exponential backoff |

---

## Related Documentation

- [PREDRIVE.md](../PREDRIVE.md) - PreDrive service documentation
- [PREMAIL.md](../PREMAIL.md) - PreMail service documentation
- [architecture/PREDRIVE.md](../architecture/PREDRIVE.md) - Storage architecture diagrams
- [Storj Documentation](https://docs.storj.io/) - Official Storj docs
