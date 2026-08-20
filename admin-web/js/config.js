// Smart Library Admin Panel - Configuration
// Central configuration for the entire application

const CONFIG = {
    // API Configuration
    API_BASE_URL: 'http://localhost:3000/api',
    
    // Timing Configuration
    REFRESH_INTERVAL: 5000,        // 5 seconds for auto-refresh
    TOAST_DURATION: 3000,           // 3 seconds for toast notifications
    SCAN_RESULT_DURATION: 5000,       // 5 seconds for scan result display
    CLOCK_UPDATE_INTERVAL: 1000,      // 1 second for live clock
    
    // UI Configuration
    MAX_ACTIVITY_LOGS: 20,           // Maximum number of activity logs to display
    ANIMATION_DURATION: 300,          // Default animation duration in ms
    DEBOUNCE_DELAY: 500,            // Debounce delay for API calls
    
    // Library Configuration
    TOTAL_SEATS: 350,                // Total number of seats in library
    SEAT_GRID_ROWS: 10,             // Seat grid visualization rows
    SEAT_GRID_COLS: 10,             // Seat grid visualization columns
    
    // Student Database (for demo purposes)
    STUDENTS: [
        { id: 'STU001', name: 'Aarav Sharma', course: 'B.Tech CSE' },
        { id: 'STU002', name: 'Priya Patel', course: 'MBA' },
        { id: 'STU003', name: 'Rohan Gupta', course: 'B.Tech ECE' },
        { id: 'STU004', name: 'Ananya Singh', course: 'BBA' },
        { id: 'STU005', name: 'Arjun Verma', course: 'B.Tech ME' },
        { id: 'STU006', name: 'Diya Reddy', course: 'B.Pharma' },
        { id: 'STU007', name: 'Kabir Mehta', course: 'B.Tech CSE' },
        { id: 'STU008', name: 'Ishita Joshi', course: 'MBA' },
        { id: 'STU009', name: 'Vihaan Kumar', course: 'B.Tech IT' },
        { id: 'STU010', name: 'Saanvi Iyer', course: 'BCA' }
    ],
    
    // Color Configuration
    COLORS: {
        PRIMARY: '#3B82F6',          // Blue 500
        SUCCESS: '#10B981',          // Emerald 500
        DANGER: '#EF4444',          // Red 500
        WARNING: '#F59E0B',          // Amber 500
        BACKGROUND: '#F9FAFB',        // Gray 50
        CARD_BG: '#FFFFFF',          // White
        TEXT_PRIMARY: '#111827',      // Gray 900
        TEXT_SECONDARY: '#6B7280'    // Gray 500
    },
    
    // Status Messages
    MESSAGES: {
        SYSTEM_ONLINE: 'System Online',
        SYSTEM_OFFLINE: 'System Offline',
        SCAN_SUCCESS_ENTRY: 'Entry Confirmed',
        SCAN_SUCCESS_EXIT: 'Exit Confirmed',
        SCAN_FAILED: 'Scan Failed',
        RESET_SUCCESS: 'System reset successfully',
        CONNECTION_ERROR: 'Failed to connect to backend',
        LOADING: 'Loading...',
        PROCESSING: 'Processing...',
        NO_STUDENTS: 'No students in library',
        LIBRARY_EMPTY: 'Library is currently empty'
    },
    
    // API Endpoints
    ENDPOINTS: {
        LIBRARY_STATUS: '/status',
        SCAN: '/scan',
        STUDENTS_INSIDE: '/students-inside',
        SCAN_LOGS: '/scan-logs',
        ADMIN_RESET: '/reset',
        HEALTH: '/health',
        SEATS: '/seats'
    },
    
    // Error Messages
    ERRORS: {
        NETWORK_ERROR: 'Network error occurred',
        DUPLICATE_SCAN: 'Duplicate scan detected',
        INVALID_STUDENT: 'Invalid student ID',
        SYSTEM_ERROR: 'System error occurred',
        CONNECTION_FAILED: 'Unable to reach backend server'
    },
    
    // Local Storage Keys
    STORAGE_KEYS: {
        LAST_UPDATE: 'lastUpdated',
        SYSTEM_STATUS: 'systemStatus',
        PREFERENCES: 'userPreferences'
    }
};

// Utility Functions
const Utils = {
    // Format time to HH:MM:SS
    formatTime: (date) => {
        if (!date) return '--:--:--';
        const d = new Date(date);
        return d.toLocaleTimeString('en-US', { 
            hour12: false, 
            hour: '2-digit', 
            minute: '2-digit', 
            second: '2-digit' 
        });
    },
    
    // Calculate live duration between entry and now (with ticking seconds for real-time display)
    calculateDuration: (entryTime) => {
        if (!entryTime) return '0s';
        const now = Date.now();
        const entry = new Date(entryTime).getTime();
        if (isNaN(entry)) return '0s';
        const diffMs = Math.max(0, now - entry);
        const diffSecs = Math.floor(diffMs / 1000);
        const diffMins = Math.floor(diffSecs / 60);
        const diffHours = Math.floor(diffMins / 60);
        const remainingMins = diffMins % 60;
        const remainingSecs = diffSecs % 60;
        
        if (diffHours > 0) {
            return `${diffHours}h ${remainingMins}m ${remainingSecs}s`;
        }
        if (diffMins > 0) {
            return `${diffMins}m ${remainingSecs}s`;
        }
        return `${diffSecs}s`;
    },
    
    // Get relative time
    getRelativeTime: (timestamp) => {
        if (!timestamp) return 'Just now';
        const now = new Date();
        const time = new Date(timestamp);
        const diffMs = now - time;
        const diffMins = Math.floor(diffMs / 60000);
        
        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins} mins ago`;
        
        const diffHours = Math.floor(diffMins / 60);
        if (diffHours < 24) return `${diffHours} hours ago`;
        
        const diffDays = Math.floor(diffHours / 24);
        return `${diffDays} days ago`;
    },
    
    // Get occupancy color class
    getOccupancyColor: (percentage) => {
        if (percentage < 50) return 'occupancy-low';
        if (percentage < 80) return 'occupancy-medium';
        return 'occupancy-high';
    },
    
    // Get duration color class
    getDurationColor: (duration) => {
        // Extract hours from duration string
        const hours = parseInt(duration) || 0;
        if (hours < 2) return 'duration-short';
        if (hours < 4) return 'duration-medium';
        return 'duration-long';
    },
    
    // Debounce function
    debounce: (func, wait) => {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },
    
    // Generate random number for demo
    randomBetween: (min, max) => {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    },
    
    // Validate student ID
    isValidStudentId: (studentId) => {
        return CONFIG.STUDENTS.some(student => student.id === studentId);
    },
    
    // Get student by ID
    getStudentById: (studentId) => {
        return CONFIG.STUDENTS.find(student => student.id === studentId);
    }
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { CONFIG, Utils };
} else {
    window.CONFIG = CONFIG;
    window.Utils = Utils;
}
