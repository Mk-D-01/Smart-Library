# Smart Library Management System - Backend API

A production-grade Node.js + TypeScript backend API for the Smart Library Management System powered by Express.js, Supabase PostgreSQL, `express-validator`, structured logging, and centralized error handling.

## Features

- ✅ **Express.js with TypeScript:** Type-safe controller, model, and routing layer.
- ✅ **Supabase Database:** PostgreSQL cloud database integration for student records, scan logs, and occupancy state.
- ✅ **Standardized API Envelope:** Uniform JSON response format across all success and error responses.
- ✅ **Request Validation:** Declarative input validation powered by `express-validator`.
- ✅ **Centralized Error Handling:** Custom operational `AppError` exception hierarchy with zero unhandled crash leaks.
- ✅ **Structured Logging:** Level-based logging (`INFO`, `WARN`, `ERROR`, `DEBUG`) with ISO timestamps and Morgan stream integration.
- ✅ **Access Expiry Enforcement:** Automatic validation of student degree duration and account active status during barcode/QR scans.

---

## Technical Stack & Dependencies

- **Framework:** Express.js (`^4.18.2`)
- **Language:** TypeScript (`^5.3.3`)
- **Database SDK:** `@supabase/supabase-js` (`^2.39.3`)
- **Validation:** `express-validator` (`^7.0.1`)
- **Security & Headers:** `cors` (`^2.8.5`), `helmet` (`^7.0.0`)
- **Logging:** `morgan` (`^1.10.0`) + Custom Structured Logger (`src/utils/logger.ts`)

For full technical dependency matrices and API schemas, see [Report/api_dependencies.md](../Report/api_dependencies.md).

---

## API Endpoints Overview

| Method | Endpoint | Description | Validation / Constraints |
| :---: | :--- | :--- | :--- |
| `POST` | `/api/scan` | Process barcode/QR scan for Entry/Exit | `studentId` string (2-50 chars, required) |
| `GET` | `/api/seats` | Get seat visual grid pictograph data | None |
| `GET` | `/api/students-inside` | List all students currently inside | None |
| `GET` | `/api/scan-logs` | Retrieve recent activity audit logs | `limit` (optional integer, $1 \le \text{limit} \le 100$) |
| `GET` | `/api/status` | Get total, occupied & available seats | None |
| `GET` | `/api/student/:studentId` | Get student details by ID | `studentId` param required |
| `POST` | `/api/reset` | Admin reset of library occupancy state | None |
| `GET` | `/api/health` | Service health check | None |

---

## Standardized Response Envelopes

### Success Response Format
```json
{
  "success": true,
  "message": "Library status retrieved successfully",
  "data": {
    "totalSeats": 100,
    "occupiedSeats": 10,
    "availableSeats": 90,
    "occupancyRate": 10
  },
  "timestamp": "2026-08-24T22:15:00.000Z"
}
```

### Error Response Format
```json
{
  "success": false,
  "error": "Request validation failed",
  "code": "VALIDATION_ERROR",
  "details": [
    {
      "field": "studentId",
      "message": "Student ID is required"
    }
  ],
  "timestamp": "2026-08-24T22:15:00.000Z"
}
```

---

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.ts         # Supabase client setup & connection validation
│   ├── controllers/
│   │   └── library.controller.ts# Request controllers with error delegation
│   ├── middleware/
│   │   ├── errorHandler.ts     # Global error catching & 404 handler
│   │   └── validate.ts         # express-validator request rules
│   ├── models/
│   │   └── library.model.ts    # Supabase queries & student access logic
│   ├── routes/
│   │   └── library.routes.ts   # Express route definitions with middlewares
│   ├── types/
│   │   └── library.types.ts    # TypeScript interface definitions
│   ├── utils/
│   │   ├── access_expiry.ts    # Student access expiry calculation
│   │   ├── appError.ts         # Operational exception hierarchy
│   │   ├── logger.ts           # Structured level logging utility
│   │   └── responseHandler.ts  # Standardized response envelopes
│   └── server.ts               # Server entrypoint & middleware mounting
├── .env.example
├── package.json
├── tsconfig.json
└── README.md
```

---

## Setup & Running Instructions

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env`:
```env
PORT=3000
NODE_ENV=development
SUPABASE_URL=https://your-supabase-url.supabase.co
SUPABASE_SERVICE_KEY=your-supabase-service-key
```

### 3. Run Development Server
```bash
npm run dev
```

### 4. Build TypeScript
```bash
npm run build
```

---
*Documentation updated August 24, 2026.*
