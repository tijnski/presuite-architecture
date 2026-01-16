# PreOffice Architecture

**URL:** https://preoffice.site
**Server:** 76.13.2.220

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PreOffice System                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                              Nginx Proxy                                 │   │
│   │                                                                          │   │
│   │   /              → Static landing page                                   │   │
│   │   /browser/*     → Collabora static files                                │   │
│   │   /cool/*        → Collabora WebSocket                                   │   │
│   │   /wopi/*        → WOPI Server                                           │   │
│   │   /api/*         → API Server                                            │   │
│   │   /oauth/callback → OAuth callback (landing page)                        │   │
│   │                                                                          │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                    │                                │                            │
│                    ▼                                ▼                            │
│   ┌────────────────────────────┐    ┌────────────────────────────────────────┐  │
│   │      WOPI Server (Bun)     │    │         Collabora Online              │  │
│   │                            │    │                                        │  │
│   │  ┌──────────────────────┐  │    │  ┌──────────────────────────────────┐ │  │
│   │  │    WOPI Endpoints    │  │    │  │        Document Editor           │ │  │
│   │  │                      │  │    │  │                                  │ │  │
│   │  │ CheckFileInfo        │  │    │  │  • Writer (Documents)            │ │  │
│   │  │ GetFile              │◄─┼────┼─►│  • Calc (Spreadsheets)           │ │  │
│   │  │ PutFile              │  │    │  │  • Impress (Presentations)       │ │  │
│   │  │ PutRelativeFile      │  │    │  │                                  │ │  │
│   │  │ Lock/Unlock          │  │    │  │  Real-time collaboration         │ │  │
│   │  │                      │  │    │  │  via WebSocket                   │ │  │
│   │  └──────────────────────┘  │    │  │                                  │ │  │
│   │                            │    │  └──────────────────────────────────┘ │  │
│   │  ┌──────────────────────┐  │    │                                        │  │
│   │  │    API Endpoints     │  │    │  Configuration:                        │  │
│   │  │                      │  │    │  • server_name: preoffice.site         │  │
│   │  │ POST /api/open       │  │    │  • ssl.enable: false (nginx handles)   │  │
│   │  │   → Generate WOPI URL│  │    │  • storage.wopi.host: wopi:8080        │  │
│   │  │                      │  │    │                                        │  │
│   │  └──────────────────────┘  │    └────────────────────────────────────────┘  │
│   │                            │                                                 │
│   │  ┌──────────────────────┐  │                                                 │
│   │  │   Storage Backends   │  │                                                 │
│   │  │                      │  │                                                 │
│   │  │  • Local filesystem  │  │                                                 │
│   │  │  • PreDrive (WOPI)   │◄─┼─────────────────────────────────────────────┐  │
│   │  │                      │  │                                             │  │
│   │  └──────────────────────┘  │                                             │  │
│   └────────────────────────────┘                                             │  │
│                                                                              │  │
└──────────────────────────────────────────────────────────────────────────────┼──┘
                                                                               │
                          ┌────────────────────────────────────────────────────┘
                          │
                          ▼
           ┌────────────────────────────┐
           │         PreDrive           │
           │                            │
           │   WOPI Integration:        │
           │   • CheckFileInfo          │
           │   • GetFile                │
           │   • PutFile                │
           │                            │
           │   Files stored in Storj    │
           └────────────────────────────┘
```

## WOPI Protocol Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      WOPI Document Open Flow                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Browser          PreOffice         Collabora        PreDrive    │
│     │                │                  │                │       │
│     │ 1. Open file   │                  │                │       │
│     │   from Drive   │                  │                │       │
│     │───────────────>│                  │                │       │
│     │                │                  │                │       │
│     │                │ 2. POST /api/open                 │       │
│     │                │    {fileId, accessToken}          │       │
│     │                │──────────────────────────────────>│       │
│     │                │                  │                │       │
│     │                │                  │  3. Validate   │       │
│     │                │                  │     token      │       │
│     │                │                  │                │       │
│     │                │ 4. Return WOPI URL                │       │
│     │                │<──────────────────────────────────│       │
│     │                │                  │                │       │
│     │ 5. Redirect to │                  │                │       │
│     │    Collabora   │                  │                │       │
│     │    with WOPI   │                  │                │       │
│     │<───────────────│                  │                │       │
│     │                │                  │                │       │
│     │ 6. Load editor │                  │                │       │
│     │───────────────────────────────────>│                │       │
│     │                │                  │                │       │
│     │                │                  │ 7. CheckFileInfo       │
│     │                │                  │───────────────>│       │
│     │                │                  │                │       │
│     │                │                  │ 8. File info   │       │
│     │                │                  │<───────────────│       │
│     │                │                  │                │       │
│     │                │                  │ 9. GetFile     │       │
│     │                │                  │───────────────>│       │
│     │                │                  │                │       │
│     │                │                  │ 10. File data  │       │
│     │                │                  │<───────────────│       │
│     │                │                  │                │       │
│     │ 11. Document   │                  │                │       │
│     │     loaded     │                  │                │       │
│     │<───────────────────────────────────│                │       │
│     │                │                  │                │       │
│     │  [User edits document...]          │                │       │
│     │                │                  │                │       │
│     │                │                  │ 12. PutFile    │       │
│     │                │                  │    (auto-save) │       │
│     │                │                  │───────────────>│       │
│     │                │                  │                │       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## WOPI Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/wopi/files/:id` | GET | CheckFileInfo - file metadata |
| `/wopi/files/:id/contents` | GET | GetFile - download content |
| `/wopi/files/:id/contents` | POST | PutFile - save changes |
| `/wopi/files/:id` | POST | Lock/Unlock operations |

## Document Types

| Type | Extension | Editor |
|------|-----------|--------|
| Document | .odt, .docx | Writer |
| Spreadsheet | .ods, .xlsx | Calc |
| Presentation | .odp, .pptx | Impress |
| Drawing | .odg | Draw |
