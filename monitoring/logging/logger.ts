/**
 * PreSuite Centralized Logger
 * Unified logging for all PreSuite services
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface LogEntry {
  timestamp: string;
  level: LogLevel;
  service: string;
  message: string;
  traceId?: string;
  spanId?: string;
  userId?: string;
  orgId?: string;
  requestId?: string;
  duration?: number;
  statusCode?: number;
  method?: string;
  path?: string;
  error?: {
    name: string;
    message: string;
    stack?: string;
  };
  meta?: Record<string, unknown>;
}

export interface LoggerConfig {
  service: string;
  level?: LogLevel;
  environment?: string;
  version?: string;
  maskSensitiveData?: boolean;
}

const LOG_LEVELS: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};

const SENSITIVE_FIELDS = [
  'password',
  'passwordHash',
  'token',
  'secret',
  'apiKey',
  'authorization',
  'cookie',
  'session',
  'creditCard',
  'ssn',
];

/**
 * Mask sensitive data in log output
 */
function maskValue(value: unknown): unknown {
  if (value === null || value === undefined) {
    return value;
  }

  if (typeof value === 'string') {
    // Mask email addresses
    if (value.includes('@') && value.includes('.')) {
      const [local, domain] = value.split('@');
      if (local && domain) {
        const masked = local.length > 2
          ? local[0] + '*'.repeat(Math.min(local.length - 2, 5)) + local[local.length - 1]
          : '***';
        return `${masked}@${domain}`;
      }
    }
    // Mask UUIDs
    if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)) {
      return value.slice(0, 8) + '-****-****-****-************';
    }
    // Mask JWT tokens
    if (/^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(value)) {
      return 'eyJ***[REDACTED]***';
    }
    return value;
  }

  if (Array.isArray(value)) {
    return value.map(maskValue);
  }

  if (typeof value === 'object') {
    const masked: Record<string, unknown> = {};
    for (const [key, val] of Object.entries(value as Record<string, unknown>)) {
      if (SENSITIVE_FIELDS.some(f => key.toLowerCase().includes(f.toLowerCase()))) {
        masked[key] = '[REDACTED]';
      } else {
        masked[key] = maskValue(val);
      }
    }
    return masked;
  }

  return value;
}

/**
 * Create a logger instance for a service
 */
export function createLogger(config: LoggerConfig) {
  const {
    service,
    level = (process.env.LOG_LEVEL as LogLevel) || 'info',
    environment = process.env.NODE_ENV || 'development',
    version = process.env.APP_VERSION || '1.0.0',
    maskSensitiveData = true,
  } = config;

  const isProduction = environment === 'production';

  function shouldLog(logLevel: LogLevel): boolean {
    return LOG_LEVELS[logLevel] >= LOG_LEVELS[level];
  }

  function formatEntry(entry: Partial<LogEntry>): string {
    const fullEntry: LogEntry = {
      timestamp: new Date().toISOString(),
      level: entry.level || 'info',
      service,
      message: entry.message || '',
      ...entry,
    };

    if (maskSensitiveData && fullEntry.meta) {
      fullEntry.meta = maskValue(fullEntry.meta) as Record<string, unknown>;
    }

    if (isProduction) {
      // JSON format for log aggregation
      return JSON.stringify(fullEntry);
    }

    // Human-readable format for development
    const meta = fullEntry.meta ? ` ${JSON.stringify(fullEntry.meta)}` : '';
    return `[${fullEntry.timestamp}] [${fullEntry.level.toUpperCase()}] [${service}] ${fullEntry.message}${meta}`;
  }

  function log(level: LogLevel, message: string, meta?: Record<string, unknown>) {
    if (!shouldLog(level)) return;

    const entry = formatEntry({ level, message, meta });

    switch (level) {
      case 'error':
        console.error(entry);
        break;
      case 'warn':
        console.warn(entry);
        break;
      case 'debug':
        console.debug(entry);
        break;
      default:
        console.log(entry);
    }
  }

  return {
    debug: (message: string, meta?: Record<string, unknown>) => log('debug', message, meta),
    info: (message: string, meta?: Record<string, unknown>) => log('info', message, meta),
    warn: (message: string, meta?: Record<string, unknown>) => log('warn', message, meta),
    error: (message: string, error?: Error | unknown, meta?: Record<string, unknown>) => {
      const errorMeta: Record<string, unknown> = { ...meta };

      if (error instanceof Error) {
        errorMeta.error = {
          name: error.name,
          message: error.message,
          ...(isProduction ? {} : { stack: error.stack }),
        };
      } else if (error) {
        errorMeta.error = String(error);
      }

      log('error', message, errorMeta);
    },

    /**
     * Log HTTP request
     */
    http: (req: { method: string; path: string; statusCode: number; duration: number; meta?: Record<string, unknown> }) => {
      log('info', 'HTTP Request', {
        method: req.method,
        path: req.path,
        statusCode: req.statusCode,
        durationMs: req.duration,
        ...req.meta,
      });
    },

    /**
     * Log security event
     */
    security: (event: string, meta?: Record<string, unknown>) => {
      log('warn', `[SECURITY] ${event}`, meta);
    },

    /**
     * Log audit event
     */
    audit: (action: string, meta?: Record<string, unknown>) => {
      log('info', `[AUDIT] ${action}`, meta);
    },

    /**
     * Create a child logger with additional context
     */
    child: (context: Record<string, unknown>) => {
      return createLogger({
        ...config,
        // Child loggers inherit config but can add context
      });
    },
  };
}

export default createLogger;
