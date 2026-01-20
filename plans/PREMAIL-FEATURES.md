# PreMail Feature Implementation Plan

> **Created:** January 20, 2026
> **Updated:** January 20, 2026
> **Status:** High Priority Complete ✅

---

## High Priority (Completed Jan 20, 2026)

| Feature | Description | Status |
|---------|-------------|--------|
| Filters & Rules | Auto-sort, auto-label, auto-archive | ✅ Complete |
| Contact Management | Address book, auto-complete from contacts | ✅ Complete |
| Email Aliases | Multiple addresses for one account | ✅ Complete |

### Implementation Summary

**Database:**
- Migrations applied to production PostgreSQL
- Tables: `email_filters`, `contacts`, `contact_groups`, `contact_group_members`, `email_aliases`

**Backend Routes:**
- `/api/v1/filters` - Full CRUD + toggle, reorder, test
- `/api/v1/contacts` - Full CRUD + autocomplete, groups, import
- `/api/v1/accounts/:id/aliases` - Full CRUD + toggle, default

**Frontend:**
- `FiltersPage.tsx` - Visual rule builder UI
- `ContactsPage.tsx` - Contact management with groups
- `AliasesPage.tsx` - Alias management per account
- `ContactAutocomplete.tsx` - Compose recipient autocomplete
- Navigation links added to sidebar

---

## Medium Priority (Future)

| Feature | Description | Status |
|---------|-------------|--------|
| Real-time Sync | WebSocket/SSE for live inbox updates | ⏳ Planned |
| Email Scheduling | Send emails at a future time | ⏳ Planned |
| Email Templates | Save/reuse common email formats | ⏳ Planned |
| Snooze Emails | Temporarily hide and resurface later | ⏳ Planned |
| Undo Send | Short delay before actually sending | ⏳ Planned |
| Read Receipts | Track when emails are opened | ⏳ Planned |
| Vacation Responder | Auto-reply when away | ⏳ Planned |

---

## Lower Priority (Backlog)

| Feature | Description | Status |
|---------|-------------|--------|
| Import/Export | Import from Gmail/Outlook, export mailbox | ⏳ Backlog |
| Keyboard Shortcuts | Power-user navigation | ⏳ Backlog |
| Email Encryption | PGP/GPG support | ⏳ Backlog |
| Spam Training | User-trainable spam filter | ⏳ Backlog |
| Bulk Actions | Select all, bulk delete/archive | ⏳ Backlog |
| Mobile App | Native iOS/Android | ⏳ Backlog |

---

## Implementation Details

### 1. Filters & Rules

**Database Schema:**
```sql
CREATE TABLE email_filters (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 0,

  -- Conditions (match any/all)
  match_type VARCHAR(10) DEFAULT 'any', -- 'any' or 'all'
  conditions JSONB NOT NULL,
  -- Example: [{"field": "from", "operator": "contains", "value": "newsletter"}]

  -- Actions
  actions JSONB NOT NULL,
  -- Example: [{"type": "label", "value": "newsletters"}, {"type": "archive"}]

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Condition Fields:**
- `from` - Sender email/name
- `to` - Recipient
- `subject` - Subject line
- `body` - Email body
- `has_attachment` - Boolean

**Condition Operators:**
- `contains`, `not_contains`
- `equals`, `not_equals`
- `starts_with`, `ends_with`
- `matches_regex`

**Actions:**
- `move_to_folder` - Move to specific folder
- `label` - Apply label
- `mark_read` - Mark as read
- `star` - Star message
- `archive` - Archive
- `delete` - Move to trash
- `forward` - Forward to address
- `never_spam` - Never mark as spam

### 2. Contact Management

**Database Schema:**
```sql
CREATE TABLE contacts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,

  -- Contact info
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  nickname VARCHAR(100),
  company VARCHAR(255),
  job_title VARCHAR(255),
  phone VARCHAR(50),
  notes TEXT,

  -- Avatar
  avatar_url TEXT,

  -- Metadata
  is_favorite BOOLEAN DEFAULT false,
  last_contacted_at TIMESTAMPTZ,
  contact_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, email)
);

CREATE TABLE contact_groups (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(7) DEFAULT '#0190FF',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE contact_group_members (
  id UUID PRIMARY KEY,
  group_id UUID REFERENCES contact_groups(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
  UNIQUE(group_id, contact_id)
);
```

**API Endpoints:**
- `GET /contacts` - List contacts (with search/filter)
- `GET /contacts/:id` - Get contact
- `POST /contacts` - Create contact
- `PATCH /contacts/:id` - Update contact
- `DELETE /contacts/:id` - Delete contact
- `GET /contacts/autocomplete?q=` - Autocomplete for compose
- `POST /contacts/import` - Import from vCard/CSV
- `GET /contacts/export` - Export to vCard

### 3. Email Aliases

**Database Schema:**
```sql
CREATE TABLE email_aliases (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  account_id UUID REFERENCES email_accounts(id) ON DELETE CASCADE,

  alias_email VARCHAR(255) NOT NULL UNIQUE,
  display_name VARCHAR(255),
  is_default BOOLEAN DEFAULT false,
  is_enabled BOOLEAN DEFAULT true,

  -- Stats
  emails_received INTEGER DEFAULT 0,
  emails_sent INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Stalwart Integration:**
- Add alias as secondary email to user principal
- Configure catch-all or explicit aliases

**Features:**
- Create aliases like `myname+shopping@premail.site`
- Send from any alias
- Track which alias receives mail
- Disable alias without deleting

---

## Files to Create/Modify

### Backend (apps/api/src/)

**New Files:**
- `routes/filters.ts` - Filter CRUD endpoints
- `routes/contacts.ts` - Contact management endpoints
- `routes/aliases.ts` - Alias management endpoints
- `services/filterEngine.ts` - Apply filters to incoming mail

**Modified Files:**
- `routes/messages.ts` - Apply filters on message fetch
- `routes/accounts.ts` - Alias send-as support

### Database (packages/db/src/)

**Modified Files:**
- `schema/index.ts` - Add new tables

### Frontend (apps/web/src/)

**New Files:**
- `pages/ContactsPage.tsx` - Contact management UI
- `pages/FiltersPage.tsx` - Filter rules UI
- `components/ContactPicker.tsx` - Autocomplete in compose
- `components/FilterBuilder.tsx` - Visual filter builder
- `components/AliasManager.tsx` - Manage aliases

**Modified Files:**
- `pages/ComposePage.tsx` - Add contact autocomplete
- `pages/SettingsPage.tsx` - Add filters/aliases sections
