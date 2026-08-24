# 🚀 Smart Library Backend API

A high-performance, cloud-native Node.js & TypeScript RESTful API powering the **Smart Library Management System**. Engineered with Express.js and fully integrated with **Supabase (PostgreSQL)**, this service features standardized API response envelopes, declarative request validation (`express-validator`), structured logging (`logger.ts`), custom operational exception handling (`AppError`), real-time seat occupancy calculation, dynamic 2D seat map rendering, access validity governance, and centralized cloud synchronization across web and mobile clients.

---

## 📑 Table of Contents

- [Key Features](#key-features)
- [Technical Stack & Dependencies](#technical-stack--dependencies)
- [API Endpoints Overview](#api-endpoints-overview)
- [Standardized Response Envelopes](#standardized-response-envelopes)
- [System Architecture & Data Flow](#-system-architecture--data-flow)
- [Directory Structure](#-directory-structure)
- [Prerequisites](#-prerequisites)
- [Database Setup (Supabase PostgreSQL)](#-database-setup-supabase-postgresql)
- [Installation & Local Setup](#-installation--local-setup)
- [Environment Variables](#-environment-variables)
- [License](#-license)

---

## Key Features

- ✅ **Express.js with TypeScript:** Type-safe controller, model, and routing layer.
- ✅ **Supabase Database:** PostgreSQL cloud database integration for student records, scan logs, and occupancy state.
- ✅ **Standardized API Envelope:** Uniform JSON response format across all success and error responses.
- ✅ **Request Validation:** Declarative input validation powered by `express-validator`.
- ✅ **Centralized Error Handling:** Custom operational `AppError` exception hierarchy with zero unhandled crash leaks.
- ✅ **Structured Logging:** Level-based logging (`INFO`, `WARN`, `ERROR`, `DEBUG`) with ISO timestamps and Morgan stream integration.
- ✅ **Access Expiry Enforcement:** Automatic validation of student degree duration and account active status during barcode/QR scans.
- ✅ **Software-Driven Scan Pipeline:** `POST /api/scan` evaluates student state, alternates between `ENTRY` and `EXIT`, and auto-provisions new students upon first scan.
- ✅ **Duplicate Scan Cooldown Guard:** 5-second anti-bounce cooldown prevents accidental double-swipes.
- ✅ **Dynamic 2D Seat Map Generator:** Produces seat coordinate matrix across 4 zones.
- ✅ **Atomic System Reset:** `POST /api/reset` clears all active check-ins, sets student statuses to `OUTSIDE`, and zeroes occupancy.

---

## Technical Stack & Dependencies

- **Framework:** Express.js (`^4.18.2`)
- **Language:** TypeScript (`^5.3.3`)
- **Database SDK:** `@supabase/supabase-js` (`^2.39.3`)
- **Validation:** `express-validator` (`^7.0.1`)
- **Security & Headers:** `cors` (`^2.8.5`), `helmet` (`^7.0.0`)
- **Logging:** `morgan` (`^1.10.0`) + Custom Structured Logger (`src/utils/logger.ts`)

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

## 🏗 System Architecture & Data Flow

```
┌────────────────────────────────────────────────────────┐
│                   Client Applications                  │
│   ┌────────────────────────┐  ┌────────────────────┐   │
│   │ Admin Web Dashboard    │  │ Flutter Mobile App │   │
│   │ (HTML5 / Tailwind / JS)│  │ (Android/iOS/Web)  │   │
│   └───────────┬────────────┘  └─────────┬──────────┘   │
└───────────────┼─────────────────────────┼──────────────┘
                │ HTTP / REST (JSON)      │ HTTP / REST (JSON)
                ▼                         ▼
┌────────────────────────────────────────────────────────┐
│               Smart Library Backend Service            │
│   ┌────────────────────────────────────────────────┐   │
│   │ Express Server (src/server.ts)                 │   │
│   │  ├── Helmet Security & CORS Middleware         │   │
│   │  ├── Morgan HTTP Request Logger                │   │
│   │  └── Global Error & 404 Handlers               │   │
│   └───────────────────────┬────────────────────────┘   │
│                           │                            │
│   ┌───────────────────────▼────────────────────────┐   │
│   │ Controller Layer (src/controllers/)            │   │
│   │  ├── processScan (Cooldown & Toggle Logic)     │   │
│   │  ├── getLibraryStatusController                │   │
│   │  ├── getSeatMap (2D Matrix Generator)          │   │
│   │  ├── getStudentsInsideController               │   │
│   │  └── resetSystem                               │   │
│   └───────────────────────┬────────────────────────┘   │
│                           │                            │
│   ┌───────────────────────▼────────────────────────┐   │
│   │ Models & Supabase Client (src/models/)         │   │
│   │  ├── @supabase/supabase-js Client              │   │
│   │  └── access_expiry.ts (Validation Utilities)   │   │
│   └───────────────────────┬────────────────────────┘   │
└───────────────────────────┼────────────────────────────┘
                            │ HTTPS / PostgreSQL (Port 443 / 5432)
                            ▼
┌────────────────────────────────────────────────────────┐
│             Supabase Cloud (PostgreSQL 15+)            │
│   ├── library_config (Total Seats, Occupied Count)     │
│   ├── students       (Profiles, Status, Expiry Date)   │
│   └── scan_logs      (Immutable Audit Trail: ENTRY/EXIT│
└────────────────────────────────────────────────────────┘
```

---

## 💻 Directory Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.ts          # Supabase client setup & connection validation
│   ├── controllers/
│   │   └── library.controller.ts # Request controllers with error delegation
│   ├── middleware/
│   │   ├── errorHandler.ts      # Global error catching & 404 handler
│   │   └── validate.ts          # express-validator request rules
│   ├── models/
│   │   └── library.model.ts     # Supabase queries & student access logic
│   ├── routes/
│   │   └── library.routes.ts    # Express route definitions with middlewares
│   ├── types/
│   │   └── library.types.ts     # TypeScript interface definitions
│   ├── utils/
│   │   ├── access_expiry.ts     # Student access expiry calculation
│   │   ├── appError.ts          # Operational exception hierarchy
│   │   ├── logger.ts            # Structured level logging utility
│   │   └── responseHandler.ts   # Standardized response envelopes
│   └── server.ts                # Server entrypoint & middleware mounting
├── .env.example
├── package.json
├── tsconfig.json
└── README.md
```

---

## 📋 Prerequisites

- **Node.js:** `v18.0.0` or higher (`v20.x` LTS recommended)
- **npm:** `v9.0.0` or higher
- **Git:** Latest version
- **Supabase Account:** Free or Pro account at [supabase.com](https://supabase.com).

Verify installed tool versions:
```bash
node -v
npm -v
git --version
```

---

## 🗄 Database Setup (Supabase PostgreSQL)

The Smart Library backend uses **Supabase PostgreSQL** as its sole persistence engine.

### 1. Create Supabase Project
1. Log in to your [Supabase Dashboard](https://app.supabase.com/).
2. Click **New Project**.
3. Enter your project details (**Name:** `Smart-Library`).

### 2. Database Schema Creation (DDL)
Open the **SQL Editor** in your Supabase dashboard and run the following script:

```sql
-- 1. Create Library Configuration Table
CREATE TABLE IF NOT EXISTS library_config (
    id SERIAL PRIMARY KEY,
    total_seats INTEGER NOT NULL DEFAULT 350,
    occupied_seats INTEGER NOT NULL DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create Students Table
CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    course VARCHAR(100) DEFAULT 'General',
    degree VARCHAR(100) DEFAULT NULL,
    semester INTEGER DEFAULT 1,
    phone VARCHAR(20) DEFAULT NULL,
    admission_date DATE DEFAULT CURRENT_DATE,
    access_expiry_date TIMESTAMP WITH TIME ZONE,
    current_status VARCHAR(20) DEFAULT 'OUTSIDE' CHECK (current_status IN ('INSIDE', 'OUTSIDE')),
    scan_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create Scan Logs Table
CREATE TABLE IF NOT EXISTS scan_logs (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(50) REFERENCES students(id) ON DELETE CASCADE,
    scan_type VARCHAR(10) NOT NULL CHECK (scan_type IN ('ENTRY', 'EXIT')),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create Index on Scan Logs
CREATE INDEX IF NOT EXISTS idx_scan_logs_student_timestamp 
ON scan_logs (student_id, timestamp DESC);
```

---

## ⚙️ Installation & Local Setup

### 1. Clone & Enter Directory
```bash
git clone https://github.com/AnubhavKiroula/Smart-Library.git
cd Smart-Library/backend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Configure Environment Variables
Copy `.env.example` to `.env`:
```env
PORT=3000
NODE_ENV=development
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key
SUPABASE_SERVICE_KEY=your-supabase-service-role-key
SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 4. Run Development Server
```bash
npm run dev
```

Expected terminal output:
```text
✅ Supabase database connected successfully
✅ Database initialized with Smart Library schema
🚀 Server is running on http://localhost:3000
📚 Smart Library Management System API
🌍 Environment: development
```

### 5. Build TypeScript
```bash
npm run build
```

---

## 🔐 Environment Variables

| Variable Name | Type | Required | Example Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `PORT` | `number` | Optional | `3000` | Port on which Express server listens (default: `3000`). |
| `NODE_ENV` | `string` | Optional | `development` | Environment mode (`development`, `production`, `test`). |
| `SUPABASE_URL` | `string` | **Yes** | `https://xyz.supabase.co` | Supabase project API endpoint. |
| `SUPABASE_SERVICE_ROLE_KEY` | `string` | **Yes** | `eyJhbGciOi...` | Supabase Service Role secret key for administrative DB queries. |
| `SUPABASE_SERVICE_KEY` | `string` | Optional | `eyJhbGciOi...` | Alternate alias for `SUPABASE_SERVICE_ROLE_KEY`. |
| `SUPABASE_ANON_KEY` | `string` | Optional | `eyJhbGciOi...` | Public anonymous key for client-side queries. |

---

## 📄 License

Distributed under the **ISC License**. See the root [LICENSE](../LICENSE) for more details.

---
*Documentation updated August 24, 2026.*
