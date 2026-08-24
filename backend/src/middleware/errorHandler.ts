import { Request, Response, NextFunction } from 'express';
import { AppError, NotFoundError } from '../utils/appError';
import { sendError } from '../utils/responseHandler';
import logger from '../utils/logger';

export { AppError };

/**
 * Global Centralized Error Handling Middleware
 */
export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  let statusCode = 500;
  let message = 'Internal Server Error';
  let errorCode = 'INTERNAL_SERVER_ERROR';
  let details: any[] | undefined = undefined;

  if (err instanceof AppError) {
    statusCode = err.statusCode;
    message = err.message;
    errorCode = err.errorCode;
    details = err.details;
  } else if (err.name === 'SyntaxError' && 'body' in err) {
    statusCode = 400;
    message = 'Malformed JSON in request body';
    errorCode = 'MALFORMED_JSON';
  } else if (err.message) {
    message = err.message;
  }

  // Log error using structured logger
  if (statusCode >= 500) {
    logger.error(`[${req.method} ${req.originalUrl}] Unhandled Exception: ${message}`, err, {
      path: req.originalUrl,
      method: req.method,
      ip: req.ip,
      body: req.body,
    });
  } else {
    logger.warn(`[${req.method} ${req.originalUrl}] Operational Warning (${statusCode}): ${message}`, {
      path: req.originalUrl,
      errorCode,
      details,
    });
  }

  sendError(res, statusCode, message, errorCode, details);
};

/**
 * 404 Route Not Found Middleware
 */
export const notFoundHandler = (req: Request, _res: Response, next: NextFunction): void => {
  next(new NotFoundError(`Route ${req.method} ${req.originalUrl} not found`));
};
