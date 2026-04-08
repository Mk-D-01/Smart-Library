// Supabase Configuration
// 
// This file contains the Supabase connection credentials.
// For production apps, consider using environment variables or secure storage.

class SupabaseConfig {
  // Supabase Project URL
  static const String url = 'https://yvzafbeubvwrsdmefuzo.supabase.co';
  
  // Supabase Anon Key (safe for client-side use)
  // Note: Using service key here - in production, use the anon key for client apps
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2emFmYmV1YnZ3cnNkbWVmdXpvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDA4Mjk5MSwiZXhwIjoyMDg5NjU4OTkxfQ.ejNEnxnsqaumiDLRJeKsYGNEQBgWwVqfUwesZ0hsef0';
  
  // Database table names
  static const String studentsTable = 'students';
  static const String scanLogsTable = 'scan_logs';
  static const String libraryConfigTable = 'library_config';
}
