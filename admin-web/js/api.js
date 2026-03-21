// Smart Library Admin Panel - API Service Layer
// Handles all communication with the backend API

class ApiService {
    constructor() {
        this.baseUrl = CONFIG.API_BASE_URL;
        this.isOnline = false;
    }

    // Generic HTTP request method
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}${endpoint.includes('?') ? '&' : '?'}_t=${Date.now()}`;
        const config = {
            headers: {
                'Content-Type': 'application/json',
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache',
                ...options.headers
            },
            mode: 'cors',
            ...options
        };

        console.log(`🌐 API Request: ${url}`);

        try {
            const response = await fetch(url, config);
            
            console.log(`📡 API Response: ${response.status} ${response.statusText}`);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            this.isOnline = true;
            console.log('✅ API Success:', data);
            return data;
        } catch (error) {
            this.isOnline = false;
            console.error(`❌ API Error [${endpoint}]:`, error);
            
            // If it's a CORS error, provide more helpful message
            if (error.message.includes('CORS') || error.message.includes('Failed to fetch')) {
                console.error('🔒 CORS Error - Check backend CORS configuration');
                throw new Error('CORS error: Backend may be blocking requests. Please check backend CORS configuration.');
            }
            
            throw error;
        }
    }

    // Get library status
    async getLibraryStatus() {
        try {
            const response = await this.request(CONFIG.ENDPOINTS.LIBRARY_STATUS);
            return response.data;
        } catch (error) {
            console.error('Error fetching library status:', error);
            throw error;
        }
    }

    // Process QR code scan
    async processScan(studentId) {
        if (!studentId) {
            throw new Error('Student ID is required');
        }

        try {
            const response = await this.request(CONFIG.ENDPOINTS.SCAN, {
                method: 'POST',
                body: JSON.stringify({ studentId })
            });

            return response;
        } catch (error) {
            console.error('Error processing scan:', error);
            throw error;
        }
    }

    // Get students currently inside library
    async getStudentsInside() {
        try {
            const response = await this.request(CONFIG.ENDPOINTS.STUDENTS_INSIDE);
            return response.data;
        } catch (error) {
            console.error('Error fetching students inside:', error);
            throw error;
        }
    }

    // Get scan logs
    async getScanLogs(limit = CONFIG.MAX_ACTIVITY_LOGS) {
        try {
            const response = await this.request(`${CONFIG.ENDPOINTS.SCAN_LOGS}?limit=${limit}`);
            return response.data;
        } catch (error) {
            console.error('Error fetching scan logs:', error);
            throw error;
        }
    }

    // Reset system
    async resetSystem() {
        try {
            const response = await this.request(CONFIG.ENDPOINTS.ADMIN_RESET, {
                method: 'POST'
            });
            return response;
        } catch (error) {
            console.error('Error resetting system:', error);
            throw error;
        }
    }

    // Check system health
    async checkHealth() {
        try {
            console.log('🏥 Checking backend health...');
            // Try test endpoint first
            await this.request('/test');
            console.log('✅ Backend health check passed');
            this.isOnline = true;
            return true;
        } catch (error) {
            console.error('❌ Backend health check failed:', error);
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
