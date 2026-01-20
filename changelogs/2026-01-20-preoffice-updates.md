# PreOffice Updates - January 20, 2026

## WOPI Server v2.1.0

### New Features

#### Document Conversion API
Added server-side document conversion powered by Collabora's convert-to endpoint.

**New Endpoints:**
- `POST /api/convert` - Convert document and download result
- `GET /api/convert/formats` - List all supported conversion formats
- `POST /api/convert/save` - Convert document and save to PreDrive

**Supported Format Conversions:**

| Source Type | Target Formats |
|-------------|----------------|
| Documents | PDF, DOCX, ODT, RTF, TXT, HTML |
| Spreadsheets | PDF, XLSX, ODS, CSV |
| Presentations | PDF, PPTX, ODP, PNG, JPG |

**Usage Example:**
```javascript
// Convert a PreDrive file to PDF
const response = await fetch('https://preoffice.site/api/convert', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <token>',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    nodeId: 'predrive-file-id',
    targetFormat: 'pdf'
  })
});

// Response is the converted file as binary download
const blob = await response.blob();
```

#### LanguageTool Integration
Enabled grammar and spell checking via LanguageTool API.

- Real-time grammar suggestions while editing
- Spelling corrections for multiple languages
- Uses LanguageTool Plus cloud API (free tier)
- Supports: English, Dutch, German, French, Spanish

---

## Configuration Changes

### docker-compose.yml
- Added LanguageTool configuration via Collabora `extra_params`
- Optional self-hosted LanguageTool service (commented out)
- Environment variable for max conversion file size

### package.json
- Added `form-data` dependency for file upload handling
- Version bumped to 2.1.0

---

## Technical Details

### Files Modified
| File | Changes |
|------|---------|
| `wopi-server/src/index.js` | +266 lines - Convert API endpoints |
| `wopi-server/package.json` | Added form-data dependency, version 2.1.0 |
| `docker-compose.yml` | LanguageTool config, optional self-hosted service |
| `collabora-config/coolwsd-override.xml` | Created config override template |

### Deployment
```bash
cd /opt/preoffice/presearch/online
docker compose down
docker compose up -d --build
```

---

## Next Steps (Planned)

- [ ] DeepL translation integration (requires API key)
- [ ] Document templates library
- [ ] Extra export formats for presentations (PNG, SVG, GIF)
- [ ] Real-time collaboration (future)

---

*Deployed: January 20, 2026*
*Server: 76.13.2.220*
