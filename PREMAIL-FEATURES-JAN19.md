# PreMail Feature Implementation Progress - January 19, 2026

## Summary

Implemented 6 major features for PreMail email client, all deployed and running at https://premail.site.

---

## Completed Features

### 1. Draft Auto-Save While Composing
**Status:** ✅ Complete

- Auto-saves drafts every 30 seconds while composing
- Shows "Saving..." and "Draft saved" indicators in compose header
- Drafts stored in IMAP Drafts folder via Stalwart
- Draft deleted upon successful send
- Prompts to save draft when closing compose window

**Files Modified:**
- `apps/api/src/lib/stalwart-mail.ts` - Added `saveDraft()` and `deleteDraft()` methods
- `apps/api/src/routes/messages.ts` - Added POST `/messages/draft` and DELETE `/messages/draft/:draftId` endpoints
- `apps/web/src/lib/api.ts` - Added `saveDraft` and `deleteDraft` API methods
- `apps/web/src/pages/ComposePage.tsx` - Added auto-save effect and draft management

---

### 2. Contact Autocomplete from Sent Emails
**Status:** ✅ Complete

- Fetches contacts from sent items folder
- Filters suggestions as user types
- Shows name and email in dropdown
- Supports comma-separated multiple recipients
- Works for To, Cc, and Bcc fields

**Files Modified:**
- `apps/api/src/lib/stalwart-mail.ts` - Added `getRecentContacts()` method
- `apps/api/src/routes/messages.ts` - Added GET `/messages/contacts` endpoint
- `apps/web/src/lib/api.ts` - Added `getContacts` API method
- `apps/web/src/components/EmailAutocomplete.tsx` - New autocomplete component
- `apps/web/src/pages/ComposePage.tsx` - Replaced input fields with EmailAutocomplete

---

### 3. Attachment Preview (Images/PDF)
**Status:** ✅ Complete

- Click-to-preview for image attachments (jpg, png, gif, etc.)
- PDF preview in iframe modal
- Download button in preview modal
- Thumbnail preview in attachment list
- Authenticated fetch for attachment content

**Files Modified:**
- `apps/api/src/lib/stalwart-mail.ts` - Updated `getMessage()` to parse attachments with contentType, added `getAttachment()` method
- `apps/api/src/routes/messages.ts` - Updated attachment download endpoint for Stalwart with `?inline=true` support
- `apps/web/src/lib/api.ts` - Added `contentType` to attachment interface
- `apps/web/src/pages/MessagePage.tsx` - Added `AttachmentCard` component with preview modal

---

### 4. Email Signatures in Settings
**Status:** ✅ Complete

- Plain text signature editor in Settings
- Live preview of signature
- Signature auto-added to new emails and replies
- Clear signature option
- Stored in localStorage

**Files Modified:**
- `apps/web/src/pages/SettingsPage.tsx` - Added signature section with state, helpers (`getEmailSignature`, `setEmailSignature`), preview
- `apps/web/src/pages/ComposePage.tsx` - Auto-loads signature for new messages and replies

---

### 5. Email Templates
**Status:** ✅ Complete

- Create/edit/delete templates in Settings
- Template name, subject, and body fields
- Templates list with edit/delete actions
- Template selector dropdown in compose toolbar
- Applies template content with signature

**Files Modified:**
- `apps/web/src/pages/SettingsPage.tsx` - Added templates section with CRUD operations, helpers (`getEmailTemplates`, `saveEmailTemplates`, `addEmailTemplate`, `deleteEmailTemplate`)
- `apps/web/src/pages/ComposePage.tsx` - Added template selector dropdown, `handleSelectTemplate()` function

---

### 6. Vacation Auto-Reply Settings
**Status:** ✅ Complete (UI only - server config required for actual auto-reply)

- Enable/disable toggle
- Optional start and end date range
- Custom subject line
- Custom auto-reply message
- Live preview
- Info note about server configuration requirement

**Files Modified:**
- `apps/web/src/pages/SettingsPage.tsx` - Added vacation section with toggle, date pickers, message editor, helpers (`getVacationSettings`, `saveVacationSettings`)

---

## Technical Details

### API Endpoints Added

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/messages/draft` | Save draft to Drafts folder |
| DELETE | `/messages/draft/:draftId` | Delete a draft |
| GET | `/messages/contacts` | Get contacts from sent emails |
| GET | `/messages/:id/attachments/:attachmentId` | Download attachment (updated for Stalwart) |

### New Components

- `EmailAutocomplete.tsx` - Email address autocomplete input
- `AttachmentCard` (in MessagePage.tsx) - Attachment preview card with modal

### Storage Keys (localStorage)

- `premail_signature` - User's email signature
- `premail_templates` - Array of email templates
- `premail_vacation` - Vacation auto-reply settings

### Stalwart Mail Client Methods Added

```typescript
// Draft management
saveDraft(options): Promise<{ draftId: string }>
deleteDraft(draftId: string): Promise<void>

// Contacts
getRecentContacts(limit?: number): Promise<Array<{ name?: string; address: string }>>

// Attachments
getAttachment(folder, messageId, attachmentId): Promise<{ content: Buffer; contentType: string; filename: string }>
```

---

## Deployment

All changes deployed to production:
- Server: `76.13.1.117`
- URL: https://premail.site
- Services: `premail-api`, `premail-web` (PM2)

---

## Notes

- Vacation auto-reply UI is complete but actual auto-reply requires Stalwart SIEVE script configuration
- All settings stored in localStorage for simplicity (could be migrated to server-side storage)
- Attachment preview uses authenticated fetch with blob URLs for security
