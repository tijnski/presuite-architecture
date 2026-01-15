/**
 * PreSuite SSO Configuration
 *
 * This file defines the shared SSO configuration used across all PreSuite services.
 * Each service should implement token verification using this specification.
 */

// JWT Configuration (must match across all services)
export const SSOConfig = {
  // Algorithm for JWT signing
  algorithm: 'HS256' as const,

  // Token issuer - must match JWT_ISSUER env var
  issuer: 'presuite',

  // Token expiration times
  expiration: {
    access: '7d',      // Access token: 7 days
    refresh: '30d',    // Refresh token: 30 days
    wopi: '24h',       // WOPI access token: 24 hours
  },

  // Services that participate in SSO
  services: {
    premail: {
      url: 'https://premail.site',
      role: 'identity-provider',
      description: 'Primary identity provider - handles user registration/login',
    },
    predrive: {
      url: 'https://predrive.eu',
      role: 'service-provider',
      description: 'Accepts SSO tokens from PreMail',
    },
    preoffice: {
      url: 'https://preoffice.site',
      role: 'service-provider',
      description: 'Accepts SSO tokens for document editing',
    },
    presuite: {
      url: 'https://presuite.eu',
      role: 'portal',
      description: 'Central hub - links to all services',
    },
  },
} as const;

// JWT Payload interface
export interface PreSuiteJWTPayload {
  // Subject (user ID) - UUID
  sub: string;

  // Organization ID - UUID
  org_id: string;

  // User email
  email: string;

  // User display name (optional)
  name?: string;

  // Token issuer (must be 'presuite')
  iss: string;

  // Issued at (Unix timestamp)
  iat: number;

  // Expiration (Unix timestamp)
  exp: number;
}

// Token verification result
export interface TokenVerificationResult {
  valid: boolean;
  payload?: PreSuiteJWTPayload;
  error?: string;
}

// Auto-provisioning configuration
export const AutoProvisionConfig = {
  // Create user if not exists when valid JWT received
  enabled: true,

  // Default organization name template
  orgNameTemplate: (email: string) => `${email.split('@')[0]}'s Organization`,

  // Default storage quota (5GB in bytes)
  defaultStorageQuota: 5 * 1024 * 1024 * 1024,

  // Default email quota (1GB in bytes)
  defaultEmailQuota: 1 * 1024 * 1024 * 1024,
} as const;

// SSO Link patterns
export const SSOLinks = {
  // From PreMail to PreDrive
  toPreDrive: (token: string) => `https://predrive.eu?token=${token}`,

  // From PreMail to PreOffice (for general access)
  toPreOffice: (token: string) => `https://preoffice.site?token=${token}`,

  // From PreDrive to PreOffice (for editing a specific file)
  toPreOfficeEdit: (fileId: string, token: string) =>
    `https://preoffice.site/edit?file=${fileId}&token=${token}`,

  // Back to PreMail
  toPreMail: () => 'https://premail.site',

  // To main hub
  toPreSuite: () => 'https://presuite.eu',
} as const;

// CORS configuration for cross-service requests
export const CORSConfig = {
  origins: [
    'https://presuite.eu',
    'https://predrive.eu',
    'https://premail.site',
    'https://preoffice.site',
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
} as const;
