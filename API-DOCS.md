# PreSuite API Documentation

Comprehensive API reference for all PreSuite services.

---

## Authentication

All APIs use JWT Bearer tokens for authentication. Tokens are issued by the central PreSuite Hub auth service.

```http
Authorization: Bearer <jwt_token>
```

### Obtaining Tokens

**Login:**
```http
POST https://presuite.eu/api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "User Name"
  }
}
```

---

## PreSuite Hub API

**Base URL:** `https://presuite.eu/api`

### Auth Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Create new account |
| POST | `/auth/login` | Authenticate user |
| GET | `/auth/verify` | Validate JWT token |
| GET | `/auth/me` | Get current user |
| PATCH | `/auth/me` | Update user profile |
| POST | `/auth/logout` | End session |
| POST | `/auth/reset-password` | Password reset |
| GET | `/auth/health` | Auth service health |

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

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login |
| POST | `/auth/register` | Register |
| GET | `/auth/me` | Current user |
| GET | `/auth/health` | Health check |

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

### WOPI Endpoints

These are used internally by Collabora Online:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wopi/files/:fileId` | CheckFileInfo |
| GET | `/wopi/files/:fileId/contents` | GetFile |
| POST | `/wopi/files/:fileId/contents` | PutFile |
| POST | `/wopi/files/:fileId` | Lock operations |

---

## Error Responses

All APIs return errors in this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  }
}
```

Common error codes:
- `UNAUTHORIZED` - Missing or invalid token (401)
- `FORBIDDEN` - Insufficient permissions (403)
- `NOT_FOUND` - Resource not found (404)
- `CONFLICT` - Resource conflict (409)
- `VALIDATION_ERROR` - Invalid input (400)
- `INTERNAL_ERROR` - Server error (500)

---

## Rate Limiting

APIs implement rate limiting:

| Endpoint Type | Limit |
|--------------|-------|
| Auth (login) | 10 req/min |
| Auth (register) | 5 req/min |
| General API | 100 req/min |
| File upload | 20 req/min |

Rate limit headers:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642000000
```

---

## WebSocket Events

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

## SDK Examples

### JavaScript/TypeScript

```typescript
// PreDrive
const response = await fetch('https://predrive.eu/api/nodes', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const { nodes } = await response.json();

// PreMail
const messages = await fetch(
  `https://premail.site/api/messages?accountId=${accountId}&folder=INBOX`,
  { headers: { 'Authorization': `Bearer ${token}` } }
).then(r => r.json());
```

### cURL

```bash
# Get files
curl -H "Authorization: Bearer $TOKEN" https://predrive.eu/api/nodes

# Send email
curl -X POST https://premail.site/api/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"uuid","to":[{"address":"test@example.com"}],"subject":"Test","text":"Hello"}'
```

---

*Last Updated: January 15, 2026*
