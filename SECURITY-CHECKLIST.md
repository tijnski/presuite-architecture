# PreSuite Security Checklist

> **Purpose:** Security audit checklist for PreSuite ecosystem
> **Last Updated:** January 20, 2026

---

## OWASP Top 10 Checklist

### A01:2021 - Broken Access Control

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| Role-based access control implemented | All | ✅ | owner/editor/viewer/commenter roles |
| JWT token validation on all protected routes | All | ✅ | Verified via middleware |
| Cross-user data access prevention | PreDrive | ✅ | orgId + userId checks |
| Cross-user data access prevention | PreMail | ✅ | accountId + userId checks |
| Admin functions protected | PreSuite | ✅ | Role checks in place |
| CORS properly configured | All | ✅ | Allow-list of origins |
| Directory traversal prevention | PreDrive | ✅ | Path sanitization |

### A02:2021 - Cryptographic Failures

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| HTTPS enforced | All | ✅ | TLS 1.2+ required |
| Passwords hashed (bcrypt) | PreSuite | ✅ | bcrypt with cost 12 |
| JWT secrets not hardcoded | All | ✅ | Environment variables |
| Sensitive data encrypted at rest | PreDrive | ✅ | BYOK encryption available |
| Mail passwords encrypted | PreMail | ✅ | Encrypted in database |

### A03:2021 - Injection

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| SQL injection prevention (parameterized) | All | ✅ | Drizzle ORM parameterized |
| NoSQL injection prevention | N/A | N/A | PostgreSQL only |
| Command injection prevention | All | ✅ | No shell exec from user input |
| XSS prevention | All | ✅ | React escapes by default |
| Content Security Policy | All | ⚠️ | Needs headers |

### A04:2021 - Insecure Design

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| Rate limiting on auth endpoints | PreSuite | ✅ | 5 req/min login, 3 req/min register |
| Rate limiting on API endpoints | All | ✅ | 1000/15min general |
| Business logic validation | All | ✅ | Zod schemas |
| Share access limits | PreDrive | ✅ | max_downloads, max_views |

### A05:2021 - Security Misconfiguration

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| Debug mode disabled in production | All | ✅ | NODE_ENV=production |
| Default credentials changed | All | ✅ | Custom JWT secrets |
| Error messages don't leak info | All | ✅ | Generic error responses |
| Security headers configured | All | ⚠️ | Check nginx config |
| Unnecessary features disabled | All | ✅ | Minimal attack surface |

### A06:2021 - Vulnerable Components

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| npm audit clean | PreSuite | 🔄 | Run `npm audit` |
| npm audit clean | PreDrive | 🔄 | Run `npm audit` |
| npm audit clean | PreMail | 🔄 | Run `npm audit` |
| Dependencies up to date | All | 🔄 | Run `npm outdated` |
| Known vulnerabilities checked | All | 🔄 | Use security script |

### A07:2021 - Identity & Authentication Failures

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| Password complexity requirements | PreSuite | ✅ | Min 8 chars, special char |
| Brute force protection | PreSuite | ✅ | Rate limiting |
| Session timeout | PreSuite | ✅ | 7-day token expiry |
| Session invalidation on logout | PreSuite | ✅ | Token revocation |
| MFA available | PreSuite | ✅ | TOTP + backup codes |
| Secure password reset | PreSuite | ✅ | Token-based |
| Web3 signature verification | PreSuite | ✅ | ethers.js verification |

### A08:2021 - Software & Data Integrity Failures

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| JWT signature verification | All | ✅ | HS256 with shared secret |
| File upload validation | PreDrive | ✅ | MIME type checking |
| Webhook signature verification | PreMail | ⚠️ | Postal RSA pending |
| CI/CD pipeline security | All | 🔄 | Review GitHub Actions |

### A09:2021 - Security Logging & Monitoring

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| Auth events logged | PreSuite | ✅ | auth_events table |
| API access logged | All | ✅ | activity_logs |
| Failed login attempts logged | PreSuite | ✅ | With IP address |
| Log retention policy | All | ⚠️ | Define policy |
| Alerting on suspicious activity | All | ⚠️ | Configure alerts |

### A10:2021 - Server-Side Request Forgery (SSRF)

| Check | Service | Status | Notes |
|-------|---------|--------|-------|
| URL validation on user input | All | ✅ | No user-controlled URLs |
| Restrict outbound connections | All | ✅ | Only known services |
| DNS rebinding protection | All | ✅ | Fixed hostnames |

---

## Additional Security Checks

### Authentication & Sessions

| Check | Status | Notes |
|-------|--------|-------|
| Secure cookie flags (HttpOnly, Secure, SameSite) | ⚠️ | Verify in browser |
| CSRF protection | ✅ | SameSite cookies |
| Session fixation prevention | ✅ | New token on login |
| Concurrent session limit | ⚠️ | Consider implementing |

### API Security

| Check | Status | Notes |
|-------|--------|-------|
| Input validation (Zod schemas) | ✅ | All endpoints |
| Output encoding | ✅ | JSON responses |
| API versioning | ✅ | /api/v1/ prefix |
| Request size limits | ✅ | body-parser limits |
| File upload size limits | ✅ | 10GB max |

### Infrastructure

| Check | Status | Notes |
|-------|--------|-------|
| Firewall rules | ⚠️ | Review server config |
| SSH key-only access | ✅ | No password auth |
| Database not publicly accessible | ✅ | Docker internal network |
| Secrets management | ✅ | Environment variables |
| Backup encryption | ⚠️ | Verify backup process |

### Security Headers (nginx)

```nginx
# Recommended headers for all services
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

---

## Running Security Audit

```bash
# Run automated security audit
./scripts/security-audit.sh

# Run npm audit on specific service
cd presuite && npm audit

# Check for outdated packages
npm outdated

# Generate security report
npm audit --json > security-report.json
```

---

## Penetration Testing Scope

### In Scope

| Target | Type | Notes |
|--------|------|-------|
| presuite.eu | Web App | Auth, OAuth, API |
| premail.site | Web App | Email operations |
| predrive.eu | Web App | File operations |
| preoffice.site | Web App | WOPI, AI chat |
| presocial.presuite.eu | Web App | Social features |
| */api/* | API | All endpoints |
| */webdav | WebDAV | PreDrive only |

### Out of Scope

- DDoS attacks
- Physical attacks
- Social engineering
- Third-party services (Storj, Stalwart, Collabora)
- Production data modification

---

## Incident Response

### Contact

- **Security Issues:** security@presuite.eu (if configured)
- **GitHub Issues:** https://github.com/tijnski/presuite/issues

### Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| Critical | Active exploitation, data breach | Immediate |
| High | Exploitable vulnerability | 24 hours |
| Medium | Potential vulnerability | 1 week |
| Low | Security improvement | 1 month |

---

## Compliance Notes

- [ ] GDPR data handling review
- [ ] Privacy policy up to date
- [ ] Terms of service reviewed
- [ ] Cookie consent implemented
- [ ] Data retention policy defined
- [ ] Right to erasure (GDPR Art. 17) implemented

---

*Last security audit: [DATE]*
*Next scheduled audit: [DATE + 30 days]*
