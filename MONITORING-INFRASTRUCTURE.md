# PreSuite Monitoring Infrastructure

> **Date:** January 16, 2026
> **Author:** Claude Opus 4.5
> **Status:** Implemented

---

## Overview

This document describes the monitoring infrastructure for the PreSuite ecosystem, including logging, metrics, alerting, health checks, and backup systems.

---

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     Monitoring Stack                            │
├─────────────────┬─────────────────┬─────────────────┬──────────┤
│    Logging      │    Metrics      │    Alerting     │  Backups │
│   (Centralized) │  (Prometheus)   │   (Webhooks)    │  (Cron)  │
└────────┬────────┴────────┬────────┴────────┬────────┴────┬─────┘
         │                 │                 │              │
         ▼                 ▼                 ▼              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PreSuite Services                          │
├──────────────┬──────────────┬──────────────┬───────────────────┤
│ PreSuite Hub │   PreMail    │   PreDrive   │    PreOffice      │
│  76.13.2.221 │  76.13.1.117 │  76.13.1.110 │   76.13.2.220     │
└──────────────┴──────────────┴──────────────┴───────────────────┘
```

---

## 1. Centralized Logging

### Location
`ARC/monitoring/logging/logger.ts`

### Features
- Structured JSON logging for production
- Human-readable format for development
- Automatic sensitive data masking (passwords, tokens, emails, UUIDs)
- Log levels: debug, info, warn, error
- HTTP request logging
- Security event logging
- Audit trail logging

### Usage

```typescript
import { createLogger } from './monitoring/logging/logger';

const logger = createLogger({
  service: 'presuite-hub',
  level: 'info',
  environment: process.env.NODE_ENV,
  version: '1.0.0',
});

// Basic logging
logger.info('Server started', { port: 3000 });
logger.warn('Rate limit approaching', { current: 95, max: 100 });
logger.error('Database connection failed', new Error('Connection refused'));

// HTTP request logging
logger.http({
  method: 'POST',
  path: '/api/auth/login',
  statusCode: 200,
  duration: 45,
});

// Security events
logger.security('Failed login attempt', { email: 'user@example.com', ip: '1.2.3.4' });

// Audit events
logger.audit('User created', { userId: '123', createdBy: 'admin' });
```

### Log Format (Production)

```json
{
  "timestamp": "2026-01-16T12:00:00.000Z",
  "level": "info",
  "service": "presuite-hub",
  "message": "User logged in",
  "userId": "12345678-****-****-****-************",
  "email": "u***r@example.com"
}
```

### Sensitive Data Masking

| Data Type | Example | Masked |
|-----------|---------|--------|
| Email | user@example.com | u***r@example.com |
| UUID | 12345678-abcd-... | 12345678-****-... |
| JWT | eyJhbG... | eyJ***[REDACTED]*** |
| Password | secret123 | [REDACTED] |

---

## 2. Metrics Collection

### Location
`ARC/monitoring/metrics/metrics.ts`

### Metric Types

| Type | Description | Use Case |
|------|-------------|----------|
| Counter | Monotonically increasing | Request counts, errors |
| Gauge | Can go up or down | Active connections, queue size |
| Histogram | Distribution of values | Request latency |

### Built-in Metrics

```typescript
import { createMetrics } from './monitoring/metrics/metrics';

const metrics = createMetrics('presuite-hub');

// Pre-configured metrics
metrics.httpRequestsTotal.inc({ method: 'GET', path: '/api', status: '200' });
metrics.httpRequestDuration.observe(0.045, { method: 'GET', path: '/api' });
metrics.httpRequestsInFlight.inc();
metrics.activeConnections.set(150);
metrics.errorsTotal.inc({ type: 'database' });
```

### Custom Metrics

```typescript
// Create custom counter
const loginAttempts = metrics.counter('login_attempts_total', 'Total login attempts');
loginAttempts.inc({ result: 'success' });

// Create custom gauge
const queueSize = metrics.gauge('job_queue_size', 'Current job queue size');
queueSize.set(42);

// Create custom histogram with custom buckets
const dbQueryDuration = metrics.histogram(
  'db_query_duration_seconds',
  'Database query duration',
  [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1]
);
dbQueryDuration.observe(0.023, { query: 'SELECT' });
```

### Prometheus Export

```typescript
// Endpoint handler
app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send(metrics.export());
});
```

Output:
```
# HELP presuite_hub_http_requests_total Total HTTP requests
# TYPE presuite_hub_http_requests_total counter
presuite_hub_http_requests_total{method="GET",path="/api",status="200"} 1234
```

---

## 3. Health Checks

### Location
`ARC/monitoring/health/health-check.ts`

### Endpoints

| Endpoint | Purpose | Response |
|----------|---------|----------|
| `/health` | Full health check | ServiceHealth object |
| `/health/live` | Liveness probe | `{ status: 'ok' }` |
| `/health/ready` | Readiness probe | `{ ready: boolean }` |

### Setup

```typescript
import { createHealthChecker, commonChecks } from './monitoring/health/health-check';

const health = createHealthChecker('presuite-hub', '1.0.0');

// Add database check
health.addCheck('database', commonChecks.database('PostgreSQL', async () => {
  await db.query('SELECT 1');
}));

// Add Redis check
health.addCheck('redis', commonChecks.redis('Redis', async () => {
  return await redis.ping();
}));

// Add external service check
health.addCheck('predrive', commonChecks.httpService(
  'PreDrive API',
  'https://predrive.eu/health',
  200
));

// Add memory check
health.addCheck('memory', commonChecks.memory('Memory', 90));
```

### Endpoint Handlers

```typescript
// Full health check
app.get('/health', async (req, res) => {
  const status = await health.check();
  const httpStatus = status.status === 'healthy' ? 200 :
                     status.status === 'degraded' ? 200 : 503;
  res.status(httpStatus).json(status);
});

// Kubernetes liveness probe
app.get('/health/live', (req, res) => {
  res.json(health.liveness());
});

// Kubernetes readiness probe
app.get('/health/ready', async (req, res) => {
  const ready = await health.readiness();
  res.status(ready.ready ? 200 : 503).json(ready);
});
```

### Health Response

```json
{
  "service": "presuite-hub",
  "version": "1.0.0",
  "status": "healthy",
  "uptime": 86400,
  "timestamp": "2026-01-16T12:00:00.000Z",
  "checks": [
    {
      "name": "database",
      "status": "healthy",
      "message": "Database connection OK",
      "latency": 5
    },
    {
      "name": "redis",
      "status": "healthy",
      "message": "Redis connection OK",
      "latency": 2
    }
  ]
}
```

---

## 4. Alerting System

### Location
`ARC/monitoring/alerting/alerting.ts`

### Supported Channels

| Channel | Description |
|---------|-------------|
| Slack | Slack webhook integration |
| Discord | Discord webhook integration |
| Webhook | Generic webhook (JSON payload) |
| Email | SMTP email (requires configuration) |

### Setup

```typescript
import { createAlertManager, createAlertRuleEvaluator } from './monitoring/alerting/alerting';

const alertManager = createAlertManager({
  service: 'presuite-hub',
  channels: [
    {
      name: 'slack-ops',
      type: 'slack',
      url: process.env.SLACK_WEBHOOK_URL,
      severities: ['warning', 'critical'],
    },
    {
      name: 'discord-alerts',
      type: 'discord',
      url: process.env.DISCORD_WEBHOOK_URL,
      severities: ['critical'],
    },
  ],
  deduplicationWindow: 5 * 60 * 1000, // 5 minutes
  rateLimitPerMinute: 10,
});

// Send alerts
await alertManager.alert('critical', 'Database Down', 'PostgreSQL connection lost', {
  server: 'db-primary',
  error: 'Connection refused',
});

// Resolve alerts
await alertManager.resolve('Database Down', 'PostgreSQL connection restored', {
  server: 'db-primary',
});
```

### Alert Rules

```typescript
const ruleEvaluator = createAlertRuleEvaluator(alertManager);

// High error rate rule
ruleEvaluator.addRule({
  name: 'high-error-rate',
  condition: async () => {
    const errorRate = await getErrorRate();
    return errorRate > 0.05; // 5% error rate
  },
  severity: 'warning',
  title: 'High Error Rate',
  message: () => `Error rate is ${(getErrorRate() * 100).toFixed(1)}%`,
  checkInterval: 60000, // Check every minute
  labels: { service: 'api' },
});

// Start automatic evaluation
ruleEvaluator.start(30000); // Evaluate every 30 seconds
```

### Alert Severities

| Severity | Color | Use Case |
|----------|-------|----------|
| info | Blue | Informational, deployments |
| warning | Orange | Degraded performance, high usage |
| critical | Red | Service down, data loss risk |

---

## 5. Backup System

### Location
`ARC/monitoring/backups/`

### Scripts

| Script | Purpose |
|--------|---------|
| `backup.sh` | Run backups |
| `restore.sh` | Restore from backup |
| `crontab.example` | Cron schedule configuration |

### Backup Schedule

```bash
# Daily backup at 2:00 AM
0 2 * * * /opt/presuite/monitoring/backups/backup.sh

# Weekly full backup on Sunday at 3:00 AM
0 3 * * 0 FULL_BACKUP=1 /opt/presuite/monitoring/backups/backup.sh
```

### What Gets Backed Up

| Service | Type | Location |
|---------|------|----------|
| PreSuite Hub | PostgreSQL | /opt/presuite-backups/databases/presuite/ |
| PreDrive | PostgreSQL | /opt/presuite-backups/databases/predrive/ |
| PreDrive | Files | /opt/presuite-backups/files/predrive/ |
| PreMail | PostgreSQL | /opt/presuite-backups/databases/premail/ |

### Configuration

```bash
# Environment variables
export BACKUP_ROOT=/opt/presuite-backups
export RETENTION_DAYS=30

# Database credentials
export PREDRIVE_DB_HOST=localhost
export PREDRIVE_DB_NAME=predrive
export PREDRIVE_DB_USER=predrive
export PREDRIVE_DB_PASSWORD=your_password

# S3 configuration (optional)
export S3_BUCKET=presuite-backups
export S3_ENDPOINT=https://s3.example.com
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret

# Alert webhook (optional)
export ALERT_WEBHOOK_URL=https://hooks.slack.com/services/xxx
```

### Running Backups

```bash
# Manual backup
./backup.sh

# List available backups
./restore.sh list

# List backups for specific service
./restore.sh list predrive

# Restore database
./restore.sh restore-db predrive /opt/presuite-backups/databases/predrive/predrive_2026-01-16.sql.gz

# Restore files
./restore.sh restore-files /opt/presuite-backups/files/predrive/storage_2026-01-16.tar.gz /opt/predrive/storage
```

---

## 6. Integration Guide

### Adding Monitoring to a Service

```typescript
// 1. Import monitoring modules
import { createLogger } from '@presuite/monitoring/logging';
import { createMetrics } from '@presuite/monitoring/metrics';
import { createHealthChecker, commonChecks } from '@presuite/monitoring/health';
import { createAlertManager } from '@presuite/monitoring/alerting';

// 2. Initialize
const logger = createLogger({ service: 'my-service' });
const metrics = createMetrics('my-service');
const health = createHealthChecker('my-service', '1.0.0');
const alerts = createAlertManager({ service: 'my-service', channels: [...] });

// 3. Add middleware for request logging/metrics
app.use((req, res, next) => {
  const start = Date.now();
  metrics.httpRequestsInFlight.inc();

  res.on('finish', () => {
    const duration = Date.now() - start;
    metrics.httpRequestsInFlight.dec();
    metrics.httpRequestsTotal.inc({
      method: req.method,
      path: req.path,
      status: String(res.statusCode),
    });
    metrics.httpRequestDuration.observe(duration / 1000, {
      method: req.method,
      path: req.path,
    });
    logger.http({
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration,
    });
  });

  next();
});

// 4. Add health checks
health.addCheck('database', commonChecks.database('PostgreSQL', pingDb));

// 5. Add health endpoints
app.get('/health', async (req, res) => res.json(await health.check()));
app.get('/metrics', (req, res) => res.type('text/plain').send(metrics.export()));
```

---

## 7. Server Monitoring URLs

| Service | Health Check | Metrics |
|---------|--------------|---------|
| PreSuite Hub | https://presuite.eu/health | https://presuite.eu/metrics |
| PreMail | https://premail.site/health | https://premail.site/metrics |
| PreDrive | https://predrive.eu/health | https://predrive.eu/metrics |
| PreOffice | https://preoffice.site/health | https://preoffice.site/metrics |

---

## 8. Troubleshooting

### Common Issues

**1. Alerts not sending**
- Check webhook URL configuration
- Verify rate limiting isn't blocking
- Check deduplication window

**2. High memory in metrics**
- Metrics store data in memory
- Call `metrics.reset()` periodically if needed
- Limit cardinality of labels

**3. Backup failures**
- Check database credentials
- Verify disk space
- Check S3 configuration

### Debug Mode

```bash
# Enable debug logging
export LOG_LEVEL=debug

# Run backup with verbose output
bash -x ./backup.sh
```

---

## Related Documentation

- [Architecture Diagrams](./architecture/README.md)
- [Testing Infrastructure](./TESTING-INFRASTRUCTURE.md)
- [SSO Implementation](./PRESUITE-SSO-IMPLEMENTATION.md)
- [User Guide](./USER-GUIDE.md)
