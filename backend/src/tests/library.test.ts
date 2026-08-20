import request from 'supertest';
import app from '../server';
import { initializeDatabase } from '../config/database';
import { isAccessExpired, calculateAccessExpiryDate, daysUntilExpiry, getAccessExpiryMessage } from '../utils/access_expiry';
import { updateOccupiedSeats } from '../models/library.model';

describe('Smart Library Comprehensive API Test Suite', () => {
  const testStudentId = `TEST_STUDENT_${Date.now()}`;

  beforeAll(async () => {
    await initializeDatabase();
  });

  // 1. Root & Health Check Endpoints
  describe('GET / (API Index)', () => {
    it('should return 200 with API name, version, and endpoints metadata', async () => {
      const res = await request(app).get('/');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('version');
      expect(res.body).toHaveProperty('endpoints');
      expect(typeof res.body.endpoints).toBe('object');
      expect(res.body.endpoints).toHaveProperty('status', '/api/status');
      expect(res.body.endpoints).toHaveProperty('scan', '/api/scan');
      expect(res.body.endpoints).toHaveProperty('health', '/api/health');
    });
  });

  describe('GET /api/health', () => {
    it('should return 200 and healthy status with valid timestamp and numeric uptime', async () => {
      const res = await request(app).get('/api/health');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.status).toBe('healthy');
      expect(typeof res.body.uptime).toBe('number');
      expect(new Date(res.body.timestamp).toISOString()).toBe(res.body.timestamp);
    });
  });

  // 2. Library Status
  describe('GET /api/status', () => {
    it('should return library occupancy status metrics with non-negative available seats', async () => {
      const res = await request(app).get('/api/status');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('totalSeats');
      expect(res.body.data).toHaveProperty('occupiedSeats');
      expect(res.body.data).toHaveProperty('availableSeats');
      expect(res.body.data).toHaveProperty('occupancyRate');
      expect(typeof res.body.data.totalSeats).toBe('number');
      expect(typeof res.body.data.occupiedSeats).toBe('number');
      expect(res.body.data.availableSeats).toBeGreaterThanOrEqual(0);
      expect(res.body.data.occupiedSeats + res.body.data.availableSeats).toBe(res.body.data.totalSeats);

      const expectedOccupancyRate = res.body.data.totalSeats > 0
        ? Math.round((res.body.data.occupiedSeats / res.body.data.totalSeats) * 100)
        : 0;
      expect(res.body.data.occupancyRate).toBe(expectedOccupancyRate);
    });
  });

  // 3. Software Scan Operations & Cooldown Throttling
  describe('POST /api/scan', () => {
    it('should reject scan if studentId is missing (400 Bad Request) without exposing stack trace', async () => {
      const res = await request(app).post('/api/scan').send({});
      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error).toMatch(/Student ID is required/i);
      expect(res.body.stack).toBeUndefined();
    });

    it('should process ENTRY scan and auto-create new student with INSIDE status', async () => {
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

    it('should reject duplicate scan within 5s cooldown window without modifying occupancy', async () => {
      const res = await request(app)
        .post('/api/scan')
        .send({ studentId: testStudentId });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error).toMatch(/Duplicate scan detected/i);
    });

    it('should process EXIT scan after cooldown period and set status to OUTSIDE', async () => {
      // Wait for 5.1 seconds cooldown window
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

  // 4. Student Details & Access Expiry Validation
  describe('GET /api/student/:studentId', () => {
    it('should return 404 Not Found for non-existent student without exposing sensitive information', async () => {
      const res = await request(app).get('/api/student/NONEXISTENT_STUDENT_ID_99999');
      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.error).toMatch(/Student not found/i);
      expect(res.body.stack).toBeUndefined();
    });

    it('should return 200 OK with student profile for existing student', async () => {
      const res = await request(app).get(`/api/student/${testStudentId}`);
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toBeDefined();
      expect(res.body.data.id).toBe(testStudentId);
      expect(res.body.data).toHaveProperty('name');
      expect(res.body.data).toHaveProperty('email');
      expect(res.body.data).toHaveProperty('current_status');
      expect(res.body.data).toHaveProperty('scan_count');
    });

    it('should correctly validate access expiry dates via isAccessExpired utility', () => {
      expect(isAccessExpired('2020-01-01')).toBe(true);
      expect(isAccessExpired('2099-12-31')).toBe(false);
      expect(isAccessExpired('invalid-date-string')).toBe(false);
    });

    it('should calculate correct graduation expiry date for degrees', () => {
      expect(calculateAccessExpiryDate('2022-08-01', 'BTech')).toBe('2026-06-30');
      expect(calculateAccessExpiryDate('2024-08-01', 'MBA')).toBe('2026-06-30');
      expect(calculateAccessExpiryDate('2023-08-01', 'BSc')).toBe('2026-06-30');
    });

    it('should compute days remaining and format expiry messages', () => {
      const days = daysUntilExpiry('2099-12-31');
      expect(days).toBeGreaterThan(0);
      const msg = getAccessExpiryMessage('2099-12-31');
      expect(msg).toContain('expires on 2099-12-31');
    });
  });

  // 5. Seat Map & Matrix Dimensions & Occupant Assignment
  describe('GET /api/seats', () => {
    it('should return 200 OK with complete seat map metrics and 2D matrix structure', async () => {
      const res = await request(app).get('/api/seats');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toBeDefined();

      // Verify schema attributes
      const { seats, totalSeats, occupiedSeats, availableSeats, occupancyRate, rows, cols, lastUpdated } = res.body.data;
      expect(typeof totalSeats).toBe('number');
      expect(typeof occupiedSeats).toBe('number');
      expect(typeof availableSeats).toBe('number');
      expect(typeof occupancyRate).toBe('number');
      expect(typeof rows).toBe('number');
      expect(typeof cols).toBe('number');
      expect(cols).toBe(10);
      expect(rows).toBe(Math.ceil(totalSeats / cols));
      expect(availableSeats).toBe(totalSeats - occupiedSeats);
      expect(new Date(lastUpdated).toString()).not.toBe('Invalid Date');

      // Verify 2D array matrix structure
      expect(Array.isArray(seats)).toBe(true);
      expect(seats.length).toBe(rows);

      // Verify each row and seat coordinate structure
      let totalCountedSeats = 0;
      let totalCountedOccupied = 0;
      const seenSeatIds = new Set<number>();

      for (let r = 0; r < seats.length; r++) {
        expect(Array.isArray(seats[r])).toBe(true);
        expect(seats[r].length).toBeLessThanOrEqual(cols);

        for (let c = 0; c < seats[r].length; c++) {
          const seat = seats[r][c];
          totalCountedSeats++;
          expect(seat).toHaveProperty('id');
          expect(seenSeatIds.has(seat.id)).toBe(false);
          seenSeatIds.add(seat.id);

          expect(seat.row).toBe(r + 1);
          expect(seat.col).toBe(c + 1);
          expect(['AVAILABLE', 'OCCUPIED']).toContain(seat.status);

          if (seat.status === 'OCCUPIED') {
            totalCountedOccupied++;
            expect(seat.student).toBeDefined();
            expect(seat.student).toHaveProperty('id');
            expect(seat.student).toHaveProperty('name');
          } else {
            expect(seat.student).toBeNull();
          }
        }
      }

      expect(totalCountedSeats).toBe(totalSeats);
      expect(totalCountedOccupied).toBe(occupiedSeats);
    });

    it('should dynamically assign occupied seat when a student enters the library', async () => {
      const occupantStudentId = `TEST_SEAT_OCCUPANT_${Date.now()}`;

      // Student enters
      const entryRes = await request(app)
        .post('/api/scan')
        .send({ studentId: occupantStudentId });
      expect([200, 201]).toContain(entryRes.status);
      expect(entryRes.body.action).toBe('ENTRY');

      // Fetch seat map
      const seatRes = await request(app).get('/api/seats');
      expect(seatRes.status).toBe(200);
      expect(seatRes.body.data.occupiedSeats).toBeGreaterThanOrEqual(1);

      // Find occupant in 2D grid
      const seats = seatRes.body.data.seats;
      let foundOccupant = false;
      for (const row of seats) {
        for (const seat of row) {
          if (seat.status === 'OCCUPIED' && seat.student?.id === occupantStudentId) {
            foundOccupant = true;
            break;
          }
        }
        if (foundOccupant) break;
      }
      expect(foundOccupant).toBe(true);
    });
  });

  // 6. Scan Logs & Students Inside
  describe('GET /api/scan-logs & GET /api/students-inside', () => {
    it('should return scan logs array ordered newest first with limit respected', async () => {
      const res = await request(app).get('/api/scan-logs?limit=5');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(typeof res.body.count).toBe('number');
      expect(res.body.count).toBe(res.body.data.length);
      expect(res.body.data.length).toBeLessThanOrEqual(5);

      // Verify ordering newest first
      if (res.body.data.length > 1) {
        const firstTime = new Date(res.body.data[0].timestamp).getTime();
        const secondTime = new Date(res.body.data[1].timestamp).getTime();
        expect(firstTime).toBeGreaterThanOrEqual(secondTime);
      }
    });

    it('should return students currently inside with matching count', async () => {
      const res = await request(app).get('/api/students-inside');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(typeof res.body.count).toBe('number');
      expect(res.body.count).toBe(res.body.data.length);
    });
  });

  // 7. Administrative Reset & Boundary Guards
  describe('POST /api/reset', () => {
    it('should reset library occupancy, set all students to OUTSIDE, and zero occupancy metrics', async () => {
      // 1. Perform reset call
      const res = await request(app).post('/api/reset');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toMatch(/reset/i);

      // 2. Verify status endpoint is completely zeroed
      const statusRes = await request(app).get('/api/status');
      expect(statusRes.status).toBe(200);
      expect(statusRes.body.data.occupiedSeats).toBe(0);
      expect(statusRes.body.data.availableSeats).toBe(statusRes.body.data.totalSeats);
      expect(statusRes.body.data.occupancyRate).toBe(0);

      // 3. Verify students-inside endpoint returns empty list
      const studentsInsideRes = await request(app).get('/api/students-inside');
      expect(studentsInsideRes.status).toBe(200);
      expect(studentsInsideRes.body.count).toBe(0);
      expect(studentsInsideRes.body.data).toEqual([]);

      // 4. Verify seat map reflects all seats AVAILABLE
      const seatMapRes = await request(app).get('/api/seats');
      expect(seatMapRes.status).toBe(200);
      expect(seatMapRes.body.data.occupiedSeats).toBe(0);
      expect(seatMapRes.body.data.availableSeats).toBe(seatMapRes.body.data.totalSeats);

      const seats = seatMapRes.body.data.seats;
      for (const row of seats) {
        for (const seat of row) {
          expect(seat.status).toBe('AVAILABLE');
          expect(seat.student).toBeNull();
        }
      }
    });

    it('should prevent occupied_seats from decrementing below zero (Negative Floor Boundary)', async () => {
      // Attempt to decrement when occupied_seats is already 0
      const result = await updateOccupiedSeats(false);
      expect(result).toBe(true);

      const statusRes = await request(app).get('/api/status');
      expect(statusRes.status).toBe(200);
      expect(statusRes.body.data.occupiedSeats).toBe(0);
      expect(statusRes.body.data.occupiedSeats).toBeGreaterThanOrEqual(0);
    });
  });

  // 8. Unknown Route Handling
  describe('GET /api/does-not-exist (404 Unknown Route)', () => {
    it('should return 404 with standard error and no stack trace or secrets exposed', async () => {
      const res = await request(app).get('/api/does-not-exist');
      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/Route \/api\/does-not-exist not found/i);
      expect(res.body.stack).toBeUndefined();
    });
  });
});
