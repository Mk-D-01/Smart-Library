import { Router, Request, Response } from 'express';
import { 
  getLibraryStatus, 
  getStudent, 
  updateStudentStatus, 
  logScan, 
  updateOccupiedSeats,
  getStudentsInside,
  getScanLogs 
} from '../models/library.model';

const router = Router();

// Get library status
router.get('/status', async (_req: Request, res: Response) => {
  try {
    const status = await getLibraryStatus();
    if (!status) {
      return res.status(500).json({
        success: false,
        error: 'Failed to fetch library status'
      });
    }

    return res.json({
      success: true,
      data: status
    });
  } catch (error) {
    console.error('Error in /status:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Process student scan
router.post('/scan', async (req: Request, res: Response) => {
  try {
    const { studentId } = req.body;

    if (!studentId) {
      return res.status(400).json({
        success: false,
        error: 'Student ID is required'
      });
    }

    // Get current student data
    const student = await getStudent(studentId);
    if (!student) {
      return res.status(404).json({
        success: false,
        error: 'Student not found'
      });
    }

    // Determine scan type and update status
    const currentStatus = student.current_status;
    const newStatus = currentStatus === 'OUTSIDE' ? 'INSIDE' : 'OUTSIDE';
    const scanType = currentStatus === 'OUTSIDE' ? 'ENTRY' : 'EXIT';
    const newScanCount = student.scan_count + 1;

    // Log the scan
    const scanLog = await logScan(studentId, scanType);
    if (!scanLog) {
      return res.status(500).json({
        success: false,
        error: 'Failed to log scan'
      });
    }

    // Update student status
    const updatedStudent = await updateStudentStatus(studentId, newStatus, newScanCount);
    if (!updatedStudent) {
      return res.status(500).json({
        success: false,
        error: 'Failed to update student status'
      });
    }

    // Update occupied seats count
    const seatUpdateSuccess = await updateOccupiedSeats(currentStatus === 'OUTSIDE');
    if (!seatUpdateSuccess) {
      return res.status(500).json({
        success: false,
        error: 'Failed to update seat count'
      });
    }

    return res.json({
      success: true,
      data: {
        student: updatedStudent,
        scanLog,
        message: `Student ${student.name} scanned ${scanType.toLowerCase()}`
      }
    });
  } catch (error) {
    console.error('Error in /scan:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Get students currently inside
router.get('/students-inside', async (_req: Request, res: Response) => {
  try {
    const students = await getStudentsInside();
    return res.json({
      success: true,
      data: students,
      count: students.length
    });
  } catch (error) {
    console.error('Error in /students-inside:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Get scan logs
router.get('/scan-logs', async (req: Request, res: Response) => {
  try {
    const limit = parseInt(req.query.limit as string) || 20;
    const logs = await getScanLogs(limit);
    return res.json({
      success: true,
      data: logs,
      count: logs.length
    });
  } catch (error) {
    console.error('Error in /scan-logs:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Get student by ID
router.get('/student/:studentId', async (req: Request, res: Response) => {
  try {
    const { studentId } = req.params;
    const student = await getStudent(studentId);
    
    if (!student) {
      return res.status(404).json({
        success: false,
        error: 'Student not found'
      });
    }

    return res.json({
      success: true,
      data: student
    });
  } catch (error) {
    console.error('Error in /student/:studentId:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Reset library (admin function)
router.post('/reset', async (_req: Request, res: Response) => {
  try {
    // This would need to be implemented based on your requirements
    // For now, just return success
    return res.json({
      success: true,
      message: 'Library reset functionality not implemented yet'
    });
  } catch (error) {
    console.error('Error in /reset:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

export default router;
