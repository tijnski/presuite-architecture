-- =============================================================================
-- PreSuite Unified Database Initialization
-- =============================================================================
--
-- ARCHITECTURE:
--   presuite  - Identity Provider (source of truth for auth)
--   premail   - Email Service (local user cache + email-specific data)
--   predrive  - Cloud Storage (local user cache + storage-specific data)
--
-- IMPORTANT: All services share the same JWT_SECRET for token validation.
-- Users/orgs are created in 'presuite' and cached locally in other services.
--
-- Run with: psql -U postgres -f init-db.sql
-- =============================================================================

-- =============================================================================
-- DATABASE CREATION
-- =============================================================================

-- Drop existing databases (CAUTION: destroys all data)
-- Uncomment only for fresh setup:
-- DROP DATABASE IF EXISTS presuite;
-- DROP DATABASE IF EXISTS premail;
-- DROP DATABASE IF EXISTS predrive;

CREATE DATABASE presuite;
CREATE DATABASE premail;
CREATE DATABASE predrive;

-- Create service users
-- TODO: Use environment variables for passwords in production
CREATE USER presuite_user WITH PASSWORD 'presuite_secure_pw';
CREATE USER premail_user WITH PASSWORD 'premail_secure_pw';
CREATE USER predrive_user WITH PASSWORD 'predrive_secure_pw';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE presuite TO presuite_user;
GRANT ALL PRIVILEGES ON DATABASE premail TO premail_user;
GRANT ALL PRIVILEGES ON DATABASE predrive TO predrive_user;


-- =============================================================================
-- =============================================================================
-- PRESUITE DATABASE (Identity Provider - Source of Truth)
-- =============================================================================
-- =============================================================================
\c presuite

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- Utility Functions
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- Core Identity Tables
-- -----------------------------------------------------------------------------

-- Organizations (multi-tenancy support)
CREATE TABLE orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE,
  plan VARCHAR(50) DEFAULT 'free',  -- free, pro, enterprise
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users (authoritative user store)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,  -- bcrypt, cost factor 12
  email_verified BOOLEAN DEFAULT FALSE,
  avatar_url VARCHAR(512),
  locale VARCHAR(10) DEFAULT 'en',
  timezone VARCHAR(50) DEFAULT 'UTC',
  disabled_at TIMESTAMPTZ,  -- NULL = active, set = disabled
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sessions (active login sessions)
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL,  -- SHA256 of JWT
  device_info JSONB DEFAULT '{}',    -- {browser, os, ip}
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Registration Sources (track where users signed up)
CREATE TABLE registration_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  source VARCHAR(50) NOT NULL,  -- presuite, premail, predrive, preoffice
  referrer VARCHAR(512),        -- HTTP referrer if available
  utm_source VARCHAR(100),
  utm_campaign VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Password Reset Tokens
CREATE TABLE password_reset_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Email Verification Tokens
CREATE TABLE email_verification_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- OAuth Clients (registered services)
CREATE TABLE oauth_clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id VARCHAR(100) UNIQUE NOT NULL,
  client_secret_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  redirect_uris TEXT[] NOT NULL,
  allowed_scopes TEXT[] DEFAULT ARRAY['openid', 'profile', 'email'],
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- OAuth Authorization Codes (temporary, for code exchange)
CREATE TABLE oauth_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code_hash VARCHAR(255) UNIQUE NOT NULL,
  client_id VARCHAR(100) NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  redirect_uri VARCHAR(512) NOT NULL,
  scope TEXT,
  code_challenge VARCHAR(128),  -- PKCE
  code_challenge_method VARCHAR(10),  -- S256 or plain
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auth Event Log (audit trail)
CREATE TABLE auth_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  event_type VARCHAR(50) NOT NULL,  -- login, logout, register, password_reset, etc.
  success BOOLEAN NOT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_org_id ON users(org_id);
CREATE INDEX idx_users_disabled ON users(disabled_at) WHERE disabled_at IS NULL;

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON sessions(token_hash);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);

CREATE INDEX idx_password_reset_token_hash ON password_reset_tokens(token_hash);
CREATE INDEX idx_password_reset_expires ON password_reset_tokens(expires_at);

CREATE INDEX idx_email_verify_token_hash ON email_verification_tokens(token_hash);

CREATE INDEX idx_oauth_codes_hash ON oauth_codes(code_hash);
CREATE INDEX idx_oauth_codes_expires ON oauth_codes(expires_at);

CREATE INDEX idx_auth_events_user ON auth_events(user_id);
CREATE INDEX idx_auth_events_type ON auth_events(event_type);
CREATE INDEX idx_auth_events_created ON auth_events(created_at);

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_orgs_updated_at
  BEFORE UPDATE ON orgs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_oauth_clients_updated_at
  BEFORE UPDATE ON oauth_clients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- Permissions
-- -----------------------------------------------------------------------------
GRANT ALL ON ALL TABLES IN SCHEMA public TO presuite_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO presuite_user;

-- -----------------------------------------------------------------------------
-- Seed OAuth Clients
-- -----------------------------------------------------------------------------
-- These are the pre-registered OAuth clients for PreSuite services
-- Secrets should be overridden via environment variables in production
INSERT INTO oauth_clients (client_id, client_secret_hash, name, redirect_uris, allowed_scopes) VALUES
  ('premail', '$2b$12$premail_client_secret_hash_placeholder', 'PreMail',
   ARRAY['https://premail.site/oauth/callback', 'http://localhost:5173/oauth/callback'],
   ARRAY['openid', 'profile', 'email']),
  ('predrive', '$2b$12$predrive_client_secret_hash_placeholder', 'PreDrive',
   ARRAY['https://predrive.eu/oauth/callback', 'http://localhost:5174/oauth/callback'],
   ARRAY['openid', 'profile', 'email']),
  ('preoffice', '$2b$12$preoffice_client_secret_hash_placeholder', 'PreOffice',
   ARRAY['https://preoffice.site/oauth/callback', 'http://localhost:3000/oauth/callback'],
   ARRAY['openid', 'profile', 'email']);


-- =============================================================================
-- =============================================================================
-- PREMAIL DATABASE (Email Service)
-- =============================================================================
-- =============================================================================
\c premail

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- Utility Functions
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- User Cache Tables (synced from PreSuite Hub via JWT claims)
-- -----------------------------------------------------------------------------
-- NOTE: These tables cache user data locally for performance.
-- The source of truth is always the presuite database.
-- NO password_hash here - authentication happens at PreSuite Hub.

CREATE TABLE orgs (
  id UUID PRIMARY KEY,  -- Same ID as presuite.orgs
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE users (
  id UUID PRIMARY KEY,  -- Same ID as presuite.users
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  -- NO password_hash - auth is handled by PreSuite Hub
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Email-Specific Tables
-- -----------------------------------------------------------------------------

CREATE TYPE account_provider AS ENUM ('stalwart', 'imap', 'gmail', 'microsoft');
CREATE TYPE account_status AS ENUM ('connecting', 'connected', 'disconnected', 'error', 'auth_error');

-- Email accounts (connections to mail servers)
CREATE TABLE email_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  engine_account_id VARCHAR(255) UNIQUE NOT NULL,  -- e.g., "stalwart:username"
  display_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  provider account_provider DEFAULT 'stalwart',
  status account_status DEFAULT 'connecting',
  error_message TEXT,
  -- Mail server credentials (for IMAP/SMTP operations)
  -- SECURITY: Should be encrypted at rest in production
  imap_host VARCHAR(255),
  imap_port INTEGER DEFAULT 993,
  smtp_host VARCHAR(255),
  smtp_port INTEGER DEFAULT 587,
  mail_password TEXT,  -- Encrypted in production
  last_sync_at TIMESTAMPTZ,
  sync_state JSONB DEFAULT '{}',  -- IMAP sync state (UIDs, etc.)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Email folders (cached folder list per account)
CREATE TABLE email_folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES email_accounts(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,           -- Display name
  path VARCHAR(512) NOT NULL,           -- IMAP path (e.g., "INBOX", "Sent")
  special_use VARCHAR(50),              -- \Inbox, \Sent, \Drafts, \Trash, \Archive
  unread_count INTEGER DEFAULT 0,
  total_count INTEGER DEFAULT 0,
  last_sync_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(account_id, path)
);

-- Email signatures
CREATE TABLE email_signatures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES email_accounts(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  content_html TEXT,
  content_text TEXT,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX idx_users_org_id ON users(org_id);
CREATE INDEX idx_users_email ON users(email);

CREATE INDEX idx_email_accounts_user_id ON email_accounts(user_id);
CREATE INDEX idx_email_accounts_email ON email_accounts(email);
CREATE INDEX idx_email_accounts_status ON email_accounts(status);

CREATE INDEX idx_email_folders_account ON email_folders(account_id);
CREATE INDEX idx_email_folders_special ON email_folders(special_use);

CREATE INDEX idx_email_signatures_account ON email_signatures(account_id);

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_orgs_updated_at
  BEFORE UPDATE ON orgs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_email_accounts_updated_at
  BEFORE UPDATE ON email_accounts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_email_folders_updated_at
  BEFORE UPDATE ON email_folders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_email_signatures_updated_at
  BEFORE UPDATE ON email_signatures
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- Permissions
-- -----------------------------------------------------------------------------
GRANT ALL ON ALL TABLES IN SCHEMA public TO premail_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO premail_user;


-- =============================================================================
-- =============================================================================
-- PREDRIVE DATABASE (Cloud Storage)
-- =============================================================================
-- =============================================================================
\c predrive

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- Utility Functions
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- User Cache Tables (synced from PreSuite Hub via JWT claims)
-- -----------------------------------------------------------------------------
-- NOTE: These tables cache user data locally for performance.
-- The source of truth is always the presuite database.
-- NO password_hash here - authentication happens at PreSuite Hub.

CREATE TABLE orgs (
  id UUID PRIMARY KEY,  -- Same ID as presuite.orgs
  name VARCHAR(255) NOT NULL,
  storage_quota BIGINT DEFAULT 5368709120,  -- 5GB default
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE users (
  id UUID PRIMARY KEY,  -- Same ID as presuite.users
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  -- NO password_hash - auth is handled by PreSuite Hub
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Groups for permission management
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(org_id, name)
);

-- Group membership
CREATE TABLE group_members (
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);

-- -----------------------------------------------------------------------------
-- File Storage Tables
-- -----------------------------------------------------------------------------

CREATE TYPE node_type AS ENUM ('folder', 'file');

-- Nodes (files and folders tree structure)
CREATE TABLE nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  type node_type NOT NULL,
  parent_id UUID REFERENCES nodes(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  starred BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,  -- Soft delete (trash)
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT chk_not_self_parent CHECK (parent_id IS DISTINCT FROM id)
);

-- Files (metadata for file nodes)
CREATE TABLE files (
  node_id UUID PRIMARY KEY REFERENCES nodes(id) ON DELETE CASCADE,
  current_version INTEGER DEFAULT 1,
  mime VARCHAR(255),
  size BIGINT DEFAULT 0,
  checksum VARCHAR(64),  -- SHA256
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT chk_version_positive CHECK (current_version >= 1),
  CONSTRAINT chk_size_non_negative CHECK (size >= 0)
);

-- File versions (version history)
CREATE TABLE file_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,
  storage_key VARCHAR(512) NOT NULL,  -- S3 object key
  size BIGINT DEFAULT 0,
  checksum VARCHAR(64),
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(node_id, version),
  CONSTRAINT chk_version_num_positive CHECK (version >= 1),
  CONSTRAINT chk_version_size_non_negative CHECK (size >= 0)
);

-- -----------------------------------------------------------------------------
-- Sharing & Permissions Tables
-- -----------------------------------------------------------------------------

CREATE TYPE share_scope AS ENUM ('view', 'download', 'edit');
CREATE TYPE permission_principal AS ENUM ('user', 'group');
CREATE TYPE permission_role AS ENUM ('owner', 'editor', 'viewer');

-- Public share links
CREATE TABLE shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  token VARCHAR(64) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ,
  password_hash VARCHAR(255),  -- Optional password protection
  scope share_scope DEFAULT 'view',
  org_only BOOLEAN DEFAULT FALSE,  -- Restrict to org members
  download_count INTEGER DEFAULT 0,
  max_downloads INTEGER,  -- NULL = unlimited
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permissions (ACL for nodes)
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  principal_type permission_principal NOT NULL,
  principal_id UUID NOT NULL,
  role permission_role NOT NULL,
  inherited BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(node_id, principal_type, principal_id)
);

-- -----------------------------------------------------------------------------
-- WebDAV & Upload Tables
-- -----------------------------------------------------------------------------

-- WebDAV locks
CREATE TABLE locks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  token VARCHAR(255) UNIQUE NOT NULL,
  owner VARCHAR(255) NOT NULL,
  depth VARCHAR(10) DEFAULT 'infinity',
  timeout INTEGER DEFAULT 3600,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TYPE upload_status AS ENUM ('pending', 'uploading', 'completed', 'failed', 'expired');

-- Multipart upload sessions
CREATE TABLE upload_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES nodes(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  storage_key VARCHAR(512) NOT NULL,
  multipart_id VARCHAR(255),  -- S3 multipart upload ID
  status upload_status DEFAULT 'pending',
  mime VARCHAR(255),
  size BIGINT,
  parts_completed INTEGER DEFAULT 0,
  parts_total INTEGER,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT chk_upload_size_non_negative CHECK (size IS NULL OR size >= 0)
);

-- -----------------------------------------------------------------------------
-- Audit Log
-- -----------------------------------------------------------------------------

CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  node_id UUID REFERENCES nodes(id) ON DELETE SET NULL,
  action VARCHAR(50) NOT NULL,  -- create, read, update, delete, share, etc.
  meta JSONB DEFAULT '{}',
  ip VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

-- Users/Groups
CREATE INDEX idx_users_org_id ON users(org_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_groups_org_id ON groups(org_id);
CREATE INDEX idx_group_members_user_id ON group_members(user_id);

-- Nodes
CREATE INDEX idx_nodes_org_id ON nodes(org_id);
CREATE INDEX idx_nodes_parent_id ON nodes(parent_id);
CREATE INDEX idx_nodes_deleted_at ON nodes(deleted_at);
CREATE INDEX idx_nodes_org_parent_active ON nodes(org_id, parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_nodes_name ON nodes(name);
CREATE INDEX idx_nodes_created_by ON nodes(created_by);

-- Files
CREATE INDEX idx_files_mime ON files(mime);
CREATE INDEX idx_file_versions_node_id ON file_versions(node_id);

-- Shares
CREATE INDEX idx_shares_token ON shares(token);
CREATE INDEX idx_shares_node_id ON shares(node_id);
CREATE INDEX idx_shares_org_id ON shares(org_id);
CREATE INDEX idx_shares_expires ON shares(expires_at) WHERE expires_at IS NOT NULL;

-- Permissions
CREATE INDEX idx_permissions_node_id ON permissions(node_id);
CREATE INDEX idx_permissions_principal ON permissions(principal_type, principal_id);
CREATE INDEX idx_permissions_org_id ON permissions(org_id);

-- Locks
CREATE INDEX idx_locks_node_id ON locks(node_id);
CREATE INDEX idx_locks_expires ON locks(expires_at);

-- Upload sessions
CREATE INDEX idx_upload_sessions_user_id ON upload_sessions(user_id);
CREATE INDEX idx_upload_sessions_status ON upload_sessions(status);
CREATE INDEX idx_upload_sessions_expires ON upload_sessions(expires_at);

-- Audit log
CREATE INDEX idx_audit_log_org_id ON audit_log(org_id);
CREATE INDEX idx_audit_log_actor_id ON audit_log(actor_id);
CREATE INDEX idx_audit_log_node_id ON audit_log(node_id);
CREATE INDEX idx_audit_log_action ON audit_log(action);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at);

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

CREATE TRIGGER trg_orgs_updated_at
  BEFORE UPDATE ON orgs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_groups_updated_at
  BEFORE UPDATE ON groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_nodes_updated_at
  BEFORE UPDATE ON nodes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_upload_sessions_updated_at
  BEFORE UPDATE ON upload_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- Permissions
-- -----------------------------------------------------------------------------

GRANT ALL ON ALL TABLES IN SCHEMA public TO predrive_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO predrive_user;


-- =============================================================================
-- END OF INITIALIZATION
-- =============================================================================
--
-- Post-initialization steps:
-- 1. Update database passwords in production
-- 2. Run migrations for any schema changes
-- 3. Seed OAuth client secrets (replace placeholders)
-- 4. Configure connection pooling (PgBouncer recommended)
--
-- To verify:
--   psql -U presuite_user -d presuite -c "\dt"
--   psql -U premail_user -d premail -c "\dt"
--   psql -U predrive_user -d predrive -c "\dt"
--
-- =============================================================================
