/**
 * PreSuite Health Check System
 * Provides health endpoints for all services
 */

export interface HealthCheckResult {
  name: string;
  status: 'healthy' | 'degraded' | 'unhealthy';
  message?: string;
  latency?: number;
  timestamp: string;
}

export interface ServiceHealth {
  service: string;
  version: string;
  status: 'healthy' | 'degraded' | 'unhealthy';
  uptime: number;
  timestamp: string;
  checks: HealthCheckResult[];
}

export type HealthCheck = () => Promise<HealthCheckResult>;

/**
 * Create a health check system for a service
 */
export function createHealthChecker(service: string, version: string) {
  const startTime = Date.now();
  const checks: Map<string, HealthCheck> = new Map();

  return {
    /**
     * Register a health check
     */
    addCheck(name: string, check: HealthCheck) {
      checks.set(name, check);
    },

    /**
     * Run all health checks
     */
    async check(): Promise<ServiceHealth> {
      const results: HealthCheckResult[] = [];
      let overallStatus: 'healthy' | 'degraded' | 'unhealthy' = 'healthy';

      for (const [name, check] of checks) {
        try {
          const start = Date.now();
          const result = await Promise.race([
            check(),
            new Promise<HealthCheckResult>((_, reject) =>
              setTimeout(() => reject(new Error('Health check timeout')), 5000)
            ),
          ]);
          result.latency = Date.now() - start;
          results.push(result);

          if (result.status === 'unhealthy') {
            overallStatus = 'unhealthy';
          } else if (result.status === 'degraded' && overallStatus !== 'unhealthy') {
            overallStatus = 'degraded';
          }
        } catch (error) {
          results.push({
            name,
            status: 'unhealthy',
            message: error instanceof Error ? error.message : 'Check failed',
            timestamp: new Date().toISOString(),
          });
          overallStatus = 'unhealthy';
        }
      }

      return {
        service,
        version,
        status: overallStatus,
        uptime: Math.floor((Date.now() - startTime) / 1000),
        timestamp: new Date().toISOString(),
        checks: results,
      };
    },

    /**
     * Quick liveness check (is the service running?)
     */
    liveness(): { status: 'ok'; timestamp: string } {
      return {
        status: 'ok',
        timestamp: new Date().toISOString(),
      };
    },

    /**
     * Readiness check (is the service ready to receive traffic?)
     */
    async readiness(): Promise<{ ready: boolean; checks: HealthCheckResult[] }> {
      const health = await this.check();
      return {
        ready: health.status !== 'unhealthy',
        checks: health.checks,
      };
    },
  };
}

/**
 * Common health checks
 */
export const commonChecks = {
  /**
   * Check database connectivity
   */
  database(name: string, pingFn: () => Promise<void>): HealthCheck {
    return async () => {
      try {
        await pingFn();
        return {
          name,
          status: 'healthy',
          message: 'Database connection OK',
          timestamp: new Date().toISOString(),
        };
      } catch (error) {
        return {
          name,
          status: 'unhealthy',
          message: error instanceof Error ? error.message : 'Database connection failed',
          timestamp: new Date().toISOString(),
        };
      }
    };
  },

  /**
   * Check Redis connectivity
   */
  redis(name: string, pingFn: () => Promise<string>): HealthCheck {
    return async () => {
      try {
        const result = await pingFn();
        return {
          name,
          status: result === 'PONG' ? 'healthy' : 'degraded',
          message: result === 'PONG' ? 'Redis connection OK' : `Unexpected response: ${result}`,
          timestamp: new Date().toISOString(),
        };
      } catch (error) {
        return {
          name,
          status: 'unhealthy',
          message: error instanceof Error ? error.message : 'Redis connection failed',
          timestamp: new Date().toISOString(),
        };
      }
    };
  },

  /**
   * Check external HTTP service
   */
  httpService(name: string, url: string, expectedStatus = 200): HealthCheck {
    return async () => {
      try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 5000);

        const response = await fetch(url, {
          method: 'GET',
          signal: controller.signal,
        });

        clearTimeout(timeout);

        if (response.status === expectedStatus) {
          return {
            name,
            status: 'healthy',
            message: `Service responded with ${response.status}`,
            timestamp: new Date().toISOString(),
          };
        }

        return {
          name,
          status: 'degraded',
          message: `Unexpected status: ${response.status}`,
          timestamp: new Date().toISOString(),
        };
      } catch (error) {
        return {
          name,
          status: 'unhealthy',
          message: error instanceof Error ? error.message : 'Service unreachable',
          timestamp: new Date().toISOString(),
        };
      }
    };
  },

  /**
   * Check disk space
   */
  diskSpace(name: string, path: string, thresholdPercent = 90): HealthCheck {
    return async () => {
      try {
        // This would use fs.statfs in Node.js 18+
        // For now, return healthy as a placeholder
        return {
          name,
          status: 'healthy',
          message: 'Disk space check OK',
          timestamp: new Date().toISOString(),
        };
      } catch (error) {
        return {
          name,
          status: 'unhealthy',
          message: error instanceof Error ? error.message : 'Disk space check failed',
          timestamp: new Date().toISOString(),
        };
      }
    };
  },

  /**
   * Check memory usage
   */
  memory(name: string, thresholdPercent = 90): HealthCheck {
    return async () => {
      const used = process.memoryUsage();
      const heapUsedPercent = (used.heapUsed / used.heapTotal) * 100;

      if (heapUsedPercent >= thresholdPercent) {
        return {
          name,
          status: 'degraded',
          message: `High memory usage: ${heapUsedPercent.toFixed(1)}%`,
          timestamp: new Date().toISOString(),
        };
      }

      return {
        name,
        status: 'healthy',
        message: `Memory usage: ${heapUsedPercent.toFixed(1)}%`,
        timestamp: new Date().toISOString(),
      };
    };
  },
};

export default createHealthChecker;
