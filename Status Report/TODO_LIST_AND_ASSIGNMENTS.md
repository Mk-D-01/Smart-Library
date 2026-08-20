# 📋 Smart Library: 5-Day Sprint TODO & Team Assignments

**Sprint Goal:** Repository & Documentation Alignment, Flutter Analyzer Cleanup, Seat Map/Pictograph Parity, API Integration Testing, and Production Release Readiness.

---

## 👥 Sprint Schedule & Ownership Matrix

| Day | Assigned Owner(s) | Primary Focus Area | Key Deliverables |
| :--- | :--- | :--- | :--- |
| **Day 1** | **Aman** | Repository & Docs Sanity, Backend Doc Drift Fix | Supabase doc alignment, Canonical API table, Git branch sync |
| **Day 2** | **Dhruv & Gaurang** | Flutter Quality & Analyzer Cleanup | 15-step `TODO_FIX.md` completion, zero analyzer warnings |
| **Day 3** | **Yuvraj** | Seat Map & Pictograph Completion Sprint | Admin Web & Flutter seat map parity, UX polish, error states |
| **Day 4** | **Machine Gun Kelly Division** | API & Integration Test Hardening | Jest suites, edge cases (duplicate scan/reset), CI test hardening |
| **Day 5** | **Yuvraj** | Release Readiness & Deployment Checkpoint | E2E smoke tests, Root README update, Docker CD verification, release tag |

---

## 📅 Detailed Day-by-Day Task Breakdown

### 🔹 DAY 1: Aman — Repository & Documentation Sanity Pass
- [ ] **1.1 Backend README Drift Resolution:**
  - Audit `backend/README.md` and eliminate legacy references to SQLite / `better-sqlite3`.
  - Update `backend/README.md` with canonical Supabase environment configuration (`SUPABASE_URL`, `SUPABASE_SERVICE_KEY`).
- [ ] **1.2 Canonical API Contract Documentation:**
  - Document all endpoints (`/api/health`, `/api/status`, `/api/scan`, `/api/students-inside`, `/api/scan-logs`, `/api/student/:studentId`, `/api/seats`, `/api/reset`).
  - Provide explicit request payloads, response schemas, and error code mappings.
- [ ] **1.3 Git & Branch Context Alignment:**
  - Review branch state (`main` vs `origin/main` vs feature branches).
  - Ensure `.env.example` matches production requirements without exposing secrets.
- [ ] **1.4 Verification:**
  - Verify backend starts locally with `npm run dev` and connects cleanly to Supabase.

---

### 🔹 DAY 2: Dhruv & Gaurang — Flutter Quality & Analyzer Cleanup
*Objective: Work systematically through `flutter_app/TODO_FIX.md` to achieve 0 analyzer warnings.*

- [ ] **2.1 Step 1: `theme_config.dart`**
  - Add `const` to `BoxShadow`, `LinearGradient`, `IconThemeData`, `GoogleFonts.inter`.
- [ ] **2.2 Step 2: `auth_provider.dart`**
  - Fix `prefer_conditional_assignment` at line 68.
- [ ] **2.3 Step 3: `admin_dashboard_screen.dart`**
  - Address `use_build_context_synchronously` warnings at lines 697, 707, 740, 748 using `if (!mounted) return;`.
- [ ] **2.4 Step 4: `admin_manual_scanner_screen.dart`**
  - Fix `prefer_const_constructors` at lines 53, 202, 283; fix `unnecessary_null_comparison` at line 319.
- [ ] **2.5 Step 5: `admin_overview_screen.dart`**
  - Fix `prefer_const_constructors` & `prefer_const_literals_to_create_immutables` at lines 189–190.
  - Migrate deprecated `.withOpacity()` $\rightarrow$ `.withValues(alpha: ...)` at lines 197, 208, 234.
- [ ] **2.6 Step 6: `admin_scanner_screen.dart`**
  - Fix `prefer_const_constructors` (lines 137, 139, 145, 147, 183, 218, 221, 225) & `prefer_const_literals_to_create_immutables` (line 138).
- [ ] **2.7 Step 7: `admin_settings_screen.dart`**
  - Fix `use_build_context_synchronously` at lines 137, 301, 337, 345, 393.
- [ ] **2.8 Step 8: `admin_students_inside_screen.dart`**
  - Fix `use_build_context_synchronously` at line 446.
- [ ] **2.9 Step 9: `admin_students_screen.dart`**
  - Fix `prefer_const_constructors` (lines 184, 323) and `use_build_context_synchronously` (lines 266, 274, 307, 315).
- [ ] **2.10 Step 10: `login_screen.dart`**
  - Fix `prefer_const_constructors` at lines 70, 71, 88, 89, 385, 390.
- [ ] **2.11 Step 11: `student_profile_screen.dart`**
  - Fix `prefer_const_constructors` at lines 181, 278, 280.
- [ ] **2.12 Step 12: `supabase_service.dart`**
  - Fix `prefer_const_declarations` at line 485.
- [ ] **2.13 Step 13: `custom_dialogs.dart`**
  - Fix `prefer_const_constructors` at line 252.
- [ ] **2.14 Step 14: `loading_skeleton.dart`**
  - Fix `prefer_const_constructors` at lines 34, 35, 97, 99, 101.
- [ ] **2.15 Step 15: `seat_map_widget.dart`**
  - Replace `.withOpacity()` with `.withValues()` at lines 42, 149, 165, 270.
  - Remove `unnecessary_to_list_in_spreads` at lines 215, 240.
- [ ] **2.16 Verification Gate:**
  - Execute `flutter analyze` inside `flutter_app/` and verify **0 warnings, 0 errors**.

---

### 🔹 DAY 3: Yuvraj — Seat Map & Pictograph Completion Sprint
- [x] **3.1 Admin Web Seat Map Integration:**
  - Ensure Admin Web panel seamlessly consumes `GET /api/seats` and renders the dynamic 10x10 seat matrix.
  - Add color indicators: Green (Available) vs Red (Occupied) with student hover popover.
- [ ] **3.2 Flutter Seat Map Navigation & UX:**
  - Verify "View Seat Map" quick-access card on `AdminOverviewScreen` transitions to Seats tab without stacking routes.
  - Verify seat detail dialog/modal on mobile when tapping on occupied/available seats.
- [x] **3.3 Edge & Loading States:**
  - Implement robust loading skeletons and empty states for zero-occupancy and error states on network drop.
- [x] **3.4 Real-Time Refresh Sync:**
  - Ensure seat grid refreshes smoothly alongside the 5-second polling tick.

---

### 🔹 DAY 4: Machine Gun Kelly Division — API & Integration Test Hardening
- [x] **4.1 Test Suite Expansion in `backend/src/tests/`:**
  - Write dedicated unit and integration tests for:
    - `POST /api/scan`:
      - Valid entry scan (even count)
      - Valid exit scan (odd count)
      - Rapid duplicate scan within 5000ms (verifying 400 rejection)
      - Non-existent student auto-registration
    - `GET /api/student/:studentId`:
      - Existing student profile fetch
      - Non-existing student 404 response
    - `GET /api/seats`:
      - Verifying 2D matrix structure, rows, cols, totalSeats, occupiedSeats calculation
    - `POST /api/reset`:
      - Verifying reset sets all students to `OUTSIDE` and `occupied_seats` to 0
- [x] **4.2 Edge Case & Error Resilience:**
  - Test negative seat prevention logic (preventing decrement below 0).
  - Test over-capacity warning logic.
  - Test access expiry logic in `access_expiry.ts`.
- [ ] **4.3 CI Pipeline Testing Gate:**
  - Validate `.github/workflows/ci.yml` runs successfully with both secret-present and smoke-test fallback modes.

---

### 🔹 DAY 5: Yuvraj — Release Readiness & Deployment Checkpoint
- [ ] **5.1 End-to-End System Smoke Test:**
  - Perform live testing across:
    1. Hardware / Simulator Scan $\rightarrow$ Backend
    2. Admin Web UI live update
    3. Flutter Mobile Admin & Student screens live update
    4. Administrative Reset execution across all clients
- [ ] **5.2 Root Documentation & Runbooks:**
  - Update root `README.md` with final architecture diagrams, endpoint documentation, and quick-start instructions.
  - Document production troubleshooting and deployment runbooks.
- [ ] **5.3 Docker & CD Verification:**
  - Verify Docker build locally using `docker-compose up`.
  - Validate `.github/workflows/cd-backend-docker.yml` triggers properly and builds clean images for GHCR.
- [ ] **5.4 Handoff & Version Tagging:**
  - Tag release checkpoint (e.g. `v1.0.0-rc1`) and prepare handoff report for stakeholders.
