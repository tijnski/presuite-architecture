# PreDrive Collaboration Features Implementation

**Date:** January 20, 2026
**Status:** Implementation Complete (Pending Testing & Deployment)
**Services:** PreDrive

---

## Overview

Implemented three major collaboration features for PreDrive:
1. **Comments System** - Threaded comments with reactions and @mentions
2. **Advanced Sharing** - Granular permissions and access controls
3. **Real-time Collaboration** - Live cursor/presence tracking and document locking

---

## 1. Comments System

### Database Schema

**New Tables:**
```sql
-- Comments table
CREATE TABLE comments (
  id UUID PRIMARY KEY,
  org_id UUID NOT NULL REFERENCES orgs(id),
  node_id UUID NOT NULL REFERENCES nodes(id),
  author_id UUID NOT NULL REFERENCES users(id),
  parent_id UUID REFERENCES comments(id),  -- For threaded replies
  content TEXT NOT NULL,
  anchor_position JSONB,  -- For inline document comments
  is_resolved BOOLEAN DEFAULT false,
  resolved_by UUID REFERENCES users(id),
  resolved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP  -- Soft delete
);

-- Reactions table
CREATE TABLE comment_reactions (
  id UUID PRIMARY KEY,
  comment_id UUID NOT NULL REFERENCES comments(id),
  user_id UUID NOT NULL REFERENCES users(id),
  emoji VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(comment_id, user_id, emoji)
);

-- Mentions table
CREATE TABLE comment_mentions (
  id UUID PRIMARY KEY,
  comment_id UUID NOT NULL REFERENCES comments(id),
  user_id UUID NOT NULL REFERENCES users(id),
  notified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(comment_id, user_id)
);
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/nodes/:nodeId/comments` | List comments (paginated, filter resolved) |
| POST | `/api/nodes/:nodeId/comments` | Create comment or reply |
| PATCH | `/api/comments/:id` | Edit comment (author only) |
| DELETE | `/api/comments/:id` | Delete comment (soft delete) |
| POST | `/api/comments/:id/resolve` | Toggle resolved status |
| POST | `/api/comments/:id/reactions` | Add emoji reaction |
| DELETE | `/api/comments/:id/reactions/:emoji` | Remove reaction |

### Features
- Threaded replies (one level deep)
- @mention support (extracts email patterns)
- Emoji reactions (👍, ❤️, 🎉, 😄, 😢, 🤔)
- Resolve/unresolve for task tracking
- Soft delete for audit trail
- Real-time WebSocket broadcasts

### Frontend Component
- `CommentThread.tsx` - Full-featured comment panel
  - Thread view with nested replies
  - Inline editing
  - Emoji picker for reactions
  - Keyboard shortcuts (⌘+Enter to send)

---

## 2. Advanced Sharing

### Database Schema Changes

**Extended `shares` table:**
```sql
ALTER TABLE shares ADD COLUMN (
  -- Granular permissions
  can_comment BOOLEAN DEFAULT false,
  can_download BOOLEAN DEFAULT true,
  can_view_activity BOOLEAN DEFAULT false,
  can_invite_others BOOLEAN DEFAULT false,

  -- Access limits
  max_downloads INTEGER,
  download_count INTEGER DEFAULT 0,
  max_views INTEGER,
  view_count INTEGER DEFAULT 0,

  -- Metadata
  name VARCHAR(255),
  description TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Extended scope enum
scope: 'view' | 'download' | 'edit' | 'comment' | 'custom'
```

**New Tables:**
```sql
-- Share invitations
CREATE TABLE share_invitations (
  id UUID PRIMARY KEY,
  share_id UUID NOT NULL REFERENCES shares(id),
  email VARCHAR(255) NOT NULL,
  invited_by UUID NOT NULL REFERENCES users(id),
  status VARCHAR(20) DEFAULT 'pending',  -- pending, accepted, declined, expired
  message TEXT,
  expires_at TIMESTAMP NOT NULL,
  accepted_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Share access log
CREATE TABLE share_access_log (
  id UUID PRIMARY KEY,
  share_id UUID NOT NULL REFERENCES shares(id),
  user_id UUID,  -- null for anonymous
  action VARCHAR(20) NOT NULL,  -- view, download, edit, comment
  ip VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Extended `permissions` table:**
```sql
ALTER TABLE permissions ADD COLUMN (
  -- Granular capabilities
  can_comment BOOLEAN,
  can_download BOOLEAN,
  can_rename BOOLEAN,
  can_delete BOOLEAN,
  can_move BOOLEAN,
  can_share BOOLEAN,
  can_view_history BOOLEAN,
  can_manage_permissions BOOLEAN,

  -- Expiration
  expires_at TIMESTAMP,

  -- Audit
  granted_by UUID REFERENCES users(id),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Extended role enum
role: 'owner' | 'editor' | 'viewer' | 'commenter'
```

### Features
- 5 share scopes: view, download, edit, comment, custom
- Granular permission toggles
- Access limits (max downloads/views)
- Password protection
- Expiration dates
- Organization-only shares
- Email invitations
- Access logging

### Frontend Component
- `AdvancedShareModal.tsx` - Complete sharing UI
  - Quick scope presets
  - Advanced options panel
  - Active share management
  - Email invitation

---

## 3. Real-time Collaboration

### Database Schema

**New Tables:**
```sql
-- Active editing sessions
CREATE TABLE document_sessions (
  id UUID PRIMARY KEY,
  node_id UUID NOT NULL REFERENCES nodes(id),
  user_id UUID NOT NULL REFERENCES users(id),
  connection_id VARCHAR(64) NOT NULL UNIQUE,
  cursor_position JSONB,  -- {line, column, offset}
  selection_range JSONB,  -- {start, end}
  color VARCHAR(7) NOT NULL,  -- User's cursor color
  last_activity TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Document operations (for OT)
CREATE TABLE document_operations (
  id UUID PRIMARY KEY,
  node_id UUID NOT NULL REFERENCES nodes(id),
  user_id UUID NOT NULL REFERENCES users(id),
  base_version INTEGER NOT NULL,
  result_version INTEGER NOT NULL,
  operation_type VARCHAR(20) NOT NULL,  -- insert, delete, replace, format
  operations JSONB NOT NULL,  -- Array of OT operations
  created_at TIMESTAMP DEFAULT NOW()
);

-- Document snapshots
CREATE TABLE document_snapshots (
  id UUID PRIMARY KEY,
  node_id UUID NOT NULL REFERENCES nodes(id),
  version INTEGER NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(node_id, version)
);
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/collaboration/documents/:nodeId/sessions` | List active sessions |
| POST | `/api/collaboration/documents/:nodeId/sessions/join` | Join editing session |
| POST | `/api/collaboration/documents/:nodeId/sessions/leave` | Leave session |
| POST | `/api/collaboration/documents/:nodeId/cursor` | Update cursor position |
| POST | `/api/collaboration/documents/:nodeId/selection` | Update selection range |
| POST | `/api/collaboration/documents/:nodeId/operations` | Submit document operation |
| GET | `/api/collaboration/documents/:nodeId/operations` | Get operations since version |
| POST | `/api/collaboration/documents/:nodeId/lock` | Acquire document lock |
| DELETE | `/api/collaboration/documents/:nodeId/lock` | Release lock |

### WebSocket Events

**New Event Types:**
```typescript
// Comment events
'comment:created' | 'comment:updated' | 'comment:deleted'
'comment:reaction_added' | 'comment:reaction_removed'

// Collaboration events
'collab:user_joined' | 'collab:user_left'
'collab:cursor_moved' | 'collab:selection_changed'
'collab:operation'
'collab:document_locked' | 'collab:document_unlocked'
```

### Features
- User presence tracking with colored avatars
- Live cursor position sharing
- Selection range visualization
- Document locking (pessimistic)
- Operation-based sync (foundation for OT)
- Stale session cleanup (5-minute timeout)
- Conflict detection

### Frontend Components
- `CollaborationPresence.tsx` - Presence bar with avatars
- `CollaboratorCursors.tsx` - Cursor overlay component

---

## Files Modified/Created

### Backend (predrive/apps/api)

**Modified:**
- `src/index.ts` - Route registration
- `packages/db/src/schema.ts` - Database schema
- `packages/shared/src/validators.ts` - Zod schemas
- `src/websocket/types.ts` - WebSocket message types

**Created:**
- `src/routes/comments.ts` - Comments API routes
- `src/routes/collaboration.ts` - Collaboration API routes

### Frontend (predrive/apps/web)

**Created:**
- `src/components/CommentThread.tsx` - Comments panel
- `src/components/AdvancedShareModal.tsx` - Advanced sharing modal
- `src/components/CollaborationPresence.tsx` - Presence indicators

---

## Validators Added

```typescript
// Comments
createCommentSchema
updateCommentSchema
addReactionSchema
listCommentsQuerySchema

// Advanced Sharing
createAdvancedShareSchema
updateShareSchema
inviteToShareSchema
setAdvancedPermissionSchema

// Collaboration
documentOperationSchema
cursorPositionSchema
selectionRangeSchema
```

---

## Security Considerations

1. **Comments**
   - XSS prevention via content sanitization
   - Only authors can edit/delete own comments
   - Editors+ can delete any comment
   - Rate limiting on creation

2. **Sharing**
   - Permission inheritance validation
   - Share token randomness (64 chars)
   - Password hashing with bcrypt
   - Access logging for audit trail

3. **Collaboration**
   - Session timeout prevents stale locks
   - Edit access required for operations
   - Conflict detection prevents data loss
   - Lock expiration prevents deadlocks

---

## Integration Points

### With Existing Features
- Uses existing WebSocket infrastructure (`wsManager`)
- Integrates with permissions system
- Leverages audit log for tracking
- Compatible with encryption (BYOK)

### WebSocket Broadcasting
All events broadcast to folder subscribers, enabling:
- Real-time comment notifications
- Live share activity
- Instant collaboration updates

---

## Deployment Steps

```bash
# 1. Run migrations (when db migration system is set up)
cd /opt/predrive
pnpm db:migrate

# 2. Build and deploy
pnpm build
docker compose -f deploy/docker-compose.prod.yml up -d --build

# 3. Verify
curl https://predrive.eu/health
```

---

## Testing Checklist

### Comments
- [ ] Create comment on file
- [ ] Reply to comment
- [ ] Edit own comment
- [ ] Delete comment
- [ ] Add reaction
- [ ] Remove reaction
- [ ] @mention user
- [ ] Resolve/unresolve comment
- [ ] WebSocket broadcast

### Advanced Sharing
- [ ] Create share with each scope
- [ ] Set custom permissions
- [ ] Password protect share
- [ ] Set expiration
- [ ] Access limits enforcement
- [ ] Email invitation
- [ ] Access log recording

### Collaboration
- [ ] Join editing session
- [ ] See other users' presence
- [ ] Cursor position updates
- [ ] Selection range sync
- [ ] Document locking
- [ ] Lock timeout
- [ ] Conflict detection

---

## Known Limitations

1. **Comments**
   - Single-level threading only
   - No real-time typing indicators
   - No attachment support (yet)

2. **Sharing**
   - No link analytics dashboard
   - No bulk invitation
   - No share templates

3. **Collaboration**
   - Pessimistic locking only (no true OT/CRDT)
   - Cursor positions simplified (no pixel-precise)
   - No offline support

---

## Future Enhancements

1. **Full OT/CRDT Implementation**
   - Use yjs or automerge library
   - True real-time co-editing
   - Offline conflict resolution

2. **Comments Enhancements**
   - File attachments in comments
   - Rich text formatting
   - Email notifications for mentions

3. **Sharing Analytics**
   - View/download graphs
   - Geographic access data
   - Time-based access patterns

---

## Related Documentation

- [PREDRIVE.md](../PREDRIVE.md) - PreDrive service overview
- [architecture/PREDRIVE.md](../architecture/PREDRIVE.md) - Architecture details
- [IMPLEMENTATION-STATUS.md](../IMPLEMENTATION-STATUS.md) - Overall progress
