# PreSocial - Architecture Documentation

## Overview

PreSocial is a **standalone social layer** for the PreSuite/Presearch ecosystem that provides federated community discussions via [Lemmy](https://join-lemmy.org/) (an open-source, federated Reddit alternative). It operates as an independent service within PreSuite, offering users authentic community insights and discussions.

**Status:** Standalone service (not integrated into SERP)
**Purpose:** Provide community-driven insights and discussions as a dedicated PreSuite application.

**Live URL:** https://presocial.presuite.eu
**Lemmy Instance:** https://lemmy.world (primary)
**GitHub Repository:** https://github.com/tijnski/presocial
**Server:** `ssh root@76.13.2.221` → `/opt/presocial`

> **Future Integration:** SERP integration may be added later as a three-column layout enhancement.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PreSocial System                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                     Three-Column SERP Layout                             │   │
│   │                                                                          │   │
│   │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐   │   │
│   │  │   Web Results    │  │  PreSocial Panel │  │   PTAs (160x600)     │   │   │
│   │  │                  │  │                  │  │                      │   │   │
│   │  │  Standard SERP   │  │  • Discussions   │  │  Promoted Text Ads   │   │   │
│   │  │  results from    │  │  • Comments      │  │  (Skyscraper format) │   │   │
│   │  │  presearch-web   │  │  • Community     │  │                      │   │   │
│   │  │                  │  │    insights      │  │                      │   │   │
│   │  │                  │  │  • Related posts │  │                      │   │   │
│   │  └──────────────────┘  └──────────────────┘  └──────────────────────┘   │   │
│   │                                                                          │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                        │                                         │
│                                        │ REST API                                │
│                                        ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                         PreSocial Backend (Hono)                         │   │
│   │                                                                          │   │
│   │  ┌──────────────────────────────────────────────────────────────────┐   │   │
│   │  │                         Middleware                                │   │   │
│   │  │   CORS  │  RateLimiter  │  Cache  │  Logger  │  Auth (optional)  │   │   │
│   │  └──────────────────────────────────────────────────────────────────┘   │   │
│   │                                                                          │   │
│   │  ┌────────────────────────────────────────────────────────────────────┐ │   │
│   │  │                          API Routes                                 │ │   │
│   │  │                                                                     │ │   │
│   │  │  GET  /api/social/search?q=<query>     - Search community posts     │ │   │
│   │  │  GET  /api/social/post/:id             - Get post with comments     │ │   │
│   │  │  GET  /api/social/communities          - List relevant communities  │ │   │
│   │  │  GET  /api/social/trending             - Trending discussions       │ │   │
│   │  │  POST /api/social/vote                 - Vote on post (auth req)    │ │   │
│   │  │  GET  /api/social/votes                - Get user's votes (auth)    │ │   │
│   │  │  POST /api/social/bookmark             - Save/unsave post (auth)    │ │   │
│   │  │  GET  /api/social/bookmarks            - Get saved posts (auth)     │ │   │
│   │  │  GET  /api/social/bookmark/:postId     - Check if saved (auth)      │ │   │
│   │  │  GET  /api/social/health               - Health check               │ │   │
│   │  │                                                                     │ │   │
│   │  └────────────────────────────────────────────────────────────────────┘ │   │
│   │                                                                          │   │
│   │  ┌──────────────────────────────────────────────────────────────────┐   │   │
│   │  │                      Service Layer                                │   │   │
│   │  │                                                                   │   │   │
│   │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │   │   │
│   │  │  │  Lemmy API   │  │   Search     │  │      Cache           │   │   │   │
│   │  │  │   Client     │  │   Service    │  │   (Redis/Memory)     │   │   │   │
│   │  │  │              │  │              │  │                      │   │   │   │
│   │  │  │ • Posts      │  │ • Query      │  │ • Query results      │   │   │   │
│   │  │  │ • Comments   │  │   parsing    │  │ • Post cache         │   │   │   │
│   │  │  │ • Communities│  │ • Relevance  │  │ • Rate limit state   │   │   │   │
│   │  │  │ • Users      │  │   scoring    │  │                      │   │   │   │
│   │  │  └──────────────┘  └──────────────┘  └──────────────────────┘   │   │   │
│   │  │                                                                   │   │   │
│   │  └──────────────────────────────────────────────────────────────────┘   │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                        │                                         │
│                                        │ Lemmy API                               │
│                                        ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                        External: Lemmy Federation                        │   │
│   │                                                                          │   │
│   │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐   │   │
│   │  │  lemmy.world     │  │  Self-hosted     │  │  Other Lemmy         │   │   │
│   │  │  (Primary)       │  │  (Fallback)      │  │  Instances           │   │   │
│   │  │                  │  │                  │  │  (Federation)        │   │   │
│   │  └──────────────────┘  └──────────────────┘  └──────────────────────┘   │   │
│   │                                                                          │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

### Frontend (Standalone App)
- **Framework:** React 18 + Vite
- **Styling:** Tailwind CSS with Dark Glass theme
- **Routing:** React Router DOM
- **Icons:** Lucide React

### Backend
- **Runtime:** Node.js 20+ (with @hono/node-server)
- **Framework:** Hono (consistent with PreDrive/PreMail)
- **Cache:** In-memory LRU cache
- **Process Manager:** PM2

### External Services
- **Lemmy API:** lemmy.world (via lemmy-js-client)
- **Authentication:** PreSuite Hub JWT

---

## Project Structure

```
PreSocial/
├── apps/
│   ├── api/                    # Backend API
│   │   ├── src/
│   │   │   ├── api/
│   │   │   │   ├── index.ts           # Hono app entry
│   │   │   │   ├── routes/social.ts   # API routes
│   │   │   │   └── middleware/        # Rate limiting
│   │   │   ├── services/
│   │   │   │   ├── lemmy.ts           # Lemmy API client
│   │   │   │   └── cache.ts           # Caching layer
│   │   │   └── types/index.ts
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
│       │   │   └── PostSkeleton.jsx
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
│       │       └── authService.js     # PreSuite auth
│       └── package.json
│
├── package.json                # Root workspace
└── ecosystem.config.cjs        # PM2 config
```

---

## Lemmy API Integration

### Core Endpoints Used

| Lemmy Endpoint | PreSocial Usage |
|----------------|-----------------|
| `GET /api/v3/search` | Search posts by query |
| `GET /api/v3/post/list` | List posts from communities |
| `GET /api/v3/post` | Get single post with details |
| `GET /api/v3/comment/list` | Get comments for a post |
| `GET /api/v3/community/list` | List relevant communities |
| `POST /api/v3/post/like` | Upvote/downvote post |
| `POST /api/v3/comment` | Create comment |

### Lemmy Client Service

```typescript
// src/services/lemmy-client.ts
import { LemmyHttp } from 'lemmy-js-client';

export class LemmyService {
  private client: LemmyHttp;
  private instanceUrl: string;

  constructor(instanceUrl = 'https://lemmy.world') {
    this.instanceUrl = instanceUrl;
    this.client = new LemmyHttp(instanceUrl);
  }

  async searchPosts(query: string, options?: SearchOptions) {
    return this.client.search({
      q: query,
      type_: 'Posts',
      sort: 'TopAll',
      limit: options?.limit || 10,
    });
  }

  async getPost(postId: number) {
    return this.client.getPost({ id: postId });
  }

  async getComments(postId: number) {
    return this.client.getComments({
      post_id: postId,
      sort: 'Top',
      limit: 20,
    });
  }

  async getCommunities(query?: string) {
    return this.client.listCommunities({
      type_: 'All',
      sort: 'TopAll',
      limit: 20,
    });
  }
}
```

---

## Data Flow

### Search Query Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   Search Query Data Flow                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   User searches "best laptop 2025"                               │
│         │                                                        │
│         ▼                                                        │
│   ┌─────────────┐                                                │
│   │ presearch-  │  1. Standard search query                      │
│   │ web SERP    │                                                │
│   └──────┬──────┘                                                │
│          │                                                       │
│          │  Parallel requests                                    │
│          ├───────────────────────────────────────┐               │
│          │                                       │               │
│          ▼                                       ▼               │
│   ┌─────────────┐                        ┌─────────────┐         │
│   │  Web Search │                        │  PreSocial  │         │
│   │  (standard) │                        │   API       │         │
│   └──────┬──────┘                        └──────┬──────┘         │
│          │                                      │                │
│          │                                      ▼                │
│          │                               ┌─────────────┐         │
│          │                               │  Cache      │         │
│          │                               │  Check      │         │
│          │                               └──────┬──────┘         │
│          │                                      │                │
│          │                          ┌───────────┴───────────┐    │
│          │                          │                       │    │
│          │                    Cache HIT              Cache MISS  │
│          │                          │                       │    │
│          │                          ▼                       ▼    │
│          │                   Return cached           Query Lemmy │
│          │                                                  │    │
│          │                                                  ▼    │
│          │                                           ┌──────────┐│
│          │                                           │ Relevance││
│          │                                           │ Scoring  ││
│          │                                           └────┬─────┘│
│          │                                                │      │
│          │                                                ▼      │
│          │                                           Store cache │
│          │                                                │      │
│          └────────────────────────────────────────────────┼──────┘
│                                                           │
│                              ▼                            │
│   ┌─────────────────────────────────────────────────────────────┐
│   │                  Combined Results Page                       │
│   │                                                              │
│   │  [Web Results]     [Community Insights]     [PTAs]          │
│   │                                                              │
│   └─────────────────────────────────────────────────────────────┘
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Frontend Components

### PreSocial Panel Component

```javascript
// PreSocial Alpine.js component for SERP integration
window.preSocialPanel = () => ({
  state: {
    loading: true,
    error: null,
    posts: [],
    communities: [],
    expanded: false,
  },

  async init() {
    const urlParams = new URLSearchParams(window.location.search);
    const query = urlParams.get('q');

    if (query) {
      await this.fetchCommunityInsights(query);
    }
  },

  async fetchCommunityInsights(query) {
    this.state.loading = true;
    this.state.error = null;

    try {
      const response = await fetch(`/api/social/search?q=${encodeURIComponent(query)}`);
      const data = await response.json();

      this.state.posts = data.posts || [];
      this.state.communities = data.communities || [];
    } catch (err) {
      this.state.error = 'Failed to load community insights';
    } finally {
      this.state.loading = false;
    }
  },

  toggleExpand() {
    this.state.expanded = !this.state.expanded;
  },

  formatTimestamp(timestamp) {
    const date = new Date(timestamp);
    return date.toLocaleDateString();
  },

  formatVotes(score) {
    if (score >= 1000) return `${(score / 1000).toFixed(1)}k`;
    return score.toString();
  },
});
```

### UI Design (Dark Glass Theme)

```html
<!-- PreSocial Panel Template -->
<div x-data="preSocialPanel()"
     class="presocial-panel bg-dark-800/80 backdrop-blur-xl rounded-xl border border-white/10 p-4">

  <!-- Header -->
  <div class="flex items-center justify-between mb-4">
    <div class="flex items-center gap-2">
      <svg class="w-5 h-5 text-presearch-default" fill="currentColor" viewBox="0 0 24 24">
        <!-- Community icon -->
      </svg>
      <h3 class="text-white font-semibold text-sm">Community Insights</h3>
    </div>
    <span class="text-xs text-gray-400">Powered by Lemmy</span>
  </div>

  <!-- Loading State -->
  <template x-if="state.loading">
    <div class="flex items-center justify-center py-8">
      <div class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
    </div>
  </template>

  <!-- Posts List -->
  <template x-if="!state.loading && !state.error">
    <div class="space-y-3">
      <template x-for="post in state.posts.slice(0, state.expanded ? 10 : 3)" :key="post.id">
        <div class="presocial-post bg-dark-700/50 rounded-lg p-3 hover:bg-dark-600/50 transition-colors cursor-pointer">
          <!-- Post Title -->
          <a :href="post.url" target="_blank" rel="noopener"
             class="text-sm font-medium text-white hover:text-presearch-default line-clamp-2"
             x-text="post.title">
          </a>

          <!-- Post Meta -->
          <div class="flex items-center gap-3 mt-2 text-xs text-gray-400">
            <span class="flex items-center gap-1">
              <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                <!-- Upvote icon -->
              </svg>
              <span x-text="formatVotes(post.score)"></span>
            </span>
            <span class="flex items-center gap-1">
              <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                <!-- Comment icon -->
              </svg>
              <span x-text="post.commentCount + ' comments'"></span>
            </span>
            <span x-text="'c/' + post.community"></span>
          </div>
        </div>
      </template>

      <!-- Show More Button -->
      <button @click="toggleExpand()"
              x-show="state.posts.length > 3"
              class="w-full py-2 text-xs text-presearch-default hover:text-white transition-colors">
        <span x-text="state.expanded ? 'Show less' : 'Show more discussions'"></span>
      </button>
    </div>
  </template>

  <!-- Error State -->
  <template x-if="state.error">
    <div class="text-center py-4 text-gray-400 text-sm" x-text="state.error"></div>
  </template>

</div>
```

---

## Standalone Application Layout

PreSocial operates as an independent application within PreSuite, accessible from the PreSuite dashboard.

### Application Structure

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                          PreSocial Standalone App                               │
│                        https://presocial.presuite.eu                            │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  PreSuite Header (logo, search, user menu)                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌──────────────────────┬──────────────────────────────────────────────────┐   │
│  │                      │                                                   │   │
│  │   Sidebar            │   Main Content Area                               │   │
│  │   (~280px)           │   (flex)                                          │   │
│  │                      │                                                   │   │
│  │  ┌────────────────┐  │  ┌────────────────────────────────────────────┐  │   │
│  │  │ Search Box     │  │  │  Tab Navigation                            │  │   │
│  │  └────────────────┘  │  │  [Feed] [Trending] [Communities] [Saved]   │  │   │
│  │                      │  └────────────────────────────────────────────┘  │   │
│  │  Communities         │                                                   │   │
│  │  ┌────────────────┐  │  ┌────────────────────────────────────────────┐  │   │
│  │  │ c/technology   │  │  │  Post Card                                 │  │   │
│  │  │ c/privacy      │  │  │  ┌──────────────────────────────────────┐  │  │   │
│  │  │ c/hardware     │  │  │  │ Title                                 │  │  │   │
│  │  │ c/programming  │  │  │  │ c/community · author · 2h ago        │  │  │   │
│  │  │ ...            │  │  │  │                                       │  │  │   │
│  │  └────────────────┘  │  │  │ Preview text or thumbnail...          │  │  │   │
│  │                      │  │  │                                       │  │  │   │
│  │  Trending Topics     │  │  │ ▲ 234  💬 56 comments                 │  │  │   │
│  │  ┌────────────────┐  │  │  └──────────────────────────────────────┘  │  │   │
│  │  │ • AI news      │  │  └────────────────────────────────────────────┘  │   │
│  │  │ • Tech layoffs │  │                                                   │   │
│  │  │ • Privacy laws │  │  ┌────────────────────────────────────────────┐  │   │
│  │  └────────────────┘  │  │  Post Card 2...                            │  │   │
│  │                      │  └────────────────────────────────────────────┘  │   │
│  │                      │                                                   │   │
│  └──────────────────────┴──────────────────────────────────────────────────┘   │
│                                                                                 │
└────────────────────────────────────────────────────────────────────────────────┘
```

### Future: SERP Integration (Planned)

A three-column SERP layout may be added in a future phase to show community insights alongside search results. This would maintain PTAs in the right column (160x600 skyscraper format) while adding a PreSocial panel between results and ads.

---

## API Specification

### Endpoints

#### GET /api/social/search

Search for community discussions relevant to the query.

**Request:**
```
GET /api/social/search?q=best+laptop+2025&limit=10
```

**Response:**
```json
{
  "query": "best laptop 2025",
  "posts": [
    {
      "id": 12345,
      "title": "What's the best laptop for programming in 2025?",
      "url": "https://lemmy.world/post/12345",
      "score": 234,
      "commentCount": 87,
      "community": "technology",
      "communityIcon": "https://...",
      "author": "username",
      "timestamp": "2025-01-10T14:30:00Z",
      "thumbnail": "https://...",
      "excerpt": "I'm looking for a new laptop..."
    }
  ],
  "communities": [
    {
      "name": "technology",
      "title": "Technology",
      "icon": "https://...",
      "subscribers": 45000,
      "url": "https://lemmy.world/c/technology"
    }
  ],
  "meta": {
    "totalResults": 156,
    "cached": true,
    "cacheAge": 300
  }
}
```

#### GET /api/social/post/:id

Get a single post with its comments.

**Response:**
```json
{
  "post": {
    "id": 12345,
    "title": "What's the best laptop...",
    "body": "Full post content...",
    "score": 234,
    "author": "username",
    "community": "technology",
    "timestamp": "2025-01-10T14:30:00Z"
  },
  "comments": [
    {
      "id": 67890,
      "content": "I recommend the...",
      "score": 45,
      "author": "commenter",
      "timestamp": "2025-01-10T15:00:00Z",
      "replies": [...]
    }
  ]
}
```

#### POST /api/social/vote

Vote on a post (requires authentication).

**Request:**
```
POST /api/social/vote
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "postId": 12345,
  "vote": "up"  // "up", "down", or "none"
}
```

**Response:**
```json
{
  "success": true,
  "postId": 12345,
  "vote": "up",
  "previousVote": null,
  "scoreChange": 1
}
```

#### GET /api/social/votes

Get all votes for the authenticated user.

**Request:**
```
GET /api/social/votes
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "votes": {
    "12345": "up",
    "67890": "down"
  }
}
```

#### GET /api/social/trending

Get trending discussions (cached, updated hourly).

**Response:**
```json
{
  "trending": [
    {
      "id": 12345,
      "title": "Trending post title",
      "community": "news",
      "score": 1500,
      "hot_rank": 9500
    }
  ]
}
```

#### POST /api/social/bookmark

Toggle save/unsave a post (requires authentication).

**Request:**
```
POST /api/social/bookmark
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "postId": 12345,
  "post": {
    "id": 12345,
    "title": "Post title",
    "url": "https://lemmy.world/post/12345",
    "score": 234,
    "commentCount": 87,
    "community": "technology",
    "author": "username",
    "timestamp": "2025-01-10T14:30:00Z",
    "thumbnail": "https://...",
    "excerpt": "Preview text..."
  }
}
```

**Response:**
```json
{
  "success": true,
  "postId": 12345,
  "saved": true
}
```

> Note: The `post` object is required when saving (not when unsaving). The endpoint toggles the bookmark state.

#### GET /api/social/bookmarks

Get all saved posts for the authenticated user.

**Request:**
```
GET /api/social/bookmarks
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "bookmarks": [
    {
      "id": 12345,
      "title": "Saved post title",
      "url": "https://lemmy.world/post/12345",
      "score": 234,
      "commentCount": 87,
      "community": "technology",
      "author": "username",
      "timestamp": "2025-01-10T14:30:00Z",
      "thumbnail": "https://...",
      "excerpt": "Preview text...",
      "savedAt": "2026-01-16T15:30:00Z"
    }
  ],
  "count": 1
}
```

#### GET /api/social/bookmark/:postId

Check if a specific post is bookmarked.

**Request:**
```
GET /api/social/bookmark/12345
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "postId": 12345,
  "saved": true
}
```

---

## Caching Strategy

### Cache Layers

1. **Query Cache (5 min TTL)**
   - Key: `presocial:search:<hash(query)>`
   - Caches full search results
   - Reduces Lemmy API calls

2. **Post Cache (15 min TTL)**
   - Key: `presocial:post:<post_id>`
   - Caches individual posts
   - Updates on user interaction

3. **Community Cache (1 hour TTL)**
   - Key: `presocial:communities`
   - Caches community list
   - Updated hourly

### Redis Implementation

```typescript
// src/services/cache.ts
import { Redis } from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export const cache = {
  async get<T>(key: string): Promise<T | null> {
    const data = await redis.get(key);
    return data ? JSON.parse(data) : null;
  },

  async set(key: string, value: any, ttlSeconds: number): Promise<void> {
    await redis.setex(key, ttlSeconds, JSON.stringify(value));
  },

  async invalidate(pattern: string): Promise<void> {
    const keys = await redis.keys(pattern);
    if (keys.length) await redis.del(...keys);
  },
};
```

---

## Authentication

PreSocial uses PreSuite Hub for centralized authentication.

### Implementation

**Frontend Auth Flow:**
1. User clicks "Sign In" in header
2. Redirected to `/login` page
3. Credentials sent to `https://presuite.eu/api/auth/login`
4. JWT token stored in localStorage
5. AuthContext provides user state to components

**Key Files:**
- `apps/web/src/services/authService.js` - Auth API client
- `apps/web/src/context/AuthContext.jsx` - React context
- `apps/web/src/pages/LoginPage.jsx` - Login/Register UI
- `apps/web/src/components/Header.jsx` - User menu

### Auth Features
- [x] Sign in with PreSuite credentials
- [x] Register new accounts
- [x] User avatar with initials
- [x] Sign out
- [x] Session persistence (localStorage)
- [x] Token verification on page load

### Authenticated Features
- [x] Vote on posts (upvote/downvote with visual feedback)
- [x] Save/bookmark posts (yellow highlight when saved)
- [x] View saved posts page (/saved)
- [ ] Comment on discussions (via Lemmy bot account)
- [ ] Save favorite communities

---

## Privacy Considerations

1. **No User Tracking:** Search queries are not logged with user identifiers
2. **Anonymous by Default:** All features work without authentication
3. **Federated:** Data lives on Lemmy instances, not PreSuite servers
4. **Caching Privacy:** Cached data contains no user-specific information
5. **GDPR Compliant:** No personal data stored without consent

---

## Deployment

### Production Server

| Property | Value |
|----------|-------|
| Server | `76.13.2.221` (shared with PreSuite Hub) |
| SSH | `ssh root@76.13.2.221` |
| Path | `/opt/presocial` |
| Process | PM2 (`presocial-api`) |
| Port | 3002 (API) |
| Domain | presocial.presuite.eu |

### Deploy Commands

```bash
# Full deployment
ssh root@76.13.2.221 "cd /opt/presocial && git pull && cd apps/web && npm run build && pm2 restart presocial-api"

# Check status
ssh root@76.13.2.221 "pm2 status presocial-api"

# View logs
ssh root@76.13.2.221 "pm2 logs presocial-api --lines 50"

# Health check
curl https://presocial.presuite.eu/health
```

### Environment Variables

```bash
# Server
PORT=3002
NODE_ENV=production

# Lemmy
LEMMY_INSTANCE_URL=https://lemmy.world

# Rate Limiting
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX=100
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

### PM2 Ecosystem

```javascript
// ecosystem.config.cjs
module.exports = {
  apps: [{
    name: 'presocial-api',
    script: 'npx',
    args: 'tsx apps/api/src/index.ts',
    cwd: '/opt/presocial',
    instances: 1,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3002,
      LEMMY_INSTANCE_URL: 'https://lemmy.world'
    }
  }]
};
```

---

## Integration with PreSuite Dashboard

PreSocial integrates with PreSuite Hub as a standalone application tile.

### PreSuite Dashboard Integration

```javascript
// In PreSuite's AppModal.jsx or dashboard
const preSuiteApps = [
  // ... existing apps
  {
    id: 'presocial',
    name: 'PreSocial',
    icon: 'MessageCircle',
    color: '#8B5CF6', // Purple
    url: 'https://presocial.presuite.eu',
    description: 'Community discussions',
  },
];
```

### Access from PreSuite

1. User logs into PreSuite Hub (presuite.eu)
2. PreSocial appears as an app tile on the dashboard
3. Click opens PreSocial in same window or new tab
4. JWT token shared for authenticated features

---

## Roadmap

### Phase 1: Standalone MVP ✅
- [x] Basic Lemmy API integration
- [x] Search endpoint with caching
- [x] Standalone app architecture
- [x] Dark Glass styled UI (React + Tailwind)
- [x] PreSuite dashboard integration
- [x] Production deployment (presocial.presuite.eu)

### Phase 2: Core Features ✅
- [x] Post browsing and search
- [x] Community discovery
- [x] Trending discussions
- [x] Mobile-responsive design

### Phase 3: Interactions ✅
- [x] PreSuite auth integration (login/register via PreSuite Hub)
- [x] Voting capability (upvote/downvote with optimistic updates)
- [x] Save/bookmark discussions (with Saved page)
- [ ] Comment viewing

### Phase 4: Advanced Features (Future)
- [ ] Self-hosted Lemmy instance
- [ ] Presearch-specific communities
- [ ] SERP integration (three-column layout)
- [ ] AI-powered relevance scoring
- [ ] Real-time updates via WebSocket

---

## Related Documents

- [PreSuite Architecture](PRESUITE.md)
- [UI Patterns](UIPatterns-PresearchWeb.md)
- [Integration Guide](INTEGRATION.md)
- [Lemmy API Docs](https://join-lemmy.org/api/)

---

*Last updated: January 16, 2026*
*Status: Production - Live at https://presocial.presuite.eu*
*Features: Authentication, Voting, Bookmarks*
