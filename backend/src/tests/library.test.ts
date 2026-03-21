import request from 'supertest';
import app from '../server';
import { initializeDatabase } from '../config/database';

describe('Smart Library API Tests', () => {
  const testStudentId = `TEST_${Date.now()}`;

  beforeAll(async () => {
    await initializeDatabase();
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
    it('should return 404 for non-existent student', async () => {
      const res = await request(app).get('/api/student/NONEXISTENT');
      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
    });
  });

  describe('POST /api/scan', () => {
    it('should process ENTRY scan and create a new student', async () => {
      const res = await request(app)
        .post('/api/scan')
        .send({ studentId: testStudentId });

      expect([200, 201]).toContain(res.status);
      expect(res.body.success).toBe(true);
      expect(res.body.action).toBe('ENTRY');
      expect(res.body.student.id).toBe(testStudentId);
      expect(res.body.student.status).toBe('INSIDE');
      expect(res.body.libraryStatus).toHaveProperty('totalSeats');
      expect(res.body.libraryStatus).toHaveProperty('occupiedSeats');
      expect(res.body.libraryStatus).toHaveProperty('availableSeats');
    });

    it('should reject duplicate scan within cooldown window', async () => {
      const res = await request(app)
        .post('/api/scan')
        .send({ studentId: testStudentId });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error).toMatch(/Duplicate scan detected/i);
    });

    it('should process EXIT scan after cooldown', async () => {
      await new Promise((resolve) => setTimeout(resolve, 5100));

      const res = await request(app)
        .post('/api/scan')
        .send({ studentId: testStudentId });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.action).toBe('EXIT');
      expect(res.body.student.id).toBe(testStudentId);
      expect(res.body.student.status).toBe('OUTSIDE');
    }, 15000);
  });

  describe('GET /api/scan-logs', () => {
    it('should return list of scan logs', async () => {
      const res = await request(app).get('/api/scan-logs');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe('GET /api/students-inside', () => {
    it('should return a students list payload', async () => {
      const res = await request(app).get('/api/students-inside');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(typeof res.body.count).toBe('number');
    });
  });
});
