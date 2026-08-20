export interface Student {
  id: string; // student ID from barcode/QR
  name: string;
  email: string;
  current_status: 'INSIDE' | 'OUTSIDE';
  scan_count: number;
  created_at: string;
  updated_at?: string;
  // Student profile fields
  course?: string; // 'B.Tech CSE', 'MBA', 'BBA', 'B.Pharma', etc.
  degree?: string; // 'BTech', 'MBA', 'BBA', 'BPharma', etc.
  admission_date?: string; // ISO date format
  access_expiry_date?: string; // ISO date format - calculated from degree + admission_date
  phone?: string;
  semester?: number;
  is_active?: boolean;
}

export interface ScanLog {
  id: number;
  student_id: string;
  scan_type: 'ENTRY' | 'EXIT';
  timestamp: string;
}

export interface LibraryConfig {
  id: number;
  total_seats: number;
  occupied_seats: number;
  last_updated: string;
}

export interface LibraryStatus {
  totalSeats: number;
  occupiedSeats: number;
  availableSeats: number;
  occupancyRate: number;
  lastUpdated: string;
}
