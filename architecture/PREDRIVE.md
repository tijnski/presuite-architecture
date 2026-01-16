# PreDrive Architecture

**URL:** https://predrive.eu
**Server:** 76.13.1.110

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PreDrive System                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                         Frontend (React + Vite)                          │   │
│   │                                                                          │   │
│   │  ┌────────────────────────────────────────────────────────────────────┐ │   │
│   │  │                        File Browser UI                              │ │   │
│   │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │ │   │
│   │  │  │ Toolbar  │  │ Sidebar  │  │ FileList │  │  Preview Panel   │   │ │   │
│   │  │  │          │  │ (Tree)   │  │ (Grid/   │  │  (Documents,     │   │ │   │
│   │  │  │ Upload   │  │          │  │  List)   │  │   Images, etc)   │   │ │   │
│   │  │  │ NewFolder│  │          │  │          │  │                  │   │ │   │
│   │  │  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘   │ │   │
│   │  └────────────────────────────────────────────────────────────────────┘ │   │
│   │                                                                          │   │
│   │  ┌────────────────────────────────────────────────────────────────────┐ │   │
│   │  │                    State & Hooks                                    │ │   │
│   │  │   useAuth │ useNodes │ useUpload │ useShare │ usePermissions       │ │   │
│   │  └────────────────────────────────────────────────────────────────────┘ │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                        │                                         │
│                                        │ HTTP/REST                               │
│                                        ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                         Backend (Hono + Bun)                             │   │
│   │                                                                          │   │
│   │  ┌──────────────────────────────────────────────────────────────────┐   │   │
│   │  │                         Middleware                                │   │   │
│   │  │   JWT Auth │ CORS │ Request Logger │ Error Handler                │   │   │
│   │  └──────────────────────────────────────────────────────────────────┘   │   │
│   │                                                                          │   │
│   │  ┌────────────────────────────────────────────────────────────────────┐ │   │
│   │  │                          API Routes                                 │ │   │
│   │  │                                                                     │ │   │
│   │  │  /api/nodes          - CRUD operations on files/folders            │ │   │
│   │  │  /api/nodes/:id/content - Upload/download file content             │ │   │
│   │  │  /api/shares         - Public/private share management             │ │   │
│   │  │  /api/permissions    - Access control management                   │ │   │
│   │  │  /api/trash          - Soft delete and restore                     │ │   │
│   │  │  /wopi/files/:id     - WOPI protocol for PreOffice                 │ │   │
│   │  │                                                                     │ │   │
│   │  └────────────────────────────────────────────────────────────────────┘ │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                        │                                         │
│           ┌────────────────────────────┴────────────────────────────┐           │
│           │                                                         │           │
│           ▼                                                         ▼           │
│   ┌────────────────────┐                                 ┌────────────────────┐ │
│   │    PostgreSQL      │                                 │       Storj        │ │
│   │     Database       │                                 │   (S3-Compatible)  │ │
│   │                    │                                 │                    │ │
│   │  ┌──────────────┐  │                                 │  ┌──────────────┐  │ │
│   │  │    nodes     │  │                                 │  │   Buckets    │  │ │
│   │  │  (metadata)  │  │                                 │  │              │  │ │
│   │  │              │  │      Presigned URLs             │  │  predrive-   │  │ │
│   │  │ • id         │  │  ◄──────────────────────────►   │  │  files       │  │ │
│   │  │ • name       │  │                                 │  │              │  │ │
│   │  │ • type       │  │                                 │  │  (encrypted  │  │ │
│   │  │ • parentId   │  │                                 │  │   at rest)   │  │ │
│   │  │ • orgId      │  │                                 │  │              │  │ │
│   │  │ • storageKey │  │                                 │  └──────────────┘  │ │
│   │  │ • size       │  │                                 │                    │ │
│   │  │ • mimeType   │  │                                 └────────────────────┘ │
│   │  └──────────────┘  │                                                        │
│   │                    │                                                        │
│   │  ┌──────────────┐  │                                                        │
│   │  │ permissions  │  │                                                        │
│   │  │ • nodeId     │  │                                                        │
│   │  │ • principal  │  │                                                        │
│   │  │ • role       │  │                                                        │
│   │  └──────────────┘  │                                                        │
│   │                    │                                                        │
│   │  ┌──────────────┐  │                                                        │
│   │  │   shares     │  │                                                        │
│   │  │ • nodeId     │  │                                                        │
│   │  │ • token      │  │                                                        │
│   │  │ • expiresAt  │  │                                                        │
│   │  └──────────────┘  │                                                        │
│   └────────────────────┘                                                        │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## File Upload Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      File Upload Flow                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Browser                    API                     Storj       │
│      │                        │                        │         │
│      │  1. POST /api/nodes    │                        │         │
│      │     {name, parentId,   │                        │         │
│      │      type: "file"}     │                        │         │
│      │ ──────────────────────>│                        │         │
│      │                        │                        │         │
│      │                        │  2. Create node in DB  │         │
│      │                        │     Generate storageKey│         │
│      │                        │                        │         │
│      │                        │  3. Generate presigned │         │
│      │                        │     PUT URL            │         │
│      │                        │ ──────────────────────>│         │
│      │                        │                        │         │
│      │                        │ <──────────────────────│         │
│      │                        │     Presigned URL      │         │
│      │                        │                        │         │
│      │  4. Return uploadUrl   │                        │         │
│      │ <──────────────────────│                        │         │
│      │                        │                        │         │
│      │  5. PUT file directly  │                        │         │
│      │     to Storj           │                        │         │
│      │ ───────────────────────────────────────────────>│         │
│      │                        │                        │         │
│      │  6. Upload complete    │                        │         │
│      │ <───────────────────────────────────────────────│         │
│      │                        │                        │         │
│      │  7. PATCH /api/nodes/:id                        │         │
│      │     {status: "ready"}  │                        │         │
│      │ ──────────────────────>│                        │         │
│      │                        │                        │         │
│      │                        │  8. Update node status │         │
│      │                        │                        │         │
│      │  9. Success response   │                        │         │
│      │ <──────────────────────│                        │         │
│      │                        │                        │         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

- **Direct Upload:** Files go directly to Storj via presigned URLs
- **Tree Structure:** Hierarchical folder organization
- **Soft Delete:** Files moved to trash before permanent deletion
- **Sharing:** Public links with optional password/expiry
- **WOPI:** Integration with PreOffice for document editing
