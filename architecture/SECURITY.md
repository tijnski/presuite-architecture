# Security Architecture

## Authentication & Authorization

```
┌─────────────────────────────────────────────────────────────────┐
│                    Security Architecture                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Authentication                        │   │
│   │                                                          │   │
│   │   ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │   │
│   │   │   OAuth     │    │   Basic     │    │   JWT      │  │   │
│   │   │   SSO       │    │   Auth      │    │  Bearer    │  │   │
│   │   │             │    │             │    │            │  │   │
│   │   │ PreSuite    │    │ Email +     │    │ API calls  │  │   │
│   │   │ Hub as IdP  │    │ Password    │    │ after auth │  │   │
│   │   └─────────────┘    └─────────────┘    └────────────┘  │   │
│   │         │                  │                  │          │   │
│   │         └──────────────────┴──────────────────┘          │   │
│   │                            │                             │   │
│   │                            ▼                             │   │
│   │              ┌─────────────────────────┐                 │   │
│   │              │   JWT Token Issued      │                 │   │
│   │              │                         │                 │   │
│   │              │  Claims:                │                 │   │
│   │              │  • sub (user ID)        │                 │   │
│   │              │  • org_id               │                 │   │
│   │              │  • email                │                 │   │
│   │              │  • name                 │                 │   │
│   │              │  • exp (1 hour)         │                 │   │
│   │              └─────────────────────────┘                 │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Authorization                         │   │
│   │                                                          │   │
│   │   ┌───────────────────────────────────────────────────┐ │   │
│   │   │              Role-Based Access Control             │ │   │
│   │   │                                                    │ │   │
│   │   │   ┌─────────┐  ┌─────────┐  ┌─────────┐          │ │   │
│   │   │   │  Owner  │  │ Editor  │  │ Viewer  │          │ │   │
│   │   │   │         │  │         │  │         │          │ │   │
│   │   │   │ • Read  │  │ • Read  │  │ • Read  │          │ │   │
│   │   │   │ • Write │  │ • Write │  │         │          │ │   │
│   │   │   │ • Delete│  │         │  │         │          │ │   │
│   │   │   │ • Share │  │         │  │         │          │ │   │
│   │   │   │ • Admin │  │         │  │         │          │ │   │
│   │   │   └─────────┘  └─────────┘  └─────────┘          │ │   │
│   │   │                                                    │ │   │
│   │   └───────────────────────────────────────────────────┘ │   │
│   │                                                          │   │
│   │   Permission Inheritance:                                │   │
│   │   Root Folder → Subfolder → File                         │   │
│   │        ↓            ↓          ↓                         │   │
│   │     owner        inherited   inherited                   │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                  Security Measures                       │   │
│   │                                                          │   │
│   │  Transport:           Application:         Data:         │   │
│   │  • TLS 1.2/1.3       • Rate limiting      • Encryption   │   │
│   │  • HTTPS only        • CSRF protection    • at rest      │   │
│   │  • HSTS headers      • XSS prevention     • Bcrypt       │   │
│   │                      • Input validation    • passwords   │   │
│   │                      • Output encoding     • S3 signed   │   │
│   │                      • Security headers    • URLs        │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Request Flow Through Security Layers

```
┌─────────────────────────────────────────────────────────────────┐
│              Request Flow Through Security Layers                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Incoming Request                                               │
│         │                                                        │
│         ▼                                                        │
│   ┌─────────────┐                                                │
│   │ Cloudflare  │  DDoS Protection, WAF, SSL Termination         │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                                │
│   │   Nginx     │  Reverse Proxy, Additional SSL, Rate Limit     │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                                │
│   │   CORS      │  Cross-Origin Request Validation               │
│   │ Middleware  │                                                │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                                │
│   │  Security   │  X-Frame-Options, CSP, XSS Protection          │
│   │  Headers    │                                                │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                                │
│   │Rate Limiter │  5 auth attempts / 15 min                      │
│   │             │  100 API requests / min                        │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                                │
│   │    Auth     │  JWT Verification, User Context                │
│   │ Middleware  │                                                │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                                │
│   │  Input      │  Zod Schema Validation, Sanitization           │
│   │ Validation  │                                                │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                                │
│   │   Route     │  Business Logic                                │
│   │  Handler    │                                                │
│   └──────┬──────┘                                                │
│          │                                                       │
│          ▼                                                       │
│   Response                                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Security Checklist

| Layer | Measure | Status |
|-------|---------|--------|
| Transport | TLS 1.2+ | ✅ |
| Transport | HTTPS redirect | ✅ |
| Transport | HSTS headers | ✅ |
| Application | Rate limiting | ✅ |
| Application | CORS policy | ✅ |
| Application | Input validation | ✅ |
| Application | XSS prevention | ✅ |
| Application | CSRF protection | ✅ |
| Data | Password hashing (bcrypt) | ✅ |
| Data | Encryption at rest (Storj) | ✅ |
| Data | Signed URLs for S3 | ✅ |

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| Login attempts | 5 per 15 min |
| Registration | 3 per hour |
| API requests | 100 per min |
| File uploads | 20 per min |
