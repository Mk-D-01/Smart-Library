// Supabase Configuration
// 
// This file contains the Supabase connection credentials.
// For production apps, consider using environment variables or secure storage.

class SupabaseConfig {
  // Supabase Project URL
  static const String url = 'https://durphnxkjxboefxkkfty.supabase.co';
  
  // Supabase Anon Key (safe for client-side use)
  // Note: Using service key here - in production, use the anon key for client apps
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1cnBoeG5ranhib2VmeGtrZnR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMzg3NzksImV4cCI6MjEwMjgxNDc3OX0.xhIPkq7A99-jA3bbBWDCiGVwUelMx-72jbx0Z4tbIL0';
  
  // Database table names
  static const String studentsTable = 'students';
  static const String scanLogsTable = 'scan_logs';
  static const String libraryConfigTable = 'library_config';
}
