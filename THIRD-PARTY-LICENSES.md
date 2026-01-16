# Third-Party Licenses

> **Purpose:** Document licenses for third-party software used in PreSuite
> **Last Updated:** January 16, 2026

---

## Overview

PreSuite relies on various open-source components. This document lists key dependencies and their licenses to ensure compliance.

---

## Infrastructure Components

| Component | License | Used By | Compliance Notes |
|-----------|---------|---------|------------------|
| **Stalwart Mail Server** | AGPLv3 | PreMail | See AGPLv3 section below |
| **PostgreSQL** | PostgreSQL License | All services | Permissive, similar to MIT |
| **Nginx** | BSD-2-Clause | PreMail, PreOffice | Permissive |
| **Caddy** | Apache 2.0 | PreDrive | Permissive |
| **Collabora Online (CODE)** | MPL 2.0 | PreOffice | Copyleft for modified files only |
| **Lemmy** | AGPLv3 | PreSocial | External API only, no modifications |
| **Redis/Valkey** | BSD-3-Clause | PreDrive, PreSocial | Permissive |

---

## AGPLv3 License - Important Notes

### Stalwart Mail Server

Stalwart Community Edition is released under **AGPLv3**. Key implications:

1. **Unmodified Use:** If you use Stalwart without modifications, you can deploy it freely without source disclosure requirements.

2. **Modified Use:** If you modify Stalwart's source code AND deploy it as a network service (like PreMail does), you must:
   - Make your modifications available under AGPLv3
   - Provide access to the modified source code
   - Include license and copyright notices

3. **Current PreSuite Status:** PreMail uses Stalwart **unmodified** - we configure it via its admin API but don't modify the source code. This means no AGPLv3 disclosure requirements apply.

4. **If Modifications Are Needed:**
   - Document all changes
   - Publish modified source code
   - Link to source in application (e.g., `/licenses` endpoint)

### Lemmy

PreSocial uses Lemmy's public API (lemmy.world) but does not run a Lemmy instance. No AGPLv3 obligations apply since we're only consuming the API, not distributing or modifying Lemmy software.

---

## MPL 2.0 License - Collabora Online

Collabora Online (CODE) is MPL 2.0 licensed:

- **File-level copyleft:** Only modified files must remain MPL 2.0
- **Larger work:** Can combine with proprietary code
- **Current Status:** PreOffice uses CODE via Docker without modifications
- **If Modified:** Changed files must be released under MPL 2.0

---

## Frontend Dependencies

All PreSuite frontend applications use permissively-licensed libraries:

| Library | License | Notes |
|---------|---------|-------|
| React | MIT | Permissive |
| Vite | MIT | Permissive |
| Tailwind CSS | MIT | Permissive |
| Hono | MIT | Permissive |
| Drizzle ORM | Apache 2.0 | Permissive |
| Lucide Icons | ISC | Permissive |
| ImapFlow | MIT | Permissive |
| Nodemailer | MIT | Permissive |

---

## External Services

| Service | Terms | Notes |
|---------|-------|-------|
| **Storj** | Commercial ToS | S3-compatible storage, pay-per-use |
| **Venice AI** | Commercial ToS | AI API for PreGPT |
| **Lemmy.world** | AGPLv3 (software) | Public instance, API usage only |
| **Let's Encrypt** | ISRG ToS | Free SSL certificates |
| **Cloudflare** | Commercial ToS | DNS and CDN |

---

## PreSuite License Summary

| Service | Our License | Key Dependencies |
|---------|-------------|------------------|
| PreSuite Hub | MIT | React, Express, PostgreSQL |
| PreDrive | Proprietary | Hono, PostgreSQL, Storj |
| PreMail | MIT | Hono, Stalwart (AGPLv3), PostgreSQL |
| PreOffice | MPL 2.0 / MIT | Collabora (MPL 2.0), Express |
| PreSocial | MIT | Hono, Lemmy API |
| ARC (this repo) | MIT | Documentation only |

---

## Compliance Checklist

- [x] Stalwart used unmodified (no AGPLv3 disclosure needed)
- [x] Collabora used via Docker unmodified (no MPL 2.0 disclosure needed)
- [x] Lemmy API only, no server deployment (no AGPLv3 applies)
- [x] All frontend deps are MIT/Apache/ISC (permissive)
- [ ] Add `/licenses` endpoint to each service (future enhancement)
- [ ] Generate SBOM for each release (future enhancement)

---

## Related Documentation

- [PREMAIL.md](PREMAIL.md) - Stalwart configuration
- [PREOFFICE.md](PREOFFICE.md) - Collabora configuration
- [PRESOCIAL.md](PRESOCIAL.md) - Lemmy integration
- [Stalwart License](https://stalw.art/docs/development/license/) - Official docs
- [AGPLv3 Full Text](https://www.gnu.org/licenses/agpl-3.0.html)
