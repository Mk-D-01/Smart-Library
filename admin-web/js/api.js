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
            console.warn('Backend unavailable, using demo library status');
            return this.getDemoLibraryStatus();
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
            console.warn('Backend unavailable, processing scan in demo mode:', error.message);
            return this.processDemoScan(studentId);
        }
    }

    // Get students currently inside library
    async getStudentsInside() {
        try {
            const response = await this.request(CONFIG.ENDPOINTS.STUDENTS_INSIDE);
            return response.data;
        } catch (error) {
            console.warn('Backend unavailable, using demo students inside');
            return this.getDemoStudentsInside();
        }
    }

    // Get scan logs
    async getScanLogs(limit = CONFIG.MAX_ACTIVITY_LOGS) {
        try {
            const response = await this.request(`${CONFIG.ENDPOINTS.SCAN_LOGS}?limit=${limit}`);
            return response.data;
        } catch (error) {
            console.warn('Backend unavailable, using demo scan logs');
            return this.getDemoScanLogs();
        }
    }

    // Get seat map (10x10 matrix with student details)
    async getSeatMap() {
        try {
            const response = await this.request(CONFIG.ENDPOINTS.SEATS);
            return response.data;
        } catch (error) {
            console.warn('Backend unavailable, using demo seat map');
            return this.getDemoSeatMap();
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
            console.warn('Backend unavailable, resetting demo state');
            this.demoStudentsCache = [];
            return {
                success: true,
                message: 'Library system reset in demo mode'
            };
        }
    }

    // Check system health
    async checkHealth() {
        try {
            await this.request('/test');
            this.isOnline = true;
            return true;
        } catch (error) {
            this.isOnline = false;
            return false;
        }
    }

    // Demo data methods (for development when backend is not available)
    getDemoLibraryStatus() {
        const insideCount = this.demoStudentsCache ? this.demoStudentsCache.length : 5;
        const total = CONFIG.TOTAL_SEATS || 350;
        const available = Math.max(0, total - insideCount);
        const percentage = Math.round((insideCount / total) * 100);

        return {
            totalSeats: total,
            occupiedSeats: insideCount,
            availableSeats: available,
            occupancyRate: percentage,
            occupancyPercentage: percentage,
            lastUpdated: new Date().toISOString()
        };
    }

    getDemoStudentsInside() {
        if (!this.demoStudentsCache) {
            this.demoStudentsCache = [];
            const numStudents = 5;
            for (let i = 0; i < numStudents; i++) {
                const student = CONFIG.STUDENTS[i % CONFIG.STUDENTS.length];
                const entryTime = new Date(Date.now() - (i * 18 + 5) * 60000);
                this.demoStudentsCache.push({
                    id: student.id,
                    name: student.name,
                    course: student.course || 'B.Tech CSE',
                    entryTime: entryTime.toISOString(),
                    created_at: entryTime.toISOString()
                });
            }
        }

        return this.demoStudentsCache;
    }

    processDemoScan(studentId) {
        if (!this.demoStudentsCache) {
            this.getDemoStudentsInside();
        }

        const existingIndex = this.demoStudentsCache.findIndex(s => s.id === studentId);
        const studentInfo = CONFIG.STUDENTS.find(s => s.id === studentId) || { id: studentId, name: `Student ${studentId}`, course: 'B.Tech CSE' };
        let action = 'ENTRY';

        if (existingIndex >= 0) {
            // Student exiting
            action = 'EXIT';
            this.demoStudentsCache.splice(existingIndex, 1);
        } else {
            // Student entering now with fresh timestamp
            action = 'ENTRY';
            const nowIso = new Date().toISOString();
            this.demoStudentsCache.unshift({
                id: studentInfo.id,
                name: studentInfo.name,
                course: studentInfo.course || 'B.Tech CSE',
                entryTime: nowIso,
                created_at: nowIso
            });
        }

        // Add to activity logs
        if (!this.demoLogsCache) this.demoLogsCache = [];
        this.demoLogsCache.unshift({
            id: Date.now(),
            student_id: studentInfo.id,
            studentId: studentInfo.id,
            name: studentInfo.name,
            student_name: studentInfo.name,
            studentName: studentInfo.name,
            scan_type: action,
            scanType: action,
            timestamp: new Date().toISOString()
        });

        const occupied = this.demoStudentsCache.length;
        const total = CONFIG.TOTAL_SEATS || 350;

        return {
            success: true,
            action: action,
            student: {
                id: studentInfo.id,
                name: studentInfo.name,
                course: studentInfo.course || 'B.Tech CSE',
                status: action === 'ENTRY' ? 'INSIDE' : 'OUTSIDE'
            },
            libraryStatus: {
                totalSeats: total,
                occupiedSeats: occupied,
                availableSeats: Math.max(0, total - occupied),
                occupancyRate: Math.round((occupied / total) * 100)
            }
        };
    }

    getDemoScanLogs() {
        if (!this.demoLogsCache) {
            this.demoLogsCache = [];
            const numLogs = 10;
            for (let i = 0; i < numLogs; i++) {
                const student = CONFIG.STUDENTS[i % CONFIG.STUDENTS.length];
                const isEntry = i % 3 !== 0;
                const timestamp = new Date(Date.now() - (i * 12 + 4) * 60000);
                this.demoLogsCache.push({
                    id: numLogs - i,
                    student_id: student.id,
                    studentId: student.id,
                    name: student.name,
                    student_name: student.name,
                    studentName: student.name,
                    scan_type: isEntry ? 'ENTRY' : 'EXIT',
                    scanType: isEntry ? 'ENTRY' : 'EXIT',
                    timestamp: timestamp.toISOString()
                });
            }
        }

        return this.demoLogsCache;
    }

    getDemoSeatMap(students = []) {
        const totalSeats = CONFIG.TOTAL_SEATS || 350;
        const cols = CONFIG.SEAT_GRID_COLS || 10;
        const rows = CONFIG.SEAT_GRID_ROWS || 10;
        const seats = [];

        const insideList = (students && students.length > 0) ? students : (this.demoStudentsCache || this.getDemoStudentsInside());
        let seatNumber = 1;

        for (let row = 0; row < rows; row++) {
            const rowSeats = [];
            for (let col = 0; col < cols; col++) {
                if (seatNumber <= totalSeats) {
                    const studentIndex = seatNumber - 1;
                    const student = studentIndex < insideList.length ? insideList[studentIndex] : null;

                    rowSeats.push({
                        id: seatNumber,
                        row: row + 1,
                        col: col + 1,
                        status: student ? 'OCCUPIED' : 'AVAILABLE',
                        student: student ? {
                            id: student.id,
                            name: student.name,
                            course: student.course || 'B.Tech CSE',
                            entryTime: student.entryTime || student.created_at || new Date().toISOString()
                        } : null
                    });
                    seatNumber++;
                }
            }
            seats.push(rowSeats);
        }

        const occupiedCount = insideList.length;
        return {
            seats,
            totalSeats,
            occupiedSeats: occupiedCount,
            availableSeats: Math.max(0, totalSeats - occupiedCount),
            occupancyRate: totalSeats > 0 ? Math.round((occupiedCount / totalSeats) * 100) : 0,
            rows,
            cols,
            lastUpdated: new Date().toISOString()
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
