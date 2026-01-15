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
│   │   ├── PreGPTChat.jsx           # AI chat modal
│   │   └── AppModal.jsx             # App modals (Mail, Drive, etc.)
│   ├── services/
│   │   └── preGPTService.js         # API client for PreGPT
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css
├── server.js                # Express backend for Venice AI proxy
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

### 4. App Modals (Functional Placeholders)
All apps open interactive modals with demo data:

| App | Features |
|-----|----------|
| **PreMail** | Inbox, folders (Sent, Starred, Archive, Trash), email list, compose button, search |
| **PreDrive** | File browser, folders/files list, upload, new folder, breadcrumb, storage indicator |
| **PreDocs** | Recent documents grid, document list, new document button, shared indicators |
| **PreSheets** | Spreadsheet grid previews, row counts, timestamps |
| **PreSlides** | Presentation cards, slide counts, aspect-ratio previews |
| **PreCalendar** | Monthly calendar, today's events, new event button |
| **PreWallet** | Balance card, Send/Receive/Swap, staking stats, transaction history |

### 5. Dashboard Widgets
- [x] Recent files section (4 items with app icons)
- [x] Trust/verification status card
- [x] Storage usage indicator (progress bar)
- [x] PRE Balance card with gradient design

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

---

## Pending Features (TODO)

### High Priority
1. **Replace hardcoded Recent files with actual data/storage integration**
   - Connect to real file system or database
   - Track user's actual recent activity

2. **Implement actual storage tracking**
   - Currently shows mock "4.2 GB / 30 GB"
   - Need real storage calculation

3. **Connect PRE Balance to real wallet/blockchain data**
   - Integrate with Presearch wallet API or blockchain
   - Show real PRE token balance

4. **Add user authentication/login system**
   - User accounts with secure authentication
   - Session management
   - Profile data storage

### Medium Priority
5. **Implement Settings panel functionality**
   - Theme preferences
   - Notification settings
   - Account settings
   - Privacy controls

6. **Add notifications system**
   - Real-time notifications
   - Notification preferences
   - Bell icon badge count

7. **Persist PreGPT chat history across sessions**
   - Local storage or backend storage
   - Chat history retrieval
   - Conversation management

### Future Enhancements
- Connect app modals to real backend services
- File upload/download in PreDrive
- Real email integration in PreMail
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

    root /var/www/presuite;
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
const VENICE_API_KEY = 'H8d2T0helnDflIuGixZRRRAhEw0eJHdMWu6CRfXMH7';

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

# Deploy to production
scp -r dist/* root@76.13.2.221:/var/www/presuite/
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `src/components/PreSuiteLaunchpad.jsx` | Main landing page with all UI components |
| `src/components/SearchBar.jsx` | Search input with autocomplete |
| `src/components/PreGPTChat.jsx` | AI chat modal component |
| `src/components/AppModal.jsx` | All app modal UIs (700+ lines) |
| `src/services/preGPTService.js` | Venice AI API client |
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

1. **When making changes**, always rebuild with `npm run build` and deploy with `scp`
2. **Backend changes** require PM2 restart: `ssh root@76.13.2.221 "pm2 restart presuite-api"`
3. **Test PreGPT** with: `curl -s https://presuite.eu/api/pregpt/status`
4. **The app modals are placeholders** - they have realistic UI but no real backend functionality yet
5. **Dark mode state** is managed in PreSuiteLaunchpad and passed down via `isDark` prop
6. **Venice AI key** is hardcoded in server.js - consider moving to environment variables

---

## Related Projects

- **PreDrive:** See `/presearch/ARC/PREDRIVE.md`
- **PreMail:** See `/presearch/ARC/Premail.md`
- **PreOffice:** See `/presearch/ARC/PREOFFICE.md`

---

*Last updated: January 15, 2026*
