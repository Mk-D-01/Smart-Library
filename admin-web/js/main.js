// Smart Library Admin Panel - Main Application Logic
// Main entry point and application controller

class LibraryAdminApp {
    constructor() {
        this.refreshInterval = null;
        this.clockInterval = null;
        this.isInitialized = false;
        this.currentData = {
            libraryStatus: null,
            studentsInside: [],
            activityLogs: []
        };
    }

    // Initialize application
    async init() {
        try {
            console.log('🚀 Initializing Smart Library Admin Panel...');
            
            // Check dependencies again
            if (!window.uiManager || !window.apiService || !window.CONFIG) {
                throw new Error('Required dependencies not loaded');
            }
            
            // Show loading state
            uiManager.showLoading();
            
            // Initialize UI components
            uiManager.populateStudentDropdown();
            
            // Setup event listeners
            this.setupEventListeners();
            
            // Load initial data
            await this.loadInitialData();
            
            // Start periodic updates
            this.startPeriodicUpdates();
            
            // Hide loading state
            uiManager.hideLoading();
            
            this.isInitialized = true;
            console.log('✅ Smart Library Admin Panel initialized successfully');
            
            // Show welcome toast
            uiManager.showToast('Welcome to Library Admin Panel', 'success');
            
        } catch (error) {
            console.error('❌ Failed to initialize app:', error);
            if (window.uiManager) {
                uiManager.hideLoading();
                uiManager.showToast('Failed to initialize application', 'error');
            }
            // Don't show error state immediately, let the app try to work in demo mode
        }
    }

    // Setup event listeners
    setupEventListeners() {
        // Scan button
        const scanButton = document.getElementById('scanButton');
        if (scanButton) {
            scanButton.addEventListener('click', Utils.debounce(this.handleScanClick.bind(this), CONFIG.DEBOUNCE_DELAY));
        }

        // Reset button
        const resetButton = document.getElementById('resetButton');
        if (resetButton) {
            resetButton.addEventListener('click', this.handleResetClick.bind(this));
        }

        // Reset modal buttons
        const cancelReset = document.getElementById('cancelReset');
        const confirmReset = document.getElementById('confirmReset');
        
        if (cancelReset) {
            cancelReset.addEventListener('click', () => {
                uiManager.hideModal('resetModal');
            });
        }
        
        if (confirmReset) {
            confirmReset.addEventListener('click', this.handleConfirmReset.bind(this));
        }

        // Student selection change
        const studentSelect = document.getElementById('studentSelect');
        if (studentSelect) {
            studentSelect.addEventListener('change', () => {
                // Clear previous scan result when selection changes
                uiManager.hideScanResult();
            });
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', this.handleKeyboardShortcuts.bind(this));
    }

    // Load initial data
    async loadInitialData() {
        try {
            // Load all data in parallel
            const [libraryStatus, studentsInside, scanLogs] = await Promise.all([
                apiService.getLibraryStatus(),
                apiService.getStudentsInside(),
                apiService.getScanLogs()
            ]);

            // Update current data
            this.currentData.libraryStatus = libraryStatus;
            this.currentData.studentsInside = studentsInside || [];
            this.currentData.activityLogs = scanLogs || [];

            // Update UI
            this.updateAllUI();

        } catch (error) {
            console.error('Error loading initial data:', error);
            // Show error state instead of falling back to demo data
            if (window.uiManager) {
                uiManager.showErrorState('Failed to connect to backend. Please ensure the backend server is running on port 3000.');
            }
        }
    }

    // Load demo data for development (removed - using real backend only)
    loadDemoData() {
        console.log('Demo data disabled - using real backend only');
    }

    // Update all UI components
    updateAllUI() {
        // Update system status
        const connectionStatus = apiService.getConnectionStatus();
        uiManager.updateSystemStatus(connectionStatus.isOnline);
        
        // Update stats
        if (this.currentData.libraryStatus) {
            uiManager.updateStats(this.currentData.libraryStatus);
            uiManager.updateSeatGrid(this.currentData.libraryStatus.occupiedSeats);
        }
        
        // Update tables
        uiManager.updateStudentsTable(this.currentData.studentsInside);
        uiManager.updateActivityLog(this.currentData.activityLogs);
        
        // Update footer
        uiManager.updateLastUpdated();
    }

    // Handle scan button click
    async handleScanClick() {
        const studentSelect = document.getElementById('studentSelect');
        const selectedStudentId = studentSelect?.value;
        
        if (!selectedStudentId) {
            uiManager.showToast('Please select a student first', 'warning');
            return;
        }

        try {
            // Show loading state
            uiManager.showLoading('scanButton');
            
            // Process scan
            const result = await apiService.processScan(selectedStudentId);
            
            // Show result
            uiManager.showScanResult(result);
            
            // Update data if successful
            if (result.success) {
                await this.refreshData();
                
                // Show success toast
                const message = result.action === 'ENTRY' ? 
                    'Student entry confirmed' : 'Student exit confirmed';
                uiManager.showToast(message, 'success');
            } else {
                uiManager.showToast(result.error || 'Scan failed', 'error');
            }
            
        } catch (error) {
            console.error('Scan error:', error);
            uiManager.showToast('Scan failed: ' + error.message, 'error');
        } finally {
            // Hide loading state
            uiManager.hideLoading('scanButton');
        }
    }

    // Handle reset button click
    handleResetClick() {
        uiManager.showModal('resetModal');
    }

    // Handle confirm reset
    async handleConfirmReset() {
        try {
            // Show loading
            uiManager.showLoading();
            
            // Hide modal
            uiManager.hideModal('resetModal');
            
            // Call reset API
            const result = await apiService.resetSystem();
            
            if (result.success) {
                uiManager.showToast(result.message || CONFIG.MESSAGES.RESET_SUCCESS, 'success');
                
                // Refresh all data
                await this.refreshData();
            } else {
                uiManager.showToast(result.error || 'Reset failed', 'error');
            }
            
        } catch (error) {
            console.error('Reset error:', error);
            uiManager.showToast('Reset failed: ' + error.message, 'error');
        } finally {
            uiManager.hideLoading();
        }
    }

    // Handle keyboard shortcuts
    handleKeyboardShortcuts(event) {
        // Ctrl/Cmd + R: Reset system
        if ((event.ctrlKey || event.metaKey) && event.key === 'r') {
            event.preventDefault();
            this.handleResetClick();
        }
        
        // Ctrl/Cmd + S: Simulate scan (if student selected)
        if ((event.ctrlKey || event.metaKey) && event.key === 's') {
            event.preventDefault();
            const studentSelect = document.getElementById('studentSelect');
            if (studentSelect?.value) {
                this.handleScanClick();
            }
        }
        
        // Escape: Close modals
        if (event.key === 'Escape') {
            uiManager.hideModal('resetModal');
        }
    }

    // Refresh all data
    async refreshData() {
        try {
            // Load fresh data
            const [libraryStatus, studentsInside, activityLogs] = await Promise.all([
                apiService.getLibraryStatus(),
                apiService.getStudentsInside(),
                apiService.getScanLogs()
            ]);

            // Update current data
            this.currentData.libraryStatus = libraryStatus;
            this.currentData.studentsInside = studentsInside || [];
            this.currentData.activityLogs = activityLogs || [];

            // Update UI
            this.updateAllUI();
            
        } catch (error) {
            console.error('Error refreshing data:', error);
        }
    }

    // Handle simulated real-time updates
    handleSimulatedUpdate(update) {
        console.log('🔄 Simulated update:', update);
        
        // Show notification for simulated scan
        const message = `${update.studentName} (${update.studentId}) - ${update.action}`;
        uiManager.showToast(message, 'success');
        
        // Add to activity logs
        this.currentData.activityLogs.unshift({
            id: Date.now(),
            studentId: update.studentId,
            studentName: update.studentName,
            scanType: update.action,
            timestamp: update.timestamp
        });
        
        // Keep only recent logs
        if (this.currentData.activityLogs.length > CONFIG.MAX_ACTIVITY_LOGS) {
            this.currentData.activityLogs = this.currentData.activityLogs.slice(0, CONFIG.MAX_ACTIVITY_LOGS);
        }
    }

    // Start periodic updates
    startPeriodicUpdates() {
        // Start clock updates
        this.clockInterval = setInterval(() => {
            uiManager.updateClock();
        }, CONFIG.CLOCK_UPDATE_INTERVAL);
        
        // Start data refresh
        this.refreshInterval = setInterval(async () => {
            if (this.isInitialized) {
                await this.refreshData();
            }
        }, CONFIG.REFRESH_INTERVAL);
        
        console.log(`⏰ Started periodic updates (refresh: ${CONFIG.REFRESH_INTERVAL}ms)`);
    }

    // Stop periodic updates
    stopPeriodicUpdates() {
        if (this.clockInterval) {
            clearInterval(this.clockInterval);
            this.clockInterval = null;
        }
        
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
        
        console.log('⏹ Stopped periodic updates');
    }

    // Handle page visibility change
    handleVisibilityChange() {
        if (document.hidden) {
            // Pause updates when page is not visible
            this.stopPeriodicUpdates();
        } else {
            // Resume updates when page becomes visible
            this.startPeriodicUpdates();
            this.refreshData(); // Immediate refresh when page becomes visible
        }
    }

    // Handle online/offline status
    handleConnectionChange() {
        const isOnline = navigator.onLine;
        uiManager.updateSystemStatus(isOnline);
        
        if (isOnline) {
            uiManager.showToast('Connection restored', 'success');
            this.refreshData();
        } else {
            uiManager.showToast('Connection lost', 'error');
        }
    }

    // Cleanup on page unload
    cleanup() {
        console.log('🧹 Cleaning up application...');
        this.stopPeriodicUpdates();
        
        // Remove event listeners
        document.removeEventListener('visibilitychange', this.handleVisibilityChange);
        window.removeEventListener('online', this.handleConnectionChange);
        window.removeEventListener('offline', this.handleConnectionChange);
    }
}

// Global function for external access
window.updateDashboard = async function() {
    if (window.app && window.app.isInitialized) {
        await window.app.refreshData();
    }
};

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', async () => {
    try {
        console.log('🔧 DOM loaded, checking dependencies...');
        
        // Check if required dependencies are loaded
        if (typeof window.uiManager === 'undefined') {
            console.error('❌ uiManager not found! Check if ui.js is loaded properly.');
            alert('Error: UI Manager not loaded. Please refresh the page.');
            return;
        }
        
        if (typeof window.apiService === 'undefined') {
            console.error('❌ apiService not found! Check if api.js is loaded properly.');
            alert('Error: API Service not loaded. Please refresh the page.');
            return;
        }
        
        if (typeof window.CONFIG === 'undefined') {
            console.error('❌ CONFIG not found! Check if config.js is loaded properly.');
            alert('Error: Configuration not loaded. Please refresh the page.');
            return;
        }
        
        console.log('✅ All dependencies loaded successfully');
        
        // Create global app instance
        window.app = new LibraryAdminApp();
        
        // Initialize app
        await window.app.init();
        
        // Setup page lifecycle handlers
        document.addEventListener('visibilitychange', () => {
            window.app.handleVisibilityChange();
        });
        
        window.addEventListener('online', () => {
            window.app.handleConnectionChange();
        });
        
        window.addEventListener('offline', () => {
            window.app.handleConnectionChange();
        });
        
        // Cleanup on page unload
        window.addEventListener('beforeunload', () => {
            window.app.cleanup();
        });
        
        // Handle errors gracefully
        window.addEventListener('error', (event) => {
            console.error('Global error:', event.error);
            if (window.uiManager) {
                uiManager.showToast('An unexpected error occurred', 'error');
            }
        });
        
        // Handle unhandled promise rejections
        window.addEventListener('unhandledrejection', (event) => {
            console.error('Unhandled promise rejection:', event.reason);
            if (window.uiManager) {
                uiManager.showToast('An unexpected error occurred', 'error');
            }
        });
        
        console.log('🎉 Smart Library Admin Panel ready!');
        
    } catch (error) {
        console.error('❌ Critical error during initialization:', error);
        alert('Failed to initialize the application. Please check the console for details.');
    }
});

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LibraryAdminApp;
}
