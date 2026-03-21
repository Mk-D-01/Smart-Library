import db, { initializeDatabase as initDB } from '../config/database';
import { Student, ScanLog, LibraryConfig, LibraryStatus } from '../types/library.types';

export { initDB as initializeDatabase };

// Small helper to ensure all related updates run inside a single SQLite transaction
export const runInTransaction = <T>(fn: () => T): T => {
  const tx = db.transaction(fn);
  return tx();
};

// Get student by ID
export const getStudent = (studentId: string): Student | null => {
  try {
    const student = db.prepare('SELECT * FROM students WHERE id = ?').get(studentId);
    return (student as Student) || null;
  } catch (error) {
    console.error(`Error in getStudent(${studentId}):`, error);
    throw error;
  }
};

// Create a new student with default OUTSIDE status and zero scan count
export const createStudent = (studentId: string, name: string): Student => {
  try {
    // Email is required by schema, so generate a deterministic placeholder
    const email = `${studentId.toLowerCase()}@student.local`;

    db.prepare(
      `
      INSERT INTO students (id, name, email, current_status, scan_count, created_at)
      VALUES (?, ?, ?, 'OUTSIDE', 0, CURRENT_TIMESTAMP)
    `,
    ).run(studentId, name, email);

    const created = getStudent(studentId);
    if (!created) {
      throw new Error(`Failed to create student with id=${studentId}`);
    }
    return created;
  } catch (error) {
    console.error(`Error in createStudent(${studentId}):`, error);
    throw error;
  }
};

// Update student status and scan count
export const updateStudentStatus = (
  studentId: string,
  status: 'INSIDE' | 'OUTSIDE',
  scanCount: number,
): Student | null => {
  try {
    const result = db
      .prepare(
        `
      UPDATE students 
      SET current_status = ?, scan_count = ? 
      WHERE id = ?
    `,
      )
      .run(status, scanCount, studentId);

    if (result.changes > 0) {
      return getStudent(studentId);
    }
    return null;
  } catch (error) {
    console.error(`Error in updateStudentStatus(${studentId}):`, error);
    throw error;
  }
};

// Log scan event
export const logScan = (studentId: string, scanType: 'ENTRY' | 'EXIT'): ScanLog | null => {
  try {
    const result = db
      .prepare(
        `
      INSERT INTO scan_logs (student_id, scan_type, timestamp)
      VALUES (?, ?, CURRENT_TIMESTAMP)
    `,
      )
      .run(studentId, scanType);

    if (result.changes > 0) {
      // Fetch the inserted row so we also get the DB timestamp
      const inserted = db
        .prepare(
          `
        SELECT * FROM scan_logs
        WHERE id = ?
      `,
        )
        .get(result.lastInsertRowid as number) as ScanLog | undefined;
      return inserted || null;
    }
    return null;
  } catch (error) {
    console.error(`Error in logScan(${studentId}):`, error);
    throw error;
  }
};

// Get the last scan for a student (used for duplicate-scan protection)
export const getLastScan = (studentId: string): ScanLog | null => {
  try {
    const log = db
      .prepare(
        `
      SELECT * FROM scan_logs
      WHERE student_id = ?
      ORDER BY timestamp DESC
      LIMIT 1
    `,
      )
      .get(studentId) as ScanLog | undefined;
    return log || null;
  } catch (error) {
    console.error(`Error in getLastScan(${studentId}):`, error);
    throw error;
  }
};

// Get current library status (derived stats + config)
export const getLibraryStatus = (): LibraryStatus | null => {
  try {
    const config = db.prepare('SELECT * FROM library_config WHERE id = 1').get() as
      | LibraryConfig
      | undefined;
    if (!config) return null;

    const availableSeats = Math.max(0, config.total_seats - config.occupied_seats);
    const occupancyRate =
      config.total_seats > 0
        ? Math.round((config.occupied_seats / config.total_seats) * 100)
        : 0;

    return {
      totalSeats: config.total_seats,
      occupiedSeats: config.occupied_seats,
      availableSeats,
      occupancyRate,
      lastUpdated: config.last_updated,
    };
  } catch (error) {
    console.error('Error in getLibraryStatus:', error);
    throw error;
  }
};

// Update occupied seats count with negative/over-capacity protection
export const updateOccupiedSeats = (increment: boolean): boolean => {
  try {
    const config = db
      .prepare('SELECT occupied_seats, total_seats FROM library_config WHERE id = 1')
      .get() as { occupied_seats: number; total_seats: number } | undefined;
    if (!config) return false;

    let newCount = increment
      ? config.occupied_seats + 1
      : Math.max(0, config.occupied_seats - 1); // never go below zero

    if (!increment && config.occupied_seats === 0) {
      console.warn(
        '[SmartLibrary] Attempted to decrement occupied_seats below 0. Forcing to 0.',
      );
    }

    if (increment && newCount > config.total_seats) {
      // Allow going over capacity but log a warning for admin
      console.warn(
        `[SmartLibrary] Library capacity exceeded: total_seats=${config.total_seats}, new_occupied_seats=${newCount}`,
      );
    }

    const result = db
      .prepare(
        `
      UPDATE library_config 
      SET occupied_seats = ?, last_updated = ? 
      WHERE id = 1
    `,
      )
      .run(newCount, new Date().toISOString());

    return result.changes > 0;
  } catch (error) {
    console.error('Error in updateOccupiedSeats:', error);
    throw error;
  }
};

// Get all students currently inside the library
export const getStudentsInside = (): Student[] => {
  try {
    return db
      .prepare("SELECT * FROM students WHERE current_status = 'INSIDE'")
      .all() as Student[];
  } catch (error) {
    console.error('Error in getStudentsInside:', error);
    return [];
  }
};

// Alias matching spec name
export const getAllStudentsInside = (): Student[] => getStudentsInside();

// Get recent scan logs (joined with student names for UI)
export const getScanLogs = (
  limit: number = 20,
): (ScanLog & { name: string })[] => {
  try {
    return db
      .prepare(
        `
      SELECT sl.*, s.name 
      FROM scan_logs sl 
      JOIN students s ON sl.student_id = s.id 
      ORDER BY sl.timestamp DESC 
      LIMIT ?
    `,
      )
      .all(limit) as (ScanLog & { name: string })[];
  } catch (error) {
    console.error('Error in getScanLogs:', error);
    return [];
  }
};

// Reset system: set all students OUTSIDE and zero occupied seats
export const resetLibrarySystem = (): void => {
  runInTransaction(() => {
    db.prepare(
      `
        UPDATE students
        SET current_status = 'OUTSIDE',
            scan_count = 0
      `,
    ).run();

    db.prepare(
      `
        UPDATE library_config
        SET occupied_seats = 0,
            last_updated = ?
        WHERE id = 1
      `,
    ).run(new Date().toISOString());
  });
};

// Add explicit types export for models
export type { Student, ScanLog, LibraryConfig, LibraryStatus };
