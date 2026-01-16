/**
 * PreSuite Monitoring Infrastructure
 *
 * This module provides centralized monitoring capabilities for all PreSuite services.
 *
 * Components:
 * - Logging: Structured, secure logging with sensitive data masking
 * - Metrics: Prometheus-compatible metrics collection
 * - Health Checks: Service health monitoring and endpoints
 * - Alerting: Webhook-based alerting (Slack, Discord, etc.)
 *
 * @example
 * ```typescript
 * import { createLogger, createMetrics, createHealthChecker, createAlertManager } from '@presuite/monitoring';
 *
 * const logger = createLogger({ service: 'my-service' });
 * const metrics = createMetrics('my-service');
 * const health = createHealthChecker('my-service', '1.0.0');
 * ```
 */

// Logging
export { createLogger } from './logging/logger';
export type { LogLevel, LogEntry, LoggerConfig } from './logging/logger';

// Metrics
export { createMetrics } from './metrics/metrics';
export type { MetricLabels, MetricValue, MetricType } from './metrics/metrics';

// Health Checks
export { createHealthChecker, commonChecks } from './health/health-check';
export type { HealthCheckResult, ServiceHealth, HealthCheck } from './health/health-check';

// Alerting
export { createAlertManager, createAlertRuleEvaluator } from './alerting/alerting';
export type { Alert, AlertSeverity, AlertChannel, AlertManagerConfig, AlertRule } from './alerting/alerting';
