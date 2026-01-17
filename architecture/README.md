# PreSuite Architecture Documentation

> **Last Updated:** January 17, 2026

This directory contains detailed architecture diagrams and documentation for the PreSuite ecosystem.

## Contents

| File | Description |
|------|-------------|
| [OVERVIEW.md](OVERVIEW.md) | High-level system architecture and quick reference |
| [OAUTH-SSO.md](OAUTH-SSO.md) | OAuth 2.0 SSO flow and token structure |
| [PREMAIL.md](PREMAIL.md) | PreMail email service architecture |
| [PREDRIVE.md](PREDRIVE.md) | PreDrive cloud storage architecture |
| [PREOFFICE.md](PREOFFICE.md) | PreOffice document editing (WOPI/Collabora) |
| [INFRASTRUCTURE.md](INFRASTRUCTURE.md) | Server layout and Docker deployments |
| [DATA-FLOWS.md](DATA-FLOWS.md) | Email send/receive and collaboration flows |
| [SECURITY.md](SECURITY.md) | Authentication, authorization, and security layers |

## Quick Reference

### Service URLs

| Service | URL | Server |
|---------|-----|--------|
| PreSuite Hub | https://presuite.eu | 76.13.2.221 |
| PreMail | https://premail.site | 76.13.1.117 |
| PreDrive | https://predrive.eu | 76.13.1.110 |
| PreOffice | https://preoffice.site | 76.13.2.220 |
| PreSocial | https://presocial.presuite.eu | 76.13.2.221 |

### Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | React, Vite, TypeScript, TailwindCSS |
| Backend | Bun, Hono, TypeScript |
| Database | PostgreSQL 16, Drizzle ORM |
| Search | Typesense |
| Storage | Storj (S3-compatible) |
| Mail Server | Stalwart Mail |
| Documents | Collabora Online (CODE) |
