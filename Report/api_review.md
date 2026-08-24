# Smart Library Management System - API Architecture & Security Review Report

**Date:** August 24, 2026  
**Target System:** Smart Library Backend API (`/api/*`)  
**Scope:** Endpoint Architecture, Concurrency, Security, Data Integrity, and Client-Server Synchronization  
**Location:** `Report/api_review.md`

---

## 1. Executive Summary

A comprehensive architectural and code-level review was conducted for all API endpoints of the **Smart Library Management System** backend. The backend implementation consists of Express.js microservices with TypeScript (`src/`) and a standalone single-file legacy/testing backend (`simple-server.js`), backed by Supabase (PostgreSQL).

While the core functionality for automated barcode/QR student entry/exit scanning and real-time seat occupancy visualization is operational, several critical architectural vulnerabilities, race conditions, security risks, and implementation discrepancies were identified.

### Summary of Tasks & Status

| Task / Endpoint | Scope | Audit Status | Key Findings |
| :--- | :--- | :---: | :--- |
| **`POST /api/scan`** | Student Scan (Entry/Exit) | ⚠️ **Action Required** | Transaction non-atomicity; Access expiry check bypassed; Potential race condition. |
| **`GET /api/seats`** | Seat Grid Pictograph | ⚠️ **Action Required** | Positional seat mapping (no fixed seat assignment); Array index shifting; Inline dynamic import overhead. |
| **`GET /api/students-inside`**| Occupancy List | ⚠️ **Action Required** | Unauthenticated PII data exposure (`email`, `phone`); Lack of pagination. |
| **`GET /api/scan-logs`** | Activity Audit Logs | ⚠️ **Action Required** | Null reference risk on deleted student joins; Unbounded limit parameter; Backend implementation mismatch. |
| **`GET /api/status`** | Library Occupancy Status | ✅ **Passed** | Returns total, occupied, available seats & occupancy rate accurately. |
| **`GET /api/student/:id`** | Student Lookup | ⚠️ **Action Required** | Unauthenticated student PII enumeration. |
| **`POST /api/reset`** | System State Reset | 🛑 **Critical Risk** | Destructive admin endpoint completely unauthenticated and accessible to any client. |
| **`GET /api/health`** | System Health | ✅ **Passed** | Returns uptime, ISO timestamp, and health status clean. |

---

## 2. Detailed Endpoint Reviews

### 2.1. `POST /api/scan` (Student Entry/Exit Scanner)

#### Description
Processes student barcode/QR code scans. Automatically toggles student state between `INSIDE` (Entry) and `OUTSIDE` (Exit) based on `scan_count` parity, updates occupied library seats, logs scan events, and returns updated room occupancy metrics.

#### Technical Analysis & Logic Flow
1. **Validation:** Checks if `studentId` is present in request body. Returns HTTP 400 if missing.
2. **Duplicate Protection:** Queries `getLastScan(studentId)` and rejects requests made within 5,000 ms (5 seconds) with a 400 error.
3. **Student Upsert:** If student does not exist, auto-creates a student record (`Student <studentId>`) with status `OUTSIDE` and `scan_count = 0`.
4. **State Transition:** 
   - Even `scan_count` (0, 2, 4...) $\rightarrow$ `ENTRY` action $\rightarrow$ `INSIDE` status.
   - Odd `scan_count` (1, 3, 5...) $\rightarrow$ `EXIT` action $\rightarrow$ `OUTSIDE` status.
5. **Occupancy Update:** Increments or decrements `occupied_seats` in `library_config`.
6. **Logging:** Inserts record into `scan_logs`.

#### Findings & Issues Identified

> [!CAUTION]
> **1. Non-Atomic Database Operations (Transaction Wrapper Bypassed)**  
> In `src/models/library.model.ts` (lines 8-12), `runInTransaction` is implemented as a dummy passthrough (`return await fn()`). Because Supabase uses HTTP-based PostgREST calls, each database query runs as a separate HTTP request. If `logScan` or `updateOccupiedSeats` fails mid-process, student status will remain updated to `INSIDE` while occupancy counters or scan logs are out of sync.

> [!WARNING]
> **2. Student Access Expiry & Account Status Verification Bypassed**  
> `library.model.ts` defines `validateStudentAccess(studentId)` which verifies `is_active` status and `access_expiry_date` (calculated via `access_expiry.ts`). However, **`processScan` in `library.controller.ts` NEVER invokes this validation!** Expired or deactivated students can scan into the library without restriction.

> [!NOTE]
> **3. Cooldown Race Condition**  
> The 5-second duplicate check (`getLastScan`) executes before student status updates. Concurrent requests sent within milliseconds can both read the prior scan log and pass verification before either log is saved.

---

### 2.2. `GET /api/seats` (Seat Grid Pictograph)

#### Description
Generates 2D pictograph visual grid matrix data (rows $\times$ columns) representing seat occupancy and individual student seat assignments for visual admin dashboards.

#### Technical Analysis & Logic Flow
1. Queries `getLibraryStatus()` for total capacity (default 100 seats).
2. Queries `getAllStudentsInside()`.
3. Constructs a grid (default $10 \times 10$). Assigns `students[i]` to seat number `i + 1`.

#### Findings & Issues Identified

> [!WARNING]
> **1. Dynamic Positional Shifting (No Fixed Seat Allocation)**  
> Seat assignment is calculated dynamically based on `students[index]`. When Student A (at seat 1) exits, all remaining students shift forward by one seat position on the visual map during the next poll, causing erratic UI updates.

> [!NOTE]
> **2. Index Truncation Over Capacity**  
> If `occupiedSeats > totalSeats` (over-capacity scenario), students with index $\ge \text{totalSeats}$ are excluded from the visual matrix array, misrepresenting active occupancy.

> [!NOTE]
> **3. Inline Dynamic Import Overhead**  
> `router.get('/seats')` in `library.routes.ts` uses `await import('../controllers/library.controller')` inside the handler function instead of a top-level module import.

---

### 2.3. `GET /api/students-inside` (Active Occupants List)

#### Description
Retrieves a list of all students currently inside the library (`current_status = 'INSIDE'`) along with total count.

#### Technical Analysis & Logic Flow
Queries `students` table filtering by `current_status = 'INSIDE'`. Returns `{ success: true, data: [...], count: N }`.

#### Findings & Issues Identified

> [!WARNING]
> **1. Unauthenticated PII Data Leakage**  
> Endpoint returns complete student database models including sensitive personal data (`email`, `phone`, `degree`, `admission_date`). Because the endpoint has no authentication layer, student PII is exposed to any network client.

> [!NOTE]
> **2. Missing Pagination**  
> Lacks limit/offset query parameters. During peak library usage (hundreds of students), the API returns a monolithic JSON array.

---

### 2.4. `GET /api/scan-logs` (Audit Activity Trail)

#### Description
Retrieves recent entry/exit activity logs for administrative monitoring. Accepts optional `limit` query parameter (default 20).

#### Technical Analysis & Logic Flow
Queries `scan_logs` ordered by `timestamp DESC`. In TypeScript backend (`library.model.ts`), performs a relational join with `students` to attach `students.name`.

#### Findings & Issues Identified

> [!CAUTION]
> **1. Unhandled Null Pointer Exception on Orphan Logs**  
> In `library.model.ts` line 282: `return data.map((log: any) => ({ ...log, name: log.students.name }))`. If a student record is removed or null, `log.students` is `null`, causing an unhandled runtime error (`Cannot read properties of null (reading 'name')`) resulting in HTTP 500.

> [!WARNING]
> **2. Unbounded Limit Parameter (Denial of Service Risk)**  
> `parseInt(limitParam, 10)` does not cap maximum limit (e.g. `?limit=500000`), allowing clients to request massive dataset joins and consume node memory.

> [!IMPORTANT]
> **3. Implementation Divergence**  
> In `simple-server.js`, `/api/scan-logs` returns raw `scan_logs` records without student names, whereas `library.routes.ts` returns joined objects containing `name`.

---

### 2.5. Review of Remaining Endpoints

#### `GET /api/status`
- **Status:** ✅ **Healthy / Passed**
- **Analysis:** Returns `totalSeats`, `occupiedSeats`, `availableSeats`, `occupancyRate`, and `lastUpdated`. Math logic correctly caps available seats at `0` minimum (`Math.max(0, totalSeats - occupiedSeats)`).

#### `GET /api/student/:studentId`
- **Status:** ⚠️ **Security Warning**
- **Analysis:** Returns student profile by ID. Allows unauthenticated enumeration of student IDs and associated personal data.

#### `POST /api/reset`
- **Status:** 🛑 **Critical Security Vulnerability**
- **Analysis:** Resets all students to `OUTSIDE` and sets `occupied_seats = 0`. **Completely unauthenticated.** Any anonymous network request can reset the state of the entire library system.

#### `GET /api/health` & `GET /`
- **Status:** ✅ **Healthy / Passed**
- **Analysis:** Returns system status, environment information, and available API routes.

---

## 3. Vulnerability & Risk Matrix

| Severity | Category | Endpoint | Issue Description | Impact |
| :---: | :--- | :--- | :--- | :--- |
| **CRITICAL** | Authorization | `POST /api/reset` | Missing Admin Authentication | Unauthorized system state wipe |
| **HIGH** | Business Logic | `POST /api/scan` | Expiry & Account Validation Bypassed | Ineligible/expired students gain entry |
| **HIGH** | Data Integrity | `POST /api/scan` | Non-Atomic DB Operations | Desynchronization of seat counts vs student states |
| **MEDIUM** | Privacy (PII) | `GET /api/students-inside` | Unauthenticated PII Exposure | Exposure of student email, phone, and degree data |
| **MEDIUM** | Reliability | `GET /api/scan-logs` | Unhandled Null Join Property Access | HTTP 500 error if referenced student record is missing |
| **LOW** | Performance | `GET /api/seats` | Inline Module Imports & Dynamic Shifting | Suboptimal route performance & UI jitter |

---

## 4. Remediation Recommendations

### Priority 1: High & Critical Fixes

1. **Enforce Access Validation in Scan Endpoint:**
   Update `processScan` in `src/controllers/library.controller.ts` to call `validateStudentAccess(studentId)` prior to performing status updates.
   ```typescript
   const accessCheck = await validateStudentAccess(studentId);
   if (!accessCheck.valid) {
     return res.status(403).json({
       success: false,
       error: accessCheck.reason || 'Access denied'
     });
   }
   ```

2. **Secure Administrative & PII Endpoints:**
   Implement authentication middleware (API key or JWT token) for `POST /api/reset`, `GET /api/students-inside`, and `GET /api/student/:studentId`.

3. **Safe Log Model Join Handling:**
   Safeguard `getScanLogs` against missing student joins:
   ```typescript
   return data.map((log: any) => ({
     ...log,
     name: log.students?.name || 'Unknown Student'
   }));
   ```

4. **Cap Log Limit Parameter:**
   Limit query parameters to a maximum threshold:
   ```typescript
   const rawLimit = parseInt(req.query.limit as string, 10) || 20;
   const limit = Math.min(Math.max(1, rawLimit), 100);
   ```

### Priority 2: Enhancements & Optimization

1. **Fixed Seat Assignment:**
   Store a `seat_number` attribute in `students` table or a separate `seat_assignments` table rather than dynamically indexing array position.
2. **Atomic Supabase Transactions:**
   Migrate multi-table updates (`students`, `library_config`, `scan_logs`) to a Supabase RPC Database Function (`process_student_scan`) to guarantee ACID transactional execution.

---

## 5. Verification Checklist

- [x] Review `/api/scan` endpoint implementation & logic
- [x] Review `/api/seats` pictograph visualization logic
- [x] Review `/api/students-inside` data payload & security
- [x] Review `/api/scan-logs` dataset querying & null safety
- [x] Audit all remaining endpoints (`/status`, `/student/:id`, `/reset`, `/health`)
- [x] Publish comprehensive API review report under `Report/api_review.md`

---
*Report generated automatically by Smart Library Automated Reviewer.*
