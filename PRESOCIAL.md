# PreSocial - Architecture Documentation

## Overview

PreSocial is a **standalone social layer** for the PreSuite/Presearch ecosystem that provides federated community discussions via [Lemmy](https://join-lemmy.org/) (an open-source, federated Reddit alternative). It operates as an independent service within PreSuite, offering users authentic community insights and discussions.

**Status:** Standalone service (not integrated into SERP)
**Purpose:** Provide community-driven insights and discussions as a dedicated PreSuite application.

**Live URL:** https://presocial.presuite.eu
**Lemmy Instance:** https://lemmy.world (primary)
**GitHub Repository:** https://github.com/tijnski/presocial
**Server:** `ssh root@76.13.2.221` → `/opt/presocial`

---

## Tech Stack

### Frontend (apps/web)

| Package | Version | Purpose |
|---------|---------|---------|
| React | 18.3.1 | UI framework |
| Vite | 5.4.11 | Build tool |
| React Router DOM | 6.28.0 | Routing |
| TailwindCSS | 3.4.17 | Styling (Dark Glass theme) |
| Lucide React | 0.468.0 | Icons |
| **date-fns** | 4.1.0 | Date formatting |
| **ethers** | 6.16.0 | Web3 wallet integration |

### Backend (apps/api)

| Component | Technology | Notes |
|-----------|------------|-------|
| **Runtime** | **Bun** | Primary runtime (NOT Node.js) |
| Framework | Hono | Lightweight web framework |
| Cache | In-memory LRU + Redis (optional) | Falls back to in-memory if Redis unavailable |
| **Storage** | File-based JSON | Persistent votes/bookmarks in `/data` |
| Auth | JWT (local or remote) | PreSuite Hub integration |

**Note:** While the code imports `@hono/node-server` for compatibility, Bun is the primary runtime as shown in `package.json` scripts.

### External Services

| Service | Purpose |
|---------|---------|
| Lemmy API (lemmy.world) | Community discussions via lemmy-js-client |
| PreSuite Hub | JWT authentication |

---

## Project Structure

```
PreSocial/
├── apps/
│   ├── api/                    # Backend API (Bun + Hono)
│   │   ├── src/
│   │   │   ├── api/
│   │   │   │   ├── index.ts           # Hono app entry
│   │   │   │   ├── routes/social.ts   # API routes
│   │   │   │   └── middleware/
│   │   │   │       ├── auth.ts        # JWT verification
│   │   │   │       └── rateLimit.ts   # Rate limiting
│   │   │   ├── services/
│   │   │   │   ├── lemmy.ts           # Lemmy API client
│   │   │   │   ├── cache.ts           # Caching layer
│   │   │   │   └── storage.ts         # Persistent file storage
│   │   │   ├── types/index.ts
│   │   │   └── index.ts               # Entry point (re-exports api)
│   │   └── package.json
│   │
│   └── web/                    # Frontend React app
│       ├── src/
│       │   ├── App.jsx
│       │   ├── main.jsx
│       │   ├── components/
│       │   │   ├── Header.jsx         # Nav with auth
│       │   │   ├── Layout.jsx
│       │   │   ├── Sidebar.jsx
│       │   │   ├── PostCard.jsx
│       │   │   ├── PostSkeleton.jsx
│       │   │   └── CommentForm.jsx    # Comment submission
│       │   ├── pages/
│       │   │   ├── FeedPage.jsx
│       │   │   ├── TrendingPage.jsx
│       │   │   ├── CommunitiesPage.jsx
│       │   │   ├── SearchPage.jsx
│       │   │   ├── PostPage.jsx
│       │   │   ├── LoginPage.jsx
│       │   │   └── SavedPage.jsx      # Bookmarked posts
│       │   ├── context/
│       │   │   ├── AuthContext.jsx    # Auth state
│       │   │   ├── VoteContext.jsx    # Vote state
│       │   │   └── BookmarkContext.jsx # Bookmark state
│       │   └── services/
│       │       ├── preSocialService.js
│       │       ├── authService.js     # PreSuite auth
│       │       └── web3Auth.js        # Web3 wallet auth
│       └── package.json
│
├── package.json                # Root workspace (Bun scripts)
├── tsconfig.json
└── .env.example
```

---

## Persistent Storage

PreSocial uses file-based storage for user votes and bookmarks. This persists data across restarts without requiring a database.

### Storage Files

| File | Purpose |
|------|---------|
| `data/votes.json` | User votes by post ID |
| `data/bookmarks.json` | Saved posts with metadata |

### Storage Configuration

```bash
# Directory for storage files (default: ./data)
STORAGE_DIR=/opt/presocial/data
```

### Storage Features

- **Auto-save:** Data saved every 5 seconds when modified
- **Graceful shutdown:** Data saved on SIGINT/SIGTERM
- **In-memory + disk:** Fast reads with persistent writes
- **Per-user isolation:** Votes/bookmarks keyed by user ID

### Storage API (internal)

```typescript
// services/storage.ts
getUserVotes(userId: string): Map<number, 'up' | 'down'>
setUserVote(userId: string, postId: number, vote: 'up' | 'down' | null): void
getUserBookmarks(userId: string): Map<number, SavedPost>
addUserBookmark(userId: string, post: SavedPost): void
removeUserBookmark(userId: string, postId: number): boolean
isPostBookmarked(userId: string, postId: number): boolean
getUserBookmarksList(userId: string): SavedPost[]
getStorageStats(): { users: number; totalVotes: number; totalBookmarks: number }
```

---

## API Specification

All routes are mounted at `/api/social/`.

### Public Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/social/search?q=<query>` | Search community posts |
| GET | `/api/social/post/:id` | Get post with comments |
| GET | `/api/social/communities` | List communities |
| GET | `/api/social/trending` | Trending discussions |
| GET | `/api/social/health` | Health check |
| GET | `/api/social/comment/status` | Check if commenting is enabled |

### Authenticated Endpoints (require JWT)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/social/vote` | Vote on post (up/down/none) |
| GET | `/api/social/votes` | Get user's votes |
| POST | `/api/social/bookmark` | Save/unsave post |
| GET | `/api/social/bookmarks` | Get saved posts |
| GET | `/api/social/bookmark/:postId` | Check if post is saved |
| POST | `/api/social/comment` | Post comment (via Lemmy bot) |

### Endpoint Details

#### GET /api/social/search

```
GET /api/social/search?q=best+laptop+2025&limit=10&sort=TopAll
```

Query parameters:
- `q` (required): Search query (1-500 chars)
- `limit` (optional): Results per page (1-50, default: 10)
- `page` (optional): Page number (1-100, default: 1)
- `sort` (optional): TopAll, TopYear, TopMonth, TopWeek, TopDay, Hot, New
- `community` (optional): Filter by community name

Response:
```json
{
  "query": "best laptop 2025",
  "posts": [...],
  "communities": [...],
  "meta": {
    "totalResults": 156,
    "cached": true,
    "processingTime": 45
  }
}
```

#### POST /api/social/vote

```
POST /api/social/vote
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "postId": 12345,
  "vote": "up"  // "up", "down", or "none"
}
```

Response:
```json
{
  "success": true,
  "postId": 12345,
  "vote": "up",
  "previousVote": null,
  "scoreChange": 1
}
```

#### POST /api/social/comment

```
POST /api/social/comment
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "postId": 12345,
  "content": "Great discussion!",
  "parentId": 67890  // optional, for replies
}
```

Response:
```json
{
  "success": true,
  "comment": {
    "id": 99999,
    "content": "Great discussion!",
    "author": "presocial_bot",
    "timestamp": "2026-01-17T10:00:00Z"
  }
}
```

**Note:** Comments are posted via a Lemmy bot account. Configure `LEMMY_BOT_USERNAME` and `LEMMY_BOT_PASSWORD` to enable.

#### GET /api/social/comment/status

Check if commenting is enabled (Lemmy bot configured).

Response:
```json
{
  "enabled": true,
  "botAccount": "presocial_bot"
}
```

---

## Authentication

PreSocial supports two JWT verification modes:

### 1. Local Verification (Recommended)

When `JWT_SECRET` is configured, tokens are verified locally without network calls.

```bash
JWT_SECRET=<same-as-presuite-hub>
JWT_ISSUER=presuite  # optional, default: presuite
```

### 2. Remote Verification (Fallback)

If `JWT_SECRET` is not set, tokens are verified via PreSuite Hub API.

```bash
AUTH_API_URL=https://presuite.eu/api/auth
```

### Web3 Authentication

The frontend includes Web3 wallet support via `ethers`:

```javascript
// services/web3Auth.js
connectWallet()     // Connect MetaMask
getNonce(address)   // Get signing nonce
signMessage(nonce)  // Sign with wallet
verifySignature()   // Verify signature
```

---

## Caching Strategy

### Cache Layers

| Cache | TTL | Purpose |
|-------|-----|---------|
| Search results | 5 min | Reduce Lemmy API calls |
| Posts | 15 min | Individual post cache |
| Communities | 1 hour | Community list |
| Trending | 30 min | Trending discussions |

### Cache Implementation

```typescript
// services/cache.ts
const CACHE_TTL = {
  SEARCH: 300,      // 5 minutes
  POST: 900,        // 15 minutes
  COMMUNITIES: 3600, // 1 hour
  TRENDING: 1800,   // 30 minutes
};

cacheGet<T>(key: string): Promise<T | null>
cacheSet(key: string, value: any, ttlSeconds: number): Promise<void>
generateSearchKey(query: string, options: object): string
getCacheStats(): Promise<{ hits: number; misses: number; size: number }>
```

### Redis Support (Optional)

If `REDIS_URL` is configured, Redis is used for caching. Otherwise, falls back to in-memory LRU cache.

```bash
REDIS_URL=redis://localhost:6379
```

---

## Deployment

### Production Server

| Property | Value |
|----------|-------|
| Server | `76.13.2.221` (shared with PreSuite Hub) |
| SSH | `ssh root@76.13.2.221` |
| Path | `/opt/presocial` |
| Port | 3002 (API) |
| Domain | presocial.presuite.eu |

### Deploy Commands (Bun)

```bash
# Full deployment
ssh root@76.13.2.221 "cd /opt/presocial && git pull && cd apps/web && npm run build && cd ../.. && bun run start"

# Development
cd /opt/presocial
bun run dev        # Run API + Web concurrently
bun run dev:api    # API only (with --watch)
bun run dev:web    # Web only

# Build
bun run build      # Build API + Web
bun run build:api  # API only (outputs to dist/)
bun run build:web  # Web only

# Production
bun run start      # Run built API
```

### Systemd Service (Recommended for Production)

```ini
# /etc/systemd/system/presocial.service
[Unit]
Description=PreSocial API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/presocial
ExecStart=/root/.bun/bin/bun run start
Restart=on-failure
Environment=NODE_ENV=production
Environment=PORT=3002

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
systemctl enable presocial
systemctl start presocial

# View logs
journalctl -u presocial -f
```

### Environment Variables

```bash
# Server
PORT=3002
NODE_ENV=production

# Lemmy Instance
LEMMY_INSTANCE_URL=https://lemmy.world

# Lemmy Bot (for posting comments)
LEMMY_BOT_USERNAME=presocial_bot
LEMMY_BOT_PASSWORD=<bot-password>

# Persistent Storage
STORAGE_DIR=/opt/presocial/data

# Redis Cache (optional)
REDIS_URL=redis://localhost:6379

# Rate Limiting
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX=100

# PreSuite Auth
JWT_SECRET=<same-as-presuite>
JWT_ISSUER=presuite
AUTH_API_URL=https://presuite.eu/api/auth

# Debug
PRESOCIAL_DEBUG=true
```

### Nginx Configuration

```nginx
server {
    server_name presocial.presuite.eu;

    # Frontend (static files)
    root /opt/presocial/apps/web/dist;
    index index.html;

    # API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:3002;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health endpoint
    location /health {
        proxy_pass http://127.0.0.1:3002;
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/presocial.presuite.eu/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/presocial.presuite.eu/privkey.pem;
}
```

---

## Frontend Components

### Pages

| Page | Path | Description |
|------|------|-------------|
| FeedPage | `/` | Main feed view |
| TrendingPage | `/trending` | Trending posts |
| CommunitiesPage | `/communities` | Browse communities |
| SearchPage | `/search` | Search results |
| PostPage | `/post/:id` | Single post with comments |
| LoginPage | `/login` | Authentication |
| SavedPage | `/saved` | Bookmarked posts |

### Context Providers

```javascript
// AuthContext.jsx
const { user, isAuthenticated, login, logout } = useAuth();

// VoteContext.jsx
const { votes, vote, getUserVote } = useVotes();

// BookmarkContext.jsx
const { bookmarks, isBookmarked, toggleBookmark } = useBookmarks();
```

### Components

| Component | Purpose |
|-----------|---------|
| Header.jsx | Navigation bar with auth |
| Layout.jsx | Page layout wrapper |
| Sidebar.jsx | Community/trending sidebar |
| PostCard.jsx | Post preview card |
| PostSkeleton.jsx | Loading state |
| CommentForm.jsx | Comment submission form |

---

## Lemmy API Integration

### Core Endpoints Used

| Lemmy Endpoint | PreSocial Usage |
|----------------|-----------------|
| `GET /api/v3/search` | Search posts by query |
| `GET /api/v3/post/list` | List posts from communities |
| `GET /api/v3/post` | Get single post |
| `GET /api/v3/comment/list` | Get comments for a post |
| `GET /api/v3/community/list` | List communities |
| `POST /api/v3/comment` | Create comment (bot account) |
| `GET /api/v3/site` | Get instance info |

### Lemmy Client Service

```typescript
// services/lemmy.ts
class LemmyService {
  searchPosts(query: string, options?: SearchOptions): Promise<Post[]>
  getPost(postId: number): Promise<Post | null>
  getComments(postId: number, limit?: number): Promise<Comment[]>
  listCommunities(query?: string, limit?: number): Promise<Community[]>
  getTrending(limit?: number): Promise<Post[]>
  getInstanceInfo(): Promise<{ name: string; version: string } | null>
  createComment(postId: number, content: string, parentId?: number, attribution?: string): Promise<Comment | null>
  getBotUsername(): string | null
}
```

---

## Features Status

### Implemented

- [x] Post browsing and search
- [x] Community discovery
- [x] Trending discussions
- [x] PreSuite auth integration (login/register)
- [x] Voting (upvote/downvote with optimistic updates)
- [x] Bookmarking (save/unsave posts)
- [x] Comment viewing (nested threads, collapsible)
- [x] **Comment posting** (via Lemmy bot account)
- [x] Persistent storage (votes, bookmarks)
- [x] Web3 wallet authentication
- [x] Mobile-responsive design

### Planned

- [ ] Self-hosted Lemmy instance
- [ ] Presearch-specific communities
- [ ] SERP integration (three-column layout)
- [ ] AI-powered relevance scoring
- [ ] Real-time updates via WebSocket
- [ ] Save favorite communities

---

## Privacy Considerations

1. **No User Tracking:** Search queries are not logged with user identifiers
2. **Anonymous by Default:** All read features work without authentication
3. **Federated:** Data lives on Lemmy instances, not PreSuite servers
4. **Local Storage:** Votes/bookmarks stored locally, not sent to Lemmy
5. **GDPR Compliant:** No personal data stored without consent

---

## Related Documents

- [PreSuite Architecture](PRESUITE.md)
- [UI Patterns](UIPatterns-PresearchWeb.md)
- [Integration Guide](INTEGRATION.md)
- [API Reference](API-REFERENCE.md)
- [Lemmy API Docs](https://join-lemmy.org/api/)

---

*Last updated: January 17, 2026*
*Status: Production - Live at https://presocial.presuite.eu*
*Runtime: Bun (not Node.js)*
