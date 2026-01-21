# Global Search Implementation

> **Status:** Deployed to production (January 21, 2026)
> **Services:** PreSuite Hub, PreDrive, PreMail

---

## Overview

Unified search across PreSuite services that searches PreDrive (files) and PreMail (emails) with live results as the user types.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PreSuite Hub (presuite.eu)               │
│                                                             │
│  SearchBar.jsx ──▶ globalSearchService.js ──▶ /api/search  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                   Promise.allSettled()
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
     ┌─────────────────┐             ┌─────────────────┐
     │    PreDrive     │             │    PreMail      │
     │  predrive.eu    │             │  premail.site   │
     │                 │             │                 │
     │ /api/search?q=  │             │ /api/v1/search  │
     └─────────────────┘             └─────────────────┘
```

---

## API Reference

### GET /api/search

**Base URL:** `https://presuite.eu/api/search`

**Authentication:** Required (Bearer token)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `q` | string | Yes | Search query (minimum 2 characters) |

**Response:**
```json
{
  "files": [
    {
      "id": "uuid",
      "name": "document.pdf",
      "type": "file",
      "mime": "application/pdf",
      "updatedAt": "2026-01-21T10:00:00Z"
    }
  ],
  "emails": [
    {
      "id": "uuid",
      "subject": "Meeting notes",
      "from": {
        "name": "John Doe",
        "address": "john@example.com"
      },
      "date": "2026-01-21T09:00:00Z",
      "preview": "Here are the notes from..."
    }
  ],
  "query": "meeting"
}
```

**Error Responses:**
| Status | Body | Description |
|--------|------|-------------|
| 400 | `{"error": "Query must be at least 2 characters"}` | Query too short |
| 401 | `{"error": {"code": "TOKEN_MISSING", "message": "Authorization required"}}` | Not authenticated |
| 500 | `{"error": "Search failed"}` | Internal error |

---

## Files Modified

### Backend

| File | Location | Changes |
|------|----------|---------|
| `server.js` | `/var/www/presuite/server.js` | Added `/api/search` endpoint (~50 lines) |

**Code location:** After PreGPT routes, before Presearch Integration routes (~line 3475)

### Frontend

| File | Location | Changes |
|------|----------|---------|
| `globalSearchService.js` | `src/services/globalSearchService.js` | New file - API client (~30 lines) |
| `SearchBar.jsx` | `src/components/SearchBar.jsx` | Added state, search logic, results UI (~80 lines) |

---

## Frontend Behavior

### Search Flow

1. User types in SearchBar
2. After 300ms debounce, if query >= 2 characters and user is authenticated:
   - `globalSearch(query)` is called
   - Results displayed in dropdown below Presearch suggestions
3. Clicking a result opens it in a new tab:
   - Files: `https://predrive.eu/files/{id}`
   - Emails: `https://premail.site/mail/{id}`

### State Variables

```javascript
const [globalResults, setGlobalResults] = useState({ files: [], emails: [] });
const [showGlobalResults, setShowGlobalResults] = useState(false);
const [searchError, setSearchError] = useState(null);
```

### UI Components

- **Files Section:** Icon + filename, links to PreDrive
- **Emails Section:** Icon + subject + sender name, links to PreMail
- Styled for both light and dark mode
- Positioned below Presearch autocomplete suggestions

---

## Testing

### API Test (without auth)
```bash
curl "https://presuite.eu/api/search?q=test"
# Expected: {"success":false,"error":{"code":"TOKEN_MISSING","message":"Authorization required"}}
```

### Manual Test
1. Go to https://presuite.eu
2. Log in with your account
3. Type at least 2 characters in the search bar (e.g., "report")
4. Verify dropdown shows:
   - Files from PreDrive (if any match)
   - Emails from PreMail (if any match)
5. Click a result to open in new tab

### Check Logs
```bash
ssh root@76.13.2.221 "pm2 logs presuite --lines 50 --nostream"
```

---

## Deployment

```bash
# Deploy to production
ssh root@76.13.2.221 "cd /var/www/presuite && git pull && npm run build && pm2 restart presuite"

# Verify deployment
ssh root@76.13.2.221 "pm2 logs presuite --lines 20 --nostream"
```

---

## Dependencies

### External Services

| Service | Endpoint | Purpose |
|---------|----------|---------|
| PreDrive | `https://predrive.eu/api/search?q=` | File search |
| PreMail | `https://premail.site/api/v1/search?query=&pageSize=5` | Email search |

Both services must accept the same JWT token issued by PreSuite Hub.

### Frontend Dependencies

- `lucide-react`: File and Mail icons
- `authService.js`: `getToken()` for authentication check

---

## Commits

| Hash | Message | Date |
|------|---------|------|
| `b427b8f` | Add global search API for unified results across services | 2026-01-21 |
| `9a9559f` | Add global search frontend integration | 2026-01-21 |
| `af7b5d2` | Add global search results dropdown UI | 2026-01-21 |

---

## Future Improvements

- [ ] Add search result highlighting
- [ ] Add keyboard navigation for results
- [ ] Add "View all" links to PreDrive/PreMail search pages
- [ ] Add PreOffice document search
- [ ] Add search history/recent searches
- [ ] Add loading spinner during search
