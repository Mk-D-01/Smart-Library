import { Router, Request, Response } from 'express';
import { getStudent } from '../models/library.model';
import {
  processScan,
  getLibraryStatusController,
  getStudentsInsideController,
  getScanLogsController,
  resetSystem,
} from '../controllers/library.controller';

const router = Router();

// Get library status
router.get('/status', getLibraryStatusController);

// Process student scan
router.post('/scan', processScan);

// Get students currently inside
router.get('/students-inside', getStudentsInsideController);

// Get scan logs
router.get('/scan-logs', getScanLogsController);

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

// Get seat occupancy pictograph
router.get('/seats', async (req: Request, res: Response) => {
  try {
    const { getSeatMap } = await import('../controllers/library.controller');
    const result = await getSeatMap(req, res);
    return result;
  } catch (error) {
    console.error('Error in /seats:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Reset library (admin function)
router.post('/reset', resetSystem);

export default router;
