-- PreSuite Database Initialization
-- Creates separate databases for each service
--
-- SECURITY NOTE: Replace passwords with secure values from environment
-- variables or secrets management in production deployments.

-- Create databases
CREATE DATABASE premail;
CREATE DATABASE predrive;

-- Create users with appropriate permissions
-- TODO: Use environment variables for passwords in production
CREATE USER premail_user WITH PASSWORD 'premail';
CREATE USER predrive_user WITH PASSWORD 'predrive';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE premail TO premail_user;
GRANT ALL PRIVILEGES ON DATABASE predrive TO predrive_user;

-- Connect to premail and set up schema
\c premail

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

-- Auto-update updated_at timestamp on row changes
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Create orgs table (shared concept)
CREATE TABLE IF NOT EXISTS orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create email accounts table
CREATE TYPE account_provider AS ENUM ('imap', 'gmail', 'microsoft');
CREATE TYPE account_status AS ENUM ('connecting', 'connected', 'disconnected', 'error', 'auth_error');

CREATE TABLE IF NOT EXISTS email_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  engine_account_id VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  provider account_provider DEFAULT 'imap',
  status account_status DEFAULT 'connecting',
  error_message TEXT,
  mail_password TEXT,
  last_sync_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================
CREATE INDEX idx_users_org_id ON users(org_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_email_accounts_user_id ON email_accounts(user_id);
CREATE INDEX idx_email_accounts_email ON email_accounts(email);
CREATE INDEX idx_email_accounts_status ON email_accounts(status);

-- =============================================================================
-- TRIGGERS
-- =============================================================================
CREATE TRIGGER trg_orgs_updated_at
  BEFORE UPDATE ON orgs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_email_accounts_updated_at
  BEFORE UPDATE ON email_accounts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =============================================================================
-- PERMISSIONS
-- =============================================================================
-- Grant permissions to premail_user
GRANT ALL ON ALL TABLES IN SCHEMA public TO premail_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO premail_user;

-- Connect to predrive and set up schema
\c predrive

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

-- Auto-update updated_at timestamp on row changes
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Create orgs table (mirrored from PreSuite Hub)
CREATE TABLE IF NOT EXISTS orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create users table (cached from PreSuite Hub for local queries)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create groups table for permission management
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(org_id, name)
);

-- Group membership (many-to-many)
CREATE TABLE IF NOT EXISTS group_members (
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);

-- =============================================================================
-- FILE STORAGE TABLES
-- =============================================================================

-- Create nodes table (files and folders)
CREATE TYPE node_type AS ENUM ('folder', 'file');

CREATE TABLE IF NOT EXISTS nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  type node_type NOT NULL,
  parent_id UUID REFERENCES nodes(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  starred BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  -- Prevent node from being its own parent
  CONSTRAINT chk_not_self_parent CHECK (parent_id IS DISTINCT FROM id)
);

-- Create files table (metadata for file nodes)
CREATE TABLE IF NOT EXISTS files (
  node_id UUID PRIMARY KEY REFERENCES nodes(id) ON DELETE CASCADE,
  current_version INTEGER DEFAULT 1,
  mime VARCHAR(255),
  size BIGINT DEFAULT 0,
  checksum VARCHAR(64),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT chk_version_positive CHECK (current_version >= 1),
  CONSTRAINT chk_size_non_negative CHECK (size >= 0)
);

-- Create file versions table
CREATE TABLE IF NOT EXISTS file_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,
  storage_key VARCHAR(512) NOT NULL,
  size BIGINT DEFAULT 0,
  checksum VARCHAR(64),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(node_id, version),
  CONSTRAINT chk_version_num_positive CHECK (version >= 1),
  CONSTRAINT chk_version_size_non_negative CHECK (size >= 0)
);

-- =============================================================================
-- SHARING & PERMISSIONS TABLES
-- =============================================================================

-- Create shares table
CREATE TYPE share_scope AS ENUM ('view', 'download');

CREATE TABLE IF NOT EXISTS shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  token VARCHAR(64) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ,
  password_hash VARCHAR(255),
  scope share_scope DEFAULT 'view',
  org_only BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create permissions table
CREATE TYPE permission_principal AS ENUM ('user', 'group');
CREATE TYPE permission_role AS ENUM ('owner', 'editor', 'viewer');

CREATE TABLE IF NOT EXISTS permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  principal_type permission_principal NOT NULL,
  principal_id UUID NOT NULL,
  role permission_role NOT NULL,
  inherited BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  -- Prevent duplicate permissions for same principal on same node
  UNIQUE(node_id, principal_type, principal_id)
);

-- =============================================================================
-- WEBDAV & UPLOAD TABLES
-- =============================================================================

-- WebDAV locking support
CREATE TABLE IF NOT EXISTS locks (
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

-- Multipart upload session tracking
CREATE TYPE upload_status AS ENUM ('pending', 'uploading', 'completed', 'failed', 'expired');

CREATE TABLE IF NOT EXISTS upload_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES nodes(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  storage_key VARCHAR(512) NOT NULL,
  multipart_id VARCHAR(255),
  status upload_status DEFAULT 'pending',
  mime VARCHAR(255),
  size BIGINT,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT chk_upload_size_non_negative CHECK (size IS NULL OR size >= 0)
);

-- =============================================================================
-- AUDIT & LOGGING
-- =============================================================================

-- Activity audit log
CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  node_id UUID REFERENCES nodes(id) ON DELETE SET NULL,
  action VARCHAR(50) NOT NULL,
  meta JSONB DEFAULT '{}',
  ip VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Nodes indexes
CREATE INDEX idx_nodes_org_id ON nodes(org_id);
CREATE INDEX idx_nodes_parent_id ON nodes(parent_id);
CREATE INDEX idx_nodes_deleted_at ON nodes(deleted_at);
CREATE INDEX idx_nodes_org_parent_active ON nodes(org_id, parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_nodes_name ON nodes(name);

-- Files indexes
CREATE INDEX idx_files_mime ON files(mime);

-- File versions indexes
CREATE INDEX idx_file_versions_node_id ON file_versions(node_id);

-- Shares indexes
CREATE INDEX idx_shares_token ON shares(token);
CREATE INDEX idx_shares_node_id ON shares(node_id);
CREATE INDEX idx_shares_org_id ON shares(org_id);
CREATE INDEX idx_shares_expires ON shares(expires_at) WHERE expires_at IS NOT NULL;

-- Permissions indexes
CREATE INDEX idx_permissions_node_id ON permissions(node_id);
CREATE INDEX idx_permissions_principal ON permissions(principal_type, principal_id);
CREATE INDEX idx_permissions_org_id ON permissions(org_id);

-- Groups indexes
CREATE INDEX idx_groups_org_id ON groups(org_id);
CREATE INDEX idx_group_members_user_id ON group_members(user_id);

-- Locks indexes
CREATE INDEX idx_locks_node_id ON locks(node_id);
CREATE INDEX idx_locks_expires ON locks(expires_at);

-- Upload sessions indexes
CREATE INDEX idx_upload_sessions_user_id ON upload_sessions(user_id);
CREATE INDEX idx_upload_sessions_status ON upload_sessions(status);
CREATE INDEX idx_upload_sessions_expires ON upload_sessions(expires_at);

-- Audit log indexes (for querying)
CREATE INDEX idx_audit_log_org_id ON audit_log(org_id);
CREATE INDEX idx_audit_log_actor_id ON audit_log(actor_id);
CREATE INDEX idx_audit_log_node_id ON audit_log(node_id);
CREATE INDEX idx_audit_log_action ON audit_log(action);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at);

-- =============================================================================
-- TRIGGERS
-- =============================================================================

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

-- =============================================================================
-- PERMISSIONS
-- =============================================================================

-- Grant permissions to predrive_user
GRANT ALL ON ALL TABLES IN SCHEMA public TO predrive_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO predrive_user;

-- =============================================================================
-- SEED DATA (Development Only - Remove in Production)
-- =============================================================================

-- Insert default org and test user
-- WARNING: Remove or replace with proper seed scripts in production
INSERT INTO orgs (id, name) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Default Organization');

INSERT INTO users (id, org_id, email, name) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'test@premail.site', 'Test User');

-- Create root folder for test user
INSERT INTO nodes (id, org_id, type, name) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'folder', 'My Drive');
