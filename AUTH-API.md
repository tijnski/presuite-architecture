# PreSuite Auth API Specification

## Overview

The PreSuite Auth API is the central authentication service for the entire PreSuite ecosystem. It handles user registration, login, token issuance, and account management for all services.

**Base URL:** `https://presuite.eu/api/auth`

## Authentication

### JWT Token Format

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

Include the token in the `Authorization` header:

```http
Authorization: Bearer <token>
```

---

## Endpoints

### POST /register

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

**Success Response (201):**
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

**Error Responses:**

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `INVALID_EMAIL` | Email format is invalid |
| 400 | `WEAK_PASSWORD` | Password does not meet requirements |
| 409 | `EMAIL_EXISTS` | Email already registered |
| 500 | `PROVISIONING_FAILED` | Failed to create mailbox/storage |

**Side Effects:**
- Creates user in PreSuite Hub database
- Creates @premail.site mailbox in Stalwart
- Initializes PreDrive storage for user

---

### POST /login

Authenticate an existing user.

**Request:**
```json
{
  "email": "user@premail.site",
  "password": "password123"
}
```

**Success Response (200):**
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

**Error Responses:**

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `MISSING_CREDENTIALS` | Email or password not provided |
| 401 | `INVALID_CREDENTIALS` | Email or password incorrect |
| 403 | `ACCOUNT_DISABLED` | Account has been disabled |

---

### GET /verify

Verify a JWT token is valid.

**Headers:**
```http
Authorization: Bearer <token>
```

**Success Response (200):**
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

**Error Responses:**

| Status | Error | Description |
|--------|-------|-------------|
| 401 | `TOKEN_MISSING` | No Authorization header |
| 401 | `TOKEN_INVALID` | Token signature invalid |
| 401 | `TOKEN_EXPIRED` | Token has expired |

---

### POST /logout

Invalidate the current session.

**Headers:**
```http
Authorization: Bearer <token>
```

**Success Response (200):**
```json
{
  "success": true
}
```

---

### POST /reset-password

Request a password reset.

**Request:**
```json
{
  "email": "user@premail.site"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "If an account exists, a reset link has been sent"
}
```

**Note:** Always returns success to prevent email enumeration.

---

### POST /reset-password/confirm

Complete a password reset.

**Request:**
```json
{
  "token": "reset-token-from-email",
  "password": "newSecurePassword123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Password has been reset"
}
```

**Error Responses:**

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `INVALID_TOKEN` | Reset token is invalid or expired |
| 400 | `WEAK_PASSWORD` | New password does not meet requirements |

---

### GET /me

Get current user information.

**Headers:**
```http
Authorization: Bearer <token>
```

**Success Response (200):**
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

### PATCH /me

Update current user information.

**Headers:**
```http
Authorization: Bearer <token>
```

**Request:**
```json
{
  "name": "John Smith"
}
```

**Success Response (200):**
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

### POST /me/password

Change password for authenticated user.

**Headers:**
```http
Authorization: Bearer <token>
```

**Request:**
```json
{
  "current_password": "oldPassword123",
  "new_password": "newSecurePassword123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Password updated"
}
```

**Error Responses:**

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `WEAK_PASSWORD` | New password does not meet requirements |
| 401 | `INVALID_PASSWORD` | Current password is incorrect |

---

### GET /health

Health check endpoint.

**Response (200):**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```

---

## CORS Configuration

The Auth API accepts requests from all PreSuite services:

```javascript
const allowedOrigins = [
  'https://presuite.eu',
  'https://predrive.eu',
  'https://premail.site',
  'https://preoffice.site'
];
```

---

## Rate Limiting

| Endpoint | Limit |
|----------|-------|
| `/register` | 5 per hour per IP |
| `/login` | 10 per minute per IP |
| `/reset-password` | 3 per hour per email |
| All others | 100 per minute per token |

---

## Error Response Format

All errors follow this format:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message"
  }
}
```

---

## Integration Examples

### From PreDrive (React)

```typescript
// src/services/auth.ts
const AUTH_API = 'https://presuite.eu/api/auth';

export async function register(data: RegisterData) {
  const response = await fetch(`${AUTH_API}/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...data, source: 'predrive' })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error.message);
  }

  const { token, user } = await response.json();
  localStorage.setItem('token', token);
  return user;
}

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
```

### From PreMail (React)

```typescript
// Same as above, but with source: 'premail'
export async function register(data: RegisterData) {
  const response = await fetch(`${AUTH_API}/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...data, source: 'premail' })
  });
  // ...
}
```

---

## Security Considerations

1. **Password Hashing:** bcrypt with cost factor 12
2. **Token Expiration:** 7 days for access tokens
3. **HTTPS Only:** All endpoints require HTTPS
4. **Rate Limiting:** Prevents brute force attacks
5. **CORS:** Restricts to known PreSuite domains
6. **No Email Enumeration:** Reset always returns success

---

*Last Updated: January 2026*
