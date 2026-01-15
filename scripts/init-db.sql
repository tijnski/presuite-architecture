-- PreSuite Database Initialization
-- Creates separate databases for each service

-- Create databases
CREATE DATABASE premail;
CREATE DATABASE predrive;

-- Create users with appropriate permissions
CREATE USER premail_user WITH PASSWORD 'premail';
CREATE USER predrive_user WITH PASSWORD 'predrive';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE premail TO premail_user;
GRANT ALL PRIVILEGES ON DATABASE predrive TO predrive_user;

-- Connect to premail and set up schema
\c premail

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

-- Create indexes
CREATE INDEX idx_users_org_id ON users(org_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_email_accounts_user_id ON email_accounts(user_id);

-- Grant permissions to premail_user
GRANT ALL ON ALL TABLES IN SCHEMA public TO premail_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO premail_user;

-- Connect to predrive and set up schema
\c predrive

-- Create orgs table (mirrored from premail)
CREATE TABLE IF NOT EXISTS orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create users table (mirrored from premail)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create nodes table (files and folders)
CREATE TYPE node_type AS ENUM ('folder', 'file');

CREATE TABLE IF NOT EXISTS nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  type node_type NOT NULL,
  parent_id UUID REFERENCES nodes(id),
  name VARCHAR(255) NOT NULL,
  starred BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create files table (metadata for file nodes)
CREATE TABLE IF NOT EXISTS files (
  node_id UUID PRIMARY KEY REFERENCES nodes(id) ON DELETE CASCADE,
  current_version INTEGER DEFAULT 1,
  mime VARCHAR(255),
  size BIGINT DEFAULT 0,
  checksum VARCHAR(64),
  created_at TIMESTAMPTZ DEFAULT NOW()
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
  UNIQUE(node_id, version)
);

-- Create shares table
CREATE TYPE share_scope AS ENUM ('view', 'download');

CREATE TABLE IF NOT EXISTS shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  token VARCHAR(64) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ,
  password_hash VARCHAR(255),
  scope share_scope DEFAULT 'view',
  org_only BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create permissions table
CREATE TYPE permission_principal AS ENUM ('user', 'group');
CREATE TYPE permission_role AS ENUM ('owner', 'editor', 'viewer');

CREATE TABLE IF NOT EXISTS permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(id),
  node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  principal_type permission_principal NOT NULL,
  principal_id UUID NOT NULL,
  role permission_role NOT NULL,
  inherited BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_nodes_org_id ON nodes(org_id);
CREATE INDEX idx_nodes_parent_id ON nodes(parent_id);
CREATE INDEX idx_nodes_deleted_at ON nodes(deleted_at);
CREATE INDEX idx_shares_token ON shares(token);
CREATE INDEX idx_shares_node_id ON shares(node_id);
CREATE INDEX idx_permissions_node_id ON permissions(node_id);
CREATE INDEX idx_file_versions_node_id ON file_versions(node_id);

-- Grant permissions to predrive_user
GRANT ALL ON ALL TABLES IN SCHEMA public TO predrive_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO predrive_user;

-- Insert default org and test user
INSERT INTO orgs (id, name) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Default Organization');

INSERT INTO users (id, org_id, email, name) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'test@premail.site', 'Test User');

-- Create root folder for test user
INSERT INTO nodes (id, org_id, type, name) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'folder', 'My Drive');
