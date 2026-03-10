import Database from 'better-sqlite3';
import path from 'path';

const dbPath = process.env.DB_PATH || path.join(process.cwd(), 'library.db');
const db: Database.Database = new Database(dbPath);

// Enable foreign keys
db.pragma('foreign_keys = ON');

export const initializeDatabase = () => {
  try {
    // 1. Create students table
    db.exec(`
      CREATE TABLE IF NOT EXISTS students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        current_status TEXT NOT NULL DEFAULT 'OUTSIDE',
        scan_count INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // 2. Create scan_logs table
    db.exec(`
      CREATE TABLE IF NOT EXISTS scan_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL,
        scan_type TEXT NOT NULL CHECK(scan_type IN ('ENTRY', 'EXIT')),
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students(id)
      )
    `);

    // 3. Create library_config table
    db.exec(`
      CREATE TABLE IF NOT EXISTS library_config (
        id INTEGER PRIMARY KEY,
        total_seats INTEGER NOT NULL DEFAULT 100,
        occupied_seats INTEGER NOT NULL DEFAULT 0,
        last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Initial config: 100 seats, 0 occupied
    const configExists = db.prepare('SELECT id FROM library_config WHERE id = 1').get();
    if (!configExists) {
      db.prepare(`
        INSERT INTO library_config (id, total_seats, occupied_seats, last_updated)
        VALUES (1, 100, 0, ?)
      `).run(new Date().toISOString());
      console.log('✅ Initial library configuration inserted');
    }

    // Insert 10 sample students
    const countResult = db.prepare('SELECT COUNT(*) as count FROM students').get() as { count: number };
    const studentCount = countResult.count;
    if (studentCount === 0) {
      const insertStudent = db.prepare(`
        INSERT INTO students (id, name, email, current_status, scan_count)
        VALUES (?, ?, ?, 'OUTSIDE', 0)
      `);

      const sampleStudents = [
        ['ST001', 'John Doe', 'john@example.com'],
        ['ST002', 'Jane Smith', 'jane@example.com'],
        ['ST003', 'Alice Johnson', 'alice@example.com'],
        ['ST004', 'Bob Williams', 'bob@example.com'],
        ['ST005', 'Charlie Brown', 'charlie@example.com'],
        ['ST006', 'David Miller', 'david@example.com'],
        ['ST007', 'Eve Davis', 'eve@example.com'],
        ['ST008', 'Frank Wilson', 'frank@example.com'],
        ['ST009', 'Grace Lee', 'grace@example.com'],
        ['ST010', 'Henry Taylor', 'henry@example.com'],
      ];

      for (const student of sampleStudents) {
        insertStudent.run(student[0], student[1], student[2]);
      }
      console.log('✅ 10 sample students inserted');
    }

    console.log('🚀 Database initialized with Smart Library schema');
  } catch (error) {
    console.error('❌ Error initializing database:', error);
    throw error;
  }
};

export const closeDatabase = () => {
  db.close();
  console.log('⏹️ Database connection closed');
};

export default db;
