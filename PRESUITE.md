# PreSuite - Project Documentation

## Overview

PreSuite is a macOS Launchpad-inspired landing page and productivity suite for Presearch. It serves as a central hub for accessing various Pre-branded applications with a focus on privacy, decentralization, and user sovereignty.

**Live URL:** https://presuite.eu
**GitHub Repository:** https://github.com/tijnski/presuite
**VPS:** 76.13.2.221 (Ubuntu 24.04, Hostinger)

---

## Tech Stack

### Frontend
- **Framework:** React 19.2.0
- **Build Tool:** Vite 5.4.21
- **Styling:** Tailwind CSS 4.1.18
- **Icons:** Lucide React 0.562.0

### Backend
- **Runtime:** Node.js 20.20.0
- **Framework:** Express 5.2.1
- **Process Manager:** PM2 (auto-restart, startup on boot)
- **AI Integration:** Venice AI API (for PreGPT)

### Infrastructure
- **Web Server:** Nginx (reverse proxy)
- **SSL:** Let's Encrypt (auto-renewal via certbot)
- **Domain:** presuite.eu (with www redirect)

---

## Project Structure

```
presuite/
├── dist/                    # Production build output
├── src/
│   ├── assets/
│   │   └── images/
│   │       ├── PandaSVG.svg                           # PrePanda mascot
│   │       ├── presearch-logo-borderless-blue.svg    # Main logo
│   │       └── presearch-logo-border-white-transparent.svg
│   ├── components/
│   │   ├── PreSuiteLaunchpad.jsx   # Main landing page
│   │   ├── SearchBar.jsx            # Search with autocomplete
│   │   ├── PreGPTChat.jsx           # AI chat modal (with history)
│   │   ├── AppModal.jsx             # App modals (Mail, Drive, etc.)
│   │   ├── Settings.jsx             # Settings panel modal
│   │   ├── Notifications.jsx        # Notifications dropdown
│   │   ├── UserProfile.jsx          # User profile panel
│   │   ├── Login.jsx                # Login page (/login)
│   │   └── Register.jsx             # Register page (/register)
│   ├── services/
│   │   ├── preGPTService.js         # API client for PreGPT
│   │   ├── authService.js           # Auth API client
│   │   ├── preDriveService.js       # PreDrive API client
│   │   └── preMailService.js        # PreMail API client
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css
├── server.js                # Express backend for Venice AI proxy
├── deploy.sh                # Server deployment script
├── package.json
├── vite.config.js
└── index.html
```

---

## Completed Features

### 1. Core UI/UX
- [x] macOS Launchpad-inspired design
- [x] Responsive glassmorphism cards with backdrop blur
- [x] Dynamic greeting based on time of day (Good morning/afternoon/evening)
- [x] Dark mode toggle with full theme support
- [x] Presearch brand color palette integration
- [x] Smooth animations and hover effects
- [x] Keyboard shortcut (⌘K) to focus search

### 2. Search Bar
- [x] Autocomplete suggestions from Presearch API (`rt53.literallysafe.com/getSuggestions`)
- [x] Keyboard navigation (arrow keys, enter, escape)
- [x] PreGPT button integration
- [x] Dark mode support
- [x] Search redirects to presearch.com

### 3. PreGPT AI Chat
- [x] Streaming responses from Venice AI
- [x] User/Assistant message bubbles
- [x] Sources dropdown with external links
- [x] Related searches chips
- [x] Typing indicator during streaming
- [x] Markdown parsing (bold, italic, code, links)
- [x] Dark mode support
- [x] "Anonymous & Non-profiling" header

### 4. App Modals
Interactive modals for each PreSuite app:

| App | Features | Status |
|-----|----------|--------|
| **PreMail** | Inbox, folders (Sent, Starred, Archive, Trash), email list, compose button, search | ✅ Real data via PreMail API |
| **PreDrive** | File browser, folders/files list, upload, new folder, breadcrumb, storage indicator | ✅ Real data via PreDrive API |
| **PreDocs** | Recent documents grid, document list, new document button, shared indicators | Demo data |
| **PreSheets** | Spreadsheet grid previews, row counts, timestamps | Demo data |
| **PreSlides** | Presentation cards, slide counts, aspect-ratio previews | Demo data |
| **PreCalendar** | Monthly calendar, today's events, new event button | Demo data |
| **PreWallet** | Balance card, Send/Receive/Swap, staking stats, transaction history | Demo data |

### 5. Dashboard Widgets
- [x] Recent files section (real data from PreDrive API)
- [x] Trust/verification status card
- [x] Storage usage indicator (real data from PreDrive API)
- [x] PRE Balance card with gradient design
- [x] Notifications dropdown with badge count
- [x] User profile panel (click avatar to open)

### 6. Backend & Deployment
- [x] Express server proxying to Venice AI
- [x] PM2 process management with auto-restart
- [x] Nginx reverse proxy configuration
- [x] SSL certificate via Let's Encrypt
- [x] API endpoints:
  - `GET /api/pregpt/status` - Health check
  - `POST /api/pregpt/summary` - Streaming AI summary
  - `POST /api/pregpt/ask` - Follow-up questions
  - `POST /api/pregpt/related-searches` - Related search suggestions

### 7. Central Identity Provider (v2.0.0)
- [x] PostgreSQL database for user storage
- [x] Auth API endpoints:
  - `POST /api/auth/register` - Create new account
  - `POST /api/auth/login` - Authenticate user
  - `GET /api/auth/verify` - Validate JWT token
  - `GET /api/auth/me` - Get current user
  - `PATCH /api/auth/me` - Update user profile
  - `POST /api/auth/logout` - End session
  - `POST /api/auth/reset-password` - Password reset
  - `GET /api/auth/health` - Auth service health
- [x] Stalwart mailbox provisioning on registration
- [x] JWT token issuance for all PreSuite services
- [x] CORS enabled for all PreSuite domains

### 8. Frontend Auth Pages (v2.0.1)
- [x] Login page (`/login`) with glassmorphism design
- [x] Register page (`/register`) with password validation
- [x] Auth service for API communication
- [x] React Router for page navigation
- [x] Dark mode support on auth pages
- [x] Redirect after successful auth
- [x] Error handling and loading states

---

## Pending Features (TODO)

### High Priority
1. ~~**Replace hardcoded Recent files with actual data/storage integration**~~ ✅ COMPLETED
   - Connected to PreDrive API via `preDriveService.js`
   - Shows user's actual recent files from PreDrive

2. ~~**Implement actual storage tracking**~~ ✅ COMPLETED
   - Connected to PreDrive API storage endpoint
   - Shows real storage usage with progress bar

3. **Connect PRE Balance to real wallet/blockchain data**
   - Integrate with Presearch wallet API or blockchain
   - Show real PRE token balance

4. ~~**Add user authentication/login system**~~ ✅ COMPLETED
   - User accounts with secure authentication
   - Session management
   - Profile data storage

### Medium Priority
5. ~~**Implement Settings panel functionality**~~ ✅ COMPLETED
   - Theme preferences (dark mode toggle)
   - Notification settings
   - Account settings
   - Privacy controls

6. ~~**Add notifications system**~~ ✅ COMPLETED
   - Notifications dropdown with bell icon
   - Mark as read/delete functionality
   - Badge count for unread notifications
   - Persisted to localStorage

7. ~~**Persist PreGPT chat history across sessions**~~ ✅ COMPLETED
   - Stored in localStorage
   - Chat history retrieval
   - Conversation management

### Future Enhancements
- ~~Connect app modals to real backend services~~ ✅ PreMail & PreDrive connected
- File upload/download in PreDrive
- ~~Real email integration in PreMail~~ ✅ COMPLETED
- Document editing in PreDocs
- Spreadsheet functionality in PreSheets
- Presentation viewer in PreSlides
- Calendar sync in PreCalendar
- Real wallet transactions in PreWallet

---

## Server Configuration

### Nginx Config (`/etc/nginx/sites-available/presuite`)
```nginx
server {
    listen 80;
    server_name presuite.eu www.presuite.eu 76.13.2.221;

    # Redirects to HTTPS (managed by certbot)
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name presuite.eu www.presuite.eu;

    ssl_certificate /etc/letsencrypt/live/presuite.eu/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/presuite.eu/privkey.pem;

    root /var/www/presuite/dist;
    index index.html;

    # API proxy to Node.js backend
    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_read_timeout 120s;
        proxy_buffering off;
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static asset caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

### PM2 Process
```bash
# Check status
pm2 status

# Restart API
pm2 restart presuite-api

# View logs
pm2 logs presuite-api
```

---

## API Configuration

### Venice AI Integration
The backend (`server.js`) proxies requests to Venice AI:

```javascript
const VENICE_API_URL = 'https://api.venice.ai/api/v1';
const VENICE_API_KEY = process.env.VENICE_API_KEY; // Stored in server .env

// Models used:
// - Fast: llama-3.3-70b
// - Balanced: llama-3.1-405b
// - Best: llama-3.1-405b
```

### Frontend API Client
Located at `src/services/preGPTService.js`:
- Uses relative URL `/api/pregpt` in production
- Uses `http://localhost:3001/api/pregpt` in development
- Automatic retry with exponential backoff
- Request cancellation support
- Configurable timeouts

---

## Development Commands

```bash
# Install dependencies
npm install

# Start development server (frontend + backend)
npm start

# Start frontend only
npm run dev

# Start backend only
npm run server

# Build for production
npm run build
```

---

## Deployment Workflow

The server has a git-based deployment setup at `/var/www/presuite/`.

### Local Development → Deploy

**Step 1: Make changes locally**
```bash
cd /path/to/presuite
# Edit files...
```

**Step 2: Commit and push to GitHub**
```bash
git add -A
git commit -m "Your changes"
git push origin main
```

**Step 3: Deploy to server**
```bash
# Option A: Use deploy script (recommended)
ssh root@76.13.2.221 "/var/www/presuite/deploy.sh"

# Option B: Manual deployment
ssh root@76.13.2.221
cd /var/www/presuite
git pull origin main
npm install  # Only if dependencies changed
npm run build
```

### Server Paths
| Path | Description |
|------|-------------|
| `/var/www/presuite/` | Git repository root |
| `/var/www/presuite/dist/` | Built files (served by Nginx) |
| `/var/www/presuite/deploy.sh` | Auto-deploy script |
| `/var/www/presuite-api/` | Backend API (separate) |

### Deploy Script (`/var/www/presuite/deploy.sh`)
```bash
#!/bin/bash
cd /var/www/presuite
echo "Pulling latest changes..."
git pull origin main
echo "Installing dependencies..."
npm install
echo "Building..."
npm run build
echo "Done! Site updated."
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `src/components/PreSuiteLaunchpad.jsx` | Main landing page with all UI components |
| `src/components/SearchBar.jsx` | Search input with autocomplete |
| `src/components/PreGPTChat.jsx` | AI chat modal component |
| `src/components/AppModal.jsx` | All app modal UIs (700+ lines) |
| `src/components/Notifications.jsx` | Notifications dropdown with badge |
| `src/components/UserProfile.jsx` | User profile panel |
| `src/components/Settings.jsx` | Settings panel modal |
| `src/components/Login.jsx` | Login page with auth flow |
| `src/components/Register.jsx` | Registration page with validation |
| `src/services/preGPTService.js` | Venice AI API client |
| `src/services/authService.js` | Auth API client (login, register, etc.) |
| `src/services/preDriveService.js` | PreDrive API client (files, storage) |
| `src/services/preMailService.js` | PreMail API client (emails, unread counts) |
| `server.js` | Express backend for API proxy |

---

## Design Specifications

### Color Palette
```javascript
const colors = {
  primary: {
    50: '#EBF4FF',
    500: '#3591FC',  // Main brand color
    600: '#2D8EFF',
    900: '#102C4C',
  },
  dark: {
    100: '#242424',
    200: '#1e1e1e',
    500: '#0f0f0f',
  },
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  purple: '#8B5CF6',
  pink: '#EC4899',
  orange: '#F97316',
};
```

### Typography
- Font: System default (San Francisco on macOS)
- Headings: Bold, responsive sizes
- Body: Regular weight, gray-600/gray-400 for dark mode

### Glassmorphism
```css
background: rgba(255, 255, 255, 0.7);  /* Light mode */
background: rgba(30, 30, 30, 0.8);     /* Dark mode */
backdrop-filter: blur(20px);
border: 1px solid rgba(255, 255, 255, 0.1);
```

---

## Notes for AI Agent

1. **When making changes**, commit to GitHub and run `ssh root@76.13.2.221 "/var/www/presuite/deploy.sh"`
2. **Backend changes** require PM2 restart: `ssh root@76.13.2.221 "pm2 restart presuite-api"`
3. **Test PreGPT** with: `curl -s https://presuite.eu/api/pregpt/status`
4. **PreMail and PreDrive modals** are connected to real APIs; other app modals use demo data
5. **Dark mode state** is managed in PreSuiteLaunchpad and passed down via `isDark` prop
6. **Venice AI key** is stored in environment variables on the server

---

## Related Projects

- **PreDrive:** See `/presearch/ARC/PREDRIVE.md`
- **PreMail:** See `/presearch/ARC/PREMAIL.md`
- **PreOffice:** See `/presearch/ARC/PREOFFICE.md`

---

*Last updated: January 15, 2026*
