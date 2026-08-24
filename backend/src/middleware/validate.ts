import { Request, Response, NextFunction } from 'express';
import { body, param, query, validationResult } from 'express-validator';
import { ValidationError } from '../utils/appError';

/**
 * Middleware to check validation results and pass formatted ValidationError to next()
 */
export const handleValidationErrors = (req: Request, _res: Response, next: NextFunction): void => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map((err: any) => ({
      field: err.type === 'field' ? err.path : err.param || 'unknown',
      message: err.msg,
      value: err.type === 'field' ? err.value : undefined,
    }));
    return next(new ValidationError('Request validation failed', formattedErrors));
  }
  next();
};

/**
 * Validation rules for POST /api/scan
 */
export const validateScan = [
  body('studentId')
    .exists({ checkNull: true, checkFalsy: true })
    .withMessage('Student ID is required')
    .isString()
    .withMessage('Student ID must be a string')
    .trim()
    .notEmpty()
    .withMessage('Student ID cannot be empty or whitespace')
    .isLength({ min: 2, max: 50 })
    .withMessage('Student ID must be between 2 and 50 characters long'),
  handleValidationErrors,
];

/**
 * Validation rules for GET /api/scan-logs
 */
export const validateScanLogs = [
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be an integer between 1 and 100')
    .toInt(),
  handleValidationErrors,
];

/**
 * Validation rules for GET /api/student/:studentId
 */
export const validateStudentIdParam = [
  param('studentId')
    .exists({ checkNull: true, checkFalsy: true })
    .withMessage('Student ID parameter is required')
    .isString()
    .trim()
    .notEmpty()
    .withMessage('Student ID parameter cannot be empty'),
  handleValidationErrors,
];
