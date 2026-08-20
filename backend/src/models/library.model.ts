import db, { initializeDatabase as initDB } from '../config/database';
import { Student, ScanLog, LibraryConfig, LibraryStatus } from '../types/library.types';
import { isAccessExpired } from '../utils/access_expiry';

export { initDB as initializeDatabase };

// Helper to simulate transactions for Supabase
export const runInTransaction = async <T>(fn: () => Promise<T>): Promise<T> => {
  // Supabase handles transactions automatically for single operations
  // For complex transactions, we'd use RPC functions, but for now this is a wrapper
  return await fn();
};

// Get student by ID
export const getStudent = async (studentId: string): Promise<Student | null> => {
  try {
    const { data, error } = await db
      .from('students')
      .select('*')
      .eq('id', studentId)
      .single();
    
    if (error) {
      if (error.code === 'PGRST116') {
        // No rows returned
        return null;
      }
      console.error(`Error in getStudent(${studentId}):`, error);
      throw error;
    }
    
    return data as Student;
  } catch (error) {
    console.error(`Error in getStudent(${studentId}):`, error);
    throw error;
  }
};

// Create a new student with default OUTSIDE status and zero scan count
export const createStudent = async (studentId: string, name: string): Promise<Student> => {
  try {
    // Email is required by schema, so generate a deterministic placeholder
    const email = `${studentId.toLowerCase()}@student.local`;

    const { data, error } = await db
      .from('students')
      .upsert({
        id: studentId,
        name,
        email,
        current_status: 'OUTSIDE',
        scan_count: 0,
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) {
      console.error(`Error in createStudent(${studentId}):`, error);
      throw error;
    }

    return data as Student;
  } catch (error) {
    console.error(`Error in createStudent(${studentId}):`, error);
    throw error;
  }
};

// Update student status and scan count
export const updateStudentStatus = async (
  studentId: string,
  status: 'INSIDE' | 'OUTSIDE',
  scanCount: number,
): Promise<Student | null> => {
  try {
    const { data, error } = await db
      .from('students')
      .update({
        current_status: status,
        scan_count: scanCount
      })
      .eq('id', studentId)
      .select()
      .single();

    if (error) {
      console.error(`Error in updateStudentStatus(${studentId}):`, error);
      throw error;
    }

    return data as Student;
  } catch (error) {
    console.error(`Error in updateStudentStatus(${studentId}):`, error);
    throw error;
  }
};

// Log scan event
export const logScan = async (studentId: string, scanType: 'ENTRY' | 'EXIT'): Promise<ScanLog | null> => {
  try {
    const { data, error } = await db
      .from('scan_logs')
      .insert({
        student_id: studentId,
        scan_type: scanType,
        timestamp: new Date().toISOString()
      })
      .select()
      .single();

    if (error) {
      console.error(`Error in logScan(${studentId}):`, error);
      throw error;
    }

    return data as ScanLog;
  } catch (error) {
    console.error(`Error in logScan(${studentId}):`, error);
    throw error;
  }
};

// Get the last scan for a student (used for duplicate-scan protection)
export const getLastScan = async (studentId: string): Promise<ScanLog | null> => {
  try {
    const { data, error } = await db
      .from('scan_logs')
      .select('*')
      .eq('student_id', studentId)
      .order('timestamp', { ascending: false })
      .limit(1)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // No rows returned
        return null;
      }
      console.error(`Error in getLastScan(${studentId}):`, error);
      throw error;
    }

    return data as ScanLog;
  } catch (error) {
    console.error(`Error in getLastScan(${studentId}):`, error);
    throw error;
  }
};

// Get current library status (derived stats + config)
export const getLibraryStatus = async (): Promise<LibraryStatus | null> => {
  try {
    const { data, error } = await db
      .from('library_config')
      .select('*')
      .eq('id', 1)
      .single();

    if (error) {
      console.error('Error in getLibraryStatus:', error);
      throw error;
    }

    const config = data as LibraryConfig;
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
export const updateOccupiedSeats = async (increment: boolean): Promise<boolean> => {
  try {
    // Get current config
    const { data: config, error: fetchError } = await db
      .from('library_config')
      .select('occupied_seats, total_seats')
      .eq('id', 1)
      .single();

    if (fetchError) {
      console.error('Error fetching current config:', fetchError);
      throw fetchError;
    }

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

    const { error: updateError } = await db
      .from('library_config')
      .update({
        occupied_seats: newCount,
        last_updated: new Date().toISOString()
      })
      .eq('id', 1);

    if (updateError) {
      console.error('Error in updateOccupiedSeats:', updateError);
      throw updateError;
    }

    return true;
  } catch (error) {
    console.error('Error in updateOccupiedSeats:', error);
    throw error;
  }
};

// Get all students currently inside the library
export const getStudentsInside = async (): Promise<Student[]> => {
  try {
    const { data, error } = await db
      .from('students')
      .select('*')
      .eq('current_status', 'INSIDE');

    if (error) {
      console.error('Error in getStudentsInside:', error);
      throw error;
    }

    return data as Student[];
  } catch (error) {
    console.error('Error in getStudentsInside:', error);
    return [];
  }
};

// Get all students inside WITH their actual library entry time from scan_logs
export const getStudentsInsideWithEntryTime = async (): Promise<(Student & { entryTime: string })[
]> => {
  try {
    // 1. Get all students currently INSIDE
    const students = await getStudentsInside();
    if (students.length === 0) return [];

    // 2. For each student, get their most recent ENTRY scan log
    const studentIds = students.map(s => s.id);
    const { data: entryLogs, error } = await db
      .from('scan_logs')
      .select('student_id, timestamp')
      .in('student_id', studentIds)
      .eq('scan_type', 'ENTRY')
      .order('timestamp', { ascending: false });

    if (error) {
      console.error('Error fetching entry logs:', error);
      // Fall back to created_at if scan_logs query fails
      return students.map(s => ({
        ...s,
        entryTime: s.created_at
      }));
    }

    // 3. Build a map of studentId -> most recent ENTRY timestamp
    const entryTimeMap: Record<string, string> = {};
    for (const log of (entryLogs || [])) {
      // Only keep the first (most recent) entry for each student
      if (!entryTimeMap[log.student_id]) {
        entryTimeMap[log.student_id] = log.timestamp;
      }
    }

    // 4. Merge entry times into student records
    return students.map(s => ({
      ...s,
      entryTime: entryTimeMap[s.id] || s.created_at
    }));
  } catch (error) {
    console.error('Error in getStudentsInsideWithEntryTime:', error);
    // Fall back to basic query
    const students = await getStudentsInside();
    return students.map(s => ({
      ...s,
      entryTime: s.created_at
    }));
  }
};

// Alias matching spec name
export const getAllStudentsInside = (): Promise<Student[]> => getStudentsInside();

// Get recent scan logs (joined with student names for UI)
export const getScanLogs = async (
  limit: number = 20,
): Promise<(ScanLog & { name: string })[]> => {
  try {
    const { data, error } = await db
      .from('scan_logs')
      .select(`
        *,
        students:student_id (
          name
        )
      `)
      .order('timestamp', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('Error in getScanLogs:', error);
      throw error;
    }

    // Transform the data to match the expected format
    return data.map((log: any) => ({
      ...log,
      name: log.students.name
    })) as (ScanLog & { name: string })[];
  } catch (error) {
    console.error('Error in getScanLogs:', error);
    return [];
  }
};

// Validate student access (check if not expired)
export const validateStudentAccess = async (studentId: string): Promise<{ valid: boolean; reason?: string }> => {
  try {
    const student = await getStudent(studentId);
    
    if (!student) {
      return { valid: false, reason: 'Student not found' };
    }

    // Check if student is active
    if (student.is_active === false) {
      return { valid: false, reason: 'Student account is deactivated' };
    }

    // If no expiry date set, allow access
    if (!student.access_expiry_date) {
      return { valid: true };
    }

    // Check if access has expired
    if (isAccessExpired(student.access_expiry_date)) {
      return { 
        valid: false, 
        reason: `Your library access expired on ${student.access_expiry_date}. Please contact the administration.`
      };
    }

    return { valid: true };
  } catch (error) {
    console.error(`Error validating student access for ${studentId}:`, error);
    // Default to allowing access if validation fails
    return { valid: true };
  }
};

// Reset system: set all students OUTSIDE and zero occupied seats
export const resetLibrarySystem = async (): Promise<void> => {
  try {
    // Reset all students
    const { error: studentError } = await db
      .from('students')
      .update({
        current_status: 'OUTSIDE',
        scan_count: 0
      })
      // Supabase/PostgREST requires a filter for UPDATE statements.
      .neq('id', '');

    if (studentError) {
      console.error('Error resetting students:', studentError);
      throw studentError;
    }

    // Reset library config
    const { error: configError } = await db
      .from('library_config')
      .update({
        occupied_seats: 0,
        last_updated: new Date().toISOString()
      })
      .eq('id', 1);

    if (configError) {
      console.error('Error resetting library config:', configError);
      throw configError;
    }
  } catch (error) {
    console.error('Error in resetLibrarySystem:', error);
    throw error;
  }
};

// Add explicit types export for models
export type { Student, ScanLog, LibraryConfig, LibraryStatus };
