-- Add course column to students table (if degree column is already used, course serves as alias)
-- Migration: Ensure course field exists for QR scan integration

ALTER TABLE students
ADD COLUMN IF NOT EXISTS course TEXT DEFAULT NULL;

COMMENT ON COLUMN students.course IS 'Course/program name: B.Tech CSE, MBA, BBA, B.Pharma, etc.';
