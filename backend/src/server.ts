import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { initializeDatabase, closeDatabase } from './config/database';
import libraryRoutes from './routes/library.routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import logger from './utils/logger';

// Load environment variables
dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 3000;

// Security & Base Middleware
app.use(helmet({
  contentSecurityPolicy: false, // Disable CSP for local development
}));

app.use(cors({
  origin: ['http://localhost:8080', 'http://127.0.0.1:8080'], // Allow admin panel & frontend apps
  credentials: true,
}));

// Stream Morgan HTTP logs into structured logger
app.use(morgan(':method :url :status :res[content-length] - :response-time ms', {
  stream: logger.morganStream,
}));

app.use(express.json()); // Parse JSON body
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded body

// Base Health & Metadata Routes
app.get('/', (_req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'Smart Library Management System API',
    version: '1.0.0',
    endpoints: {
      status: '/api/status',
      scan: '/api/scan',
      studentsInside: '/api/students-inside',
      scanLogs: '/api/scan-logs',
      seats: '/api/seats',
      health: '/api/health',
    },
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/health', (_req: Request, res: Response) => {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// API Routes
app.use('/api', libraryRoutes);

// 404 Route Not Found Handler
app.use(notFoundHandler);

// Centralized Error Handler (must be last middleware)
app.use(errorHandler);

// Server Startup Function
export const startServer = async () => {
  try {
    await initializeDatabase();
  } catch (error: any) {
    logger.error('Failed to initialize database on server start:', error);
    process.exit(1);
  }

  let server: any;
  if (process.env.NODE_ENV !== 'test') {
    server = app.listen(PORT, () => {
      logger.info(`🚀 Server running on http://localhost:${PORT}`);
      logger.info(`📚 Smart Library Management System API v1.0.0`);
      logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`🏥 Health Check: http://localhost:${PORT}/api/health`);
    });
  }

  // Graceful shutdown handling
  const shutdown = () => {
    logger.info('Received shutdown signal, closing server...');
    if (server) {
      server.close(() => {
        logger.info('HTTP server closed cleanly');
        closeDatabase();
        process.exit(0);
      });
    } else {
      closeDatabase();
      process.exit(0);
    }
  };

  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
};

if (process.env.NODE_ENV !== 'test') {
  void startServer();
}

export default app;
