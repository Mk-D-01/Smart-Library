/**
 * Structured Backend Logging Utility
 * Provides formatted JSON/console output with ISO timestamps, severity levels, and metadata.
 */

export type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR';

interface LogPayload {
  timestamp: string;
  level: LogLevel;
  message: string;
  meta?: Record<string, any>;
  stack?: string;
}

class Logger {
  private formatLog(level: LogLevel, message: string, meta?: Record<string, any>, error?: Error): string {
    const payload: LogPayload = {
      timestamp: new Date().toISOString(),
      level,
      message,
      ...(meta && Object.keys(meta).length > 0 && { meta }),
      ...(error && error.stack && { stack: error.stack }),
    };

    if (process.env.NODE_ENV === 'production') {
      return JSON.stringify(payload);
    }

    const emoji = {
      DEBUG: '🐛',
      INFO: 'ℹ️ ',
      WARN: '⚠️ ',
      ERROR: '❌ ',
    }[level];

    const metaStr = meta ? ` | Meta: ${JSON.stringify(meta)}` : '';
    const errStr = error?.stack ? `\nStack: ${error.stack}` : '';
    return `[${payload.timestamp}] ${emoji} ${level}: ${message}${metaStr}${errStr}`;
  }

  public debug(message: string, meta?: Record<string, any>): void {
    if (process.env.NODE_ENV === 'development' || process.env.DEBUG) {
      console.log(this.formatLog('DEBUG', message, meta));
    }
  }

  public info(message: string, meta?: Record<string, any>): void {
    console.log(this.formatLog('INFO', message, meta));
  }

  public warn(message: string, meta?: Record<string, any>): void {
    console.warn(this.formatLog('WARN', message, meta));
  }

  public error(message: string, error?: Error, meta?: Record<string, any>): void {
    console.error(this.formatLog('ERROR', message, meta, error));
  }

  // Stream adapter for Morgan HTTP logger integration
  public morganStream = {
    write: (message: string) => {
      this.info(message.trim(), { source: 'HTTP' });
    },
  };
}

export const logger = new Logger();
export default logger;
