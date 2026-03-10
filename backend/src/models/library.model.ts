import db, { initializeDatabase as initDB } from '../config/database';
import { Student, ScanLog, LibraryConfig, LibraryStatus } from '../types/library.types';

export { initDB as initializeDatabase };

// Get student by ID
export const getStudent = (studentId: string): Student | null => {
  try {
    const student = db.prepare('SELECT * FROM students WHERE id = ?').get(studentId);
    return student as Student || null;
  } catch (error) {
    console.error(`Error in getStudent(${studentId}):`, error);
    throw error;
  }
};

// Update student status and scan count
export const updateStudentStatus = (
  studentId: string, 
  status: 'INSIDE' | 'OUTSIDE', 
  scanCount: number
): Student | null => {
  try {
    const result = db.prepare(`
      UPDATE students 
      SET current_status = ?, scan_count = ? 
      WHERE id = ?
    `).run(status, scanCount, studentId);
    
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
export const logScan = (
  studentId: string, 
  scanType: 'ENTRY' | 'EXIT'
): ScanLog | null => {
  try {
    const timestamp = new Date().toISOString();
    const result = db.prepare(`
      INSERT INTO scan_logs (student_id, scan_type, timestamp)
      VALUES (?, ?, ?)
    `).run(studentId, scanType, timestamp);
    
    if (result.changes > 0) {
      return {
        id: result.lastInsertRowid as number,
        student_id: studentId,
        scan_type: scanType,
        timestamp: timestamp
      };
    }
    return null;
  } catch (error) {
    console.error(`Error in logScan(${studentId}):`, error);
    throw error;
  }
};

// Get current library status
export const getLibraryStatus = (): LibraryStatus | null => {
  try {
    const config = db.prepare('SELECT * FROM library_config WHERE id = 1').get() as LibraryConfig;
    if (!config) return null;
    
    const availableSeats = Math.max(0, config.total_seats - config.occupied_seats);
    const occupancyRate = config.total_seats > 0 
      ? Math.round((config.occupied_seats / config.total_seats) * 100) 
      : 0;
    
    return {
      totalSeats: config.total_seats,
      occupiedSeats: config.occupied_seats,
      availableSeats,
      occupancyRate,
      lastUpdated: config.last_updated
    };
  } catch (error) {
    console.error('Error in getLibraryStatus:', error);
    throw error;
  }
};

// Update occupied seats count
export const updateOccupiedSeats = (increment: boolean): boolean => {
  try {
    const config = db.prepare('SELECT occupied_seats, total_seats FROM library_config WHERE id = 1').get() as { occupied_seats: number, total_seats: number } | undefined;
    if (!config) return false;
    
    let newCount = increment 
      ? config.occupied_seats + 1 
      : Math.max(0, config.occupied_seats - 1);
    
    // Safety check for increment
    if (increment && newCount > config.total_seats) {
      newCount = config.total_seats;
    }
    
    const result = db.prepare(`
      UPDATE library_config 
      SET occupied_seats = ?, last_updated = ? 
      WHERE id = 1
    `).run(newCount, new Date().toISOString());
    
    return result.changes > 0;
  } catch (error) {
    console.error('Error in updateOccupiedSeats:', error);
    throw error;
  }
};

// Helper: Get all students currently inside the library (not explicitly requested but useful)
export const getStudentsInside = (): Student[] => {
  try {
    return db.prepare("SELECT * FROM students WHERE current_status = 'INSIDE'").all() as Student[];
  } catch (error) {
    console.error('Error in getStudentsInside:', error);
    return [];
  }
};

// Helper: Get recent scan logs (not explicitly requested but useful)
export const getScanLogs = (limit: number = 20): (ScanLog & { name: string })[] => {
  try {
    return db.prepare(`
      SELECT sl.*, s.name 
      FROM scan_logs sl 
      JOIN students s ON sl.student_id = s.id 
      ORDER BY sl.timestamp DESC 
      LIMIT ?
    `).all(limit) as (ScanLog & { name: string })[];
  } catch (error) {
    console.error('Error in getScanLogs:', error);
    return [];
  }
};

// Add explicit types export for models
export type { Student, ScanLog, LibraryConfig, LibraryStatus };
