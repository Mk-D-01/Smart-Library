import { Router } from 'express';
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

// Reset library (admin function)
router.post('/reset', resetSystem);

export default router;
