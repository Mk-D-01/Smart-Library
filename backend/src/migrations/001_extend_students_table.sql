-- Extend students table with degree tracking and access expiry fields
-- Migration: Add student details for degree-based access expiry

ALTER TABLE students
ADD COLUMN IF NOT EXISTS degree TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS admission_date DATE DEFAULT NULL,
ADD COLUMN IF NOT EXISTS access_expiry_date DATE DEFAULT NULL,
ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS semester INTEGER DEFAULT NULL,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Add comment for documentation
COMMENT ON COLUMN students.degree IS 'Degree program: BTech, MBA, BBA, BPharma, etc.';
COMMENT ON COLUMN students.admission_date IS 'Date of admission in ISO format';
COMMENT ON COLUMN students.access_expiry_date IS 'Date when library access expires, calculated from degree duration';
COMMENT ON COLUMN students.phone IS 'Student contact phone number';
COMMENT ON COLUMN students.semester IS 'Current semester of the student';
COMMENT ON COLUMN students.is_active IS 'Soft-delete flag: true = active, false = deactivated';
COMMENT ON COLUMN students.updated_at IS 'Last update timestamp';
