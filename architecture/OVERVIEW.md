# High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PreSuite Ecosystem                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│    ┌──────────────┐                                                              │
│    │   Browser    │                                                              │
│    │    (User)    │                                                              │
│    └──────┬───────┘                                                              │
│           │                                                                      │
│           │ HTTPS                                                                │
│           ▼                                                                      │
│    ┌─────────────────────────────────────────────────────────────────────┐      │
│    │                        Cloudflare CDN/DNS                            │      │
│    │         (SSL Termination, DDoS Protection, Caching)                  │      │
│    └─────────────────────────────────────────────────────────────────────┘      │
│           │                                                                      │
│           ▼                                                                      │
│    ┌─────────────────────────────────────────────────────────────────────┐      │
│    │                         Load Balancer / Nginx                        │      │
│    └───┬─────────────┬─────────────┬─────────────┬───────────────────────┘      │
│        │             │             │             │                               │
│        ▼             ▼             ▼             ▼                               │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐                        │
│   │PreSuite │  │ PreMail │  │PreDrive │  │  PreOffice  │                        │
│   │   Hub   │  │         │  │         │  │             │                        │
│   │  (IdP)  │  │ (Email) │  │(Storage)│  │   (Docs)    │                        │
│   └────┬────┘  └────┬────┘  └────┬────┘  └──────┬──────┘                        │
│        │            │            │              │                                │
│        └────────────┴─────┬──────┴──────────────┘                                │
│                           │                                                      │
│                           ▼                                                      │
│    ┌─────────────────────────────────────────────────────────────────────┐      │
│    │                      Shared Infrastructure                           │      │
│    │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐    │      │
│    │  │PostgreSQL│  │  Storj   │  │Typesense │  │ Stalwart Mail    │    │      │
│    │  │    DB    │  │(S3 Store)│  │ (Search) │  │(IMAP/SMTP Server)│    │      │
│    │  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘    │      │
│    └─────────────────────────────────────────────────────────────────────┘      │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Service Responsibilities

| Service | Role | Key Features |
|---------|------|--------------|
| **PreSuite Hub** | Identity Provider | User auth, JWT issuance, Web3 wallet auth, dashboard |
| **PreMail** | Email Service | IMAP/SMTP via Stalwart, threading, labels |
| **PreDrive** | Cloud Storage | Files, folders, sharing, Storj backend |
| **PreOffice** | Document Editing | Collabora Online, WOPI protocol, PrePanda AI |
| **PreSocial** | Community Platform | Lemmy-powered discussions, voting, bookmarks |

## Ports Reference

| Service | Port | Protocol |
|---------|------|----------|
| HTTPS | 443 | TLS |
| HTTP (redirect) | 80 | TCP |
| PostgreSQL | 5432 | TCP |
| Typesense | 8108 | HTTP |
| IMAP | 993 | TLS |
| SMTP | 587 | STARTTLS |
| Collabora | 9980 | HTTP |
| WOPI | 8080 | HTTP |
