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
            
            // Visualization and Seat Map
            seatGrid: document.getElementById('seatGrid'),
            seatTooltip: document.getElementById('seatTooltip'),
            seatDetailModal: document.getElementById('seatDetailModal'),
            closeSeatModal: document.getElementById('closeSeatModal'),
            closeSeatModalBtn: document.getElementById('closeSeatModalBtn'),
            seatModalTitle: document.getElementById('seatModalTitle'),
            seatModalSubtitle: document.getElementById('seatModalSubtitle'),
            seatModalIcon: document.getElementById('seatModalIcon'),
            seatModalHeader: document.getElementById('seatModalHeader'),
            seatModalStatusBanner: document.getElementById('seatModalStatusBanner'),
            seatModalStatusDot: document.getElementById('seatModalStatusDot'),
            seatModalStatusText: document.getElementById('seatModalStatusText'),
            seatModalOccupantCard: document.getElementById('seatModalOccupantCard'),
            seatModalStudentAvatar: document.getElementById('seatModalStudentAvatar'),
            seatModalStudentName: document.getElementById('seatModalStudentName'),
            seatModalStudentId: document.getElementById('seatModalStudentId'),
            seatModalEntryTime: document.getElementById('seatModalEntryTime'),
            seatModalDuration: document.getElementById('seatModalDuration'),
            seatModalVacantNotice: document.getElementById('seatModalVacantNotice'),
            seatModalSelectBtn: document.getElementById('seatModalSelectBtn'),
            seatModalSelectBtnText: document.getElementById('seatModalSelectBtnText'),
            seatMapTotalBadge: document.getElementById('seatMapTotalBadge'),
            seatMapAvailableBadge: document.getElementById('seatMapAvailableBadge'),
            seatMapOccupiedBadge: document.getElementById('seatMapOccupiedBadge'),

            // Theme Toggle
            themeToggleBtn: document.getElementById('themeToggleBtn'),
            themeToggleIcon: document.getElementById('themeToggleIcon'),
            themeToggleText: document.getElementById('themeToggleText')
        };

        this.activeSeatFilter = 'all';
        this.activeSeatZone = 1;
        this.currentSeatMap = null;
    }

    // Setup event listeners
    setupEventListeners() {
        // Close modal on backdrop click
        this.elements.resetModal?.addEventListener('click', (e) => {
            if (e.target === this.elements.resetModal) {
                this.hideModal('resetModal');
            }
        });

        // Close seat detail modal
        this.elements.closeSeatModal?.addEventListener('click', () => this.hideSeatModal());
        this.elements.closeSeatModalBtn?.addEventListener('click', () => this.hideSeatModal());
        this.elements.seatDetailModal?.addEventListener('click', (e) => {
            if (e.target === this.elements.seatDetailModal) {
                this.hideSeatModal();
            }
        });

        // Seat detail modal action button (Select in scanner)
        this.elements.seatModalSelectBtn?.addEventListener('click', () => {
            const studentId = this.elements.seatModalSelectBtn.getAttribute('data-student-id');
            if (studentId && this.elements.studentSelect) {
                this.elements.studentSelect.value = studentId;
                this.hideSeatModal();
                this.elements.studentSelect.scrollIntoView({ behavior: 'smooth', block: 'center' });
                this.elements.studentSelect.classList.add('ring-4', 'ring-purple-300');
                setTimeout(() => {
                    this.elements.studentSelect.classList.remove('ring-4', 'ring-purple-300');
                }, 1500);
                this.showToast(`Selected student ${studentId} in Scanner`, 'info');
            } else {
                this.hideSeatModal();
                this.elements.studentSelect?.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        });

        // Seat zone buttons (Zone 1 to 4 for 350 seats)
        const zoneBtns = document.querySelectorAll('[data-seat-zone]');
        zoneBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const zone = parseInt(btn.getAttribute('data-seat-zone')) || 1;
                this.setSeatZone(zone);
            });
        });

        // Seat filter buttons
        const filterBtns = document.querySelectorAll('[data-seat-filter]');
        filterBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const filter = btn.getAttribute('data-seat-filter');
                this.setSeatFilter(filter);
            });
        });

        // Theme Toggle
        this.initTheme();
        this.elements.themeToggleBtn?.addEventListener('click', () => this.toggleTheme());

        // Start Live Clock immediately
        this.updateClock();
        if (!this.clockTimer) {
            this.clockTimer = setInterval(() => this.updateClock(), 1000);
        }

        // Close modal on ESC key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.hideModal('resetModal');
                this.hideSeatModal();
            }
        });
    }

    // Initialize Theme (Dark/Light)
    initTheme() {
        const savedTheme = localStorage.getItem('smart_library_theme');
        const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        const isDark = savedTheme === 'dark' || (!savedTheme && prefersDark);
        this.applyTheme(isDark);
    }

    // Toggle Theme
    toggleTheme() {
        const isDark = !document.documentElement.classList.contains('dark');
        this.applyTheme(isDark);
        localStorage.setItem('smart_library_theme', isDark ? 'dark' : 'light');
        this.showToast(`Switched to ${isDark ? 'Dark' : 'Light'} Mode`, 'info');
    }

    // Apply Theme to DOM
    applyTheme(isDark) {
        if (isDark) {
            document.documentElement.classList.add('dark');
            if (this.elements.themeToggleIcon) {
                this.elements.themeToggleIcon.className = 'fas fa-sun text-amber-400';
            }
            if (this.elements.themeToggleText) {
                this.elements.themeToggleText.textContent = 'Light';
            }
        } else {
            document.documentElement.classList.remove('dark');
            if (this.elements.themeToggleIcon) {
                this.elements.themeToggleIcon.className = 'fas fa-moon text-indigo-500';
            }
            if (this.elements.themeToggleText) {
                this.elements.themeToggleText.textContent = 'Dark';
            }
        }
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

    // Update live clock and all active real-time timers
    updateClock() {
        // 1. Update Header Live Clock
        if (this.elements.liveClock) {
            const now = new Date();
            const timeString = now.toLocaleTimeString('en-US', { 
                hour12: true, 
                hour: '2-digit', 
                minute: '2-digit', 
                second: '2-digit' 
            });
            this.elements.liveClock.textContent = timeString;
        }

        // 2. Update all live durations in Students Inside table
        const durationElements = document.querySelectorAll('.live-duration[data-entry-time]');
        durationElements.forEach(el => {
            const entryTime = el.getAttribute('data-entry-time');
            if (entryTime) {
                const liveDuration = Utils.calculateDuration(entryTime);
                el.textContent = liveDuration;
                // Update color class dynamically
                el.className = `px-4 py-3 text-sm font-semibold live-duration ${Utils.getDurationColor(liveDuration)}`;
            }
        });

        // 3. Update Seat Detail Modal duration if modal is open with an occupant
        if (this.activeModalEntryTime && this.elements.seatModalDuration && !this.elements.seatDetailModal?.classList.contains('hidden')) {
            this.elements.seatModalDuration.textContent = Utils.calculateDuration(this.activeModalEntryTime);
        }
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
        if (this.elements.occupancyPercentage) {
            this.elements.occupancyPercentage.textContent = `${percentage}% occupied`;
        }
        if (this.elements.progressPercentage) {
            this.elements.progressPercentage.textContent = `${percentage}%`;
        }
        
        // Update progress bar
        this.updateProgressBar(percentage);
        
        // Update circular progress
        this.updateCircularProgress(percentage);
        
        // Update occupancy color coding
        this.updateOccupancyColors(percentage);
    }

    // Animate number counting with ultra-smooth easeOutExpo
    animateNumber(element, targetValue) {
        if (!element) return;

        const startValue = parseInt(element.textContent) || 0;
        if (startValue === targetValue) return;

        const duration = 650;
        const startTime = performance.now();

        // easeOutExpo curve for buttery smooth deceleration
        const easeOutExpo = (t) => t === 1 ? 1 : 1 - Math.pow(2, -10 * t);

        const animate = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const easedProgress = easeOutExpo(progress);
            const currentValue = Math.round(startValue + (targetValue - startValue) * easedProgress);
            
            element.textContent = currentValue;

            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                element.textContent = targetValue;
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

    // Update students table with avatar, course badge, live duration
    updateStudentsTable(students) {
        if (!this.elements.studentsTableBody) return;

        const hasStudents = students && students.length > 0;
        
        if (hasStudents) {
            this.elements.studentsTableBody.innerHTML = students.map(student => {
                const rawTime = student.entryTime || student.created_at || student.timestamp;
                const entryDate = rawTime ? new Date(rawTime) : new Date();
                
                const entryTime = entryDate.toLocaleTimeString('en-IN', { 
                    hour12: true, 
                    hour: '2-digit', 
                    minute: '2-digit' 
                });
                
                const duration = Utils.calculateDuration(entryDate);
                const name = student.name || 'Student';
                const initials = name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
                const course = student.course || student.degree || '';
                const courseBadge = course 
                    ? `<span class="inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-indigo-100 text-indigo-700 dark:bg-indigo-900/40 dark:text-indigo-300">${course}</span>` 
                    : '';
                
                return `
                    <tr class="border-b border-gray-100 dark:border-gray-800 table-row-hover transition-colors duration-150">
                        <td class="px-4 py-3 text-sm font-mono text-gray-500 dark:text-gray-400">${student.id}</td>
                        <td class="px-4 py-3">
                            <div class="flex items-center gap-3">
                                <div class="w-8 h-8 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">${initials}</div>
                                <div>
                                    <p class="text-sm font-semibold text-gray-900 dark:text-white">${name}</p>
                                    ${courseBadge}
                                </div>
                            </div>
                        </td>
                        <td class="px-4 py-3 text-sm text-gray-600 dark:text-gray-300 font-mono">${entryTime}</td>
                        <td class="px-4 py-3 text-sm font-semibold live-duration ${Utils.getDurationColor(duration)}" data-entry-time="${entryDate.toISOString()}">${duration}</td>
                        <td class="px-4 py-3 text-sm">
                            <button onclick="window.uiManager.handleMarkExit('${student.id}')" 
                                    class="px-3 py-1.5 border border-red-400 text-red-500 rounded-lg hover:bg-red-500 hover:text-white hover:border-red-500 transition-all duration-200 text-xs cursor-pointer font-medium">
                                <i class="fas fa-sign-out-alt mr-1"></i>Exit
                            </button>
                        </td>
                    </tr>
                `;
            }).join('');
            
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
                const isEntry = log.scan_type === 'ENTRY';
                const badgeClass = isEntry ? 'badge-entry' : 'badge-exit';
                const icon = isEntry ? 'fa-sign-in-alt' : 'fa-sign-out-alt';
                const timestamp = log.timestamp ? new Date(log.timestamp).toLocaleTimeString('en-IN', { 
                    hour12: false, 
                    hour: '2-digit', 
                    minute: '2-digit' 
                }) : '--:--:--';
                
                return `
                    <tr class="border-b border-gray-200 table-row-hover">
                        <td class="px-4 py-3 text-sm text-gray-600">${timestamp}</td>
                        <td class="px-4 py-3 text-sm font-mono text-gray-600">${log.student_id}</td>
                        <td class="px-4 py-3 text-sm font-medium text-gray-900">${log.student_id}</td>
                        <td class="px-4 py-3 text-sm">
                            <span class="${badgeClass}">
                                <i class="fas ${icon} text-xs"></i>
                                ${log.scan_type}
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

    // Set active zone for 400-seat library (Zone 1: 1-100, Zone 2: 101-200, Zone 3: 201-300, Zone 4: 301-400)
    setSeatZone(zone) {
        this.activeSeatZone = Math.max(1, Math.min(4, zone));

        // Update active zone label in navigator banner
        const zoneLabels = {
            1: 'Zone 1 (Desks 1–100)',
            2: 'Zone 2 (Desks 101–200)',
            3: 'Zone 3 (Desks 201–300)',
            4: 'Zone 4 (Desks 301–400)'
        };
        const activeLabel = document.getElementById('activeZoneLabel');
        if (activeLabel) {
            activeLabel.textContent = zoneLabels[this.activeSeatZone] || `Zone ${this.activeSeatZone}`;
        }

        // Update active class on zone cards and buttons
        const zoneBtns = document.querySelectorAll('[data-seat-zone]');
        zoneBtns.forEach(btn => {
            const btnZone = parseInt(btn.getAttribute('data-seat-zone')) || 1;
            if (btnZone === this.activeSeatZone) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });

        if (this.currentSeatMap) {
            this.updateSeatGrid(this.currentSeatMap);
        }
    }

    // Update dynamic 10x10 seat map visualization (Total 400 capacity across zones with in-place reconciliation)
    updateSeatGrid(seatMapData) {
        if (!this.elements.seatGrid) return;

        const totalCapacity = CONFIG.TOTAL_SEATS || 400;
        let normalizedData = null;

        // Handle numeric input (legacy fallback) or complete seatMap object
        if (typeof seatMapData === 'number') {
            const occupied = Math.max(0, Math.min(totalCapacity, seatMapData));
            normalizedData = {
                totalSeats: totalCapacity,
                occupiedSeats: occupied,
                availableSeats: Math.max(0, totalCapacity - occupied),
                occupancyRate: Math.round((occupied / totalCapacity) * 100),
                seats: []
            };
        } else if (seatMapData && typeof seatMapData === 'object') {
            normalizedData = {
                ...seatMapData,
                totalSeats: seatMapData.totalSeats || totalCapacity,
                occupiedSeats: seatMapData.occupiedSeats !== undefined ? seatMapData.occupiedSeats : 0,
                availableSeats: seatMapData.availableSeats !== undefined ? seatMapData.availableSeats : totalCapacity
            };
        } else {
            normalizedData = {
                totalSeats: totalCapacity,
                occupiedSeats: 0,
                availableSeats: totalCapacity,
                occupancyRate: 0,
                seats: []
            };
        }

        this.currentSeatMap = normalizedData;

        // Calculate global counts across all 350 seats
        const totalSeats = normalizedData.totalSeats || totalCapacity;
        const occupiedSeats = normalizedData.occupiedSeats || 0;
        const availableSeats = Math.max(0, totalSeats - occupiedSeats);

        // Update badge counters in header with smooth animations
        if (this.elements.seatMapTotalBadge) this.elements.seatMapTotalBadge.textContent = totalSeats;
        if (this.elements.seatMapOccupiedBadge) this.elements.seatMapOccupiedBadge.textContent = occupiedSeats;
        if (this.elements.seatMapAvailableBadge) this.elements.seatMapAvailableBadge.textContent = availableSeats;

        // Flatten existing seats if provided from backend
        const seatMapLookup = new Map();
        if (Array.isArray(normalizedData.seats)) {
            const flat = Array.isArray(normalizedData.seats[0]) ? normalizedData.seats.flat() : normalizedData.seats;
            flat.forEach(s => {
                if (s && s.id) seatMapLookup.set(s.id, s);
            });
        }

        // Zone calculations (Zone 1: 1-100, Zone 2: 101-200, Zone 3: 201-300, Zone 4: 301-350)
        const currentZone = this.activeSeatZone || 1;
        const zoneOffset = (currentZone - 1) * 100;
        const rowLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

        // In-Place DOM Diffing: If zone is already rendered, reconcile in-place to prevent hover interruption & layout thrash
        const existingSeats = this.elements.seatGrid.querySelectorAll('.seat[data-seat-id]');
        if (this.renderedZone === currentZone && existingSeats.length > 0) {
            existingSeats.forEach(seatEl => {
                const deskNumber = parseInt(seatEl.getAttribute('data-seat-id'));
                let seat = seatMapLookup.get(deskNumber);
                if (!seat) {
                    const isOcc = deskNumber <= occupiedSeats;
                    const demoStudent = isOcc && CONFIG.STUDENTS ? CONFIG.STUDENTS[(deskNumber - 1) % CONFIG.STUDENTS.length] : null;
                    seat = {
                        id: deskNumber,
                        zone: currentZone,
                        status: isOcc ? 'OCCUPIED' : 'AVAILABLE',
                        student: isOcc ? {
                            id: demoStudent ? demoStudent.id : `STU${String(deskNumber).padStart(3, '0')}`,
                            name: demoStudent ? demoStudent.name : `Student ${deskNumber}`,
                            entryTime: new Date(Date.now() - (deskNumber * 8) * 60000).toISOString(),
                            duration: `${(deskNumber * 8) % 180 + 15}m`
                        } : null
                    };
                }

                const isOccupied = seat.status === 'OCCUPIED';
                const currentStatus = seatEl.getAttribute('data-status');
                
                // Update only if status or student changed
                if (currentStatus !== seat.status) {
                    seatEl.setAttribute('data-status', seat.status);
                    if (isOccupied) {
                        seatEl.classList.remove('seat-available');
                        seatEl.classList.add('seat-occupied');
                        if (!seatEl.querySelector('.seat-cell-pulse')) {
                            const pulse = document.createElement('span');
                            pulse.className = 'seat-cell-pulse';
                            seatEl.prepend(pulse);
                        }
                    } else {
                        seatEl.classList.remove('seat-occupied');
                        seatEl.classList.add('seat-available');
                        const pulse = seatEl.querySelector('.seat-cell-pulse');
                        if (pulse) pulse.remove();
                    }
                }

                const sublabel = seatEl.querySelector('.seat-sublabel');
                if (sublabel) {
                    sublabel.textContent = isOccupied ? '👤' : `#${deskNumber}`;
                }

                // Update data attributes
                seatEl.setAttribute('data-student-id', seat.student?.id || '');
                seatEl.setAttribute('data-student-name', seat.student?.name || '');
                seatEl.setAttribute('data-entry-time', seat.student?.entryTime || '');
                seatEl.setAttribute('data-duration', seat.student?.duration || '');

                // Update filter dimming state
                const isDimmed = (this.activeSeatFilter === 'available' && isOccupied) ||
                                 (this.activeSeatFilter === 'occupied' && !isOccupied);
                if (isDimmed) {
                    seatEl.classList.add('seat-dimmed');
                } else {
                    seatEl.classList.remove('seat-dimmed');
                }
            });
            return;
        }

        // Full Render (First load or Zone change)
        this.renderedZone = currentZone;
        const matrixHtml = [];

        for (let r = 0; r < 10; r++) {
            const rowLetter = rowLetters[r] || `R${r + 1}`;
            const rowCells = [];
            // Row Label Badge
            rowCells.push(`<div class="seat-row-label">${rowLetter}</div>`);

            for (let c = 0; c < 10; c++) {
                const deskNumber = zoneOffset + (r * 10) + c + 1;
                const seatCode = `${rowLetter}${c + 1}`;

                // Check if desk is within 350 capacity
                if (deskNumber > totalSeats) {
                    rowCells.push(`
                        <div class="seat bg-gray-100 border border-gray-200 text-gray-300 cursor-not-allowed opacity-40 select-none" 
                             title="Desk #${deskNumber} (Buffer)">
                            <span class="seat-number text-gray-300">--</span>
                        </div>
                    `);
                    continue;
                }

                let seat = seatMapLookup.get(deskNumber);
                if (!seat) {
                    const isOcc = deskNumber <= occupiedSeats;
                    const demoStudent = isOcc && CONFIG.STUDENTS ? CONFIG.STUDENTS[(deskNumber - 1) % CONFIG.STUDENTS.length] : null;
                    seat = {
                        id: deskNumber,
                        row: r + 1,
                        col: c + 1,
                        zone: currentZone,
                        status: isOcc ? 'OCCUPIED' : 'AVAILABLE',
                        student: isOcc ? {
                            id: demoStudent ? demoStudent.id : `STU${String(deskNumber).padStart(3, '0')}`,
                            name: demoStudent ? demoStudent.name : `Student ${deskNumber}`,
                            entryTime: new Date(Date.now() - (deskNumber * 8) * 60000).toISOString(),
                            duration: `${(deskNumber * 8) % 180 + 15}m`
                        } : null
                    };
                }

                const isOccupied = seat.status === 'OCCUPIED';
                const isDimmed = (this.activeSeatFilter === 'available' && isOccupied) ||
                                 (this.activeSeatFilter === 'occupied' && !isOccupied);

                const studentId = seat.student?.id || '';
                const studentName = seat.student?.name || '';
                const entryTime = seat.student?.entryTime || '';
                const duration = seat.student?.duration || '';

                rowCells.push(`
                    <div class="seat ${isOccupied ? 'seat-occupied' : 'seat-available'} ${isDimmed ? 'seat-dimmed' : ''}" 
                         data-seat-id="${deskNumber}"
                         data-seat-code="${seatCode}"
                         data-zone="${currentZone}"
                         data-row="${r + 1}"
                         data-col="${c + 1}"
                         data-status="${seat.status}"
                         data-student-id="${studentId}"
                         data-student-name="${studentName}"
                         data-entry-time="${entryTime}"
                         data-duration="${duration}"
                         tabindex="0"
                         role="button"
                         title="Desk #${deskNumber} (${seatCode}, Zone ${currentZone}) - ${seat.status}">
                        ${isOccupied ? '<span class="seat-cell-pulse"></span>' : ''}
                        <span class="seat-number">${seatCode}</span>
                        <span class="seat-sublabel">${isOccupied ? '👤' : `#${deskNumber}`}</span>
                    </div>
                `);
            }

            matrixHtml.push(`
                <div class="seat-row" data-row="${rowLetter}">
                    ${rowCells.join('')}
                </div>
            `);
        }

        this.elements.seatGrid.innerHTML = matrixHtml.join('');

        // Attach event listeners to all seat elements
        const seatElements = this.elements.seatGrid.querySelectorAll('.seat:not(.cursor-not-allowed)');
        seatElements.forEach(seatEl => {
            // Hover Tooltip with slight dynamic movement
            seatEl.addEventListener('mouseenter', (e) => this.showSeatTooltip(e, seatEl));
            seatEl.addEventListener('mousemove', (e) => this.positionSeatTooltip(e, seatEl));
            seatEl.addEventListener('mouseleave', () => this.hideSeatTooltip());

            // Click Detail Modal
            seatEl.addEventListener('click', () => {
                const seatData = {
                    id: seatEl.getAttribute('data-seat-id'),
                    code: seatEl.getAttribute('data-seat-code'),
                    zone: seatEl.getAttribute('data-zone'),
                    row: seatEl.getAttribute('data-row'),
                    col: seatEl.getAttribute('data-col'),
                    status: seatEl.getAttribute('data-status'),
                    student: seatEl.getAttribute('data-student-id') ? {
                        id: seatEl.getAttribute('data-student-id'),
                        name: seatEl.getAttribute('data-student-name'),
                        entryTime: seatEl.getAttribute('data-entry-time'),
                        duration: seatEl.getAttribute('data-duration')
                    } : null
                };
                this.showSeatModal(seatData);
            });
        });
    }

    // Set active filter for seat grid (all / available / occupied)
    setSeatFilter(filter) {
        this.activeSeatFilter = filter;

        // Update active class on filter buttons
        const filterBtns = document.querySelectorAll('[data-seat-filter]');
        filterBtns.forEach(btn => {
            if (btn.getAttribute('data-seat-filter') === filter) {
                btn.classList.add('active', 'bg-white', 'shadow-sm', 'text-gray-900');
                btn.classList.remove('text-gray-600');
            } else {
                btn.classList.remove('active', 'bg-white', 'shadow-sm', 'text-gray-900');
                btn.classList.add('text-gray-600');
            }
        });

        if (!this.elements.seatGrid) return;
        const seatElements = this.elements.seatGrid.querySelectorAll('.seat');
        seatElements.forEach(seatEl => {
            const isOccupied = seatEl.classList.contains('seat-occupied');
            const shouldDim = (filter === 'available' && isOccupied) ||
                              (filter === 'occupied' && !isOccupied);

            if (shouldDim) {
                seatEl.classList.add('seat-dimmed');
            } else {
                seatEl.classList.remove('seat-dimmed');
            }
        });
    }

    // Show floating seat tooltip
    showSeatTooltip(event, seatEl) {
        if (!this.elements.seatTooltip) return;

        const code = seatEl.getAttribute('data-seat-code');
        const id = seatEl.getAttribute('data-seat-id');
        const zone = seatEl.getAttribute('data-zone') || '1';
        const status = seatEl.getAttribute('data-status');
        const studentName = seatEl.getAttribute('data-student-name');
        const studentId = seatEl.getAttribute('data-student-id');
        const duration = seatEl.getAttribute('data-duration');
        const isOccupied = status === 'OCCUPIED';

        let content = `
            <div class="flex items-center justify-between gap-3 mb-1.5 pb-1 border-b border-gray-700">
                <span class="font-bold text-white tracking-wide">Seat ${code} <span class="text-gray-400 text-[10px] font-normal">(Zone ${zone} • #${id})</span></span>
                <span class="px-1.5 py-0.5 rounded text-[10px] font-bold ${isOccupied ? 'bg-rose-500/30 text-rose-300 border border-rose-500/50' : 'bg-emerald-500/30 text-emerald-300 border border-emerald-500/50'}">
                    ${status}
                </span>
            </div>
        `;

        if (isOccupied) {
            content += `
                <div class="space-y-1">
                    <p class="font-semibold text-rose-200 truncate flex items-center">
                        <i class="fas fa-user-graduate mr-1.5 text-xs"></i>${studentName || 'Active Student'}
                    </p>
                    <p class="text-[11px] text-gray-300">ID: <span class="font-mono text-white font-semibold">${studentId}</span></p>
                    ${duration ? `<p class="text-[10px] text-gray-400"><i class="fas fa-clock mr-1"></i>${duration}</p>` : ''}
                </div>
            `;
        } else {
            content += `
                <p class="text-[11px] text-emerald-300 flex items-center">
                    <i class="fas fa-check-circle mr-1.5"></i>Available for check-in
                </p>
            `;
        }

        content += `<p class="text-[9px] text-gray-400 mt-1.5 pt-1 border-t border-gray-800 text-center">Click for details</p>`;

        this.elements.seatTooltip.innerHTML = content;
        this.elements.seatTooltip.classList.remove('hidden');
        this.positionSeatTooltip(event, seatEl);
    }

    // Position tooltip above the seat cell with GPU hardware-acceleration (translate3d)
    positionSeatTooltip(event, seatEl) {
        if (!this.elements.seatTooltip || this.elements.seatTooltip.classList.contains('hidden')) return;

        if (this.tooltipRaf) cancelAnimationFrame(this.tooltipRaf);
        this.tooltipRaf = requestAnimationFrame(() => {
            const rect = seatEl.getBoundingClientRect();
            const tooltipX = Math.round(rect.left + (rect.width / 2));
            const tooltipY = Math.round(rect.top - 8);

            this.elements.seatTooltip.style.left = '0px';
            this.elements.seatTooltip.style.top = '0px';
            this.elements.seatTooltip.style.transform = `translate3d(${tooltipX}px, ${tooltipY}px, 0) translate(-50%, -100%)`;
        });
    }

    // Hide floating seat tooltip
    hideSeatTooltip() {
        if (this.tooltipRaf) {
            cancelAnimationFrame(this.tooltipRaf);
            this.tooltipRaf = null;
        }
        if (this.elements.seatTooltip) {
            this.elements.seatTooltip.classList.add('hidden');
        }
    }

    // Show seat detail modal
    // Show seat detail modal with rich student profile
    showSeatModal(seat) {
        if (!this.elements.seatDetailModal) return;

        const isOccupied = seat.status === 'OCCUPIED';
        const rowLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
        const rowLetter = rowLetters[parseInt(seat.row) - 1] || `Row ${seat.row}`;
        const seatCode = seat.code || `${rowLetter}${seat.col}`;
        const zoneNum = seat.zone || Math.ceil(parseInt(seat.id) / 100) || 1;

        // Header and Titles
        if (this.elements.seatModalTitle) {
            this.elements.seatModalTitle.textContent = `Seat #${seatCode} (Desk ${seat.id})`;
        }
        if (this.elements.seatModalSubtitle) {
            this.elements.seatModalSubtitle.textContent = `Zone ${zoneNum} • Row ${rowLetter} (${seat.row}) • Column ${seat.col}`;
        }

        // Header theme
        if (this.elements.seatModalHeader) {
            this.elements.seatModalHeader.className = isOccupied
                ? 'px-6 py-5 bg-gradient-to-r from-rose-700 via-rose-800 to-rose-900 text-white flex items-center justify-between'
                : 'px-6 py-5 bg-gradient-to-r from-emerald-700 via-teal-800 to-gray-900 text-white flex items-center justify-between';
        }

        // Status banner
        if (this.elements.seatModalStatusBanner) {
            this.elements.seatModalStatusBanner.className = isOccupied
                ? 'p-3.5 rounded-xl flex items-center justify-between bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-800/60'
                : 'p-3.5 rounded-xl flex items-center justify-between bg-emerald-50 dark:bg-emerald-950/40 border border-emerald-200 dark:border-emerald-800/60';
        }
        if (this.elements.seatModalStatusDot) {
            this.elements.seatModalStatusDot.className = isOccupied
                ? 'w-2.5 h-2.5 rounded-full bg-rose-500 animate-pulse'
                : 'w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse';
        }
        if (this.elements.seatModalStatusText) {
            this.elements.seatModalStatusText.textContent = isOccupied ? 'OCCUPIED' : 'AVAILABLE';
            this.elements.seatModalStatusText.className = isOccupied
                ? 'text-sm font-bold text-rose-700 dark:text-rose-300'
                : 'text-sm font-bold text-emerald-700 dark:text-emerald-300';
        }

        // Ensure student data is resolved for occupied seats
        let student = seat.student;
        const seatIdNum = parseInt(seat.id) || 1;

        // If seat is marked occupied but student info isn't attached directly to seat, look up from studentsInside
        if (isOccupied && !student) {
            const insideList = window.app?.currentData?.studentsInside || [];
            if (insideList.length > 0) {
                const idx = (seatIdNum - 1) % insideList.length;
                student = insideList[idx];
            }
        }

        // Occupant info / Vacant notice
        if (isOccupied && student) {
            if (this.elements.seatModalOccupantCard) this.elements.seatModalOccupantCard.classList.remove('hidden');
            if (this.elements.seatModalVacantNotice) this.elements.seatModalVacantNotice.classList.add('hidden');

            const name = student.name || 'Active Student';
            const id = student.id || `STU${seat.id}`;
            const initials = name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase() || 'ST';
            const rawEntry = student.entryTime || student.created_at || student.timestamp;
            
            // Set active modal entry time so live clock ticks it in real time
            this.activeModalEntryTime = rawEntry || new Date().toISOString();
            const liveDuration = Utils.calculateDuration(this.activeModalEntryTime);

            if (this.elements.seatModalStudentAvatar) this.elements.seatModalStudentAvatar.textContent = initials;
            if (this.elements.seatModalStudentName) this.elements.seatModalStudentName.textContent = name;
            if (this.elements.seatModalStudentId) {
                const course = student.course || student.degree || '';
                const courseLabel = course ? ` • ${course}` : '';
                this.elements.seatModalStudentId.textContent = `ID: ${id}${courseLabel}`;
            }
            if (this.elements.seatModalEntryTime) {
                this.elements.seatModalEntryTime.textContent = rawEntry 
                    ? new Date(rawEntry).toLocaleTimeString('en-IN', { hour12: true, hour: '2-digit', minute: '2-digit', second: '2-digit' })
                    : 'Checked in recently';
            }
            if (this.elements.seatModalDuration) {
                this.elements.seatModalDuration.textContent = liveDuration;
            }

            if (this.elements.seatModalSelectBtn) {
                this.elements.seatModalSelectBtn.setAttribute('data-student-id', id);
                this.elements.seatModalSelectBtn.classList.remove('hidden');
            }
            if (this.elements.seatModalSelectBtnText) {
                this.elements.seatModalSelectBtnText.textContent = `Select ${id} in Scanner`;
            }
        } else {
            this.activeModalEntryTime = null;
            if (this.elements.seatModalOccupantCard) this.elements.seatModalOccupantCard.classList.add('hidden');
            if (this.elements.seatModalVacantNotice) this.elements.seatModalVacantNotice.classList.remove('hidden');
            if (this.elements.seatModalSelectBtn) {
                this.elements.seatModalSelectBtn.removeAttribute('data-student-id');
                this.elements.seatModalSelectBtn.classList.add('hidden');
            }
        }

        this.elements.seatDetailModal.classList.remove('hidden');
    }

    // Hide seat detail modal
    hideSeatModal() {
        this.activeModalEntryTime = null;
        if (this.elements.seatDetailModal) {
            this.elements.seatDetailModal.classList.add('hidden');
        }
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
                this.showToast('Error marking exit: ' + error.message, 'error');
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
