import request from 'supertest';
import app from '../server';
import db from '../config/database';

describe('Smart Library API Tests', () => {
  // Before all tests, ensure DB is initialized
  // Actually, server.ts already does it.
  
  afterAll(async () => {
    // Close DB connection after all tests
    db.close();
  });

  describe('GET /api/health', () => {
    it('should return 200 and healthy status', async () => {
      const res = await request(app).get('/api/health');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.status).toBe('healthy');
    });
  });

  describe('GET /api/status', () => {
    it('should return library occupancy status', async () => {
      const res = await request(app).get('/api/status');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('totalSeats');
      expect(res.body.data).toHaveProperty('occupiedSeats');
    });
  });

  describe('GET /api/student/:id', () => {
    it('should return student data for ST001', async () => {
      const res = await request(app).get('/api/student/ST001');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBe('ST001');
    });

    it('should return 404 for non-existent student', async () => {
      const res = await request(app).get('/api/student/NONEXISTENT');
      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
    });
  });

  describe('POST /api/scan', () => {
    it('should process ENTRY scan for ST001', async () => {
      // First ensure ST001 is OUTSIDE
      db.prepare("UPDATE students SET current_status = 'OUTSIDE' WHERE id = 'ST001'").run();
      
      const res = await request(app)
        .post('/api/scan')
        .send({ studentId: 'ST001' });
      
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.student.current_status).toBe('INSIDE');
      expect(res.body.data.scanLog.scan_type).toBe('ENTRY');
    });

    it('should process EXIT scan for ST001', async () => {
      // ST001 is now INSIDE from previous test
      const res = await request(app)
        .post('/api/scan')
        .send({ studentId: 'ST001' });
      
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.student.current_status).toBe('OUTSIDE');
      expect(res.body.data.scanLog.scan_type).toBe('EXIT');
    });
  });

  describe('GET /api/scan-logs', () => {
    it('should return list of scan logs', async () => {
      const res = await request(app).get('/api/scan-logs');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });
});
