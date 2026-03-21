import { Request, Response } from 'express';
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
  runInTransaction,
} from '../models/library.model';

// Process a scan using odd/even scan_count:
// - Even scan_count (0, 2, 4, ...)  => ENTRY  => status INSIDE
// - Odd  scan_count (1, 3, 5, ...)  => EXIT   => status OUTSIDE
export const processScan = async (req: Request, res: Response) => {
  try {
    const { studentId } = req.body;

    // 1. Validate input
    if (!studentId) {
      return res.status(400).json({
        success: false,
        error: 'Student ID is required',
      });
    }

    // 2. Check for duplicate scan (within 5 seconds)
    const lastScan = getLastScan(studentId);
    if (lastScan) {
      const timeDiffMs = Date.now() - new Date(lastScan.timestamp).getTime();
      if (timeDiffMs < 5000) {
        return res.status(400).json({
          success: false,
          error: 'Duplicate scan detected. Please wait 5 seconds.',
        });
      }
    }

    // 3–8. Run all DB changes atomically inside a single transaction and
    // return the computed values so they are definitely assigned.
    const { action, updatedStudent, libraryStatus, createdNew } = runInTransaction(() => {
      let createdNewInner = false;

      let student = getStudent(studentId);
      if (!student) {
        const name = `Student ${studentId}`;
        student = createStudent(studentId, name);
        createdNewInner = true;
      }

      const scanCount = student.scan_count;
      const isEntry = scanCount % 2 === 0; // Even = Entry, Odd = Exit
      const actionInner: 'ENTRY' | 'EXIT' = isEntry ? 'ENTRY' : 'EXIT';
      const newStatusInner: 'INSIDE' | 'OUTSIDE' = isEntry ? 'INSIDE' : 'OUTSIDE';

      // 5. Update student (status + scan_count)
      const updated = updateStudentStatus(studentId, newStatusInner, scanCount + 1);
      if (!updated) {
        throw new Error('Failed to update student status');
      }
      const updatedStudentInner = updated;

      // 6. Update library occupancy with edge-case protections inside model
      const seatUpdated = updateOccupiedSeats(isEntry);
      if (!seatUpdated) {
        throw new Error('Failed to update library occupancy');
      }

      // 7. Log the scan
      const logged = logScan(studentId, actionInner);
      if (!logged) {
        throw new Error('Failed to log scan');
      }

      // 8. Get updated library status
      const libraryStatusInner = getLibraryStatus();
      if (!libraryStatusInner) {
        throw new Error('Failed to fetch updated library status');
      }
      return {
        action: actionInner,
        newStatus: newStatusInner,
        updatedStudent: updatedStudentInner,
        libraryStatus: libraryStatusInner,
        createdNew: createdNewInner,
      };
    });

    const statusCode = createdNew ? 201 : 200;

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
    });
  } catch (error) {
    console.error('Error processing scan:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};

// Simple wrappers for other library operations

export const getLibraryStatusController = async (_req: Request, res: Response) => {
  try {
    const status = getLibraryStatus();
    if (!status) {
      return res.status(500).json({
        success: false,
        error: 'Failed to fetch library status',
      });
    }

    return res.status(200).json({
      success: true,
      data: status,
    });
  } catch (error) {
    console.error('Error in getLibraryStatusController:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};

export const getStudentsInsideController = async (_req: Request, res: Response) => {
  try {
    const students = getAllStudentsInside();

    return res.status(200).json({
      success: true,
      data: students,
      count: students.length,
    });
  } catch (error) {
    console.error('Error in getStudentsInsideController:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};

export const getScanLogsController = async (req: Request, res: Response) => {
  try {
    const limitParam = req.query.limit as string | undefined;
    const limit = limitParam ? parseInt(limitParam, 10) : 20;

    const logs = getScanLogs(limit);

    return res.status(200).json({
      success: true,
      data: logs,
      count: logs.length,
    });
  } catch (error) {
    console.error('Error in getScanLogsController:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};

export const resetSystem = async (_req: Request, res: Response) => {
  try {
    resetLibrarySystem();

    return res.status(200).json({
      success: true,
      message: 'Library system has been reset: all students OUTSIDE and occupied seats set to 0.',
    });
  } catch (error) {
    console.error('Error in resetSystem:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};

