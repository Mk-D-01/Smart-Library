// Smart Library Admin Panel - UI Manipulation Functions
// Handles all UI updates and DOM manipulations

class UIManager {
    constructor() {
        this.elements = {};
        this.initializeElements();
        this.setupEventListeners();
    }

    // Cache DOM elements
    initializeElements() {
        this.elements = {
            // Header elements
            systemStatus: document.getElementById('systemStatus'),
            liveClock: document.getElementById('liveClock'),
            
            // Stats elements
            totalSeats: document.getElementById('totalSeats'),
            occupiedSeats: document.getElementById('occupiedSeats'),
            availableSeats: document.getElementById('availableSeats'),
            occupancyPercentage: document.getElementById('occupancyPercentage'),
            occupancyRate: document.getElementById('occupancyRate'),
            progressRingCircle: document.getElementById('progressRingCircle'),
            progressBar: document.getElementById('progressBar'),
            progressPercentage: document.getElementById('progressPercentage'),
            
            // Scan simulator elements
            studentSelect: document.getElementById('studentSelect'),
            scanButton: document.getElementById('scanButton'),
            scanResult: document.getElementById('scanResult'),
            
            // Tables
            studentsTableBody: document.getElementById('studentsTableBody'),
            studentsEmptyState: document.getElementById('studentsEmptyState'),
            studentsCount: document.getElementById('studentsCount'),
            activityTableBody: document.getElementById('activityTableBody'),
            
            // Modals and overlays
            resetModal: document.getElementById('resetModal'),
            loadingOverlay: document.getElementById('loadingOverlay'),
            toastContainer: document.getElementById('toastContainer'),
            
            // Buttons
            resetButton: document.getElementById('resetButton'),
            cancelReset: document.getElementById('cancelReset'),
            confirmReset: document.getElementById('confirmReset'),
            
            // Footer
            lastUpdated: document.getElementById('lastUpdated'),
            
            // Visualization
            seatGrid: document.getElementById('seatGrid')
        };
    }

    // Setup event listeners
    setupEventListeners() {
        // Close modal on backdrop click
        this.elements.resetModal?.addEventListener('click', (e) => {
            if (e.target === this.elements.resetModal) {
                this.hideModal('resetModal');
            }
        });

        // Close modal on ESC key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.hideModal('resetModal');
            }
        });
    }

    // Update system status
    updateSystemStatus(isOnline) {
        if (!this.elements.systemStatus) return;

        const statusDot = this.elements.systemStatus.querySelector('div');
        const statusText = this.elements.systemStatus.querySelector('span');

        if (isOnline) {
            statusDot.className = 'w-2 h-2 bg-success rounded-full animate-pulse';
            statusText.textContent = CONFIG.MESSAGES.SYSTEM_ONLINE;
            statusText.className = 'text-sm font-medium text-gray-700';
            this.elements.systemStatus.className = 'flex items-center space-x-2';
        } else {
            statusDot.className = 'w-2 h-2 bg-danger rounded-full animate-pulse';
            statusText.textContent = CONFIG.MESSAGES.SYSTEM_OFFLINE;
            statusText.className = 'text-sm font-medium text-gray-700';
            this.elements.systemStatus.className = 'flex items-center space-x-2';
        }
    }

    // Update live clock
    updateClock() {
        if (!this.elements.liveClock) return;

        const now = new Date();
        const timeString = now.toLocaleTimeString('en-US', { 
            hour12: false, 
            hour: '2-digit', 
            minute: '2-digit', 
            second: '2-digit' 
        });
        this.elements.liveClock.textContent = timeString;
    }

    // Update library statistics
    updateStats(stats) {
        if (!stats) return;

        // Update numbers with animation
        this.animateNumber(this.elements.totalSeats, stats.totalSeats);
        this.animateNumber(this.elements.occupiedSeats, stats.occupiedSeats);
        this.animateNumber(this.elements.availableSeats, stats.availableSeats);
        
        // Update percentage displays
        const percentage = stats.occupancyPercentage;
        this.elements.occupancyPercentage.textContent = `${percentage}% occupied`;
        this.elements.occupancyRate.textContent = `${percentage}%`;
        this.elements.progressPercentage.textContent = `${percentage}%`;
        
        // Update progress bar
        this.updateProgressBar(percentage);
        
        // Update circular progress
        this.updateCircularProgress(percentage);
        
        // Update occupancy color coding
        this.updateOccupancyColors(percentage);
    }

    // Animate number counting
    animateNumber(element, targetValue) {
        if (!element) return;

        const startValue = parseInt(element.textContent) || 0;
        const duration = 500;
        const startTime = performance.now();

        const animate = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const currentValue = Math.floor(startValue + (targetValue - startValue) * progress);
            
            element.textContent = currentValue;
            element.classList.add('count-up');

            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };

        requestAnimationFrame(animate);
    }

    // Update progress bar
    updateProgressBar(percentage) {
        if (!this.elements.progressBar) return;

        let colorClass = 'bg-gradient-to-r from-green-500 to-green-600';
        if (percentage >= 80) {
            colorClass = 'bg-gradient-to-r from-red-500 to-red-600';
        } else if (percentage >= 50) {
            colorClass = 'bg-gradient-to-r from-amber-500 to-amber-600';
        }

        this.elements.progressBar.className = `h-full ${colorClass} rounded-full transition-all duration-700 progress-bar flex items-center justify-end pr-2`;
        this.elements.progressBar.style.width = `${percentage}%`;
        
        // Add percentage text inside progress bar
        const percentageText = this.elements.progressBar.querySelector('span');
        if (percentageText) {
            percentageText.textContent = `${percentage}%`;
        }
    }

    // Update circular progress
    updateCircularProgress(percentage) {
        if (!this.elements.progressRingCircle) return;

        const circumference = 2 * Math.PI * 100; // radius = 100
        const offset = circumference - (percentage / 100) * circumference;
        
        // Set CSS variable for animation
        document.documentElement.style.setProperty('--progress-offset', offset);
        
        // Update stroke color based on percentage
        let strokeColor = '#10B981';
        if (percentage >= 80) {
            strokeColor = '#EF4444';
        } else if (percentage >= 50) {
            strokeColor = '#F59E0B';
        }
        
        // Update gradient stops
        const gradient = document.querySelector('#gradient');
        if (gradient) {
            const stops = gradient.querySelectorAll('stop');
            if (percentage >= 80) {
                stops[0].setAttribute('stop-color', '#EF4444');
                stops[1].setAttribute('stop-color', '#DC2626');
            } else if (percentage >= 50) {
                stops[0].setAttribute('stop-color', '#F59E0B');
                stops[1].setAttribute('stop-color', '#D97706');
            } else {
                stops[0].setAttribute('stop-color', '#10B981');
                stops[1].setAttribute('stop-color', '#059669');
            }
        }
        
        // Trigger animation
        this.elements.progressRingCircle.style.strokeDashoffset = offset;
        
        // Update percentage text
        const percentageText = document.querySelector('.progress-percentage');
        if (percentageText) {
            percentageText.textContent = `${percentage}%`;
        }
    }

    // Update occupancy colors
    updateOccupancyColors(percentage) {
        const colorClass = Utils.getOccupancyColor(percentage);
        
        // Update occupied seats card
        const occupiedCard = this.elements.occupiedSeats?.closest('.stat-card');
        if (occupiedCard) {
            occupiedCard.classList.remove('occupancy-low', 'occupancy-medium', 'occupancy-high');
            occupiedCard.classList.add(colorClass);
        }
    }

    // Populate student dropdown
    populateStudentDropdown() {
        if (!this.elements.studentSelect) return;

        this.elements.studentSelect.innerHTML = '<option value="">Choose a student...</option>';
        
        CONFIG.STUDENTS.forEach(student => {
            const option = document.createElement('option');
            option.value = student.id;
            option.textContent = `${student.id} - ${student.name}`;
            this.elements.studentSelect.appendChild(option);
        });
    }

    // Show scan result
    showScanResult(result) {
        if (!this.elements.scanResult) return;

        const isSuccess = result.success;
        const isEntry = result.action === 'ENTRY';
        
        this.elements.scanResult.className = `scan-result ${isSuccess ? 'scan-result-success' : 'scan-result-error'}`;
        
        if (isSuccess) {
            this.elements.scanResult.innerHTML = `
                <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 ${isEntry ? 'bg-success' : 'bg-danger'} bg-opacity-20 rounded-full flex items-center justify-center">
                        <i class="fas ${isEntry ? 'fa-sign-in-alt' : 'fa-sign-out-alt'} ${isEntry ? 'text-success' : 'text-danger'}"></i>
                    </div>
                    <div>
                        <p class="font-semibold">${isEntry ? '✓ Entry Confirmed' : '✓ Exit Confirmed'}</p>
                        <p class="text-sm">Student: ${result.student?.name || 'Unknown'} (${result.student?.id || 'N/A'})</p>
                        <p class="text-sm">Time: ${Utils.formatTime(new Date())}</p>
                        <p class="text-sm">Seats Available: ${result.libraryStatus?.availableSeats || 'N/A'}</p>
                    </div>
                </div>
            `;
        } else {
            this.elements.scanResult.innerHTML = `
                <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-danger bg-opacity-20 rounded-full flex items-center justify-center">
                        <i class="fas fa-exclamation-triangle text-danger"></i>
                    </div>
                    <div>
                        <p class="font-semibold">✗ Scan Failed</p>
                        <p class="text-sm">Error: ${result.error || CONFIG.ERRORS.SYSTEM_ERROR}</p>
                        <p class="text-sm">Please try again</p>
                    </div>
                </div>
            `;
        }

        this.elements.scanResult.classList.remove('hidden');

        // Auto-hide after configured duration
        setTimeout(() => {
            this.hideScanResult();
        }, CONFIG.SCAN_RESULT_DURATION);
    }

    // Hide scan result
    hideScanResult() {
        if (this.elements.scanResult) {
            this.elements.scanResult.classList.add('hidden');
        }
    }

    // Update students table
    updateStudentsTable(students) {
        if (!this.elements.studentsTableBody) return;

        const hasStudents = students && students.length > 0;
        
        if (hasStudents) {
            this.elements.studentsTableBody.innerHTML = students.map(student => `
                <tr class="border-b border-gray-200 table-row-hover">
                    <td class="px-4 py-3 text-sm font-mono text-gray-600">${student.id}</td>
                    <td class="px-4 py-3 text-sm font-medium text-gray-900">${student.name}</td>
                    <td class="px-4 py-3 text-sm text-gray-600">${Utils.formatTime(student.entryTime)}</td>
                    <td class="px-4 py-3 text-sm ${Utils.getDurationColor(student.duration)}">${student.duration}</td>
                    <td class="px-4 py-3 text-sm">
                        <button onclick="window.uiManager.handleMarkExit('${student.id}')" 
                                class="px-3 py-1 border border-red-500 text-red-500 rounded hover:bg-danger hover:text-white transition-colors text-xs">
                            <i class="fas fa-sign-out-alt mr-1"></i>Mark Exit
                        </button>
                    </td>
                </tr>
            `).join('');
            
            this.elements.studentsCount.textContent = `${students.length} students`;
            this.elements.studentsCount.classList.remove('hidden');
            this.elements.studentsEmptyState.classList.add('hidden');
        } else {
            this.elements.studentsTableBody.innerHTML = '';
            this.elements.studentsCount.classList.add('hidden');
            this.elements.studentsEmptyState.classList.remove('hidden');
        }
    }

    // Update activity log table
    updateActivityLog(logs) {
        if (!this.elements.activityTableBody) return;

        if (logs && logs.length > 0) {
            this.elements.activityTableBody.innerHTML = logs.map(log => {
                const isEntry = log.scanType === 'ENTRY';
                const badgeClass = isEntry ? 'badge-entry' : 'badge-exit';
                const icon = isEntry ? 'fa-sign-in-alt' : 'fa-sign-out-alt';
                
                return `
                    <tr class="border-b border-gray-200 table-row-hover">
                        <td class="px-4 py-3 text-sm text-gray-600">${Utils.getRelativeTime(log.timestamp)}</td>
                        <td class="px-4 py-3 text-sm font-mono text-gray-600">${log.studentId}</td>
                        <td class="px-4 py-3 text-sm font-medium text-gray-900">${log.studentName}</td>
                        <td class="px-4 py-3 text-sm">
                            <span class="${badgeClass}">
                                <i class="fas ${icon} text-xs"></i>
                                ${log.scanType}
                            </span>
                        </td>
                        <td class="px-4 py-3 text-sm">
                            <span class="text-success">
                                <i class="fas fa-check-circle"></i> Success
                            </span>
                        </td>
                    </tr>
                `;
            }).join('');
        } else {
            this.elements.activityTableBody.innerHTML = `
                <tr>
                    <td colspan="5" class="text-center py-8 text-gray-500">
                        <i class="fas fa-clipboard-list text-2xl mb-2"></i>
                        <p>No activity logs available</p>
                    </td>
                </tr>
            `;
        }
    }

    // Update seat grid visualization
    updateSeatGrid(occupiedSeats) {
        if (!this.elements.seatGrid) return;

        const totalSeats = CONFIG.TOTAL_SEATS;
        const seats = [];
        
        // Create seat array
        for (let i = 0; i < totalSeats; i++) {
            const isOccupied = i < occupiedSeats;
            seats.push(`
                <div class="seat ${isOccupied ? 'seat-occupied' : 'seat-empty'}" 
                     title="Seat ${i + 1}">
                    ${isOccupied ? '👤' : ''}
                </div>
            `);
        }

        this.elements.seatGrid.innerHTML = seats.join('');
    }

    // Show loading state
    showLoading(element = null) {
        if (element) {
            element.classList.add('btn-loading');
            element.disabled = true;
        } else {
            this.elements.loadingOverlay.classList.remove('hidden');
        }
    }

    // Hide loading state
    hideLoading(element = null) {
        if (element) {
            element.classList.remove('btn-loading');
            element.disabled = false;
        } else {
            this.elements.loadingOverlay.classList.add('hidden');
        }
    }

    // Show toast notification
    showToast(message, type = 'success') {
        if (!this.elements.toastContainer) return;

        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        
        const icon = type === 'success' ? 'fa-check-circle' : 
                     type === 'error' ? 'fa-exclamation-circle' : 
                     'fa-info-circle';
        
        toast.innerHTML = `
            <i class="fas ${icon}"></i>
            <span>${message}</span>
        `;

        this.elements.toastContainer.appendChild(toast);

        // Auto-remove after duration
        setTimeout(() => {
            toast.style.animation = 'slideInRight 0.3s ease-out reverse';
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 300);
        }, CONFIG.TOAST_DURATION);
    }

    // Show modal
    showModal(modalId) {
        const modal = this.elements[modalId];
        if (modal) {
            modal.classList.remove('hidden');
            modal.classList.add('modal-backdrop');
            const content = modal.querySelector('.bg-white');
            if (content) {
                content.classList.add('modal-content');
            }
        }
    }

    // Hide modal
    hideModal(modalId) {
        const modal = this.elements[modalId];
        if (modal) {
            modal.classList.add('hidden');
            modal.classList.remove('modal-backdrop');
        }
    }

    // Handle mark exit button click
    async handleMarkExit(studentId) {
        const confirmed = confirm(`Mark student ${studentId} as exited?`);
        if (confirmed) {
            try {
                const result = await apiService.processScan(studentId);
                if (result.success) {
                    this.showToast('Student marked as exited', 'success');
                    // Trigger dashboard update
                    if (window.updateDashboard) {
                        window.updateDashboard();
                    }
                } else {
                    this.showToast(result.error || 'Failed to mark exit', 'error');
                }
            } catch (error) {
                this.showToast('Error marking exit', 'error');
            }
        }
    }

    // Update last updated timestamp
    updateLastUpdated() {
        if (this.elements.lastUpdated) {
            this.elements.lastUpdated.textContent = Utils.formatTime(new Date());
        }
    }

    // Show error state
    showErrorState(message) {
        const errorHtml = `
            <div class="bg-white rounded-xl shadow-lg p-8 text-center max-w-md mx-auto mt-8">
                <div class="w-16 h-16 bg-danger bg-opacity-20 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-exclamation-triangle text-danger text-2xl"></i>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">⚠️ Connection Error</h3>
                <p class="text-gray-600 mb-4">${message}</p>
                <p class="text-sm text-gray-500 mb-6">Please check:</p>
                <ul class="text-left text-sm text-gray-600 space-y-1 mb-6">
                    <li>• Backend is running (port 3000)</li>
                    <li>• No network issues</li>
                </ul>
                <button onclick="location.reload()" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors">
                    <i class="fas fa-refresh mr-2"></i>Retry Connection
                </button>
            </div>
        `;
        
        document.body.innerHTML = errorHtml;
    }
}

// Create singleton instance
const uiManager = new UIManager();

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = uiManager;
} else {
    window.uiManager = uiManager;
}
