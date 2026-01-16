/**
 * PreSuite Metrics Collection
 * Prometheus-compatible metrics for all services
 */

export interface MetricLabels {
  [key: string]: string;
}

export interface MetricValue {
  value: number;
  labels: MetricLabels;
  timestamp: number;
}

export type MetricType = 'counter' | 'gauge' | 'histogram';

interface Metric {
  name: string;
  help: string;
  type: MetricType;
  values: MetricValue[];
}

/**
 * In-memory metrics store
 */
class MetricsRegistry {
  private metrics: Map<string, Metric> = new Map();
  private service: string;

  constructor(service: string) {
    this.service = service;
  }

  /**
   * Create or get a counter metric
   */
  counter(name: string, help: string) {
    const fullName = `${this.service}_${name}`;
    if (!this.metrics.has(fullName)) {
      this.metrics.set(fullName, {
        name: fullName,
        help,
        type: 'counter',
        values: [],
      });
    }

    const metric = this.metrics.get(fullName)!;

    return {
      inc: (labels: MetricLabels = {}, value = 1) => {
        const existing = metric.values.find(
          v => JSON.stringify(v.labels) === JSON.stringify(labels)
        );
        if (existing) {
          existing.value += value;
          existing.timestamp = Date.now();
        } else {
          metric.values.push({ value, labels, timestamp: Date.now() });
        }
      },
    };
  }

  /**
   * Create or get a gauge metric
   */
  gauge(name: string, help: string) {
    const fullName = `${this.service}_${name}`;
    if (!this.metrics.has(fullName)) {
      this.metrics.set(fullName, {
        name: fullName,
        help,
        type: 'gauge',
        values: [],
      });
    }

    const metric = this.metrics.get(fullName)!;

    return {
      set: (value: number, labels: MetricLabels = {}) => {
        const existing = metric.values.find(
          v => JSON.stringify(v.labels) === JSON.stringify(labels)
        );
        if (existing) {
          existing.value = value;
          existing.timestamp = Date.now();
        } else {
          metric.values.push({ value, labels, timestamp: Date.now() });
        }
      },
      inc: (labels: MetricLabels = {}, value = 1) => {
        const existing = metric.values.find(
          v => JSON.stringify(v.labels) === JSON.stringify(labels)
        );
        if (existing) {
          existing.value += value;
          existing.timestamp = Date.now();
        } else {
          metric.values.push({ value, labels, timestamp: Date.now() });
        }
      },
      dec: (labels: MetricLabels = {}, value = 1) => {
        const existing = metric.values.find(
          v => JSON.stringify(v.labels) === JSON.stringify(labels)
        );
        if (existing) {
          existing.value -= value;
          existing.timestamp = Date.now();
        } else {
          metric.values.push({ value: -value, labels, timestamp: Date.now() });
        }
      },
    };
  }

  /**
   * Create or get a histogram metric
   */
  histogram(name: string, help: string, buckets: number[] = [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]) {
    const fullName = `${this.service}_${name}`;
    if (!this.metrics.has(fullName)) {
      this.metrics.set(fullName, {
        name: fullName,
        help,
        type: 'histogram',
        values: [],
      });
    }

    const metric = this.metrics.get(fullName)!;
    const bucketCounters: Map<string, Map<number, number>> = new Map();
    const sums: Map<string, number> = new Map();
    const counts: Map<string, number> = new Map();

    return {
      observe: (value: number, labels: MetricLabels = {}) => {
        const labelKey = JSON.stringify(labels);

        // Initialize if needed
        if (!bucketCounters.has(labelKey)) {
          bucketCounters.set(labelKey, new Map(buckets.map(b => [b, 0])));
          sums.set(labelKey, 0);
          counts.set(labelKey, 0);
        }

        // Update bucket counters
        const counters = bucketCounters.get(labelKey)!;
        for (const bucket of buckets) {
          if (value <= bucket) {
            counters.set(bucket, (counters.get(bucket) || 0) + 1);
          }
        }

        // Update sum and count
        sums.set(labelKey, (sums.get(labelKey) || 0) + value);
        counts.set(labelKey, (counts.get(labelKey) || 0) + 1);

        // Store for export
        metric.values = [];
        for (const [lk, bc] of bucketCounters) {
          const parsedLabels = JSON.parse(lk);
          for (const [bucket, count] of bc) {
            metric.values.push({
              value: count,
              labels: { ...parsedLabels, le: String(bucket) },
              timestamp: Date.now(),
            });
          }
          metric.values.push({
            value: bc.get(buckets[buckets.length - 1]) || 0,
            labels: { ...parsedLabels, le: '+Inf' },
            timestamp: Date.now(),
          });
        }
      },
      startTimer: (labels: MetricLabels = {}) => {
        const start = process.hrtime.bigint();
        return () => {
          const end = process.hrtime.bigint();
          const durationMs = Number(end - start) / 1_000_000;
          this.histogram(name, help, buckets).observe(durationMs / 1000, labels);
        };
      },
    };
  }

  /**
   * Export metrics in Prometheus format
   */
  export(): string {
    const lines: string[] = [];

    for (const metric of this.metrics.values()) {
      lines.push(`# HELP ${metric.name} ${metric.help}`);
      lines.push(`# TYPE ${metric.name} ${metric.type}`);

      for (const value of metric.values) {
        const labelStr = Object.entries(value.labels)
          .map(([k, v]) => `${k}="${v}"`)
          .join(',');
        const suffix = labelStr ? `{${labelStr}}` : '';
        lines.push(`${metric.name}${suffix} ${value.value}`);
      }
    }

    return lines.join('\n');
  }

  /**
   * Get metrics as JSON
   */
  toJSON() {
    const result: Record<string, unknown> = {};
    for (const [name, metric] of this.metrics) {
      result[name] = {
        help: metric.help,
        type: metric.type,
        values: metric.values,
      };
    }
    return result;
  }

  /**
   * Reset all metrics
   */
  reset() {
    this.metrics.clear();
  }
}

/**
 * Create a metrics registry for a service
 */
export function createMetrics(service: string) {
  const registry = new MetricsRegistry(service);

  // Default metrics
  const httpRequestsTotal = registry.counter('http_requests_total', 'Total HTTP requests');
  const httpRequestDuration = registry.histogram('http_request_duration_seconds', 'HTTP request duration in seconds');
  const httpRequestsInFlight = registry.gauge('http_requests_in_flight', 'Current HTTP requests being processed');
  const activeConnections = registry.gauge('active_connections', 'Number of active connections');
  const errorsTotal = registry.counter('errors_total', 'Total errors');

  return {
    registry,

    // Pre-configured metrics
    httpRequestsTotal,
    httpRequestDuration,
    httpRequestsInFlight,
    activeConnections,
    errorsTotal,

    // Custom metric creation
    counter: (name: string, help: string) => registry.counter(name, help),
    gauge: (name: string, help: string) => registry.gauge(name, help),
    histogram: (name: string, help: string, buckets?: number[]) => registry.histogram(name, help, buckets),

    // Export
    export: () => registry.export(),
    toJSON: () => registry.toJSON(),
    reset: () => registry.reset(),
  };
}

export default createMetrics;
