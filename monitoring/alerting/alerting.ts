/**
 * PreSuite Alerting System
 * Sends alerts via webhooks (Slack, Discord, Email, etc.)
 */

export type AlertSeverity = 'info' | 'warning' | 'critical';

export interface Alert {
  id: string;
  service: string;
  severity: AlertSeverity;
  title: string;
  message: string;
  timestamp: string;
  labels?: Record<string, string>;
  resolved?: boolean;
  resolvedAt?: string;
}

export interface AlertChannel {
  name: string;
  type: 'slack' | 'discord' | 'webhook' | 'email';
  url?: string;
  config?: Record<string, unknown>;
  severities: AlertSeverity[];
}

export interface AlertManagerConfig {
  service: string;
  channels: AlertChannel[];
  deduplicationWindow?: number; // ms
  rateLimitPerMinute?: number;
}

/**
 * Create an alert manager for a service
 */
export function createAlertManager(config: AlertManagerConfig) {
  const {
    service,
    channels,
    deduplicationWindow = 5 * 60 * 1000, // 5 minutes
    rateLimitPerMinute = 10,
  } = config;

  const recentAlerts: Map<string, number> = new Map();
  const alertCounts: { count: number; resetAt: number } = { count: 0, resetAt: Date.now() + 60000 };

  /**
   * Generate alert fingerprint for deduplication
   */
  function getFingerprint(alert: Omit<Alert, 'id' | 'timestamp'>): string {
    return `${alert.service}:${alert.severity}:${alert.title}:${JSON.stringify(alert.labels || {})}`;
  }

  /**
   * Check if alert should be deduplicated
   */
  function shouldDeduplicate(fingerprint: string): boolean {
    const lastSent = recentAlerts.get(fingerprint);
    if (!lastSent) return false;
    return Date.now() - lastSent < deduplicationWindow;
  }

  /**
   * Check rate limit
   */
  function checkRateLimit(): boolean {
    const now = Date.now();
    if (now >= alertCounts.resetAt) {
      alertCounts.count = 0;
      alertCounts.resetAt = now + 60000;
    }
    return alertCounts.count < rateLimitPerMinute;
  }

  /**
   * Format alert for Slack
   */
  function formatSlackMessage(alert: Alert): object {
    const color = {
      info: '#2196F3',
      warning: '#FF9800',
      critical: '#F44336',
    }[alert.severity];

    return {
      attachments: [
        {
          color,
          title: `[${alert.severity.toUpperCase()}] ${alert.title}`,
          text: alert.message,
          fields: [
            { title: 'Service', value: alert.service, short: true },
            { title: 'Time', value: alert.timestamp, short: true },
            ...(alert.labels
              ? Object.entries(alert.labels).map(([k, v]) => ({ title: k, value: v, short: true }))
              : []),
          ],
          footer: 'PreSuite Alerting',
          ts: Math.floor(new Date(alert.timestamp).getTime() / 1000),
        },
      ],
    };
  }

  /**
   * Format alert for Discord
   */
  function formatDiscordMessage(alert: Alert): object {
    const color = {
      info: 0x2196F3,
      warning: 0xFF9800,
      critical: 0xF44336,
    }[alert.severity];

    return {
      embeds: [
        {
          title: `[${alert.severity.toUpperCase()}] ${alert.title}`,
          description: alert.message,
          color,
          fields: [
            { name: 'Service', value: alert.service, inline: true },
            { name: 'Time', value: alert.timestamp, inline: true },
            ...(alert.labels
              ? Object.entries(alert.labels).map(([k, v]) => ({ name: k, value: v, inline: true }))
              : []),
          ],
          footer: { text: 'PreSuite Alerting' },
          timestamp: alert.timestamp,
        },
      ],
    };
  }

  /**
   * Send alert to a channel
   */
  async function sendToChannel(channel: AlertChannel, alert: Alert): Promise<boolean> {
    if (!channel.severities.includes(alert.severity)) {
      return false;
    }

    if (!channel.url) {
      console.error(`Alert channel ${channel.name} has no URL configured`);
      return false;
    }

    try {
      let body: string;
      let contentType = 'application/json';

      switch (channel.type) {
        case 'slack':
          body = JSON.stringify(formatSlackMessage(alert));
          break;
        case 'discord':
          body = JSON.stringify(formatDiscordMessage(alert));
          break;
        case 'webhook':
          body = JSON.stringify(alert);
          break;
        case 'email':
          // Email would require SMTP configuration
          console.log(`Email alert: ${alert.title}`);
          return true;
        default:
          body = JSON.stringify(alert);
      }

      const response = await fetch(channel.url, {
        method: 'POST',
        headers: { 'Content-Type': contentType },
        body,
      });

      return response.ok;
    } catch (error) {
      console.error(`Failed to send alert to ${channel.name}:`, error);
      return false;
    }
  }

  return {
    /**
     * Send an alert
     */
    async alert(
      severity: AlertSeverity,
      title: string,
      message: string,
      labels?: Record<string, string>
    ): Promise<Alert | null> {
      const alert: Alert = {
        id: `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
        service,
        severity,
        title,
        message,
        timestamp: new Date().toISOString(),
        labels,
      };

      const fingerprint = getFingerprint(alert);

      // Check deduplication
      if (shouldDeduplicate(fingerprint)) {
        console.debug(`Alert deduplicated: ${title}`);
        return null;
      }

      // Check rate limit
      if (!checkRateLimit()) {
        console.warn('Alert rate limit exceeded');
        return null;
      }

      // Send to all matching channels
      const results = await Promise.all(
        channels.map(channel => sendToChannel(channel, alert))
      );

      if (results.some(r => r)) {
        recentAlerts.set(fingerprint, Date.now());
        alertCounts.count++;
        return alert;
      }

      return null;
    },

    /**
     * Send info alert
     */
    info: (title: string, message: string, labels?: Record<string, string>) =>
      this.alert('info', title, message, labels),

    /**
     * Send warning alert
     */
    warning: (title: string, message: string, labels?: Record<string, string>) =>
      this.alert('warning', title, message, labels),

    /**
     * Send critical alert
     */
    critical: (title: string, message: string, labels?: Record<string, string>) =>
      this.alert('critical', title, message, labels),

    /**
     * Resolve an alert
     */
    async resolve(
      title: string,
      message: string,
      labels?: Record<string, string>
    ): Promise<Alert | null> {
      const alert: Alert = {
        id: `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
        service,
        severity: 'info',
        title: `[RESOLVED] ${title}`,
        message,
        timestamp: new Date().toISOString(),
        labels,
        resolved: true,
        resolvedAt: new Date().toISOString(),
      };

      // Clear deduplication for this alert type
      const fingerprint = getFingerprint({ ...alert, title });
      recentAlerts.delete(fingerprint);

      // Send to all channels
      await Promise.all(channels.map(channel => sendToChannel(channel, alert)));

      return alert;
    },
  };
}

/**
 * Alert rules for automated alerting
 */
export interface AlertRule {
  name: string;
  condition: () => boolean | Promise<boolean>;
  severity: AlertSeverity;
  title: string;
  message: string | (() => string);
  checkInterval: number; // ms
  labels?: Record<string, string>;
}

/**
 * Create an alert rule evaluator
 */
export function createAlertRuleEvaluator(alertManager: ReturnType<typeof createAlertManager>) {
  const rules: AlertRule[] = [];
  const ruleStates: Map<string, { firing: boolean; lastCheck: number }> = new Map();
  let evaluationInterval: NodeJS.Timeout | null = null;

  return {
    /**
     * Add an alert rule
     */
    addRule(rule: AlertRule) {
      rules.push(rule);
      ruleStates.set(rule.name, { firing: false, lastCheck: 0 });
    },

    /**
     * Evaluate all rules
     */
    async evaluate() {
      const now = Date.now();

      for (const rule of rules) {
        const state = ruleStates.get(rule.name)!;

        // Check if it's time to evaluate this rule
        if (now - state.lastCheck < rule.checkInterval) {
          continue;
        }

        state.lastCheck = now;

        try {
          const shouldFire = await rule.condition();

          if (shouldFire && !state.firing) {
            // Alert is firing
            state.firing = true;
            const message = typeof rule.message === 'function' ? rule.message() : rule.message;
            await alertManager.alert(rule.severity, rule.title, message, rule.labels);
          } else if (!shouldFire && state.firing) {
            // Alert resolved
            state.firing = false;
            const message = typeof rule.message === 'function' ? rule.message() : rule.message;
            await alertManager.resolve(rule.title, `${message} - Issue resolved`, rule.labels);
          }
        } catch (error) {
          console.error(`Error evaluating rule ${rule.name}:`, error);
        }
      }
    },

    /**
     * Start automatic rule evaluation
     */
    start(interval = 30000) {
      if (evaluationInterval) {
        return;
      }
      evaluationInterval = setInterval(() => this.evaluate(), interval);
      // Run immediately
      this.evaluate();
    },

    /**
     * Stop automatic rule evaluation
     */
    stop() {
      if (evaluationInterval) {
        clearInterval(evaluationInterval);
        evaluationInterval = null;
      }
    },
  };
}

export default createAlertManager;
