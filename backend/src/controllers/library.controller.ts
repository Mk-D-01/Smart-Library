import { Request, Response } from 'express';
import {
  getStudent,
  createStudent,
  updateStudentStatus,
  logScan,
  getLastScan,
  getLibraryStatus,
  updateOccupiedSeats,
  getStudentsInsideWithEntryTime,
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
    const lastScan = await getLastScan(studentId);
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

      // 5. Update student (status + scan_count)
      const updated = await updateStudentStatus(studentId, newStatusInner, scanCount + 1);
      if (!updated) {
        throw new Error('Failed to update student status');
      }
      const updatedStudentInner = updated;

      // 6. Update library occupancy with edge-case protections inside model
      const seatUpdated = await updateOccupiedSeats(isEntry);
      if (!seatUpdated) {
        throw new Error('Failed to update library occupancy');
      }

      // 7. Log the scan
      const logged = await logScan(studentId, actionInner);
      if (!logged) {
        throw new Error('Failed to log scan');
      }

      // 8. Get updated library status
      const libraryStatusInner = await getLibraryStatus();
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
        course: (updatedStudent as any).degree || (updatedStudent as any).course || null,
        semester: (updatedStudent as any).semester || null,
        phone: (updatedStudent as any).phone || null,
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
    const status = await getLibraryStatus();
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
    // Use enriched query that includes real entry time from scan_logs
    const students = await getStudentsInsideWithEntryTime();

    return res.status(200).json({
      success: true,
      data: students.map(s => ({
        id: s.id,
        name: s.name,
        email: s.email,
        current_status: s.current_status,
        scan_count: s.scan_count,
        created_at: s.created_at,
        entryTime: s.entryTime,
        course: (s as any).degree || (s as any).course || null,
        semester: (s as any).semester || null,
        phone: (s as any).phone || null,
      })),
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

    const logs = await getScanLogs(limit);

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
    await resetLibrarySystem();

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

// Generate seat map pictograph data
export const getSeatMap = async (_req: Request, res: Response) => {
  try {
    // Get library config for total seats
    const status = await getLibraryStatus();
    const totalSeats = status?.totalSeats || 400;
    
    // Get students with REAL entry times from scan_logs
    const students = await getStudentsInsideWithEntryTime();
    
    // Generate seat grid (10x10 per zone)
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
            student: student ? {
              id: student.id,
              name: student.name,
              entryTime: student.entryTime,
              course: (student as any).degree || (student as any).course || null,
            } : null
          });
          seatNumber++;
        }
      }
      seats.push(rowSeats);
    }
    
    return res.status(200).json({
      success: true,
      data: {
        seats,
        totalSeats,
        occupiedSeats: students.length,
        availableSeats: totalSeats - students.length,
        occupancyRate: totalSeats > 0 ? Math.round((students.length / totalSeats) * 100) : 0,
        rows,
        cols,
        lastUpdated: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error in getSeatMap:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};
