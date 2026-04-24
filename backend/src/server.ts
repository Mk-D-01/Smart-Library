import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { initializeDatabase, closeDatabase } from './config/database';
import libraryRoutes from './routes/library.routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

// Load environment variables
dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet({
  contentSecurityPolicy: false, // Disable CSP for development
}));
app.use(cors({
  origin: ['http://localhost:8080', 'http://127.0.0.1:8080'], // Allow admin panel
  credentials: true
}));
app.use(morgan('combined'));
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Basic Health/Index Routes
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
      health: '/api/health'
    },
  });
});

app.get('/api/health', (_req: Request, res: Response) => {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API Routes
app.use('/api', libraryRoutes);

// 404 Handler
app.use(notFoundHandler);

// Error Handler (must be last)
app.use(errorHandler);

// Initialize database
export const startServer = async () => {
  try {
    await initializeDatabase();
  } catch (error) {
    console.error('Failed to initialize database:', error);
    process.exit(1);
  }

  // Start server
  let server: any;
  if (process.env.NODE_ENV !== 'test') {
    server = app.listen(PORT, () => {
      console.log(`🚀 Server is running on http://localhost:${PORT}`);
      console.log(`📚 Smart Library Management System API`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`);
    });
  }

  // Graceful shutdown
  const shutdown = () => {
    console.log('Stopping server...');
    if (server) {
      server.close(() => {
        console.log('HTTP server closed');
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
