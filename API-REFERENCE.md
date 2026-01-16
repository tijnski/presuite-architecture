# PreSuite API Reference

Comprehensive API documentation for all PreSuite services.

> **Last Updated:** January 16, 2026

---

## Table of Contents

- [Authentication](#authentication)
- [PreSuite Hub API](#presuite-hub-api)
- [PreDrive API](#predrive-api)
- [PreMail API](#premail-api)
- [PreOffice API](#preoffice-api)
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
- **CORS:** Restricted to PreSuite domains (`presuite.eu`, `predrive.eu`, `premail.site`, `preoffice.site`)

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
| `password` | string | Yes | Minimum 8 characters |
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

### PreGPT Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/pregpt/status` | Health check |
| POST | `/pregpt/summary` | Streaming AI summary |
| POST | `/pregpt/ask` | Follow-up questions |
| POST | `/pregpt/related-searches` | Related search suggestions |

---

## PreDrive API

**Base URL:** `https://predrive.eu/api`

### Nodes (Files & Folders)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/nodes` | List root nodes |
| GET | `/nodes/:id` | Get node details |
| GET | `/nodes/:id/children` | List children |
| POST | `/nodes` | Create node |
| PATCH | `/nodes/:id` | Update node |
| DELETE | `/nodes/:id` | Delete node |
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

### Shares

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/shares` | List user's shares |
| POST | `/shares` | Create share link |
| GET | `/shares/:token` | Get shared node (public) |
| DELETE | `/shares/:id` | Revoke share |

**Create Share:**
```http
POST /api/shares
Content-Type: application/json
Authorization: Bearer <token>

{
  "nodeId": "uuid",
  "expiresAt": "2026-02-15T00:00:00Z",
  "password": "optional"
}
```

### Storage

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/storage/usage` | Get storage usage |

**Response:**
```json
{
  "used": 4500000000,
  "total": 32212254720,
  "percentage": 13.97
}
```

---

## PreMail API

**Base URL:** `https://premail.site/api`

### Accounts

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/accounts` | List email accounts |
| POST | `/accounts` | Add email account |
| DELETE | `/accounts/:id` | Remove account |

### Messages

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/messages` | List messages |
| GET | `/messages/:id` | Get message |
| POST | `/messages` | Send message |
| PATCH | `/messages/:id` | Update flags |
| DELETE | `/messages/:id` | Delete message |

**List Messages:**
```http
GET /api/messages?accountId=uuid&folder=INBOX&page=0&pageSize=20
Authorization: Bearer <token>
```

**Response:**
```json
{
  "messages": [
    {
      "id": "123",
      "from": { "name": "Sender", "address": "sender@example.com" },
      "subject": "Hello",
      "date": "2026-01-15T10:00:00Z",
      "flags": { "seen": false, "flagged": false },
      "preview": "Message preview..."
    }
  ],
  "total": 150,
  "page": 0,
  "pages": 8
}
```

**Send Message:**
```http
POST /api/messages
Content-Type: application/json
Authorization: Bearer <token>

{
  "accountId": "uuid",
  "to": [{ "address": "recipient@example.com" }],
  "subject": "Hello",
  "text": "Plain text body",
  "html": "<p>HTML body</p>"
}
```

### Folders

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/folders` | List folders |
| POST | `/folders` | Create folder |
| DELETE | `/folders/:name` | Delete folder |

### Attachments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/attachments/:messageId/:attachmentId` | Download attachment |
| POST | `/attachments/upload` | Upload attachment |

### Search

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/search?q=query` | Search messages |

### WebSocket Events

PreMail supports WebSocket for real-time updates:

**Connect:**
```javascript
const ws = new WebSocket('wss://premail.site/ws?token=jwt_token');
```

**Events:**
```json
{ "type": "new_message", "data": { "accountId": "uuid", "folder": "INBOX" } }
{ "type": "message_read", "data": { "messageId": "123" } }
{ "type": "folder_update", "data": { "folder": "INBOX", "unread": 5 } }
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

// PreMail - List messages
const messages = await fetch(
  `https://premail.site/api/messages?accountId=${accountId}&folder=INBOX`,
  { headers: { 'Authorization': `Bearer ${token}` } }
).then(r => r.json());
```

### cURL

```bash
# Login
curl -X POST https://presuite.eu/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@premail.site","password":"password123"}'

# Get files
curl -H "Authorization: Bearer $TOKEN" https://predrive.eu/api/nodes

# Send email
curl -X POST https://premail.site/api/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"uuid","to":[{"address":"test@example.com"}],"subject":"Test","text":"Hello"}'
```

---

## Health Endpoints

All services expose health check endpoints:

| Service | Endpoint |
|---------|----------|
| PreSuite Hub | `GET https://presuite.eu/api/auth/health` |
| PreDrive | `GET https://predrive.eu/api/health` |
| PreMail | `GET https://premail.site/api/health` |
| PreOffice | `GET https://preoffice.site/api/health` |

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-01-15T10:30:00Z",
  "version": "1.0.0"
}
```
