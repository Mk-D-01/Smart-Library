// Smart Library Admin Panel - API Service Layer
// Handles all communication with the backend API

class ApiService {
    constructor() {
        this.baseUrl = CONFIG.API_BASE_URL;
        this.isOnline = false;
    }

    // Generic HTTP request method
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const config = {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        };

        try {
            const response = await fetch(url, config);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            this.isOnline = true;
            return data;
        } catch (error) {
            this.isOnline = false;
            console.error(`API Error [${endpoint}]:`, error);
            throw error;
        }
    }

    // Get library status
    async getLibraryStatus() {
        try {
            const data = await this.request(CONFIG.ENDPOINTS.LIBRARY_STATUS);
            return {
                success: true,
                totalSeats: data.totalSeats || CONFIG.TOTAL_SEATS,
                occupiedSeats: data.occupiedSeats || 0,
                availableSeats: data.availableSeats || CONFIG.TOTAL_SEATS,
                occupancyPercentage: data.occupancyPercentage || 0
            };
        } catch (error) {
            console.error('Error fetching library status:', error);
            // Return demo data for development
            return this.getDemoLibraryStatus();
        }
    }

    // Process QR code scan
    async processScan(studentId) {
        if (!studentId) {
            throw new Error('Student ID is required');
        }

        try {
            const data = await this.request(CONFIG.ENDPOINTS.SCAN, {
                method: 'POST',
                body: JSON.stringify({ studentId })
            });

            return {
                success: true,
                action: data.action, // 'ENTRY' or 'EXIT'
                student: data.student,
                libraryStatus: data.libraryStatus,
                message: data.message
            };
        } catch (error) {
            console.error('Error processing scan:', error);
            return {
                success: false,
                error: error.message || CONFIG.ERRORS.SYSTEM_ERROR
            };
        }
    }

    // Get students currently inside library
    async getStudentsInside() {
        try {
            const data = await this.request(CONFIG.ENDPOINTS.STUDENTS_INSIDE);
            return {
                success: true,
                students: Array.isArray(data) ? data : []
            };
        } catch (error) {
            console.error('Error fetching students inside:', error);
            // Return demo data for development
            return this.getDemoStudentsInside();
        }
    }

    // Get scan logs
    async getScanLogs(limit = CONFIG.MAX_ACTIVITY_LOGS) {
        try {
            const data = await this.request(`${CONFIG.ENDPOINTS.SCAN_LOGS}?limit=${limit}`);
            return {
                success: true,
                logs: Array.isArray(data) ? data : []
            };
        } catch (error) {
            console.error('Error fetching scan logs:', error);
            // Return demo data for development
            return this.getDemoScanLogs();
        }
    }

    // Reset system
    async resetSystem() {
        try {
            const data = await this.request(CONFIG.ENDPOINTS.ADMIN_RESET, {
                method: 'POST'
            });
            return {
                success: true,
                message: data.message || CONFIG.MESSAGES.RESET_SUCCESS
            };
        } catch (error) {
            console.error('Error resetting system:', error);
            return {
                success: false,
                error: error.message || CONFIG.ERRORS.SYSTEM_ERROR
            };
        }
    }

    // Check system health
    async checkHealth() {
        try {
            await this.request('/health');
            this.isOnline = true;
            return true;
        } catch (error) {
            this.isOnline = false;
            return false;
        }
    }

    // Demo data methods (for development when backend is not available)
    getDemoLibraryStatus() {
        const occupied = Utils.randomBetween(30, 70);
        const available = CONFIG.TOTAL_SEATS - occupied;
        const percentage = Math.round((occupied / CONFIG.TOTAL_SEATS) * 100);

        return {
            success: true,
            totalSeats: CONFIG.TOTAL_SEATS,
            occupiedSeats: occupied,
            availableSeats: available,
            occupancyPercentage: percentage
        };
    }

    getDemoStudentsInside() {
        const demoStudents = [];
        const numStudents = Utils.randomBetween(5, 15);
        
        for (let i = 0; i < numStudents; i++) {
            const student = CONFIG.STUDENTS[i % CONFIG.STUDENTS.length];
            const entryTime = new Date(Date.now() - Utils.randomBetween(15, 240) * 60000);
            
            demoStudents.push({
                id: student.id,
                name: student.name,
                entryTime: entryTime.toISOString(),
                duration: Utils.calculateDuration(entryTime)
            });
        }

        return {
            success: true,
            students: demoStudents.sort((a, b) => new Date(b.entryTime) - new Date(a.entryTime))
        };
    }

    getDemoScanLogs() {
        const logs = [];
        const numLogs = Utils.randomBetween(10, 20);
        
        for (let i = 0; i < numLogs; i++) {
            const student = CONFIG.STUDENTS[Utils.randomBetween(0, CONFIG.STUDENTS.length - 1)];
            const isEntry = Math.random() > 0.5;
            const timestamp = new Date(Date.now() - Utils.randomBetween(1, 120) * 60000);
            
            logs.push({
                id: numLogs - i,
                studentId: student.id,
                studentName: student.name,
                scanType: isEntry ? 'ENTRY' : 'EXIT',
                timestamp: timestamp.toISOString()
            });
        }

        return {
            success: true,
            logs: logs.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
        };
    }

    // Simulate real-time updates
    simulateRealtimeUpdate() {
        // Simulate occasional scan events
        if (Math.random() > 0.95) { // 5% chance every update
            const student = CONFIG.STUDENTS[Utils.randomBetween(0, CONFIG.STUDENTS.length - 1)];
            const isEntry = Math.random() > 0.5;
            
            return {
                type: 'simulated_scan',
                studentId: student.id,
                studentName: student.name,
                action: isEntry ? 'ENTRY' : 'EXIT',
                timestamp: new Date().toISOString()
            };
        }
        return null;
    }

    // Get connection status
    getConnectionStatus() {
        return {
            isOnline: this.isOnline,
            message: this.isOnline ? CONFIG.MESSAGES.SYSTEM_ONLINE : CONFIG.MESSAGES.SYSTEM_OFFLINE
        };
    }
}

// Create singleton instance
const apiService = new ApiService();

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = apiService;
} else {
    window.apiService = apiService;
}
