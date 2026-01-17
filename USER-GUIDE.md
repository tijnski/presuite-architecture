# PreSuite User Guide

> **Version:** 1.1
> **Last Updated:** January 17, 2026

---

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [PreSuite Hub](#2-presuite-hub)
3. [PreMail - Email](#3-premail---email)
4. [PreDrive - Cloud Storage](#4-predrive---cloud-storage)
5. [PreOffice - Document Editing](#5-preoffice---document-editing)
6. [Single Sign-On (SSO)](#6-single-sign-on-sso)
7. [Keyboard Shortcuts](#7-keyboard-shortcuts)
8. [Troubleshooting](#8-troubleshooting)
9. [Privacy & Security](#9-privacy--security)

---

## 1. Getting Started

### 1.1 What is PreSuite?

PreSuite is a privacy-focused productivity suite that includes:

| Application | Purpose | URL |
|-------------|---------|-----|
| **PreSuite Hub** | Central dashboard & account management | https://presuite.eu |
| **PreMail** | Email client with threading & search | https://premail.site |
| **PreDrive** | Cloud file storage & sharing | https://predrive.eu |
| **PreOffice** | Document, spreadsheet & presentation editor | https://preoffice.site |
| **PreSocial** | Community discussions & forums | https://presocial.presuite.eu |

### 1.2 Creating an Account

1. Visit https://presuite.eu
2. Click **"Sign Up"**
3. Enter your email address
4. Create a strong password (must include uppercase, lowercase, number, and special character)
5. Enter your name
6. Click **"Create Account"**
7. Verify your email address by clicking the link sent to your inbox

### 1.3 Signing In

You can sign in to any PreSuite application in three ways:

**Option A: Direct Login**
1. Go to the application (e.g., https://premail.site)
2. Enter your email and password
3. Click **"Sign In"**

**Option B: Single Sign-On (Recommended)**
1. Go to any PreSuite application
2. Click **"Sign in with PreSuite"**
3. You'll be redirected to PreSuite Hub
4. Sign in once
5. You're now signed in to all PreSuite apps

**Option C: Web3 Wallet Login**
1. Go to https://presuite.eu
2. Click **"Connect Wallet"**
3. MetaMask (or compatible wallet) will prompt for connection
4. Sign the authentication message
5. Your account is automatically created with a `@web3.premail.site` email address

---

## 2. PreSuite Hub

### 2.1 Dashboard Overview

The PreSuite Hub is your central command center:

```
┌─────────────────────────────────────────────────────────────┐
│  PreSuite Hub                                    [User ▼]   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Welcome back, [Your Name]!                                │
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│   │             │  │             │  │             │        │
│   │   PreMail   │  │  PreDrive   │  │  PreOffice  │        │
│   │             │  │             │  │             │        │
│   │   [Open]    │  │   [Open]    │  │   [Open]    │        │
│   └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│   Recent Activity                                           │
│   ├─ Email from john@example.com          2 minutes ago    │
│   ├─ Uploaded report.pdf                  15 minutes ago   │
│   └─ Edited Q4 Budget.xlsx                1 hour ago       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Account Settings

Access your account settings by clicking your name in the top right corner:

- **Profile** - Update your name and profile picture
- **Security** - Change password, enable two-factor authentication
- **Connected Apps** - View and manage OAuth app connections
- **Notifications** - Configure email and push notification preferences

---

## 3. PreMail - Email

### 3.1 Interface Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PreMail                              [Search...]        [Compose]      │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌────────────────────────────┐  ┌─────────────────────┐ │
│  │ FOLDERS  │  │ INBOX (23)                 │  │ MESSAGE VIEW        │ │
│  │          │  │                            │  │                     │ │
│  │ Inbox    │  │ ○ John Doe                 │  │ From: John Doe      │ │
│  │ Sent     │  │   Project Update           │  │ To: You             │ │
│  │ Drafts   │  │   Hey, here's the...       │  │ Subject: Project... │ │
│  │ Spam     │  │   10:34 AM                 │  │                     │ │
│  │ Trash    │  │                            │  │ Hey,                │ │
│  │          │  │ ● Jane Smith        (3)    │  │                     │ │
│  │ Labels   │  │   Re: Meeting Notes        │  │ Here's the latest   │ │
│  │ ├ Work   │  │   Thanks for sending...    │  │ update on the       │ │
│  │ ├ Personal│ │   9:15 AM                  │  │ project...          │ │
│  │ └ Projects│ │                            │  │                     │ │
│  │          │  │ ○ Newsletter               │  │ [Reply] [Forward]   │ │
│  │          │  │   Weekly Digest            │  │                     │ │
│  └──────────┘  └────────────────────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Reading Email

**Viewing a Message:**
1. Click on any email in your inbox
2. The message content appears in the right panel
3. Thread indicator (3) shows related messages in the conversation

**Conversation View:**
- Emails are automatically grouped into threads
- Click the thread count to expand and see all messages
- Most recent message appears at the bottom

### 3.3 Composing Email

**Writing a New Email:**
1. Click the **[Compose]** button
2. Fill in the fields:
   - **To:** Recipient email address (separate multiple with commas)
   - **Cc:** Carbon copy recipients (optional)
   - **Bcc:** Blind carbon copy (optional)
   - **Subject:** Email subject line
   - **Body:** Your message
3. Click **[Send]**

**Formatting Options:**
- **Bold** - Ctrl/Cmd + B
- *Italic* - Ctrl/Cmd + I
- Underline - Ctrl/Cmd + U
- Bullet list - Click list icon
- Numbered list - Click numbered list icon

**Attachments:**
1. Click the paperclip icon or drag files into the compose window
2. Maximum attachment size: 25MB per file
3. Supported formats: PDF, Office documents, images, archives

### 3.4 Managing Email

**Actions:**
| Action | How To |
|--------|--------|
| Reply | Click **[Reply]** or press R |
| Reply All | Click **[Reply All]** or press A |
| Forward | Click **[Forward]** or press F |
| Delete | Click trash icon or press Delete |
| Archive | Click archive icon or press E |
| Mark as Read/Unread | Click envelope icon or press U |
| Star/Important | Click star icon or press S |

**Organizing with Labels:**
1. Select one or more emails (checkbox on left)
2. Click the label icon
3. Choose an existing label or create a new one
4. Labels appear as colored tags on emails

**Filtering & Search:**
- Use the search bar to find emails
- Search operators:
  - `from:john@example.com` - Emails from specific sender
  - `to:me` - Emails sent to you
  - `subject:meeting` - Emails with "meeting" in subject
  - `has:attachment` - Emails with attachments
  - `after:2026-01-01` - Emails after a date
  - `before:2026-01-15` - Emails before a date

### 3.5 External Email Accounts

Connect your existing email accounts to PreMail:

1. Go to **Settings** → **Accounts**
2. Click **[Add Account]**
3. Enter your email provider details:
   - Email address
   - IMAP server (e.g., imap.gmail.com)
   - IMAP port (usually 993)
   - SMTP server (e.g., smtp.gmail.com)
   - SMTP port (usually 587)
   - Password or App Password
4. Click **[Connect]**

**Common Provider Settings:**

| Provider | IMAP Server | SMTP Server |
|----------|-------------|-------------|
| Gmail | imap.gmail.com:993 | smtp.gmail.com:587 |
| Outlook | outlook.office365.com:993 | smtp.office365.com:587 |
| Yahoo | imap.mail.yahoo.com:993 | smtp.mail.yahoo.com:587 |

### 3.6 Push Notifications

Enable push notifications to get alerted about new emails:

1. Go to **Settings** → **Notifications**
2. Toggle **"Enable Push Notifications"**
3. Your browser will ask for permission - click **Allow**
4. Choose which types of emails trigger notifications

---

## 4. PreDrive - Cloud Storage

### 4.1 Interface Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PreDrive                    [Search...]     [Upload ▲]  [New Folder]   │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌────────────────────────────────────────────────────┐  │
│  │ SIDEBAR  │  │ My Drive > Documents                               │  │
│  │          │  │                                                    │  │
│  │ My Drive │  │  Name              Size      Modified    Actions   │  │
│  │ Shared   │  │  ─────────────────────────────────────────────     │  │
│  │ Recent   │  │  📁 Projects       --        Jan 10      ⋮        │  │
│  │ Starred  │  │  📁 Reports        --        Jan 12      ⋮        │  │
│  │ Trash    │  │  📄 Budget.xlsx    245 KB    Jan 14      ⋮        │  │
│  │          │  │  📄 Notes.docx     52 KB     Jan 15      ⋮        │  │
│  │ Storage  │  │  🖼️ Photo.jpg      1.2 MB    Jan 15      ⋮        │  │
│  │ ████░░░  │  │                                                    │  │
│  │ 2.5/10GB │  │                                                    │  │
│  └──────────┘  └────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Uploading Files

**Method 1: Upload Button**
1. Click **[Upload ▲]** button
2. Select files from your computer
3. Wait for upload to complete

**Method 2: Drag and Drop**
1. Drag files from your computer
2. Drop them anywhere in the file list area
3. Progress bar shows upload status

**Upload Limits:**
- Maximum file size: 5GB per file
- Supported file types: All file types supported

### 4.3 Creating Folders

1. Click **[New Folder]** button
2. Enter folder name
3. Press Enter or click **[Create]**

**Folder Organization Tips:**
- Use descriptive names
- Create subfolders for projects
- Keep related files together

### 4.4 File Actions

Right-click any file or click the **⋮** menu to see options:

| Action | Description |
|--------|-------------|
| **Open** | View or edit the file |
| **Open with PreOffice** | Edit documents in PreOffice |
| **Download** | Download to your computer |
| **Share** | Create a sharing link |
| **Move** | Move to another folder |
| **Copy** | Create a copy |
| **Rename** | Change the file name |
| **Star** | Add to starred items |
| **Delete** | Move to trash |

### 4.5 Sharing Files

**Creating a Share Link:**
1. Right-click the file → **Share**
2. Configure sharing options:
   - **Anyone with link** - Public access
   - **Password protected** - Require password
   - **Expiration date** - Link expires after set date
3. Click **[Create Link]**
4. Copy the link and share it

**Sharing Settings:**
```
┌─────────────────────────────────────────┐
│ Share "Report.pdf"                      │
├─────────────────────────────────────────┤
│                                         │
│ Link access:                            │
│ ○ Anyone with the link                  │
│ ● Anyone with link and password         │
│                                         │
│ Password: [••••••••]                    │
│                                         │
│ Expires: [Jan 30, 2026    ▼]            │
│                                         │
│ Permissions:                            │
│ ○ View only                             │
│ ● View and download                     │
│                                         │
│ [Cancel]              [Create Link]     │
└─────────────────────────────────────────┘
```

**Managing Shared Links:**
1. Go to **Shared** in the sidebar
2. See all files you've shared
3. Click **⋮** to modify or revoke access

### 4.6 Trash & Recovery

**Deleting Files:**
- Select file(s) and press Delete, or
- Right-click → **Delete**
- Files move to Trash (not permanently deleted)

**Recovering Files:**
1. Go to **Trash** in sidebar
2. Right-click the file → **Restore**
3. File returns to original location

**Permanent Deletion:**
1. Go to **Trash**
2. Right-click → **Delete Forever**, or
3. Click **[Empty Trash]** to delete all

> **Note:** Files in Trash are automatically deleted after 30 days

### 4.7 Preview & Quick View

PreDrive supports previewing many file types without downloading:

| File Type | Preview Support |
|-----------|-----------------|
| Images (JPG, PNG, GIF, SVG) | Full preview |
| PDF | Full preview with pages |
| Text files | Full preview |
| Office documents | Preview via PreOffice |
| Video (MP4, WebM) | Video player |
| Audio (MP3, WAV) | Audio player |

**To preview:** Click the file name or press Space

---

## 5. PreOffice - Document Editing

### 5.1 Available Applications

PreOffice includes three main applications:

| App | Icon | File Types | Use For |
|-----|------|------------|---------|
| **PreDocs** | 📝 | .docx, .odt, .doc | Documents, letters, reports |
| **PreSheets** | 📊 | .xlsx, .ods, .xls | Spreadsheets, budgets, data |
| **PreSlides** | 📽️ | .pptx, .odp, .ppt | Presentations, slideshows |

### 5.2 Creating New Documents

**From PreOffice:**
1. Go to https://preoffice.site
2. Click **[New Document]**, **[New Spreadsheet]**, or **[New Presentation]**
3. Start editing

**From PreDrive:**
1. Click **[New]** button
2. Select document type
3. Document opens in PreOffice

### 5.3 Opening Existing Files

**From PreDrive:**
1. Right-click any Office document
2. Select **"Open with PreOffice"**
3. Document opens in a new tab

**Direct Upload:**
1. Go to https://preoffice.site
2. Click **[Open File]**
3. Select file from your computer

### 5.4 PreDocs - Document Editor

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PreDocs                                          [Share] [Download]    │
├─────────────────────────────────────────────────────────────────────────┤
│  File  Edit  View  Insert  Format  Tools  Help                          │
├─────────────────────────────────────────────────────────────────────────┤
│  [B] [I] [U] [S] | Font ▼ | Size ▼ | ¶ | ≡ | • | 1. |                  │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                                                                  │   │
│  │                     Quarterly Report                             │   │
│  │                                                                  │   │
│  │  Executive Summary                                               │   │
│  │                                                                  │   │
│  │  This quarter showed significant growth in all key metrics...    │   │
│  │                                                                  │   │
│  │  Key Highlights:                                                 │   │
│  │  • Revenue increased 15%                                         │   │
│  │  • Customer satisfaction at 94%                                  │   │
│  │  • New product launch successful                                 │   │
│  │                                                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                              Page 1/3   │
└─────────────────────────────────────────────────────────────────────────┘
```

**Common Features:**
- Text formatting (bold, italic, underline, strikethrough)
- Headings and paragraph styles
- Bullet and numbered lists
- Tables and images
- Headers and footers
- Page numbers
- Comments and track changes

### 5.5 PreSheets - Spreadsheet Editor

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PreSheets                                        [Share] [Download]    │
├─────────────────────────────────────────────────────────────────────────┤
│  File  Edit  View  Insert  Format  Data  Tools  Help                    │
├─────────────────────────────────────────────────────────────────────────┤
│  fx  =SUM(B2:B10)                                                       │
├─────────────────────────────────────────────────────────────────────────┤
│     │    A         │    B        │    C        │    D        │         │
│  ───┼──────────────┼─────────────┼─────────────┼─────────────┼         │
│   1 │ Item         │ Q1 Sales    │ Q2 Sales    │ Total       │         │
│  ───┼──────────────┼─────────────┼─────────────┼─────────────┼         │
│   2 │ Product A    │ $12,500     │ $15,200     │ $27,700     │         │
│   3 │ Product B    │ $8,300      │ $9,100      │ $17,400     │         │
│   4 │ Product C    │ $22,100     │ $24,800     │ $46,900     │         │
│  ───┼──────────────┼─────────────┼─────────────┼─────────────┼         │
│   5 │ Total        │ $42,900     │ $49,100     │ $92,000     │         │
│     │              │             │             │             │         │
├─────────────────────────────────────────────────────────────────────────┤
│  Sheet1  Sheet2  Sheet3  [+]                                            │
└─────────────────────────────────────────────────────────────────────────┘
```

**Common Features:**
- Formulas and functions (SUM, AVERAGE, VLOOKUP, etc.)
- Cell formatting (number, currency, date, percentage)
- Conditional formatting
- Charts and graphs
- Sorting and filtering
- Multiple sheets
- Freeze rows/columns

**Useful Formulas:**
| Formula | Description | Example |
|---------|-------------|---------|
| `=SUM(A1:A10)` | Add values | Sum of A1 through A10 |
| `=AVERAGE(B1:B10)` | Calculate average | Average of B1 through B10 |
| `=IF(A1>100,"Yes","No")` | Conditional | If A1 > 100, show "Yes" |
| `=VLOOKUP(A1,B:C,2,0)` | Lookup value | Find A1 in column B, return column C |
| `=TODAY()` | Current date | Today's date |
| `=CONCATENATE(A1," ",B1)` | Combine text | Join A1 and B1 with space |

### 5.6 PreSlides - Presentation Editor

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PreSlides                                        [Share] [Present]     │
├─────────────────────────────────────────────────────────────────────────┤
│  File  Edit  View  Insert  Slide  Format  Tools  Help                   │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────┐  ┌───────────────────────────────────────────────────────────┐│
│  │  1  │  │                                                           ││
│  │█████│  │              Annual Review 2026                           ││
│  │     │  │                                                           ││
│  ├─────┤  │                 Your Company                              ││
│  │  2  │  │                                                           ││
│  │     │  │                                                           ││
│  │     │  │                  [Insert Image]                           ││
│  ├─────┤  │                                                           ││
│  │  3  │  │                                                           ││
│  │     │  │                                                           ││
│  │     │  └───────────────────────────────────────────────────────────┘│
│  └─────┘                                                     Slide 1/10│
└─────────────────────────────────────────────────────────────────────────┘
```

**Common Features:**
- Slide layouts and templates
- Text boxes and shapes
- Images and media
- Transitions and animations
- Speaker notes
- Presentation mode (full screen)
- Export to PDF

**Presentation Mode:**
1. Click **[Present]** button or press F5
2. Use arrow keys to navigate slides
3. Press Escape to exit

### 5.7 Real-Time Collaboration

Work together with others on the same document:

1. Click **[Share]** button
2. Enter email addresses of collaborators
3. Set permissions (Editor or Viewer)
4. Click **[Send Invite]**

**Collaboration Features:**
- See other users' cursors in real-time
- Changes sync automatically
- Color-coded cursors for each user
- Comment and reply to discussions

```
┌─────────────────────────────────────────┐
│ Currently editing:                      │
│                                         │
│ 🔵 You (editing paragraph 2)            │
│ 🟢 John Doe (editing paragraph 5)       │
│ 🟡 Jane Smith (viewing)                 │
│                                         │
└─────────────────────────────────────────┘
```

### 5.8 Auto-Save & Version History

**Auto-Save:**
- Documents save automatically every few seconds
- Look for "All changes saved" indicator
- No need to manually save

**Version History:**
1. Go to **File** → **Version History**
2. See all previous versions with timestamps
3. Click to preview any version
4. Click **[Restore]** to revert to that version

### 5.9 Exporting Documents

**Download in Different Formats:**
1. Go to **File** → **Download As**
2. Choose format:
   - PDF (for sharing, printing)
   - Microsoft Office format (.docx, .xlsx, .pptx)
   - OpenDocument format (.odt, .ods, .odp)
   - Plain text (.txt) - documents only

---

## 6. Single Sign-On (SSO)

### 6.1 How SSO Works

Single Sign-On allows you to sign in once and access all PreSuite applications:

```
                    Sign in once
                         │
                         ▼
                  ┌─────────────┐
                  │  PreSuite   │
                  │    Hub      │
                  └──────┬──────┘
                         │
    ┌────────────┬───────┼───────┬────────────┐
    │            │       │       │            │
    ▼            ▼       ▼       ▼            ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ PreMail │ │PreDrive │ │PreOffice│ │PreSocial│
└─────────┘ └─────────┘ └─────────┘ └─────────┘
    ▲            ▲       ▲       ▲
    │            │       │       │
    └────────────┴───────┴───────┘
                 │
      Access all apps without
       signing in again
```

### 6.2 Using SSO

1. Go to any PreSuite application
2. Click **"Sign in with PreSuite"**
3. Enter your PreSuite credentials (if not already signed in)
4. You're automatically signed in to all apps

### 6.3 Session Management

- Sessions last for 7 days
- After 7 days, you'll need to sign in again
- For security, sign out when using public computers

**To Sign Out:**
1. Click your profile picture/name
2. Click **"Sign Out"**
3. You'll be signed out of all PreSuite apps

---

## 7. Keyboard Shortcuts

### 7.1 Global Shortcuts

| Shortcut | Action |
|----------|--------|
| Ctrl/Cmd + S | Save (in editors) |
| Ctrl/Cmd + Z | Undo |
| Ctrl/Cmd + Shift + Z | Redo |
| Ctrl/Cmd + C | Copy |
| Ctrl/Cmd + X | Cut |
| Ctrl/Cmd + V | Paste |
| Ctrl/Cmd + A | Select all |
| Ctrl/Cmd + F | Find |
| Ctrl/Cmd + P | Print |
| Escape | Close dialog/cancel |

### 7.2 PreMail Shortcuts

| Shortcut | Action |
|----------|--------|
| C | Compose new email |
| R | Reply |
| A | Reply all |
| F | Forward |
| E | Archive |
| # or Delete | Delete |
| U | Mark unread/read |
| S | Star/unstar |
| / | Focus search |
| J | Next email |
| K | Previous email |
| Enter | Open email |
| Escape | Close email |

### 7.3 PreDrive Shortcuts

| Shortcut | Action |
|----------|--------|
| U | Upload files |
| Shift + F | New folder |
| Enter | Open file/folder |
| Delete | Move to trash |
| Space | Preview file |
| Ctrl/Cmd + Click | Select multiple |
| Shift + Click | Select range |
| Ctrl/Cmd + A | Select all |
| F2 | Rename |
| Ctrl/Cmd + D | Download |

### 7.4 PreOffice Shortcuts

| Shortcut | Action |
|----------|--------|
| Ctrl/Cmd + B | Bold |
| Ctrl/Cmd + I | Italic |
| Ctrl/Cmd + U | Underline |
| Ctrl/Cmd + Shift + S | Strikethrough |
| Ctrl/Cmd + ] | Increase font size |
| Ctrl/Cmd + [ | Decrease font size |
| Ctrl/Cmd + L | Align left |
| Ctrl/Cmd + E | Align center |
| Ctrl/Cmd + R | Align right |
| Ctrl/Cmd + J | Justify |
| Tab | Indent |
| Shift + Tab | Outdent |
| F5 | Start presentation (PreSlides) |

---

## 8. Troubleshooting

### 8.1 Common Issues

#### Can't Sign In

**Problem:** "Invalid email or password" error

**Solutions:**
1. Check that Caps Lock is off
2. Verify you're using the correct email address
3. Try resetting your password:
   - Click "Forgot Password"
   - Enter your email
   - Check inbox for reset link

**Problem:** "Too many attempts" error

**Solution:** Wait 15 minutes before trying again (rate limiting protection)

---

#### Files Not Uploading

**Problem:** Upload fails or hangs

**Solutions:**
1. Check your internet connection
2. Verify file size is under 5GB
3. Try a different browser
4. Clear browser cache and try again
5. Disable browser extensions temporarily

---

#### Document Won't Open

**Problem:** PreOffice shows loading or error

**Solutions:**
1. Refresh the page (F5)
2. Check if the file is corrupted (try opening locally)
3. Try downloading and re-uploading the file
4. Clear browser cache
5. Check file format is supported

---

#### Email Not Sending

**Problem:** Emails stuck in Outbox

**Solutions:**
1. Check internet connection
2. Verify recipient email addresses
3. Check attachment size (max 25MB)
4. Try composing a new email
5. Check for spam folder delivery

---

#### SSO Not Working

**Problem:** "Sign in with PreSuite" redirects but doesn't sign in

**Solutions:**
1. Clear browser cookies
2. Try incognito/private browsing
3. Ensure pop-ups aren't blocked
4. Check if third-party cookies are enabled
5. Try a different browser

---

### 8.2 Browser Requirements

PreSuite works best with modern browsers:

| Browser | Minimum Version | Recommended |
|---------|-----------------|-------------|
| Chrome | 90+ | Latest |
| Firefox | 90+ | Latest |
| Safari | 14+ | Latest |
| Edge | 90+ | Latest |

**Required Settings:**
- JavaScript enabled
- Cookies enabled
- Local storage enabled
- Pop-ups allowed for presuite.eu

### 8.3 Getting Help

If you're still having issues:

1. **Check Status Page** - Visit status.presuite.eu for service status
2. **Search Help Center** - help.presuite.eu
3. **Contact Support** - support@presuite.eu
4. **Community Forum** - community.presuite.eu

---

## 9. Privacy & Security

### 9.1 Data Protection

**Your data is protected by:**

- **Encryption in Transit** - All data encrypted with TLS 1.3
- **Encryption at Rest** - Files encrypted in storage
- **Zero-Knowledge Design** - We can't read your files
- **European Servers** - Data stored in EU data centers
- **GDPR Compliant** - Full compliance with EU privacy laws

### 9.2 Security Best Practices

**Account Security:**
1. Use a strong, unique password
2. Enable two-factor authentication (2FA)
3. Don't share your login credentials
4. Sign out on shared computers
5. Review connected apps regularly

**File Security:**
1. Use password protection for sensitive shares
2. Set expiration dates on share links
3. Review who has access to shared files
4. Revoke access when no longer needed

**Email Security:**
1. Don't click suspicious links
2. Verify sender addresses
3. Be cautious with attachments
4. Report phishing to security@presuite.eu

### 9.3 Privacy Settings

Access privacy settings in any app:

1. Click your profile picture
2. Go to **Settings** → **Privacy**
3. Configure:
   - Activity logging
   - Data retention
   - Analytics opt-out
   - Marketing preferences

### 9.4 Data Export

You can export all your data at any time:

1. Go to PreSuite Hub
2. Click **Settings** → **Privacy** → **Export Data**
3. Select what to export:
   - Account information
   - All emails
   - All files
   - All documents
4. Click **[Request Export]**
5. You'll receive a download link via email

### 9.5 Account Deletion

To delete your account and all data:

1. Go to PreSuite Hub
2. Click **Settings** → **Account** → **Delete Account**
3. Enter your password to confirm
4. Click **[Delete My Account]**

> **Warning:** This action is permanent and cannot be undone. All emails, files, and documents will be permanently deleted.

---

## Appendix A: Supported File Formats

### Documents
| Format | Extension | Open | Edit | Create |
|--------|-----------|------|------|--------|
| Word Document | .docx | ✅ | ✅ | ✅ |
| Word 97-2003 | .doc | ✅ | ✅ | ❌ |
| OpenDocument Text | .odt | ✅ | ✅ | ✅ |
| Rich Text | .rtf | ✅ | ✅ | ❌ |
| Plain Text | .txt | ✅ | ✅ | ✅ |

### Spreadsheets
| Format | Extension | Open | Edit | Create |
|--------|-----------|------|------|--------|
| Excel Workbook | .xlsx | ✅ | ✅ | ✅ |
| Excel 97-2003 | .xls | ✅ | ✅ | ❌ |
| OpenDocument Spreadsheet | .ods | ✅ | ✅ | ✅ |
| CSV | .csv | ✅ | ✅ | ✅ |

### Presentations
| Format | Extension | Open | Edit | Create |
|--------|-----------|------|------|--------|
| PowerPoint | .pptx | ✅ | ✅ | ✅ |
| PowerPoint 97-2003 | .ppt | ✅ | ✅ | ❌ |
| OpenDocument Presentation | .odp | ✅ | ✅ | ✅ |

### Images (Preview Only)
| Format | Extension |
|--------|-----------|
| JPEG | .jpg, .jpeg |
| PNG | .png |
| GIF | .gif |
| SVG | .svg |
| WebP | .webp |
| BMP | .bmp |

### Other (Preview/Download)
| Format | Extension |
|--------|-----------|
| PDF | .pdf |
| ZIP | .zip |
| MP4 | .mp4 |
| MP3 | .mp3 |

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **SSO** | Single Sign-On - Sign in once to access all apps |
| **OAuth** | Authorization protocol used for SSO |
| **JWT** | JSON Web Token - Secure token for authentication |
| **IMAP** | Protocol for receiving email |
| **SMTP** | Protocol for sending email |
| **WOPI** | Protocol connecting PreDrive and PreOffice |
| **Thread** | Group of related emails in a conversation |
| **Share Link** | URL that allows others to access your files |
| **2FA** | Two-Factor Authentication - Extra security layer |

---

*Thank you for using PreSuite!*

*For the latest updates and features, visit https://presuite.eu*
