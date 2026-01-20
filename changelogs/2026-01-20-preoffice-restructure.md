# PreOffice Restructure & UI Streamlining

**Date:** January 20, 2026
**Author:** Claude Opus 4.5

---

## Summary

Major restructuring of PreOffice: separated the combined repository into two dedicated repos (web and desktop), streamlined the UI to match PreSuite Hub design system, and updated all deployment configurations.

---

## 1. UI Streamlining (preoffice.site)

### Footer Update
- **Before:** "PreOffice Online - Part of the Presearch ecosystem"
- **After:** "Don't trust us, **Pre-verify us** - Your data. Your control."
- Added lock icon SVG for privacy emphasis
- "Powered by LibreOffice Technology" as secondary line with reduced opacity

### App Card Styling
- Icons resized from 80x80px to 64x64px
- Hover opacity changed from 0.8 to 0.7
- Border-radius changed from 16px to 12px (rounded-xl)
- Shadow lightened to `0 2px 8px rgba(0, 0, 0, 0.1)`

### PrePanda AI Button
- Added purple button (#8B5CF6) to header navigation
- Positioned before Sign In button
- Sparkle icon with "PrePanda" label
- Opens PrePanda AI assistant window at `presuite.eu/prepanda`
- Responsive: label hidden on mobile, icon-only display

### Hover Effect Consistency
- Buttons: opacity 0.9 on hover (was 0.6)
- Cards/links: opacity 0.7 on hover
- Logo: opacity 0.7 on hover
- All transitions using 0.15s ease

### Hero Section Polish
- h1 font size reduced from 3rem to 2.5rem
- Paragraph font size reduced from 1.25rem to 1rem
- Max-width tightened from 600px to 500px

---

## 2. Repository Separation

### Old Structure (Archived)
```
tijnski/preoffice (ARCHIVED)
├── core/                    # LibreOffice source (13GB, gitignored)
├── presearch/online/        # Web version
├── presearch/extension/     # Desktop extensions
├── presearch/ui/            # Desktop UI
├── packaging/               # Desktop packaging
└── installers/              # Desktop installers
```

### New Structure

#### preoffice-web (https://github.com/tijnski/preoffice-web)
Production web version deployed to https://preoffice.site
```
preoffice-web/
├── docker-compose.yml       # Container orchestration
├── wopi-server/             # WOPI protocol server
│   └── src/index.js
├── nginx/                   # Reverse proxy config
│   └── nginx.conf
├── branding/                # Landing page
│   └── static/index.html
├── ai-assistant/            # PrePanda AI integration
├── brand/                   # Design tokens & assets
├── scripts/                 # Deployment scripts
├── .env.example
└── README.md
```

#### preoffice-desktop (https://github.com/tijnski/preoffice-desktop)
LibreOffice-based desktop application (build locally)
```
preoffice-desktop/
├── build.sh                 # LibreOffice build script
├── autogen.input            # Build configuration
├── BUILD.md                 # Build instructions
├── presearch/
│   ├── extension/           # PrePanda extension (.oxt)
│   ├── ui/                  # Custom UI & themes
│   │   ├── icon-theme/
│   │   ├── color-scheme/
│   │   ├── startcenter/
│   │   └── templates/
│   └── integrations/        # PreDrive, PreGPT integrations
├── presearch-office/        # Additional branding
├── packaging/               # macOS, Linux, Windows
├── installers/              # Platform-specific installers
├── fonts/                   # Custom fonts
├── docs/                    # Documentation
└── compliance/              # Licensing (MPL-2.0, MIT)
```

---

## 3. Server Deployment Updates

### Before
```bash
# Old path structure
/opt/preoffice/presearch/online/docker-compose.yml
```

### After
```bash
# New path structure (preoffice-web repo at root)
/opt/preoffice/docker-compose.yml
```

### Migration Steps Performed
1. Stopped Docker containers on server
2. Backed up .env file
3. Moved old repo to /opt/preoffice-old
4. Cloned preoffice-web to /opt/preoffice
5. Restored .env and collabora-config
6. Started Docker containers
7. Verified site responding (HTTP 200)
8. Removed old backup

### Updated Deploy Command
```bash
# Old
ssh root@76.13.2.220 "cd /opt/preoffice && git pull && cd presearch/online && docker compose up -d --build"

# New
ssh root@76.13.2.220 "cd /opt/preoffice && git pull && docker compose up -d --build"
```

---

## 4. GitHub Changes

| Action | Repository | URL |
|--------|------------|-----|
| Created | preoffice-web | https://github.com/tijnski/preoffice-web |
| Created | preoffice-desktop | https://github.com/tijnski/preoffice-desktop |
| Archived | preoffice | https://github.com/tijnski/preoffice |

---

## 5. Documentation Updates

### CLAUDE.md
- Updated GitHub Repositories section with new repos
- Added note about archived preoffice repo
- Updated PreOffice service details with both repo structures
- Fixed deploy and logs commands for new directory structure
- Updated "Last Updated" date to January 20, 2026

---

## 6. Local Folder Changes

### Deleted
- `/Users/.../presearch/preoffice/` (old combined repo)

### Created
- `/Users/.../presearch/preoffice-web/` (Collabora Online web version)
- `/Users/.../presearch/preoffice-desktop/` (LibreOffice desktop version)

---

## Commits

| Repository | Commit | Message |
|------------|--------|---------|
| preoffice | 4b7ea58 | Streamline PreOffice UI to match PreSuite design system |
| preoffice-web | dbf7faf | Initial commit: PreOffice Web (Collabora Online) |
| preoffice-desktop | a74dcac | Initial commit: PreOffice Desktop (LibreOffice-based) |
| presuite-architecture | 1e518e6 | Update CLAUDE.md with new PreOffice repo structure |
| presuite-architecture | d87581d | Add changelog for PreOffice repo separation |

---

## Verification

- [x] https://preoffice.site returns HTTP 200
- [x] UI changes visible (footer, PrePanda button, card styling)
- [x] preoffice-web repo accessible on GitHub
- [x] preoffice-desktop repo accessible on GitHub
- [x] Old preoffice repo archived
- [x] Server running from new repo structure
- [x] Documentation updated
