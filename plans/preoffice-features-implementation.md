# PreOffice Features Implementation Plan

> **Created:** January 20, 2026
> **Status:** Phase 1, 2.1 & Auth Complete
> **Server:** 76.13.2.220 (`/opt/preoffice`)

---

## Current State

- **Collabora CODE 25.04.8.1** (Development Edition)
- **WOPI Server v2.1.0** with PreDrive integration + Convert API
- **PrePanda AI** (Venice API) for document assistance

### Already Working
- Document editing (Writer, Calc, Impress, Draw)
- PreDrive file integration
- WOPI protocol (CheckFileInfo, GetFile, PutFile)
- File locking
- Web3 wallet login
- Zotero citation support

---

## Implementation Tasks

### Phase 1: Quick Wins (Configuration Only)

#### 1.1 LanguageTool Integration
**Status:** ✅ Complete

Enable external grammar and spell checking via LanguageTool API.

**Configuration:**
```xml
<languagetool>
  <enabled>true</enabled>
  <base_url>https://api.languagetoolplus.com/v2</base_url>
  <ssl_verification>true</ssl_verification>
</languagetool>
```

**Options:**
- Free cloud API (rate limited)
- Self-hosted LanguageTool container
- Premium API with higher limits

#### 1.2 DeepL Translation
**Status:** ⏳ Pending

Add document translation capability.

**Configuration:**
```xml
<deepl>
  <enabled>true</enabled>
  <api_url>https://api-free.deepl.com/v2</api_url>
  <auth_key>${DEEPL_API_KEY}</auth_key>
</deepl>
```

#### 1.3 Extra Export Formats
**Status:** ⏳ Pending

Enable additional export formats for presentations:
- PNG, SVG, GIF, BMP, TIFF from slides

---

### Phase 2: WOPI Server Enhancements

#### 2.1 Convert-to API
**Status:** ✅ Complete

Expose Collabora's document conversion capability.

**New Endpoint:** `POST /api/convert`

**Request:**
```json
{
  "nodeId": "predrive-file-id",
  "targetFormat": "pdf"
}
```

**Supported Conversions:**
- Documents → PDF, DOCX, ODT, RTF, TXT, HTML
- Spreadsheets → PDF, XLSX, ODS, CSV
- Presentations → PDF, PPTX, ODP, PNG (slides)

#### 2.2 Document Templates
**Status:** ⏳ Pending

Implement template library with PreDrive storage.

**New Endpoints:**
- `GET /api/templates` - List available templates
- `POST /api/templates/create` - Create doc from template
- `POST /api/templates/save` - Save doc as template

**Template Categories:**
- Documents: Letters, Reports, Resumes, Invoices
- Spreadsheets: Budgets, Trackers, Timesheets
- Presentations: Pitch decks, Reports, Education

---

### Phase 3: Advanced Features

#### 3.1 Real-time Collaboration
**Status:** ⏳ Pending (Future)

Enable multiple users editing same document.

**Requirements:**
- WebSocket session management
- WOPI lock coordination
- User presence indicators
- Conflict resolution

#### 3.2 Document Signing
**Status:** ⏳ Pending (Future)

Digital signature integration.

---

## Environment Variables

Add to `/opt/preoffice/presearch/online/.env`:

```bash
# LanguageTool (optional - for self-hosted)
LANGUAGETOOL_URL=http://languagetool:8010/v2

# DeepL Translation
DEEPL_API_KEY=your-deepl-api-key

# Convert-to settings
MAX_CONVERT_SIZE_MB=50
CONVERT_TIMEOUT_MS=60000
```

---

## Deployment Steps

### Step 1: Update Collabora Configuration
```bash
# Create custom coolwsd.xml overlay
# Mount via docker-compose volumes
```

### Step 2: Update WOPI Server
```bash
cd /opt/preoffice/presearch/online/wopi-server
# Add new endpoints
# Update package.json if needed
```

### Step 3: Rebuild & Deploy
```bash
cd /opt/preoffice/presearch/online
docker compose down
docker compose up -d --build
```

---

## Testing Checklist

- [x] LanguageTool: Enabled via Collabora extra_params (API: languagetoolplus.com)
- [ ] DeepL: Select text, verify translate option in menu (needs API key)
- [x] Convert-to: `/api/convert/formats` endpoint tested and working
- [ ] Templates: Create document from template, verify content

---

## Files Modified

| File | Changes |
|------|---------|
| `docker-compose.yml` | Add LanguageTool service, config volumes |
| `wopi-server/src/index.js` | Add convert-to endpoint |
| `coolwsd-override.xml` | LanguageTool + DeepL config |
| `.env` | New API keys |

---

## Progress Log

### January 20, 2026
- Analyzed current Collabora CODE capabilities
- Identified implementable features
- ✅ Implemented Convert-to API endpoints:
  - `POST /api/convert` - Convert file and download
  - `GET /api/convert/formats` - List supported formats
  - `POST /api/convert/save` - Convert and save to PreDrive
- ✅ Configured LanguageTool integration via Collabora extra_params
- ✅ Updated docker-compose.yml with new configuration
- ✅ WOPI server updated to v2.1.0 with form-data dependency
- ✅ Deployed and tested - all services running
- ✅ Implemented Web3 authentication with SSO:
  - MetaMask wallet connection
  - Nonce-based signature verification via PreSuite Hub
  - JWT token storage with expiry tracking
  - Proactive token refresh before expiry
  - Auto-refresh on 401 responses
  - New user welcome with mail credentials
- ✅ Updated landing page auth script (index.html)
