# Rich Text Compose Editor for PreMail

## Overview
Replace the plain `<textarea>` in ComposePage with a TipTap-based rich text editor supporting full email formatting.

## Current State
- **File:** `/Users/tijnhoorneman/Documents/Documents-MacBook/presearch/premail/apps/web/src/pages/ComposePage.tsx`
- **Current:** Plain `<textarea>` with naive `\n` → `<br>` conversion
- **Backend:** Already supports `html` field - no backend changes needed

## Implementation Plan

### Step 1: Install TipTap Dependencies
```bash
cd /Users/tijnhoorneman/Documents/Documents-MacBook/presearch/premail/apps/web
pnpm add @tiptap/react @tiptap/pm @tiptap/starter-kit \
  @tiptap/extension-link @tiptap/extension-image @tiptap/extension-table \
  @tiptap/extension-table-row @tiptap/extension-table-cell @tiptap/extension-table-header \
  @tiptap/extension-text-align @tiptap/extension-color @tiptap/extension-text-style \
  @tiptap/extension-font-family @tiptap/extension-underline @tiptap/extension-placeholder \
  @tiptap/extension-code-block-lowlight lowlight
```

### Step 2: Create RichTextEditor Component
**New file:** `apps/web/src/components/RichTextEditor.tsx`

Features to implement:
- TipTap editor with all extensions configured
- Toolbar with formatting buttons:
  - Text style: Bold, Italic, Underline, Strikethrough
  - Headings: H1, H2, H3
  - Lists: Bullet, Numbered
  - Alignment: Left, Center, Right, Justify
  - Links: Insert/edit link
  - Images: Insert image (URL or inline base64)
  - Tables: Insert/edit table
  - Code blocks: With syntax highlighting
  - Text color & highlight
  - Font family selector
  - Clear formatting
- Bubble menu for quick formatting on selection
- Placeholder text support
- Dark mode styling matching PreMail theme

### Step 3: Create Toolbar Component
**New file:** `apps/web/src/components/EditorToolbar.tsx`

- Icon-based toolbar using lucide-react icons
- Tooltip on hover
- Active state highlighting
- Dropdown menus for headings, colors, fonts
- Table insertion dialog
- Link insertion dialog with validation

### Step 4: Update ComposePage
**Modify:** `apps/web/src/pages/ComposePage.tsx`

Changes:
1. Replace `<textarea>` with `<RichTextEditor>`
2. Update state from `body: string` to editor content
3. Generate both `text` and `html` on send:
   - `html`: editor.getHTML()
   - `text`: editor.getText() (plain text fallback)
4. Add "Plain text" toggle option
5. Handle paste (strip dangerous HTML)

### Step 5: Add Editor Styles
**Modify:** `apps/web/src/index.css`

Add TipTap-specific styles:
- `.ProseMirror` base styles
- Table styling
- Code block styling with syntax highlighting
- Image handling (max-width, centering)
- Blockquote styling
- Link styling (underline, color)
- Dark mode variants

### Step 6: Handle Reply/Forward Quoting
When replying/forwarding, prepend quoted content with proper HTML formatting:
- Add blockquote wrapper
- Include original sender info
- Preserve original HTML formatting

## Files to Create/Modify

| Action | File |
|--------|------|
| Create | `apps/web/src/components/RichTextEditor.tsx` |
| Create | `apps/web/src/components/EditorToolbar.tsx` |
| Modify | `apps/web/src/pages/ComposePage.tsx` |
| Modify | `apps/web/src/index.css` |

## Verification

1. **Build check:** `cd apps/web && pnpm build` - no TypeScript errors
2. **Visual test:** Open compose page, verify toolbar renders
3. **Formatting test:** Apply bold, italic, lists, headings - verify HTML output
4. **Table test:** Insert table, add rows/columns
5. **Image test:** Insert image via URL
6. **Link test:** Add link, verify href works
7. **Send test:** Compose formatted email, send, verify received email has formatting
8. **Dark mode:** Toggle theme, verify editor adapts
9. **Reply test:** Reply to email, verify quote block appears

## Technical Details

### TipTap Extensions Configuration
```typescript
const extensions = [
  StarterKit.configure({
    heading: { levels: [1, 2, 3] },
    codeBlock: false, // Use lowlight version
  }),
  Underline,
  Link.configure({ openOnClick: false }),
  Image.configure({ inline: true }),
  Table.configure({ resizable: true }),
  TableRow,
  TableCell,
  TableHeader,
  TextAlign.configure({ types: ['heading', 'paragraph'] }),
  TextStyle,
  Color,
  FontFamily,
  Placeholder.configure({ placeholder: 'Write your message...' }),
  CodeBlockLowlight.configure({ lowlight }),
];
```

### Theme Colors (Presearch Brand)
- Primary: `#0190FF` (Presearch Azure)
- Dark bg: `#1e1e1e`
- Dark surface: `#262626`
- Light bg: `#f5f5f5`
- Text: `#1e1e1e` / dark: `#f5f5f5`
