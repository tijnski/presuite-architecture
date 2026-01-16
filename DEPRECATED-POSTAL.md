# Postal Deprecation Notice

> **Status:** TO BE REMOVED
> **Created:** January 16, 2026

---

## Summary

Postal mail server integration was planned but never fully implemented. PreMail uses **Stalwart Mail Server** directly for both inbound and outbound email. Postal code should be removed from the codebase.

---

## Current State

### Files to Remove

**PreMail repository (`premail/`):**

```
packages/postal/           # Entire directory - never used
├── src/
│   ├── index.ts
│   ├── client.ts
│   └── types.ts
├── package.json
└── tsconfig.json
```

**References to remove:**

| File | Reference |
|------|-----------|
| `premail/package.json` | `@premail/postal` workspace reference |
| `premail/pnpm-workspace.yaml` | `packages/postal` entry (if exists) |
| `premail/apps/api/package.json` | Any `@premail/postal` dependency |
| `premail/.env.example` | Any `POSTAL_*` environment variables |

**ARC documentation:**
| File | Action |
|------|--------|
| `PREMAIL.md` | Remove `postal/` from project structure |
| `IMPLEMENTATION-STATUS.md` | Remove Postal migration tasks |
| `architecture/INFRASTRUCTURE.md` | Remove Postal from external services diagram |

---

## Why Not Postal?

1. **Stalwart handles everything** - IMAP and SMTP for @premail.site
2. **Simpler architecture** - One mail server instead of two
3. **Never implemented** - Postal integration was planned but not completed
4. **Maintenance burden** - Extra code with no benefit

---

## Removal Steps

### 1. Remove Postal Package
```bash
cd premail
rm -rf packages/postal
```

### 2. Update package.json
Remove any `@premail/postal` references from:
- Root `package.json`
- `apps/api/package.json`

### 3. Clean Environment
Remove from `.env` and `.env.example`:
```bash
# Remove these lines:
POSTAL_API_URL=
POSTAL_API_KEY=
POSTAL_SERVER=
```

### 4. Update Documentation
- [ ] Update `PREMAIL.md` project structure
- [ ] Remove from `IMPLEMENTATION-STATUS.md`
- [ ] Update architecture diagrams

### 5. Verify Build
```bash
cd premail
pnpm install
pnpm build
pnpm test
```

---

## After Removal

PreMail email flow will remain:
```
User → PreMail API → Stalwart SMTP → Recipient
                   ↓
            Stalwart IMAP (Sent Items)
```

No Postal involvement needed.

---

## Related

- [PREMAIL.md](PREMAIL.md) - PreMail documentation
- [IMPLEMENTATION-STATUS.md](IMPLEMENTATION-STATUS.md) - Task tracking
