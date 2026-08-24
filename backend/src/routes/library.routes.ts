import { Router } from 'express';
import {
  processScan,
  getLibraryStatusController,
  getStudentsInsideController,
  getScanLogsController,
  getStudentByIdController,
  getSeatMap,
  resetSystem,
} from '../controllers/library.controller';
import {
  validateScan,
  validateScanLogs,
  validateStudentIdParam,
} from '../middleware/validate';

const router = Router();

// Get library status
router.get('/status', getLibraryStatusController);

// Process student barcode/QR scan
router.post('/scan', validateScan, processScan);

// Get students currently inside
router.get('/students-inside', getStudentsInsideController);

// Get scan activity logs
router.get('/scan-logs', validateScanLogs, getScanLogsController);

// Get student by ID
router.get('/student/:studentId', validateStudentIdParam, getStudentByIdController);

// Get seat occupancy pictograph
router.get('/seats', getSeatMap);

// Reset library occupancy (admin function)
router.post('/reset', resetSystem);

export default router;
