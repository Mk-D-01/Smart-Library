import { Response } from 'express';

export interface StandardSuccessResponse<T = any> {
  success: true;
  message?: string;
  data?: T;
  timestamp: string;
  [key: string]: any;
}

export interface StandardErrorPayload {
  code: string;
  message: string;
  details?: any[];
}

export interface StandardErrorResponse {
  success: false;
  error: string | StandardErrorPayload;
  timestamp: string;
}

/**
 * Send standardized success response
 */
export const sendSuccess = <T>(
  res: Response,
  statusCode: number = 200,
  data?: T,
  message?: string,
  extraPayload: Record<string, any> = {}
): Response => {
  const responseEnvelope: StandardSuccessResponse<T> = {
    success: true,
    ...(message && { message }),
    ...(data !== undefined && { data }),
    timestamp: new Date().toISOString(),
    ...extraPayload,
  };

  return res.status(statusCode).json(responseEnvelope);
};

/**
 * Send standardized error response
 */
export const sendError = (
  res: Response,
  statusCode: number = 500,
  message: string = 'An error occurred',
  errorCode: string = 'INTERNAL_ERROR',
  details?: any[]
): Response => {
  const errorEnvelope: StandardErrorResponse = {
    success: false,
    error: message, // Backward-compatible string message
    timestamp: new Date().toISOString(),
    ...(details && details.length > 0 && { details }),
    ...(errorCode && { code: errorCode }),
  };

  return res.status(statusCode).json(errorEnvelope);
};
