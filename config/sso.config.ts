/**
 * PreSuite SSO Configuration
 * Version: 2.0.0
 *
 * ARCHITECTURE CHANGE: PreSuite Hub is now the central identity provider.
 * All services delegate authentication to PreSuite Hub.
 * Registration is available from any service.
 */

// ============================================
// JWT Configuration
// ============================================

export const JWTConfig = {
  // Algorithm for JWT signing
  algorithm: 'HS256' as const,

  // Token issuer - must match JWT_ISSUER env var
  issuer: 'presuite',

  // Token expiration times
  expiration: {
    access: '7d',      // Access token: 7 days
    refresh: '30d',    // Refresh token: 30 days
    wopi: '24h',       // WOPI access token: 24 hours
    reset: '1h',       // Password reset token: 1 hour
  },
} as const;

// ============================================
// Service Registry
// ============================================

export const Services = {
  presuite: {
    name: 'PreSuite Hub',
    url: 'https://presuite.eu',
    server: '76.13.2.221',
    role: 'identity-provider',
    description: 'Central identity provider and hub',
    features: ['auth', 'pregpt', 'search', 'dashboard'],
  },
  premail: {
    name: 'PreMail',
    url: 'https://premail.site',
    server: '76.13.1.117',
    role: 'service-provider',
    description: 'Privacy-focused email service',
    features: ['imap', 'smtp', 'email'],
  },
  predrive: {
    name: 'PreDrive',
    url: 'https://predrive.eu',
    server: '76.13.1.110',
    role: 'service-provider',
    description: 'Cloud storage service',
    features: ['storage', 'sharing', 'webdav'],
  },
  preoffice: {
    name: 'PreOffice',
    url: 'https://preoffice.site',
    server: '76.13.2.220',
    role: 'service-provider',
    description: 'Document editing service',
    features: ['wopi', 'documents', 'collabora'],
  },
} as const;

// ============================================
// Auth API Configuration
// ============================================

export const AuthAPI = {
  // Base URL for auth endpoints
  baseUrl: 'https://presuite.eu/api/auth',

  // Endpoints
  endpoints: {
    register: '/register',
    login: '/login',
    logout: '/logout',
    verify: '/verify',
    me: '/me',
    resetPassword: '/reset-password',
    resetPasswordConfirm: '/reset-password/confirm',
    health: '/health',
  },

  // Which services can register users
  registrationSources: ['presuite', 'premail', 'predrive', 'preoffice'],
} as const;

// ============================================
// JWT Payload Interface
// ============================================

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

// ============================================
// Registration Source Tracking
// ============================================

export type RegistrationSource = 'presuite' | 'premail' | 'predrive' | 'preoffice';

export interface RegistrationRequest {
  email: string;
  password: string;
  name: string;
  source: RegistrationSource;
}

export interface RegistrationResponse {
  success: boolean;
  user: {
    id: string;
    email: string;
    name: string;
    org_id: string;
  };
  token: string;
}

// ============================================
// Auto-Provisioning Configuration
// ============================================

export const ProvisioningConfig = {
  // Create user resources when valid JWT received
  autoProvision: true,

  // Default organization name template
  orgNameTemplate: (email: string) => `${email.split('@')[0]}'s Organization`,

  // Default quotas
  quotas: {
    // Email quota (1GB)
    email: 1 * 1024 * 1024 * 1024,
    // Storage quota (5GB)
    storage: 5 * 1024 * 1024 * 1024,
  },

  // On registration, create:
  onRegistration: {
    // Create Stalwart mailbox
    createMailbox: true,
    // Initialize PreDrive storage
    createStorage: true,
  },
} as const;

// ============================================
// SSO Link Generators
// ============================================

export const SSOLinks = {
  // Generate SSO URL with token
  withToken: (serviceUrl: string, token: string) =>
    `${serviceUrl}?token=${encodeURIComponent(token)}`,

  // Service-specific links
  toPreSuite: (token?: string) =>
    token ? `https://presuite.eu?token=${token}` : 'https://presuite.eu',

  toPreMail: (token?: string) =>
    token ? `https://premail.site?token=${token}` : 'https://premail.site',

  toPreDrive: (token?: string) =>
    token ? `https://predrive.eu?token=${token}` : 'https://predrive.eu',

  toPreOffice: (token?: string) =>
    token ? `https://preoffice.site?token=${token}` : 'https://preoffice.site',

  // Open document in PreOffice
  toPreOfficeEdit: (fileId: string, token: string) =>
    `https://preoffice.site/edit?file=${fileId}&token=${token}`,

  // Auth page links (for redirect-based SSO)
  toLogin: (returnUrl?: string) =>
    returnUrl
      ? `https://presuite.eu/login?redirect=${encodeURIComponent(returnUrl)}`
      : 'https://presuite.eu/login',

  toRegister: (returnUrl?: string) =>
    returnUrl
      ? `https://presuite.eu/register?redirect=${encodeURIComponent(returnUrl)}`
      : 'https://presuite.eu/register',
} as const;

// ============================================
// CORS Configuration
// ============================================

export const CORSConfig = {
  // Allowed origins
  origins: [
    'https://presuite.eu',
    'https://predrive.eu',
    'https://premail.site',
    'https://preoffice.site',
    // Development
    'http://localhost:3000',
    'http://localhost:3001',
    'http://localhost:4000',
    'http://localhost:4001',
    'http://localhost:5173',
  ],

  // CORS options
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
} as const;

// ============================================
// Token Verification Helpers
// ============================================

export const TokenVerification = {
  // Extract token from Authorization header
  extractToken: (authHeader: string | undefined): string | null => {
    if (!authHeader?.startsWith('Bearer ')) return null;
    return authHeader.slice(7);
  },

  // Extract token from URL query parameter
  extractTokenFromUrl: (url: string): string | null => {
    const params = new URLSearchParams(new URL(url).search);
    return params.get('token');
  },

  // Check if token is about to expire (within 1 hour)
  isExpiringSoon: (exp: number): boolean => {
    const oneHour = 60 * 60;
    return exp - Math.floor(Date.now() / 1000) < oneHour;
  },
} as const;

// ============================================
// Error Codes
// ============================================

export const AuthErrors = {
  // Registration errors
  INVALID_EMAIL: 'Email format is invalid',
  WEAK_PASSWORD: 'Password does not meet requirements',
  EMAIL_EXISTS: 'Email already registered',
  PROVISIONING_FAILED: 'Failed to create user resources',

  // Login errors
  MISSING_CREDENTIALS: 'Email and password are required',
  INVALID_CREDENTIALS: 'Invalid email or password',
  ACCOUNT_DISABLED: 'Account has been disabled',

  // Token errors
  TOKEN_MISSING: 'Authorization header required',
  TOKEN_INVALID: 'Invalid or malformed token',
  TOKEN_EXPIRED: 'Token has expired',

  // General errors
  INTERNAL_ERROR: 'An internal error occurred',
} as const;
