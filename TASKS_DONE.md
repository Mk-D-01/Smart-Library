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

---

## 👥 Other Contributors (Template for Upcoming Weeks)

### 👤 [Contributor Name]
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3
