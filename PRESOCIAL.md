# PreSocial - Architecture Documentation

## Overview

PreSocial is a **standalone social layer** for the PreSuite/Presearch ecosystem that provides federated community discussions via [Lemmy](https://join-lemmy.org/) (an open-source, federated Reddit alternative). It operates as an independent service within PreSuite, offering users authentic community insights and discussions.

**Status:** Standalone service (not integrated into SERP)
**Purpose:** Provide community-driven insights and discussions as a dedicated PreSuite application.

**Live URL:** https://presocial.presuite.eu (planned)
**Lemmy Instance:** https://lemmy.world (primary) / Self-hosted fallback
**GitHub Repository:** https://github.com/tijnski/presocial

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
│   │  │  POST /api/social/comment              - Add comment (auth req)     │ │   │
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

### Frontend (SERP Integration)
- **Framework:** Vanilla JS + Alpine.js (matches presearch-web)
- **Styling:** Tailwind CSS with Dark Glass theme
- **Component Library:** Custom PreSocial components

### Backend
- **Runtime:** Bun / Node.js 20+
- **Framework:** Hono (consistent with PreDrive/PreMail)
- **Database:** PostgreSQL (for caching, user preferences)
- **Cache:** Redis or in-memory LRU cache
- **Process Manager:** PM2 or Docker

### External Services
- **Lemmy API:** lemmy.world (primary instance)
- **Authentication:** PreSuite Hub JWT (optional for voting/commenting)

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

## Authentication (Optional)

PreSocial supports optional authentication through PreSuite Hub for users who want to:
- Vote on posts
- Comment on discussions
- Save favorite communities

### Auth Flow

```
User wants to vote → Check PreSuite JWT → Valid? →
  → YES: Link PreSuite account to Lemmy bot account → Execute action
  → NO: Prompt login via PreSuite Hub
```

### Lemmy Bot Account

For authenticated actions, PreSocial uses a bot account on lemmy.world:
- Bot performs actions on behalf of verified PreSuite users
- Actions are rate-limited per user
- No direct Lemmy account creation required

---

## Privacy Considerations

1. **No User Tracking:** Search queries are not logged with user identifiers
2. **Anonymous by Default:** All features work without authentication
3. **Federated:** Data lives on Lemmy instances, not PreSuite servers
4. **Caching Privacy:** Cached data contains no user-specific information
5. **GDPR Compliant:** No personal data stored without consent

---

## Deployment

### Server Requirements

| Resource | Specification |
|----------|---------------|
| CPU | 2 vCPUs |
| RAM | 4 GB |
| Storage | 20 GB SSD |
| OS | Ubuntu 24.04 |

### Environment Variables

```bash
# Server
PORT=3002
NODE_ENV=production

# Lemmy
LEMMY_INSTANCE_URL=https://lemmy.world
LEMMY_BOT_USERNAME=presocial_bot
LEMMY_BOT_PASSWORD=<secret>

# Cache
REDIS_URL=redis://localhost:6379

# Auth (optional)
JWT_SECRET=<same-as-presuite>
AUTH_API_URL=https://presuite.eu/api/auth

# Rate Limiting
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX=100
```

### Docker Compose

```yaml
version: '3.8'

services:
  presocial-api:
    build: .
    ports:
      - "3002:3002"
    environment:
      - NODE_ENV=production
      - LEMMY_INSTANCE_URL=https://lemmy.world
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    restart: unless-stopped

volumes:
  redis-data:
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

### Phase 1: Standalone MVP
- [x] Basic Lemmy API integration
- [x] Search endpoint with caching
- [x] Standalone app architecture
- [ ] Dark Glass styled UI
- [ ] PreSuite dashboard integration

### Phase 2: Core Features
- [ ] Post browsing and search
- [ ] Community discovery
- [ ] Trending discussions
- [ ] Mobile-responsive design

### Phase 3: Interactions
- [ ] PreSuite auth integration
- [ ] Voting capability (via bot account)
- [ ] Save/bookmark discussions
- [ ] Comment viewing

### Phase 4: Advanced Features (Future)
- [ ] Self-hosted Lemmy instance (presocial.presuite.eu)
- [ ] Presearch-specific communities
- [ ] SERP integration (three-column layout)
- [ ] AI-powered relevance scoring
- [ ] Real-time updates via WebSocket

---

## Related Documents

- [PreSuite Architecture](presuite.md)
- [UI Patterns](UIPatterns-PresearchWeb.md)
- [Integration Guide](INTEGRATION.md)
- [Lemmy API Docs](https://join-lemmy.org/api/)

---

*Last updated: January 16, 2026*
