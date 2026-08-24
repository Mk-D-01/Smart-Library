# Smart Library System - API Dependencies & Architecture Specifications

**Document Version:** 1.0.0  
**Target System:** Smart Library Backend API (`backend/src`)  
**Date:** August 24, 2026  
**File Location:** `Report/api_dependencies.md`

---

## 1. Technical Dependency Matrix

### 1.1. Core Runtime & Production Dependencies

| Dependency Name | Specified Version | Purpose & Usage in Architecture |
| :--- | :--- | :--- |
| **`express`** | `^4.18.2` | Primary HTTP application web framework handling routing, middlewares, and request dispatching. |
| **`@supabase/supabase-js`** | `^2.39.3` | Supabase PostgreSQL client database SDK for real-time querying, student upserts, scan logs, and config metadata. |
| **`express-validator`** | `^7.0.1` | Declarative request body, query parameter, and route parameter validation middleware. |
| **`cors`** | `^2.8.5` | Cross-Origin Resource Sharing middleware enabling secure cross-origin requests from Flutter app & Admin web panel. |
| **`helmet`** | `^7.0.0` | HTTP header security hardening middleware protecting against XSS, clickjacking, and MIME sniffing. |
| **`morgan`** | `^1.10.0` | HTTP access request logger piped directly into `logger.ts` structured logging stream. |
| **`dotenv`** | `^16.3.1` | Environment variable loader mapping `.env` file variables into Node runtime `process.env`. |
| **`jsonwebtoken`** | `^9.0.2` | JWT token utility for authentication and session management. |
| **`bcryptjs`** | `^2.4.3` | Password and token hashing algorithm provider. |
| **`better-sqlite3`** | `^12.6.2` | Local embedded SQLite database driver fallback option. |

### 1.2. Development & Tooling Dependencies

| Dependency Name | Specified Version | Purpose & Usage |
| :--- | :--- | :--- |
| **`typescript`** | `^5.3.3` | Static type checker compiler ensuring end-to-end type safety across controllers, models, and routes. |
| **`ts-node`** | `^10.9.2` | Execution engine executing TypeScript source files directly during local development. |
| **`nodemon`** | `^3.0.2` | Development process watcher reloading `src/server.ts` upon source file modifications. |
| **`jest`** / **`ts-jest`** | `^29.6.1` / `^29.4.6` | Unit and integration testing framework executing backend test suites (`src/tests/*.test.ts`). |
| **`supertest`** | `^7.2.2` | HTTP assertion testing library evaluating API endpoints without manual web server binding. |
| **`@types/*`** | Various | TypeScript declaration definitions for Node, Express, Helmet, Cors, Morgan, Jest, and Supertest. |

---

## 2. Environment Variables Specification

The backend service relies on the following environment variable definitions (`.env`):

| Variable Key | Required | Default Value | Description |
| :--- | :---: | :--- | :--- |
| `PORT` | Optional | `3000` | Local HTTP network port for Express web server. |
| `NODE_ENV` | Optional | `development` | Deployment environment state (`development`, `production`, `test`). |
| `SUPABASE_URL` | **Required** | `https://<project-ref>.supabase.co` | Supabase cloud instance API URL endpoint. |
| `SUPABASE_SERVICE_KEY` | **Required** | `eyJ...` | Supabase service-role secret key bypassing RLS policies for backend API. |

---

## 3. Standardized API Response Contracts

All API endpoints strictly follow unified JSON response structures for both success and error responses.

### 3.1. Standardized Success Envelope Schema

```json
{
  "success": true,
  "message": "Human-readable operation summary message",
  "data": { ... },
  "timestamp": "2026-08-24T22:15:00.000Z"
}
```

#### Field Specifications
- **`success`** (`boolean`): Always `true` for HTTP 2xx status codes.
- **`message`** (`string`, optional): Description of operational outcome.
- **`data`** (`object` | `array` | `null`): Payload payload object or dataset.
- **`timestamp`** (`string`): ISO 8601 UTC timestamp of response creation.

---

### 3.2. Standardized Error Envelope Schema

```json
{
  "success": false,
  "error": "Error message describing failure reason",
  "code": "ERROR_CATEGORY_CODE",
  "details": [
    {
      "field": "studentId",
      "message": "Student ID is required"
    }
  ],
  "timestamp": "2026-08-24T22:15:00.000Z"
}
```

#### Standard Error Codes

| HTTP Code | Error Code Constant | Description |
| :---: | :--- | :--- |
| `400` | `BAD_REQUEST` / `VALIDATION_ERROR` | Malformed request body, missing fields, or validation rule violation. |
| `401` | `UNAUTHORIZED` | Authentication credentials missing or invalid. |
| `403` | `FORBIDDEN` / `ACCESS_EXPIRED` | Student account expired or deactivated. |
| `404` | `NOT_FOUND` / `STUDENT_NOT_FOUND` | Requested route or student entity missing. |
| `409` | `CONFLICT` / `DUPLICATE_SCAN` | State conflict or duplicate scan event within 5-second cooldown. |
| `500` | `INTERNAL_SERVER_ERROR` | Unhandled runtime exception or database error. |

---

## 4. API Endpoints & Request Validation Specifications

### 4.1. `POST /api/scan`
- **Description:** Process student barcode/QR code scan for automated entry or exit.
- **Validation Rules (`validateScan`):**
  - `studentId` (string, required): Cannot be empty or whitespace. Length: 2 to 50 characters.
- **Access Expiry Check:** Automatically verifies `validateStudentAccess(studentId)`.
- **Response Format:**
  ```json
  {
    "success": true,
    "action": "ENTRY",
    "student": {
      "id": "STU001",
      "name": "Student STU001",
      "status": "INSIDE"
    },
    "libraryStatus": {
      "totalSeats": 100,
      "occupiedSeats": 1,
      "availableSeats": 99
    },
    "timestamp": "2026-08-24T22:15:00.000Z"
  }
  ```

### 4.2. `GET /api/seats`
- **Description:** Returns visual seat occupancy grid matrix ($10 \times 10$) and room statistics.
- **Validation Rules:** None (public reading route).
- **Response Data:** Returns 2D seat matrix with status (`OCCUPIED` vs `AVAILABLE`) and assigned student preview.

### 4.3. `GET /api/students-inside`
- **Description:** Retrieves array list of all students currently inside the library (`current_status = 'INSIDE'`).
- **Response Payload:** `{ success: true, data: [...], count: N, timestamp: "..." }`

### 4.4. `GET /api/scan-logs`
- **Description:** Retrieves recent scan activity audit logs.
- **Validation Rules (`validateScanLogs`):**
  - `limit` (query string parameter, optional integer): Value constrained to range $1 \le \text{limit} \le 100$. Default: `20`.
- **Null Safety:** Relational joins return fallback student names (`Student <id>`) if referenced student entity is missing.

### 4.5. `GET /api/status`
- **Description:** Returns total, occupied, available seats, occupancy percentage, and last update timestamp.

### 4.6. `GET /api/student/:studentId`
- **Description:** Retrieves student record by ID.
- **Validation Rules (`validateStudentIdParam`):** `studentId` route parameter must be non-empty string.

### 4.7. `POST /api/reset`
- **Description:** Administrative system reset clearing occupancy count to 0 and setting all student statuses to `OUTSIDE`.

### 4.8. `GET /api/health`
- **Description:** System health check endpoint returning status `healthy`, server uptime, and timestamp.

---

## 5. Centralized Error Handling & Logging Architecture

```
                       ┌─────────────────────────┐
                       │  Incoming HTTP Request  │
                       └────────────┬────────────┘
                                    │
                         ┌──────────▼──────────┐
                         │  Morgan Logger Stream│
                         └──────────┬──────────┘
                                    │
                         ┌──────────▼──────────┐
                         │ express-validator   │
                         └──────────┬──────────┘
                                    │ (passes validation)
                         ┌──────────▼──────────┐
                         │ Controller / Model  │
                         └──────────┬──────────┘
                                    │ (throws AppError or Exception)
                         ┌──────────▼──────────┐
                         │ Centralized Error   │
                         │ Handler Middleware  │
                         └──────────┬──────────┘
                                    │
               ┌────────────────────┴────────────────────┐
               │                                         │
    ┌──────────▼──────────┐                   ┌──────────▼──────────┐
    │ Structured Logger   │                   │ Standard JSON Error │
    │ (Console / JSON)    │                   │ Envelope Response   │
    └─────────────────────┘                   └─────────────────────┘
```

- **Structured Logger (`src/utils/logger.ts`)**: Outputs contextual logs with ISO timestamps, severity icons (`ℹ️`, `⚠️`, `❌`, `🐛`), metadata, and stack trace details.
- **Centralized Middleware (`src/middleware/errorHandler.ts`)**: Intercepts operational errors (`AppError`), validation failures (`ValidationError`), and unexpected runtime errors, preventing unhandled app crashes.
