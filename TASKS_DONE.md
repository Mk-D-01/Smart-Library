# 📋 Smart Library Project Task Tracker

This tracker maintains a weekly record of completed deliverables, active milestones, and validation results across all contributors. Team members update their respective sections at the end of each work cycle.

---

## 👤 Contributor: Anubhav Kiroula

### 🗓️ Week: Software-Only Migration & Full System Validation (August 2026)

#### 1. Hardware & IoT Dependency Removal
- [x] **Audit Codebase:** Scanned entire repository for physical hardware references (`GPIO`, `serial`, `RFID`, `Arduino`, `ESP32`, `USB HID`, physical scanner SDKs).
- [x] **Package Clean-Up:** Removed `better-sqlite3` and `@types/better-sqlite3` native build dependencies from `backend/package.json` and regenerated `package-lock.json`.
- [x] **Container Optimization:** Streamlined `backend/Dockerfile.fresh` to clean `node:20-alpine` without unnecessary C++ native compilation tools (`python3`, `make`, `g++`).
- [x] **UI Copy Updates:** Updated `flutter_app/lib/screens/admin/admin_manual_scanner_screen.dart` to software QR/camera scanning descriptions.
- [x] **Architecture Redesign:** Updated root `README.md`, `backend/README.md`, `PROJECT_FLOW_AND_CODEBASE_ARCHITECTURE.md`, and `WORK_SUMMARY_AND_TECH_STACK.md` to reflect software-driven entry/exit scanning via HTTP API.

#### 2. Backend API Test Suite & Edge-Case Hardening
- [x] **Complete Endpoint Coverage:** Expanded `backend/src/tests/library.test.ts` to 20 test cases across all 13 required scenarios.
- [x] **API Index:** Verified `GET /` metadata catalog and versioning.
- [x] **Health Check:** Verified `GET /api/health` returns HTTP 200 `healthy`, uptime, and valid ISO timestamp.
- [x] **Status & Occupancy:** Verified `GET /api/status` metrics, non-negative available seat boundary, and occupancy rate calculations.
- [x] **Software Scan Pipeline:** Verified `POST /api/scan` for missing student ID validation (HTTP 400), entry auto-registration (status `INSIDE`), 5-second cooldown throttle, and exit toggle (status `OUTSIDE`).
- [x] **Student Lookup:** Verified `GET /api/student/:id` (HTTP 200 for existing, HTTP 404 for non-existent without stack trace exposure).
- [x] **Access Expiry Utilities:** Validated graduation calculations, days until expiry, and active status guards.
- [x] **Seat Map Pictograph:** Verified `GET /api/seats` 2D grid matrix, unique seat IDs, total capacity consistency, and dynamic occupant assignment.
- [x] **Scan Logs & Students Inside:** Verified `GET /api/scan-logs` (newest-first ordering, limit enforcement) and `GET /api/students-inside`.
- [x] **System Reset & Boundary Guards:** Verified `POST /api/reset` sets all students to `OUTSIDE` and zeroes occupancy, with negative floor protection.
- [x] **404 Route Protection:** Verified `GET /api/does-not-exist` returns clean error without leaking stack traces or credentials.

#### 3. Subsystem Verification & CI/CD Validation
- [x] **Backend Build & Type-Check:** Ran `npm run type-check` (0 errors) and `npm run build` (successful compilation).
- [x] **Automated Tests:** Ran `npm test -- --runInBand` (20/20 tests passed across 2 suites).
- [x] **Flutter Client Check:** Ran `flutter analyze` (0 issues found) and `flutter test` (all tests passed).
- [x] **Docker Container Validation:** Built `smart-library-backend:latest`, verified container startup, tested `GET /api/health` against container, tested restart capability, and cleanly tore down compose stack.
- [x] **CI/CD Configuration:** Validated `.github/workflows/ci.yml` and `cd-backend-docker.yml` syntax and least-privilege permissions.
- [x] **Team Database Migration:** Migrated database to new team-accessible Supabase project (`durphnxkjxboefxkkfty`), configured Realtime tables, updated Flutter config and backend env, and verified 20/20 test suites.

---

## 👤 Contributor: Yuvraj

### 🗓️ Week: Seat Map & Pictograph Completion Sprint (August 2026)

#### 1. Dynamic 10×10 Seat Map in Admin Web Panel (350 Capacity)
- [x] **API Contract Integration:** Configured `CONFIG.ENDPOINTS.SEATS = '/seats'` with `TOTAL_SEATS = 350` and implemented `apiService.getSeatMap()` / `getDemoSeatMap()` to seamlessly consume real-time seat matrix data from the backend.
- [x] **Floorplan Matrix Visualization:** Engineered a dynamic 10×10 interactive desk grid with Row letters (A–J), Column numbers (1–10), and multi-zone navigation (Zones 1–4) representing the full 350-seat library capacity.
- [x] **Dynamic Hover Movement & Micro-Animations:** Added cubic-bezier spring physics to seat cells (`transform: translateY(-5px) scale(1.10)`) and dynamic seat number displacement (`transform: translateY(-1.5px) scale(1.08)`) on hover for rich tactile feedback.
- [x] **Real-Time Interactive Popover/Tooltip:** Added high-performance floating tooltip (`#seatTooltip`) displaying Zone, Desk ID, row/col coordinates, student profile (Name, ID, duration) on hover.
- [x] **Interactive Seat Details Modal:** Implemented `#seatDetailModal` with complete student profile view, check-in timestamps, session duration, and a quick-action "Select in Scanner" trigger.
- [x] **Grid Filtering & State Synchronization:** Added interactive filter tabs (`All (350)`, `Available (X)`, `Occupied (Y)`) and hooked seat map updates directly into the 5-second polling loop and instant scan/reset triggers.

#### 2. Real-Time Dynamic Durations & SQL Student Data Integration
- [x] **Real-Time Duration & Live Entry Timestamp Fix:** Refactored backend `getStudentsInsideWithEntryTime()` and `getSeatMap()` to join `students` with actual `ENTRY` timestamps from `scan_logs`. Replaced static fallback times with dynamic ticking elapsed time on both the Admin Web Panel and Flutter app.
- [x] **QR Scan Database Integration (SQL):** Enriched `processScan`, `getStudentsInsideController`, and `getSeatMap` to query and return full student profile fields (`id`, `name`, `course`/`degree`, `semester`, `phone`). Added SQL migration `002_add_course_column.sql`.
- [x] **Enhanced UI & Aesthetics:** Upgraded Admin Web Panel with glassmorphism design (`backdrop-filter: blur`), animated student avatars, course badges, gradient hover effects on table rows, and pulsing connection health indicators.
- [x] **Flutter App Consistency:** Updated Flutter `Student` and `SeatStudent` models to support `course` and `entryTime`, rendering real-time durations and course badges in the seat details bottom sheet.

#### 3. Student Portal Dark Theme & Navigation Fixes
- [x] **Fixed Student Login & Route Navigation:** Removed broken delayed `pushReplacementNamed('/student')` from `login_screen.dart` to allow reactive `AuthWrapper` to manage transition seamlessly to `AppNavigation`.
- [x] **Dark Mode in Student Portal:** Connected `StudentProfileScreen`'s dark mode toggle to `ThemeProvider.setDarkMode()`, added a direct theme toggle button in `StudentDashboardScreen` and `StudentHistoryScreen` AppBars, and wrapped `AppNavigation` in `Consumer<ThemeProvider>` for instantaneous app-wide theme switching.
- [x] **Student Multi-Zone Seats Tab:** Added dedicated `StudentSeatsScreen` with `SeatMapWidget` to student navigation tabs for full interactive 350-seat floorplan access.


## 👤 Contributor: Dhruv & Gaurang

🗓️ Week: Smart Library Frontend Code Quality & Analyzer Cleanup Sprint (August 2026)

1. Compile-Time const Performance & Memory Optimization
[x]Theme & Input Decoration Optimization (theme_config.dart): Added const modifiers to compile-time OutlineInputBorder, RoundedRectangleBorder, and DialogThemeData instances across Light and Dark themes without altering visual behavior.
[x]Custom Dialogs & Loading Skeletons (custom_dialogs.dart, loading_skeleton.dart): Enforced const constructors on shape borders (RoundedRectangleBorder), BorderRadius, and layout [x]placeholders for SuccessDialog, ErrorDialog, ConfirmDialog, and skeleton loaders.
[x]Screen & Card Widget Optimizations (login_screen.dart, student_profile_screen.dart, admin_overview_screen.dart, admin_settings_screen.dart): Added const constructors for static layout containers, card shapes, text styles, and border radii while maintaining dynamic theme getters.
2. Flutter Async BuildContext & Navigation Safety Refactoring
[x]Safe Context Usage Across Async Gaps: Refactored async dialog callbacks and navigation handlers in admin_dashboard_screen.dart, admin_students_screen.dart, admin_settings_screen.dart, admin_manual_scanner_screen.dart, and student_profile_screen.dart to capture NavigatorState, ScaffoldMessenger, and LibraryProvider before async gaps and check mounted / context.mounted before UI updates.
[x]State Guarding in Scanning & Student Lists: Added if (mounted) guards inside the finally block of _processScan in admin_manual_scanner_screen.dart and _loadAllStudents() in admin_students_screen.dart to prevent memory leaks and unhandled state updates on unmounted widgets.
[x]String Interpolation & Context Separation (admin_students_inside_screen.dart): Fixed missing student string interpolation in _showForceExitDialog (including student name and ID in confirmation dialogs and SnackBars) while enforcing mounted guards.
3. Type Safety, Null-Coalescing & Modern API Upgrades
[x]Authentication Provider Null-Coalescing (auth_provider.dart): Refactored student retrieval and fallback creation into a clean null-coalescing assignment (final student = await _supabaseService.getStudent(userId) ?? await _supabaseService.upsertStudent(userId);), preserving auth flow integrity.
[x]Strong Typing in Scanner Logs (admin_scanner_screen.dart): Strongly typed parameter signatures (_buildRecentScanItem(ScanLog log)) to eliminate implicit dynamic warnings.
[x]Collection for Elements (seat_map_widget.dart): Replaced array spread operators (...map(...)) with list-literal for elements for clean, performant seat grid building.
[x]Modern Color Opacity & Deprecation Fixes: Migrated deprecated color opacity methods to modern withValues(alpha: ...) APIs and updated Supabase.initialize in main.dart to use publishableKey.
4. Native Platform Runner & Build Configuration Fix
[x]Windows Build Manifest Regeneration: Recreated missing windows/runner/runner.exe.manifest configuration via flutter create --platforms=windows ., resolving CMake compilation errors and enabling clean flutter run -d windows execution.
5. Zero-Warning Zero-Error Flutter Analyzer Compliance
[x]Analyzer Verification: Successfully ran flutter analyze across the entire codebase with 0 errors and 0 warnings achieved without suppressing analyzer rules or editing analysis_options.yaml.
