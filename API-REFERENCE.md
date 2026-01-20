# PreSuite API Reference

Comprehensive API documentation for all PreSuite services.

> **Last Updated:** January 17, 2026

---

## Table of Contents

- [Authentication](#authentication)
- [PreSuite Hub API](#presuite-hub-api)
- [PreDrive API](#predrive-api)
- [PreMail API](#premail-api)
- [PreOffice API](#preoffice-api)
- [PreSocial API](#presocial-api)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [SDK Examples](#sdk-examples)

---

## Authentication

All PreSuite APIs use JWT Bearer tokens issued by the central PreSuite Hub auth service.

### Token Format

```typescript
interface PreSuiteToken {
  sub: string;       // User ID (UUID)
  org_id: string;    // Organization ID (UUID)
  email: string;     // Email address
  name?: string;     // Display name
  iss: 'presuite';   // Always "presuite"
  iat: number;       // Issued at (Unix timestamp)
  exp: number;       // Expires at (Unix timestamp)
}
```

### Token Usage

Include the token in the `Authorization` header for all authenticated requests:

```http
Authorization: Bearer <token>
```

### Security

- **Password Hashing:** bcrypt with cost factor 12
- **Token Expiration:** 7 days for access tokens
- **HTTPS Only:** All endpoints require HTTPS
- **CORS:** Restricted to PreSuite domains (`presuite.eu`, `predrive.eu`, `premail.site`, `preoffice.site`, `presocial.presuite.eu`)

---

## PreSuite Hub API

**Base URL:** `https://presuite.eu/api`

### Auth Endpoints

#### POST /auth/register

Create a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe",
  "source": "presuite"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Email or username (username becomes user@premail.site) |
| `password` | string | Yes | Minimum 12 characters |
| `name` | string | Yes | Display name |
| `source` | string | No | Originating service: `presuite`, `premail`, `predrive`, `preoffice` |

**Response (201):**
```json
{
  "success": true,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@premail.site",
    "name": "John Doe",
    "org_id": "550e8400-e29b-41d4-a716-446655440001"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Errors:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_EMAIL` | Email format is invalid |
| 400 | `WEAK_PASSWORD` | Password does not meet requirements |
| 409 | `EMAIL_EXISTS` | Email already registered |
| 500 | `PROVISIONING_FAILED` | Failed to create mailbox/storage |

**Side Effects:**
- Creates user in PreSuite Hub database
- Creates @premail.site mailbox in Stalwart
- Initializes PreDrive storage for user

---

#### POST /auth/login

Authenticate an existing user.

**Request:**
```json
{
  "email": "user@premail.site",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@premail.site",
    "name": "John Doe",
    "org_id": "550e8400-e29b-41d4-a716-446655440001"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Errors:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `MISSING_CREDENTIALS` | Email or password not provided |
| 401 | `INVALID_CREDENTIALS` | Email or password incorrect |
| 403 | `ACCOUNT_DISABLED` | Account has been disabled |

---

#### GET /auth/verify

Verify a JWT token is valid.

**Headers:**
```http
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "valid": true,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@premail.site",
    "name": "John Doe",
    "org_id": "550e8400-e29b-41d4-a716-446655440001"
  }
}
```

**Errors:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `TOKEN_MISSING` | No Authorization header |
| 401 | `TOKEN_INVALID` | Token signature invalid |
| 401 | `TOKEN_EXPIRED` | Token has expired |

---

#### GET /auth/me

Get current user information.

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@premail.site",
  "name": "John Doe",
  "org_id": "550e8400-e29b-41d4-a716-446655440001",
  "created_at": "2024-01-15T10:30:00Z",
  "email_verified": true
}
```

---

#### PATCH /auth/me

Update current user information.

**Request:**
```json
{
  "name": "John Smith"
}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@premail.site",
    "name": "John Smith",
    "org_id": "550e8400-e29b-41d4-a716-446655440001"
  }
}
```

---

#### POST /auth/logout

Invalidate the current session.

**Response (200):**
```json
{
  "success": true
}
```

---

#### POST /auth/reset-password

Request a password reset.

**Request:**
```json
{
  "email": "user@premail.site"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "If an account exists, a reset link has been sent"
}
```

> Always returns success to prevent email enumeration.

---

#### POST /auth/reset-password/confirm

Complete a password reset.

**Request:**
```json
{
  "token": "reset-token-from-email",
  "password": "newSecurePassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password has been reset"
}
```

---

#### POST /auth/me/password

Change password for authenticated user.

**Request:**
```json
{
  "current_password": "oldPassword123",
  "new_password": "newSecurePassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password updated"
}
```

---

### Web3 Authentication

#### POST /auth/web3/nonce

Get a nonce for wallet signature verification.

**Request:**
```json
{
  "address": "0x1234...abcd"
}
```

**Response (200):**
```json
{
  "nonce": "Sign this message to authenticate: abc123...",
  "expiresAt": "2026-01-17T11:00:00Z"
}
```

---

#### POST /auth/web3/verify

Verify wallet signature and authenticate.

**Request:**
```json
{
  "address": "0x1234...abcd",
  "signature": "0xsigned..."
}
```

**Response (200):**
```json
{
  "success": true,
  "user": { ... },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

#### POST /auth/web3/link

Link a wallet to an existing account.

**Request:**
```json
{
  "address": "0x1234...abcd",
  "signature": "0xsigned..."
}
```

**Response (200):**
```json
{
  "success": true,
  "walletLinked": true
}
```

---

### OAuth 2.0 / OIDC

PreSuite Hub acts as an OAuth 2.0 / OpenID Connect provider.

#### GET /oauth/authorize

OAuth authorization endpoint (redirect-based flow).

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | Yes | OAuth client ID |
| `redirect_uri` | Yes | Callback URL |
| `response_type` | Yes | `code` or `token` |
| `scope` | No | Space-separated scopes (e.g., `openid profile email`) |
| `state` | Recommended | CSRF protection token |

**Redirects to:** `{redirect_uri}?code={auth_code}&state={state}`

---

#### POST /oauth/token

Exchange authorization code for tokens.

**Request:**
```json
{
  "grant_type": "authorization_code",
  "code": "auth_code_here",
  "redirect_uri": "https://app.example.com/callback",
  "client_id": "client_id",
  "client_secret": "client_secret"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 604800,
  "refresh_token": "refresh_token_here",
  "id_token": "eyJhbGciOiJIUzI1NiIs...",
  "scope": "openid profile email"
}
```

---

#### GET /oauth/userinfo

Get user information (OIDC UserInfo endpoint).

**Headers:**
```http
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@premail.site",
  "email_verified": true,
  "name": "John Doe",
  "preferred_username": "johndoe"
}
```

---

#### GET /.well-known/openid-configuration

OIDC Discovery document.

**Response (200):**
```json
{
  "issuer": "https://presuite.eu",
  "authorization_endpoint": "https://presuite.eu/api/oauth/authorize",
  "token_endpoint": "https://presuite.eu/api/oauth/token",
  "userinfo_endpoint": "https://presuite.eu/api/oauth/userinfo",
  "jwks_uri": "https://presuite.eu/api/oauth/jwks",
  "response_types_supported": ["code", "token", "id_token"],
  "subject_types_supported": ["public"],
  "id_token_signing_alg_values_supported": ["HS256", "RS256"]
}
```

---

### Sessions Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/auth/sessions` | List active sessions |
| DELETE | `/auth/sessions/:id` | Revoke specific session |
| DELETE | `/auth/sessions` | Revoke all sessions except current |

---

### PreGPT Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/pregpt/status` | Health check |
| POST | `/pregpt/summary` | Streaming AI summary |
| POST | `/pregpt/ask` | Follow-up questions |
| POST | `/pregpt/related-searches` | Related search suggestions |

---

### Presearch Integration

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/presearch/search` | Proxy search to Presearch |
| GET | `/presearch/stats` | Get user search stats |
| POST | `/presearch/link` | Link Presearch account |

---

## PreDrive API

**Base URL:** `https://predrive.eu/api`

### Nodes (Files & Folders)

#### Basic Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/nodes` | List root nodes |
| GET | `/nodes/:id` | Get node details |
| GET | `/nodes/:id/children` | List children |
| POST | `/nodes` | Create node |
| PATCH | `/nodes/:id` | Update node |
| DELETE | `/nodes/:id` | Delete node (soft delete to trash) |
| GET | `/nodes/:id/content` | Download file |
| PUT | `/nodes/:id/content` | Upload file |

**Create Folder:**
```http
POST /api/nodes
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "New Folder",
  "type": "folder",
  "parentId": null
}
```

**Upload File:**
```http
PUT /api/nodes/:id/content
Content-Type: application/octet-stream
Authorization: Bearer <token>

<binary file content>
```

---

#### Advanced Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/nodes/:id/copy` | Copy node |
| POST | `/nodes/:id/move` | Move node to different parent |
| POST | `/nodes/:id/star` | Star/favorite a node |
| DELETE | `/nodes/:id/star` | Remove star |
| POST | `/nodes/:id/restore` | Restore from trash |
| DELETE | `/nodes/:id/permanent` | Permanently delete |
| GET | `/nodes/search` | Search nodes |
| GET | `/nodes/starred` | List starred nodes |
| GET | `/nodes/recent` | List recently accessed |
| GET | `/nodes/trash` | List trash items |

**Search Nodes:**
```http
GET /api/nodes/search?q=report&type=file&extension=pdf
Authorization: Bearer <token>
```

**Query Parameters:**

| Parameter | Description |
|-----------|-------------|
| `q` | Search query |
| `type` | `file` or `folder` |
| `extension` | File extension filter |
| `parentId` | Limit to folder |
| `createdAfter` | ISO date filter |
| `modifiedAfter` | ISO date filter |

---

### Shares

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/shares` | List user's shares |
| POST | `/shares` | Create share link |
| GET | `/shares/:token` | Get shared node (public) |
| GET | `/shares/:token/content` | Download shared file (public) |
| PATCH | `/shares/:id` | Update share settings |
| DELETE | `/shares/:id` | Revoke share |

**Create Share:**
```http
POST /api/shares
Content-Type: application/json
Authorization: Bearer <token>

{
  "nodeId": "uuid",
  "expiresAt": "2026-02-15T00:00:00Z",
  "password": "optional",
  "permissions": ["view", "download"]
}
```

**Response:**
```json
{
  "id": "share-uuid",
  "token": "abc123xyz",
  "url": "https://predrive.eu/s/abc123xyz",
  "expiresAt": "2026-02-15T00:00:00Z",
  "permissions": ["view", "download"]
}
```

---

### Permissions

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/nodes/:id/permissions` | List node permissions |
| POST | `/nodes/:id/permissions` | Add permission |
| PATCH | `/nodes/:id/permissions/:permId` | Update permission |
| DELETE | `/nodes/:id/permissions/:permId` | Remove permission |

**Add Permission:**
```http
POST /api/nodes/:id/permissions
Content-Type: application/json
Authorization: Bearer <token>

{
  "userId": "user-uuid",
  "role": "editor",
  "notify": true
}
```

**Roles:**
- `viewer` - Read-only access
- `commenter` - View + comment
- `editor` - View + edit
- `owner` - Full control

---

### Activity

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/activity` | Get activity feed |
| GET | `/nodes/:id/activity` | Get node activity |

**Activity Response:**
```json
{
  "activities": [
    {
      "id": "activity-uuid",
      "type": "file_upload",
      "nodeId": "node-uuid",
      "nodeName": "report.pdf",
      "userId": "user-uuid",
      "userName": "John Doe",
      "timestamp": "2026-01-17T10:00:00Z"
    }
  ]
}
```

---

### Storage

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/storage/usage` | Get storage usage |
| GET | `/storage/quota` | Get quota details |

**Response:**
```json
{
  "used": 4500000000,
  "total": 32212254720,
  "percentage": 13.97,
  "breakdown": {
    "files": 4000000000,
    "trash": 500000000
  }
}
```

---

### Integrations

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/integrations/preoffice/open` | Open file in PreOffice |
| POST | `/integrations/premail/attach` | Attach file to email |

---

### WebDAV

PreDrive supports WebDAV protocol at `https://predrive.eu/dav/`.

**Authentication:** Use JWT token as password with email as username.

```bash
# Mount via WebDAV
mount -t davfs https://predrive.eu/dav/ /mnt/predrive
```

---

## PreMail API

**Base URL:** `https://premail.site/api/v1`

> **Note:** All PreMail endpoints use the `/api/v1` prefix.

### Auth (Proxied to PreSuite Hub)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login (proxied to PreSuite) |
| POST | `/auth/register` | Register (proxied to PreSuite) |
| GET | `/auth/verify` | Verify token (proxied to PreSuite) |
| POST | `/auth/logout` | Logout |

---

### Accounts

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/accounts` | List email accounts |
| POST | `/accounts` | Add email account |
| GET | `/accounts/:id` | Get account details |
| PATCH | `/accounts/:id` | Update account |
| DELETE | `/accounts/:id` | Remove account |
| POST | `/accounts/:id/sync` | Force sync account |
| GET | `/accounts/:id/folders` | List IMAP folders |

**Add External Account:**
```http
POST /api/v1/accounts
Content-Type: application/json
Authorization: Bearer <token>

{
  "email": "user@gmail.com",
  "provider": "imap",
  "imapHost": "imap.gmail.com",
  "imapPort": 993,
  "smtpHost": "smtp.gmail.com",
  "smtpPort": 465,
  "username": "user@gmail.com",
  "password": "app-password"
}
```

**Provider Types:** `imap`, `gmail`, `microsoft`

---

### Messages

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/messages` | List messages |
| GET | `/messages/:id` | Get message details |
| POST | `/messages` | Send message |
| POST | `/messages/draft` | Save draft |
| PATCH | `/messages/:id` | Update flags/labels |
| DELETE | `/messages/:id` | Delete message |
| POST | `/messages/:id/move` | Move to folder |
| POST | `/messages/:id/copy` | Copy to folder |

**List Messages:**
```http
GET /api/v1/messages?accountId=uuid&folder=INBOX&page=0&pageSize=20
Authorization: Bearer <token>
```

**Query Parameters:**

| Parameter | Default | Description |
|-----------|---------|-------------|
| `accountId` | - | Email account ID |
| `folder` | `INBOX` | Folder name |
| `page` | `0` | Page number |
| `pageSize` | `20` | Items per page (max 100) |
| `labelId` | - | Filter by label |
| `unreadOnly` | `false` | Only unread messages |

**Response:**
```json
{
  "messages": [
    {
      "id": "123",
      "uid": 456,
      "from": { "name": "Sender", "address": "sender@example.com" },
      "to": [{ "name": "You", "address": "you@premail.site" }],
      "subject": "Hello",
      "date": "2026-01-15T10:00:00Z",
      "flags": { "seen": false, "flagged": false, "answered": false },
      "labels": ["work", "important"],
      "preview": "Message preview...",
      "hasAttachments": true
    }
  ],
  "total": 150,
  "page": 0,
  "pages": 8
}
```

**Send Message:**
```http
POST /api/v1/messages
Content-Type: application/json
Authorization: Bearer <token>

{
  "accountId": "uuid",
  "to": [{ "name": "Recipient", "address": "recipient@example.com" }],
  "cc": [],
  "bcc": [],
  "subject": "Hello",
  "text": "Plain text body",
  "html": "<p>HTML body</p>",
  "attachments": ["attachment-uuid-1", "attachment-uuid-2"],
  "replyTo": "original-message-id",
  "inReplyTo": "<message-id@example.com>"
}
```

**Update Message Flags:**
```http
PATCH /api/v1/messages/:id
Content-Type: application/json
Authorization: Bearer <token>

{
  "flags": {
    "seen": true,
    "flagged": false
  },
  "addLabels": ["work"],
  "removeLabels": ["todo"]
}
```

---

### Labels

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/labels` | List user labels |
| POST | `/labels` | Create label |
| GET | `/labels/:id` | Get label details |
| PATCH | `/labels/:id` | Update label |
| DELETE | `/labels/:id` | Delete label |
| GET | `/labels/:id/messages` | List messages with label |

**Create Label:**
```http
POST /api/v1/labels
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "Work",
  "color": "#4285f4",
  "parentId": null
}
```

**Response:**
```json
{
  "id": "label-uuid",
  "name": "Work",
  "color": "#4285f4",
  "parentId": null,
  "messageCount": 0,
  "unreadCount": 0
}
```

---

### Calendar

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/calendar/events` | List calendar events |
| POST | `/calendar/events` | Create event |
| GET | `/calendar/events/:id` | Get event details |
| PATCH | `/calendar/events/:id` | Update event |
| DELETE | `/calendar/events/:id` | Delete event |
| POST | `/calendar/events/:id/respond` | Respond to invite |

**List Events:**
```http
GET /api/v1/calendar/events?start=2026-01-01&end=2026-01-31
Authorization: Bearer <token>
```

**Create Event:**
```http
POST /api/v1/calendar/events
Content-Type: application/json
Authorization: Bearer <token>

{
  "title": "Team Meeting",
  "description": "Weekly sync",
  "start": "2026-01-20T10:00:00Z",
  "end": "2026-01-20T11:00:00Z",
  "location": "Conference Room A",
  "attendees": [
    { "email": "colleague@example.com", "name": "Colleague" }
  ],
  "reminders": [
    { "type": "email", "minutes": 15 },
    { "type": "push", "minutes": 5 }
  ],
  "recurrence": {
    "frequency": "weekly",
    "interval": 1,
    "until": "2026-06-01"
  }
}
```

---

### Search

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/search` | Search messages |
| GET | `/search/suggestions` | Get search suggestions |

**Search Messages:**
```http
GET /api/v1/search?q=meeting&accountId=uuid&folder=INBOX&from=sender@example.com
Authorization: Bearer <token>
```

**Query Parameters:**

| Parameter | Description |
|-----------|-------------|
| `q` | Search query |
| `accountId` | Filter by account |
| `folder` | Filter by folder |
| `from` | Filter by sender |
| `to` | Filter by recipient |
| `subject` | Filter by subject |
| `hasAttachment` | `true`/`false` |
| `after` | Date filter (ISO) |
| `before` | Date filter (ISO) |
| `labelId` | Filter by label |

---

### Notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications` | List notifications |
| PATCH | `/notifications/:id/read` | Mark as read |
| POST | `/notifications/read-all` | Mark all as read |
| GET | `/notifications/settings` | Get notification settings |
| PATCH | `/notifications/settings` | Update settings |

---

### Attachments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/messages/:messageId/attachments/:attachmentId` | Download attachment |
| POST | `/attachments/upload` | Upload attachment for sending |

**Upload Attachment:**
```http
POST /api/v1/attachments/upload
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <binary>
```

**Response:**
```json
{
  "id": "attachment-uuid",
  "filename": "document.pdf",
  "contentType": "application/pdf",
  "size": 125000
}
```

---

### PreDrive Integration

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/predrive/attach` | Attach file from PreDrive |
| POST | `/predrive/save` | Save attachment to PreDrive |

**Attach from PreDrive:**
```http
POST /api/v1/predrive/attach
Content-Type: application/json
Authorization: Bearer <token>

{
  "nodeId": "predrive-file-uuid"
}
```

---

### Webhooks

Webhooks for integrations (signature-verified, no auth required).

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/webhooks/inbound` | Receive inbound email notifications |
| POST | `/webhooks/delivery` | Delivery status updates |

**Inbound Webhook Payload:**
```json
{
  "event": "new_message",
  "accountId": "uuid",
  "messageId": "123",
  "from": "sender@example.com",
  "subject": "New message",
  "timestamp": "2026-01-17T10:00:00Z"
}
```

---

## PreOffice API

**Base URL:** `https://preoffice.site/api`

### Documents

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/edit` | Get editor URL |
| POST | `/create` | Create new document |
| GET | `/health` | Health check |

**Get Editor URL:**
```http
POST /api/edit
Content-Type: application/json

{
  "filePath": "/documents/report.docx",
  "userToken": "jwt_token",
  "userId": "uuid",
  "userName": "User Name"
}
```

**Response:**
```json
{
  "editorUrl": "https://preoffice.site/browser/dist/cool.html?WOPISrc=...",
  "fileId": "base64_encoded_path",
  "accessToken": "wopi_token",
  "expiresIn": "24h"
}
```

**Create Document:**
```http
POST /api/create
Content-Type: application/json

{
  "type": "document|spreadsheet|presentation|drawing",
  "folder": "/documents",
  "name": "New Document.odt",
  "userToken": "jwt_token",
  "userId": "uuid"
}
```

### WOPI Endpoints (Internal)

Used internally by Collabora Online:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wopi/files/:fileId` | CheckFileInfo |
| GET | `/wopi/files/:fileId/contents` | GetFile |
| POST | `/wopi/files/:fileId/contents` | PutFile |
| POST | `/wopi/files/:fileId` | Lock operations |

---

## PreSocial API

**Base URL:** `https://presocial.presuite.eu/api`

PreSocial is a Lemmy-based social platform with custom API extensions.

### Search

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/social/search` | Search posts and communities |

**Search:**
```http
GET /api/social/search?q=presearch&type=posts&sort=hot
Authorization: Bearer <token>
```

**Query Parameters:**

| Parameter | Default | Description |
|-----------|---------|-------------|
| `q` | - | Search query |
| `type` | `all` | `posts`, `communities`, `users`, `all` |
| `sort` | `hot` | `hot`, `new`, `top`, `active` |
| `page` | `1` | Page number |
| `limit` | `20` | Results per page |

---

### Posts

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/social/post/:id` | Get post details |
| POST | `/social/post` | Create post |
| PATCH | `/social/post/:id` | Update post |
| DELETE | `/social/post/:id` | Delete post |

**Create Post:**
```http
POST /api/social/post
Content-Type: application/json
Authorization: Bearer <token>

{
  "communityId": "community-id",
  "title": "My Post Title",
  "body": "Post content in markdown",
  "url": "https://optional-link.com",
  "nsfw": false
}
```

---

### Comments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/social/post/:id/comments` | Get post comments |
| POST | `/social/comment` | Create comment |
| PATCH | `/social/comment/:id` | Update comment |
| DELETE | `/social/comment/:id` | Delete comment |

**Create Comment:**
```http
POST /api/social/comment
Content-Type: application/json
Authorization: Bearer <token>

{
  "postId": "post-id",
  "parentId": null,
  "content": "This is my comment"
}
```

---

### Communities

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/social/communities` | List communities |
| GET | `/social/community/:id` | Get community details |
| POST | `/social/community/:id/subscribe` | Subscribe to community |
| DELETE | `/social/community/:id/subscribe` | Unsubscribe |

---

### Trending

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/social/trending` | Get trending content |

**Response:**
```json
{
  "posts": [...],
  "communities": [...],
  "tags": [
    { "name": "presearch", "count": 150 },
    { "name": "crypto", "count": 89 }
  ]
}
```

---

### Voting

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/social/vote` | Vote on post or comment |

**Vote:**
```http
POST /api/social/vote
Content-Type: application/json
Authorization: Bearer <token>

{
  "targetId": "post-or-comment-id",
  "targetType": "post",
  "score": 1
}
```

**Score Values:** `1` (upvote), `0` (remove vote), `-1` (downvote)

---

### Bookmarks

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/social/bookmarks` | List bookmarks |
| POST | `/social/bookmark` | Add bookmark |
| DELETE | `/social/bookmark/:id` | Remove bookmark |

---

### Web3 Authentication

PreSocial supports wallet-based authentication via PreSuite Hub.

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/web3/nonce` | Get wallet nonce |
| POST | `/auth/web3/verify` | Verify wallet signature |

---

## Error Handling

All APIs return errors in this format:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message"
  }
}
```

### Common Error Codes

| Code | Status | Description |
|------|--------|-------------|
| `UNAUTHORIZED` | 401 | Missing or invalid token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `VALIDATION_ERROR` | 400 | Invalid input |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

---

## Rate Limiting

| Endpoint Type | Limit |
|--------------|-------|
| `/auth/register` | 5 req/hour per IP |
| `/auth/login` | 10 req/min per IP |
| `/auth/reset-password` | 3 req/hour per email |
| File upload | 20 req/min |
| General API | 100 req/min per token |

**Response Headers:**
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642000000
```

---

## SDK Examples

### JavaScript/TypeScript

```typescript
const AUTH_API = 'https://presuite.eu/api/auth';

// Login
export async function login(email: string, password: string) {
  const response = await fetch(`${AUTH_API}/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });

  if (!response.ok) {
    throw new Error('Invalid credentials');
  }

  const { token, user } = await response.json();
  localStorage.setItem('token', token);
  return user;
}

// PreDrive - List files
const response = await fetch('https://predrive.eu/api/nodes', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const { nodes } = await response.json();

// PreMail - List messages (note /api/v1 prefix)
const messages = await fetch(
  `https://premail.site/api/v1/messages?accountId=${accountId}&folder=INBOX`,
  { headers: { 'Authorization': `Bearer ${token}` } }
).then(r => r.json());

// PreSocial - Get trending
const trending = await fetch('https://presocial.presuite.eu/api/social/trending', {
  headers: { 'Authorization': `Bearer ${token}` }
}).then(r => r.json());
```

### cURL

```bash
# Login
curl -X POST https://presuite.eu/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@premail.site","password":"password123"}'

# Get files
curl -H "Authorization: Bearer $TOKEN" https://predrive.eu/api/nodes

# Send email (note /api/v1 prefix)
curl -X POST https://premail.site/api/v1/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"uuid","to":[{"address":"test@example.com"}],"subject":"Test","text":"Hello"}'

# Search PreSocial
curl -H "Authorization: Bearer $TOKEN" \
  "https://presocial.presuite.eu/api/social/search?q=presearch&type=posts"
```

---

## Health Endpoints

All services expose health check endpoints:

| Service | Endpoint |
|---------|----------|
| PreSuite Hub | `GET https://presuite.eu/api/health` |
| PreDrive | `GET https://predrive.eu/api/health` |
| PreMail | `GET https://premail.site/health` |
| PreOffice | `GET https://preoffice.site/health` |
| PreSocial | `GET https://presocial.presuite.eu/api/health` |

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-01-17T10:30:00Z"
}
```
