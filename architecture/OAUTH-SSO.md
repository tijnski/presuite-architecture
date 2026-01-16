# OAuth SSO Flow

## Authorization Code Flow

```
┌────────────┐                              ┌────────────┐                              ┌────────────┐
│            │                              │            │                              │            │
│   User     │                              │  PreSuite  │                              │  Service   │
│  Browser   │                              │  Hub (IdP) │                              │ (PreMail)  │
│            │                              │            │                              │            │
└─────┬──────┘                              └─────┬──────┘                              └─────┬──────┘
      │                                           │                                           │
      │  1. User clicks "Sign in with PreSuite"   │                                           │
      │ ─────────────────────────────────────────────────────────────────────────────────────>│
      │                                           │                                           │
      │  2. Generate state, redirect to IdP       │                                           │
      │ <─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
      │                                           │                                           │
      │  3. GET /api/oauth/authorize              │                                           │
      │      ?client_id=premail                   │                                           │
      │      &redirect_uri=.../oauth/callback     │                                           │
      │      &response_type=code                  │                                           │
      │      &scope=openid profile email          │                                           │
      │      &state=random-uuid                   │                                           │
      │ ─────────────────────────────────────────>│                                           │
      │                                           │                                           │
      │  4. Show login form (if not logged in)    │                                           │
      │ <─────────────────────────────────────────│                                           │
      │                                           │                                           │
      │  5. User submits credentials              │                                           │
      │ ─────────────────────────────────────────>│                                           │
      │                                           │                                           │
      │  6. Validate credentials                  │                                           │
      │     Generate authorization code           │                                           │
      │                                           │                                           │
      │  7. Redirect to callback with code        │                                           │
      │ <─────────────────────────────────────────│                                           │
      │     302 Location: .../oauth/callback      │                                           │
      │         ?code=auth-code&state=...         │                                           │
      │                                           │                                           │
      │  8. GET /oauth/callback?code=...&state=...│                                           │
      │ ─────────────────────────────────────────────────────────────────────────────────────>│
      │                                           │                                           │
      │                                           │  9. POST /api/oauth/token                 │
      │                                           │      grant_type=authorization_code        │
      │                                           │      code=auth-code                       │
      │                                           │      client_id + client_secret            │
      │                                           │ <─────────────────────────────────────────│
      │                                           │                                           │
      │                                           │  10. Validate code, generate tokens       │
      │                                           │                                           │
      │                                           │  11. Return tokens                        │
      │                                           │      {access_token, id_token, token_type} │
      │                                           │ ─────────────────────────────────────────>│
      │                                           │                                           │
      │  12. Set session, redirect to app         │                                           │
      │ <─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
      │                                           │                                           │
      │  13. User is now authenticated            │                                           │
      │ <═════════════════════════════════════════════════════════════════════════════════════│
      │                                           │                                           │
```

## Token Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                         ID Token (JWT)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Header (Base64):                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  {                                                       │   │
│  │    "alg": "HS256",                                       │   │
│  │    "typ": "JWT"                                          │   │
│  │  }                                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           .                                     │
│  Payload (Base64):                                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  {                                                       │   │
│  │    "sub": "550e8400-e29b-41d4-a716-446655440000",       │   │
│  │    "org_id": "660e8400-e29b-41d4-a716-446655440000",    │   │
│  │    "email": "user@example.com",                          │   │
│  │    "name": "John Doe",                                   │   │
│  │    "iss": "presuite",                                    │   │
│  │    "aud": "premail",                                     │   │
│  │    "iat": 1736956800,                                    │   │
│  │    "exp": 1736960400                                     │   │
│  │  }                                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           .                                     │
│  Signature (Base64):                                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  HMACSHA256(                                             │   │
│  │    base64UrlEncode(header) + "." +                       │   │
│  │    base64UrlEncode(payload),                             │   │
│  │    JWT_SECRET                                            │   │
│  │  )                                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Token Claims

| Claim | Description |
|-------|-------------|
| `sub` | User ID (UUID) |
| `org_id` | Organization ID |
| `email` | User email address |
| `name` | Display name |
| `iss` | Issuer (always "presuite") |
| `aud` | Audience (target service) |
| `iat` | Issued at timestamp |
| `exp` | Expiration timestamp |
