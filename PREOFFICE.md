# PreOffice - Architecture Reference Document

## Overview

PreOffice is a LibreOffice fork branded for the Presearch/Presuite ecosystem. It consists of two main components:
1. **PreOffice Desktop** - Full LibreOffice fork with Presearch integrations
2. **PreOffice Online** - Web-based document editing powered by Collabora Online

**Production URL:** https://preoffice.site
**Production Server:** 76.13.2.220 (srv1273269)
**GitHub Repository:** https://github.com/tijnski/preoffice

---

## Technology Stack

### PreOffice Online (Web Version)

#### Backend
- **WOPI Server:** Node.js 20 with Express
- **Document Engine:** Collabora Online (CODE)
- **Protocol:** WOPI (Web Application Open Platform Interface)
- **Auth:** JWT with HS256 signing
- **Storage:** PreDrive integration via API

#### Frontend
- **UI:** Collabora Online browser client
- **Landing Page:** Static HTML with Presearch branding

#### Infrastructure
- **Containerization:** Docker Compose
- **Reverse Proxy:** Nginx with SSL
- **SSL:** Let's Encrypt (auto-renewal via certbot)
- **Session Store:** Redis

### PreOffice Desktop

#### Core
- **Base:** LibreOffice core (C++, Java, Python)
- **Extensions:** Python UNO API
- **Build System:** GNU Make, autoconf

#### Extensions
- **PrePanda:** AI assistant sidebar (Python)
- **PreDrive:** Cloud storage integration (Python)
- **Presearch Search:** Quick search integration

---

## Project Structure

```
preoffice/
├── presearch/
│   ├── online/                    # PreOffice Online (web version)
│   │   ├── docker-compose.yml     # Container orchestration
│   │   ├── .env                   # Environment config
│   │   ├── wopi-server/           # WOPI protocol server
│   │   │   ├── Dockerfile
│   │   │   ├── package.json
│   │   │   └── src/
│   │   │       └── index.js       # Main WOPI server
│   │   ├── nginx/
│   │   │   └── nginx.conf         # Reverse proxy config
│   │   └── branding/
│   │       └── static/
│   │           └── index.html     # Landing page
│   │
│   ├── extension/                 # Main PreOffice extension
│   │   ├── build-extension.sh
│   │   ├── META-INF/manifest.xml
│   │   ├── Addons.xcu            # Menu definitions
│   │   ├── OptionsDialog.xcu     # Preferences UI
│   │   ├── python/
│   │   │   ├── prepanda.py       # AI assistant
│   │   │   └── predrive.py       # Cloud storage
│   │   ├── dialogs/              # XDL dialog definitions
│   │   └── icons/                # Extension icons
│   │
│   ├── integrations/
│   │   ├── predrive/             # Standalone PreDrive extension
│   │   │   ├── build.sh
│   │   │   ├── META-INF/manifest.xml
│   │   │   ├── python/predrive.py
│   │   │   └── dialogs/
│   │   ├── pregpt/               # PreGPT AI integration
│   │   ├── presearch-search/     # Search integration
│   │   └── privacy-check/        # Privacy checker
│   │
│   ├── brand/
│   │   ├── tokens.json           # Design tokens
│   │   ├── assets/               # Logos, icons
│   │   ├── splash/               # Splash screens
│   │   └── patches/              # Core branding patches
│   │
│   └── ui/
│       ├── icon-theme/           # Custom icon theme
│       ├── color-scheme/         # Color configurations
│       ├── startcenter/          # Start center branding
│       ├── notebookbar/          # Ribbon UI customization
│       ├── templates/            # Document templates
│       └── defaults/             # Default settings
│
├── core/                          # LibreOffice source (submodule)
├── compliance/
│   ├── LICENSES/
│   ├── NOTICE
│   └── TRADEMARK.md
├── installers/
│   ├── windows/
│   ├── macos/
│   └── linux/
└── docs/
    ├── BUILDING.md
    ├── CONTRIBUTING.md
    └── SECURITY.md
```

---

## PreOffice Online Architecture

### Docker Services

```yaml
services:
  collabora:    # Collabora Online (CODE) - port 9980
  wopi:         # WOPI Server - port 8080
  nginx:        # Reverse proxy - ports 80, 443
  redis:        # Session store - port 6379
```

### WOPI Protocol Flow

```
Browser → Nginx → Collabora (cool.html)
                      ↓
              WOPI CheckFileInfo
                      ↓
              Nginx → WOPI Server → PreDrive API
                      ↓
              WOPI GetFile / PutFile
                      ↓
              Document editing via WebSocket
```

### Key WOPI Endpoints

```
GET  /wopi/files/:fileId              # CheckFileInfo - file metadata
GET  /wopi/files/:fileId/contents     # GetFile - download content
POST /wopi/files/:fileId/contents     # PutFile - save content
POST /wopi/files/:fileId              # Lock/Unlock/Rename operations
```

### API Endpoints

```
POST /api/edit                # Get editor URL for existing file
POST /api/create              # Create new document
GET  /health                  # Health check
GET  /hosting/discovery       # WOPI discovery (proxied to Collabora)
```

---

## WOPI Server Implementation

### Configuration (index.js)

```javascript
const config = {
  predriveApiUrl: process.env.PREDRIVE_API_URL,     // https://predrive.eu/api
  wopiBaseUrl: process.env.WOPI_BASE_URL,           // https://preoffice.site/wopi
  collaboraUrl: process.env.COLLABORA_URL,          // http://collabora:9980
  collaboraPublicUrl: process.env.COLLABORA_PUBLIC_URL, // https://preoffice.site
  jwtSecret: process.env.JWT_SECRET,
  tokenExpiry: '24h'
};
```

### Demo Mode

For local testing without PreDrive backend:
- Files stored in memory (`demoFiles` Map)
- CheckFileInfo returns mock metadata
- GetFile/PutFile use in-memory storage

### JWT Token Payload

```javascript
{
  userId: string,      // User identifier
  fileId: string,      // Base64-encoded file path
  sessionId: string,   // UUID session ID
  iat: number,         // Issued at
  exp: number          // Expiration
}
```

---

## Nginx Configuration

### SSL Setup (Production)

```nginx
server {
    listen 443 ssl http2;
    server_name preoffice.site;

    ssl_certificate /etc/letsencrypt/live/preoffice.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/preoffice.site/privkey.pem;
    
    # Collabora WebSocket (CRITICAL - must be regex for proper priority)
    location ~ ^/cool/(.*)/ws$ {
        proxy_pass http://collabora:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 36000s;
    }

    # Collabora static files
    location ^~ /browser {
        proxy_pass http://collabora:9980;
        proxy_set_header Host $host;
    }

    # WOPI endpoints
    location /wopi/ {
        proxy_pass http://wopi:8080/wopi/;
        proxy_set_header Host $host;
        proxy_read_timeout 36000s;
    }

    # Other cool endpoints (NO ^~ so websocket regex takes priority)
    location ~ ^/cool {
        proxy_pass http://collabora:9980;
        proxy_set_header Host $host;
    }
}
```

### Important: Nginx Location Priority

Nginx location matching priority:
1. Exact match `=`
2. Prefix match with `^~`
3. Regex match `~` or `~*`
4. Regular prefix match

The WebSocket location MUST be regex (`~`) and the general `/cool` MUST NOT use `^~` prefix, otherwise WebSocket connections will fail.

---

## Environment Variables

### Production (.env)

```bash
# Collabora Admin
COLLABORA_ADMIN_USER=admin
COLLABORA_ADMIN_PASS=<generated>

# API
PREDRIVE_API_URL=https://predrive.eu/api

# WOPI Configuration
WOPI_BASE_URL=https://preoffice.site/wopi
COLLABORA_PUBLIC_URL=https://preoffice.site

# Security
JWT_SECRET=<generated>

# Domain
DOMAIN=preoffice.site
```

### Docker Compose Environment

```yaml
collabora:
  environment:
    - aliasgroup1=https://preoffice.site
    - username=${COLLABORA_ADMIN_USER}
    - password=${COLLABORA_ADMIN_PASS}
    - server_name=preoffice.site
    - extra_params=--o:ssl.enable=false --o:ssl.termination=true
```

---

## Deployment

### Production Server (76.13.2.220)

#### Directory Structure
```
/opt/preoffice/
├── presearch/online/
│   ├── .env
│   ├── docker-compose.yml
│   ├── wopi-server/
│   ├── nginx/
│   └── branding/
```

#### SSL Certificates
```
/etc/letsencrypt/live/preoffice.site/
├── fullchain.pem
└── privkey.pem
```

### Deployment Commands

```bash
# SSH to server
ssh root@76.13.2.220

# Navigate to project
cd /opt/preoffice/presearch/online

# Pull latest code
git pull origin main

# Rebuild and restart
docker compose down
docker compose up -d --build

# View logs
docker compose logs -f

# Check status
docker compose ps
curl https://preoffice.site/health
```

### SSL Certificate Renewal

```bash
# Certbot auto-renewal (already configured)
certbot renew

# Manual renewal
certbot certonly --standalone -d preoffice.site
docker compose restart nginx
```

---

## PreDrive Integration

### WOPI to PreDrive Flow

1. User clicks "Open in PreOffice" in PreDrive
2. PreDrive calls `/api/edit` with file path and user token
3. WOPI server generates access token and editor URL
4. Collabora opens, calls CheckFileInfo
5. WOPI server fetches file metadata from PreDrive API
6. GetFile downloads content from PreDrive
7. User edits document
8. PutFile saves back to PreDrive

### PreDrive API Calls

```javascript
// Download file
GET ${predriveApiUrl}/files/content?path=${filePath}
Authorization: Bearer ${userToken}

// Upload file
PUT ${predriveApiUrl}/files/content?path=${filePath}
Authorization: Bearer ${userToken}
Content-Type: application/json
{
  "content": "<base64>",
  "encoding": "base64"
}
```

---

## Desktop Extension Development

### Extension Structure

```
extension.oxt (ZIP archive)
├── META-INF/
│   └── manifest.xml          # Component registration
├── description.xml           # Extension metadata
├── Addons.xcu               # Menu items
├── OptionsDialog.xcu        # Preferences page
├── python/
│   └── module.py            # Python UNO components
├── dialogs/
│   └── dialog.xdl           # Dialog definitions
└── icons/
    └── icon.png             # Toolbar icons
```

### Building Extensions

```bash
cd presearch/extension
./build-extension.sh
# Output: PreOffice-1.0.0.oxt

# Install
/Applications/LibreOffice.app/Contents/MacOS/unopkg add PreOffice-1.0.0.oxt
```

### Python UNO Example

```python
import uno
from com.sun.star.task import XJobExecutor

class MyJob(unohelper.Base, XJobExecutor):
    def __init__(self, ctx):
        self.ctx = ctx
    
    def trigger(self, args):
        desktop = self.ctx.ServiceManager.createInstanceWithContext(
            "com.sun.star.frame.Desktop", self.ctx)
        doc = desktop.getCurrentComponent()
        # Do something with document

g_ImplementationHelper = unohelper.ImplementationHelper()
g_ImplementationHelper.addImplementation(
    MyJob, "com.presearch.MyJob", ("com.sun.star.task.Job",))
```

---

## Branding Guidelines

### Design Tokens

```json
{
  "colors": {
    "primary": "#2D8EFF",
    "background-tint": "#EAF3FF",
    "background-soft": "#FAFBFC",
    "text-primary": "#000000",
    "text-secondary": "#494949"
  }
}
```

### Required Attribution

- "Based on LibreOffice technology" in About dialog
- MPL license notices preserved
- LibreOffice trademarks NOT used in branding

---

## Common Operations

### Restart Services

```bash
# All services
docker compose restart

# Specific service
docker compose restart wopi

# Full rebuild
docker compose down && docker compose up -d --build
```

### View Logs

```bash
# All logs
docker compose logs -f

# Specific service
docker compose logs -f collabora
docker compose logs -f wopi
docker compose logs -f nginx
```

### Test WOPI Endpoints

```bash
# Health check
curl https://preoffice.site/health

# Create document
curl -X POST https://preoffice.site/api/create \
  -H "Content-Type: application/json" \
  -d '{"type":"document"}'
```

---

## Troubleshooting

### WebSocket Connection Failed

1. Check nginx config has proper location priority
2. Verify WebSocket location uses regex `~` not `^~`
3. Check Collabora logs: `docker compose logs collabora`
4. Ensure `aliasgroup1` matches your domain

### WOPI CheckFileInfo 404

1. Check file exists in PreDrive
2. Verify access token is valid
3. Check WOPI_BASE_URL uses correct host
4. For demo mode, files are in-memory only

### SSL Certificate Issues

```bash
# Check certificate
openssl s_client -connect preoffice.site:443 -servername preoffice.site

# Renew certificate
certbot renew
docker compose restart nginx
```

### Collabora Not Starting

1. Check Docker logs: `docker compose logs collabora`
2. Verify memory (needs ~2GB minimum)
3. Check port 9980 not in use
4. Ensure CAP_MKNOD capability

---

## Security Notes

- JWT secrets should be unique per deployment
- SSL termination at nginx (Collabora runs HTTP internally)
- Access tokens expire after 24 hours
- File locks prevent concurrent editing conflicts
- Demo mode stores files in memory (not persistent)

---

## Related Services

| Service | URL | Server | Purpose |
|---------|-----|--------|---------|
| PreDrive | https://predrive.eu | 76.13.1.110 | Cloud storage |
| PreMail | https://premail.site | 76.13.1.117 | Email service |
| PreOffice | https://preoffice.site | 76.13.2.220 | Document editing |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `presearch/online/docker-compose.yml` | Container orchestration |
| `presearch/online/wopi-server/src/index.js` | WOPI server implementation |
| `presearch/online/nginx/nginx.conf` | Reverse proxy configuration |
| `presearch/online/branding/static/index.html` | Landing page |
| `presearch/extension/python/prepanda.py` | AI assistant extension |
| `presearch/integrations/predrive/python/predrive.py` | PreDrive integration |
| `presearch/brand/tokens.json` | Design tokens |
| `CLAUDE.md` | AI agent guidelines |

---

*Last Updated: January 2026*
