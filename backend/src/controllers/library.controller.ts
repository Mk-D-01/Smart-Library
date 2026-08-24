import { Request, Response, NextFunction } from 'express';
import {
  getStudent,
  createStudent,
  updateStudentStatus,
  logScan,
  getLastScan,
  getLibraryStatus,
  updateOccupiedSeats,
  getAllStudentsInside,
  getScanLogs,
  resetLibrarySystem,
  validateStudentAccess,
  runInTransaction,
} from '../models/library.model';
import { sendSuccess, sendError } from '../utils/responseHandler';
import { BadRequestError, ForbiddenError, NotFoundError } from '../utils/appError';
import logger from '../utils/logger';

/**
 * Process a student barcode/QR scan (ENTRY or EXIT)
 */
export const processScan = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { studentId } = req.body;

    // 1. Input validation (guaranteed by express-validator, but defensive check)
    if (!studentId) {
      throw new BadRequestError('Student ID is required', 'MISSING_STUDENT_ID');
    }

    // 2. Validate student account status and access expiry date
    const accessCheck = await validateStudentAccess(studentId);
    if (!accessCheck.valid) {
      logger.warn(`Scan rejected for ${studentId}: ${accessCheck.reason}`);
      throw new ForbiddenError(accessCheck.reason || 'Library access denied or expired', 'ACCESS_EXPIRED');
    }

    // 3. Check for duplicate scan (within 5 seconds cooldown window)
    const lastScan = await getLastScan(studentId);
    if (lastScan) {
      const timeDiffMs = Date.now() - new Date(lastScan.timestamp).getTime();
      if (timeDiffMs < 5000) {
        throw new BadRequestError('Duplicate scan detected. Please wait 5 seconds.', 'DUPLICATE_SCAN');
      }
    }

    // 4. Perform atomic operations
    const { action, updatedStudent, libraryStatus, createdNew } = await runInTransaction(async () => {
      let createdNewInner = false;

      let student = await getStudent(studentId);
      if (!student) {
        const name = `Student ${studentId}`;
        student = await createStudent(studentId, name);
        createdNewInner = true;
      }

      const scanCount = student.scan_count;
      const isEntry = scanCount % 2 === 0; // Even = Entry, Odd = Exit
      const actionInner: 'ENTRY' | 'EXIT' = isEntry ? 'ENTRY' : 'EXIT';
      const newStatusInner: 'INSIDE' | 'OUTSIDE' = isEntry ? 'INSIDE' : 'OUTSIDE';

      // Update student status and scan count
      const updated = await updateStudentStatus(studentId, newStatusInner, scanCount + 1);
      if (!updated) {
        throw new Error('Failed to update student status');
      }

      // Update occupancy counter
      const seatUpdated = await updateOccupiedSeats(isEntry);
      if (!seatUpdated) {
        throw new Error('Failed to update library occupancy');
      }

      // Log scan event
      const logged = await logScan(studentId, actionInner);
      if (!logged) {
        throw new Error('Failed to log scan event');
      }

      // Fetch fresh status
      const libraryStatusInner = await getLibraryStatus();
      if (!libraryStatusInner) {
        throw new Error('Failed to fetch updated library status');
      }

      return {
        action: actionInner,
        newStatus: newStatusInner,
        updatedStudent: updated,
        libraryStatus: libraryStatusInner,
        createdNew: createdNewInner,
      };
    });

    const statusCode = createdNew ? 201 : 200;
    logger.info(`Scan processed successfully for ${studentId}: ${action}`, { studentId, action });

    return res.status(statusCode).json({
      success: true,
      action,
      student: {
        id: updatedStudent.id,
        name: updatedStudent.name,
        status: updatedStudent.current_status,
      },
      libraryStatus: {
        totalSeats: libraryStatus.totalSeats,
        occupiedSeats: libraryStatus.occupiedSeats,
        availableSeats: libraryStatus.availableSeats,
      },
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get overall library occupancy status
 */
export const getLibraryStatusController = async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const status = await getLibraryStatus();
    if (!status) {
      throw new Error('Failed to fetch library status');
    }

    return sendSuccess(res, 200, status, 'Library status retrieved successfully');
  } catch (error) {
    next(error);
  }
};

/**
 * Get list of all students currently inside the library
 */
export const getStudentsInsideController = async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const students = await getAllStudentsInside();

    return sendSuccess(res, 200, students, 'Students inside retrieved successfully', {
      count: students.length,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get recent scan logs with optional limit
 */
export const getScanLogsController = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const limitParam = req.query.limit as string | undefined;
    const rawLimit = limitParam ? parseInt(limitParam, 10) : 20;
    const limit = Math.min(Math.max(1, rawLimit || 20), 100);

    const logs = await getScanLogs(limit);

    // Safe mapping in case student relation is null
    const safeLogs = logs.map((log: any) => ({
      id: log.id,
      student_id: log.student_id,
      name: log.name || log.students?.name || `Student ${log.student_id}`,
      scan_type: log.scan_type,
      timestamp: log.timestamp,
    }));

    return sendSuccess(res, 200, safeLogs, 'Scan logs retrieved successfully', {
      count: safeLogs.length,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get student by ID
 */
export const getStudentByIdController = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { studentId } = req.params;
    const student = await getStudent(studentId);

    if (!student) {
      throw new NotFoundError(`Student with ID '${studentId}' not found`, 'STUDENT_NOT_FOUND');
    }

    return sendSuccess(res, 200, student, 'Student details retrieved successfully');
  } catch (error) {
    next(error);
  }
};

/**
 * Reset library occupancy state (Admin action)
 */
export const resetSystem = async (_req: Request, res: Response, next: NextFunction) => {
  try {
    await resetLibrarySystem();
    logger.warn('Library system was reset by administrator');

    return sendSuccess(
      res,
      200,
      null,
      'Library system has been reset: all students set to OUTSIDE and occupied seats set to 0.'
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Generate seat map pictograph data
 */
export const getSeatMap = async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const status = await getLibraryStatus();
    const totalSeats = status?.totalSeats || 100;
    const students = await getAllStudentsInside();

    const cols = 10;
    const rows = Math.ceil(totalSeats / cols);

    const seats = [];
    let seatNumber = 1;

    for (let row = 0; row < rows; row++) {
      const rowSeats = [];
      for (let col = 0; col < cols; col++) {
        if (seatNumber <= totalSeats) {
          const studentIndex = seatNumber - 1;
          const student = studentIndex < students.length ? students[studentIndex] : null;

          rowSeats.push({
            id: seatNumber,
            row: row + 1,
            col: col + 1,
            status: student ? 'OCCUPIED' : 'AVAILABLE',
            student: student
              ? {
                  id: student.id,
                  name: student.name,
                }
              : null,
          });
          seatNumber++;
        }
      }
      seats.push(rowSeats);
    }

    const seatMapData = {
      seats,
      totalSeats,
      occupiedSeats: students.length,
      availableSeats: Math.max(0, totalSeats - students.length),
      occupancyRate: totalSeats > 0 ? Math.round((students.length / totalSeats) * 100) : 0,
      rows,
      cols,
      lastUpdated: new Date().toISOString(),
    };

    return sendSuccess(res, 200, seatMapData, 'Seat map generated successfully');
  } catch (error) {
    next(error);
  }
};
