# 🚀 Smart Library Backend API

A high-performance, cloud-native Node.js & TypeScript RESTful API powering the **Smart Library Management System**. Engineered with Express.js and fully integrated with **Supabase (PostgreSQL)**, this service handles automated student check-in/out scanning, real-time 350-seat occupancy calculations, dynamic 2D seat map rendering, access validity governance, and centralized cloud synchronization across web and mobile clients.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [System Architecture & Data Flow](#-system-architecture--data-flow)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Database Setup (Supabase PostgreSQL)](#-database-setup-supabase-postgresql)
  - [1. Create Supabase Project](#1-create-supabase-project)
  - [2. Fetch Connection Credentials](#2-fetch-connection-credentials)
  - [3. Database Schema Creation (DDL)](#3-database-schema-creation-ddl)
  - [4. Apply Migrations](#4-apply-migrations)
  - [5. Seed Demo Data](#5-seed-demo-data)
  - [6. Row-Level Security (RLS) Configuration](#6-row-level-security-rls-configuration)
- [Installation & Local Setup](#-installation--local-setup)
- [Environment Variables](#-environment-variables)
- [Usage & Quickstart](#-usage--quickstart)
- [API Reference](#-api-reference)
- [Testing & Quality Assurance](#-testing--quality-assurance)
- [Docker & Containerization](#-docker--containerization)
- [Troubleshooting & FAQ](#-troubleshooting--faq)
- [Contributing Guidelines](#-contributing-guidelines)
- [License](#-license)

---

## 📖 Project Overview

The **Smart Library Backend** serves as the central data orchestrator for campus library facilities. It completely eliminates paper-based attendance registers and legacy standalone databases in favor of a modern, software-driven REST API powered by **Supabase PostgreSQL**.

### Core Responsibilities:
1. **Automated Entry/Exit Scanning:** Consumes student ID inputs from the Admin Web Panel and Flutter Mobile App via `POST /api/scan`, intelligently toggling student statuses (`INSIDE` vs `OUTSIDE`) and logging chronological audit events.
2. **Real-Time 350-Seat Occupancy Engine:** Dynamically calculates occupied vs. available seat counts, percentage ratios, and outputs a 2D floorplan matrix (`GET /api/seats`) across 4 library zones with exact desk-to-student associations.
3. **Identity & Expiry Governance:** Validates student registration, course degree durations, and calculates expiration windows to ensure only authorized students enter the facility.
4. **Resilient Cloud Persistence:** Direct integration with Supabase PostgreSQL ensures high availability, automatic connection pooling, and live synchronization across multiple client instances.

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
│   ├── library_config (Total 350 Seats, Occupied Count) │
│   ├── students       (Profiles, Status, Expiry Date)   │
│   └── scan_logs      (Immutable Audit Trail: ENTRY/EXIT│
└────────────────────────────────────────────────────────┘
```

---

## ✨ Features

- **⚡ Cloud-Native REST API:** Built with Node.js 20 LTS, TypeScript 5, Express.js, and `@supabase/supabase-js`.
- **🔄 Software-Driven Scan Pipeline:** `POST /api/scan` evaluates student state, alternates between `ENTRY` and `EXIT`, and auto-provisions new students upon first scan.
- **🛡️ Duplicate Scan Cooldown Guard:** 5-second anti-bounce cooldown prevents accidental double-swipes and race conditions.
- **🗺️ Dynamic 2D Seat Map Generator:** Produces a 10×10 seat coordinate matrix (Rows A–J, Cols 1–10) across 4 zones representing all 350 seats.
- **⏱️ Live Study Duration Tracking:** Joins active occupants with their exact `ENTRY` timestamps from `scan_logs` to enable ticking real-time duration badges on client apps.
- **🔒 Degree-Based Expiry Validation:** Calculates degree duration (e.g., BTech: 4 years, MBA: 2 years) and enforces access expiration guards.
- **🧹 Atomic System Reset:** `POST /api/reset` clears all active check-ins, sets student statuses to `OUTSIDE`, and zeroes occupancy with negative-value floor protections.
- **🌐 Hardened Security & CORS:** Configured with `helmet` header protections and explicit CORS whitelists for web and mobile origins.
- **🧪 Comprehensive Test Suite:** 20 Jest + Supertest integration tests verifying all endpoints, boundary conditions, and database interactions.
- **🐳 Multi-Stage Docker Build:** Streamlined `node:20-alpine` image with zero native compilation overhead.

---

## 💻 Tech Stack

- **Runtime Environment:** [Node.js](https://nodejs.org/) (v18.x or v20.x LTS)
- **Programming Language:** [TypeScript](https://www.typescriptlang.org/) (v5.3.3)
- **Framework:** [Express.js](https://expressjs.com/) (v4.18.2)
- **Database:** [Supabase](https://supabase.com/) (Managed PostgreSQL 15+)
- **Supabase SDK:** [`@supabase/supabase-js`](https://www.npmjs.com/package/@supabase/supabase-js) (v2.39.3)
- **Security & Middleware:** [Helmet](https://helmetjs.github.io/) (v7.0.0), [CORS](https://github.com/expressjs/cors) (v2.8.5), [dotenv](https://github.com/motdotla/dotenv), [Morgan](https://github.com/expressjs/morgan)
- **Testing Tools:** [Jest](https://jestjs.io/) (v29.6.1), [ts-jest](https://kulshekhar.github.io/ts-jest/) (v29.4.6), [Supertest](https://github.com/ladjs/supertest) (v7.2.2)
- **Development Tooling:** [Nodemon](https://nodemon.io/) (v3.0.2), [ts-node](https://typestrong.org/ts-node/) (v10.9.2)
- **Containerization:** [Docker](https://www.docker.com/) & Docker Compose

---

## 📋 Prerequisites

Before running the backend, ensure you have the following installed:

- **Node.js:** `v18.0.0` or higher (`v20.x` LTS recommended)
- **npm:** `v9.0.0` or higher
- **Git:** Latest version
- **Docker Desktop:** *(Optional, for containerized execution)*
- **Supabase Account:** Free or Pro account at [supabase.com](https://supabase.com).

Verify installed tool versions:
```bash
node -v
npm -v
git --version
```

---

## 🗄 Database Setup (Supabase PostgreSQL)

The Smart Library backend uses **Supabase PostgreSQL** as its sole persistence engine. Follow these steps to provision and configure your database.

### 1. Create Supabase Project
1. Log in to your [Supabase Dashboard](https://app.supabase.com/).
2. Click **New Project**.
3. Enter your project details:
   - **Name:** `Smart-Library` (or your preferred name)
   - **Database Password:** Enter a strong password and store it securely.
   - **Region:** Select the region closest to your deployment server.
4. Click **Create new project** and wait ~2 minutes for provisioning to complete.

---

### 2. Fetch Connection Credentials
1. In your Supabase Project Dashboard, navigate to **Project Settings** (gear icon) ➔ **API**.
2. Locate the following values:
   - **Project URL:** `https://your-project-id.supabase.co`
   - **`anon` `public` key:** `eyJhbGciOi...`
   - **`service_role` `secret` key:** `eyJhbGciOi...` *(Revealed by clicking "Reveal secret key")*

> [!IMPORTANT]
> The backend server requires the **`service_role`** key to perform administrative database operations (reading/writing student statuses, inserting scan logs, and resetting library configurations).

---

### 3. Database Schema Creation (DDL)
Open the **SQL Editor** in your Supabase dashboard and run the following script to create all core tables:

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

-- 4. Create Index on Scan Logs for fast lookup
CREATE INDEX IF NOT EXISTS idx_scan_logs_student_timestamp 
ON scan_logs (student_id, timestamp DESC);
```

---

### 4. Apply Migrations
If updating an existing database, ensure the migrations located in `backend/src/migrations/` have been executed:

#### Migration `001_extend_students_table.sql`:
```sql
ALTER TABLE students
ADD COLUMN IF NOT EXISTS degree TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS admission_date DATE DEFAULT NULL,
ADD COLUMN IF NOT EXISTS access_expiry_date DATE DEFAULT NULL,
ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS semester INTEGER DEFAULT NULL,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

#### Migration `002_add_course_column.sql`:
```sql
ALTER TABLE students
ADD COLUMN IF NOT EXISTS course TEXT DEFAULT NULL;
```

---

### 5. Seed Demo Data
Run this SQL block in the **Supabase SQL Editor** to populate initial library configuration and test student accounts:

```sql
-- Initialize Library Capacity (350 Seats)
INSERT INTO library_config (id, total_seats, occupied_seats, last_updated)
VALUES (1, 350, 0, NOW())
ON CONFLICT (id) DO UPDATE 
SET total_seats = EXCLUDED.total_seats,
    occupied_seats = EXCLUDED.occupied_seats;

-- Insert Seed Students
INSERT INTO students (id, name, email, course, degree, semester, current_status, scan_count, access_expiry_date, is_active)
VALUES 
  ('STU001', 'Aarav Sharma', 'aarav.sharma@student.local', 'B.Tech CSE', 'BTech', 4, 'OUTSIDE', 0, NOW() + INTERVAL '2 years', true),
  ('STU002', 'Priya Patel', 'priya.patel@student.local', 'MBA', 'MBA', 2, 'OUTSIDE', 0, NOW() + INTERVAL '1 year', true),
  ('STU003', 'Rohan Gupta', 'rohan.gupta@student.local', 'B.Tech ECE', 'BTech', 6, 'OUTSIDE', 0, NOW() + INTERVAL '1 year', true),
  ('STU004', 'Ananya Singh', 'ananya.singh@student.local', 'BBA', 'BBA', 2, 'OUTSIDE', 0, NOW() + INTERVAL '2 years', true),
  ('STU005', 'Arjun Verma', 'arjun.verma@student.local', 'B.Tech ME', 'BTech', 4, 'OUTSIDE', 0, NOW() + INTERVAL '2 years', true),
  ('25101210443', 'Aman Singh', '25101210443@student.local', 'B.Tech CSE', 'BTech', 4, 'OUTSIDE', 0, NOW() + INTERVAL '2 years', true)
ON CONFLICT (id) DO NOTHING;
```

---

### 6. Row-Level Security (RLS) Configuration
By default, the backend connects using the `SUPABASE_SERVICE_ROLE_KEY`, which automatically bypasses RLS policies for server-side queries.

If you enable RLS on the tables, execute:
```sql
ALTER TABLE library_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_logs ENABLE ROW LEVEL SECURITY;

-- Allow public read access to library_config
CREATE POLICY "Allow public read library_config" 
ON library_config FOR SELECT USING (true);

-- Allow public read access to students
CREATE POLICY "Allow public read students" 
ON students FOR SELECT USING (true);

-- Allow public read access to scan_logs
CREATE POLICY "Allow public read scan_logs" 
ON scan_logs FOR SELECT USING (true);
```

---

## ⚙️ Installation & Local Setup

### 1. Clone & Enter Directory
```bash
git clone https://github.com/AnubhavKiroula/Smart-Library.git
cd Smart-Library/backend
```

### 2. Install Node Dependencies
```bash
# Clean install exact dependencies
npm ci
```

### 3. Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
# Linux/macOS
cp .env.example .env

# Windows (PowerShell)
Copy-Item .env.example .env

# Windows (Command Prompt)
copy .env.example .env
```

Edit `backend/.env` with your Supabase project credentials:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Supabase Cloud Database Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key
SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 4. Verify TypeScript Compilation
```bash
npm run type-check
```

---

## 🔐 Environment Variables

The backend requires the following environment variables:

| Variable Name | Type | Required | Example Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `PORT` | `number` | Optional | `3000` | Port on which Express server listens (default: `3000`). |
| `NODE_ENV` | `string` | Optional | `development` | Environment mode (`development`, `production`, `test`). |
| `SUPABASE_URL` | `string` | **Yes** | `https://xyz.supabase.co` | Supabase project API endpoint. |
| `SUPABASE_SERVICE_ROLE_KEY` | `string` | **Yes** | `eyJhbGciOi...` | Supabase Service Role secret key for administrative DB queries. |
| `SUPABASE_SERVICE_KEY` | `string` | Optional | `eyJhbGciOi...` | Alternate alias for `SUPABASE_SERVICE_ROLE_KEY`. |
| `SUPABASE_ANON_KEY` | `string` | Optional | `eyJhbGciOi...` | Public anonymous key for client-side queries. |

> [!CAUTION]
> Never commit `backend/.env` or publish the `SUPABASE_SERVICE_ROLE_KEY` to public repositories.

---

## 🚦 Usage & Quickstart

### Available CLI Scripts

Execute the following commands from the `backend/` directory:

| Command | Description |
| :--- | :--- |
| `npm run dev` | Starts server in development mode with **Nodemon** auto-reloading on file change. |
| `npm run type-check` | Runs TypeScript compiler checks (`tsc --noEmit`) to validate types without emitting JS. |
| `npm run build` | Compiles TypeScript source files into production-ready JavaScript in `dist/`. |
| `npm start` | Executes the compiled production bundle (`node dist/server.js`). |
| `npm test` | Runs the full Jest integration test suite against the API. |
| `npm test -- --runInBand` | Runs Jest tests sequentially (recommended for database-sensitive assertions). |

### Launching the Development Server:
```bash
npm run dev
```

Terminal output:
```text
✅ Supabase database connected successfully
✅ Database initialized with Smart Library schema
🚀 Server is running on http://localhost:3000
📚 Smart Library Management System API
🌍 Environment: development
🏥 Health Check: http://localhost:3000/api/health
```

---

## 📡 API Reference

Base URL: `http://localhost:3000` or `http://localhost:3000/api`

### 1. Health & Discovery

#### `GET /`
Returns API metadata and route directory.
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Smart Library Management System API",
  "version": "1.0.0",
  "endpoints": {
    "status": "/api/status",
    "scan": "/api/scan",
    "studentsInside": "/api/students-inside",
    "scanLogs": "/api/scan-logs",
    "seats": "/api/seats",
    "health": "/api/health"
  }
}
```

#### `GET /api/health`
Health check endpoint reporting server status and uptime.
- **Response `200 OK`:**
```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2026-08-20T18:00:00.000Z",
  "uptime": 128.42
}
```

---

### 2. Occupancy & Library Operations

#### `GET /api/status`
Returns real-time library occupancy metrics.
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "totalSeats": 350,
    "occupiedSeats": 42,
    "availableSeats": 308,
    "occupancyRate": 12.0,
    "isFull": false,
    "lastUpdated": "2026-08-20T18:00:00.000Z"
  }
}
```

---

### 3. Student Check-In / Check-Out Scanning

#### `POST /api/scan`
Processes a student entry or exit scan. Automatically creates the student profile if it does not exist in Supabase.

- **Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "studentId": "STU001"
}
```

- **Response `200 OK` (Entry):**
```json
{
  "success": true,
  "data": {
    "action": "ENTRY",
    "student": {
      "id": "STU001",
      "name": "Aarav Sharma",
      "course": "B.Tech CSE",
      "current_status": "INSIDE",
      "scan_count": 1
    },
    "libraryStatus": {
      "totalSeats": 350,
      "occupiedSeats": 1,
      "availableSeats": 349,
      "occupancyRate": 0.29
    },
    "timestamp": "2026-08-20T18:00:00.000Z"
  }
}
```

- **Response `200 OK` (Exit):**
```json
{
  "success": true,
  "data": {
    "action": "EXIT",
    "student": {
      "id": "STU001",
      "name": "Aarav Sharma",
      "course": "B.Tech CSE",
      "current_status": "OUTSIDE",
      "scan_count": 2
    },
    "libraryStatus": {
      "totalSeats": 350,
      "occupiedSeats": 0,
      "availableSeats": 350,
      "occupancyRate": 0.0
    },
    "timestamp": "2026-08-20T18:05:00.000Z"
  }
}
```

- **Error Codes:**
  - `400 Bad Request`: `{"success": false, "error": "Student ID is required"}`
  - `429 Too Many Requests`: `{"success": false, "error": "Duplicate scan. Please wait 5 seconds."}`

---

#### `GET /api/student/:studentId`
Looks up student profile and current status.
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "id": "STU001",
    "name": "Aarav Sharma",
    "email": "aarav.sharma@student.local",
    "course": "B.Tech CSE",
    "current_status": "INSIDE",
    "scan_count": 1,
    "access_expiry_date": "2028-06-30T00:00:00.000Z",
    "is_active": true
  }
}
```

---

#### `GET /api/students-inside`
Returns all students currently inside with active entry timestamps.
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "STU001",
      "name": "Aarav Sharma",
      "course": "B.Tech CSE",
      "current_status": "INSIDE",
      "scan_count": 1,
      "entry_time": "2026-08-20T18:00:00.000Z"
    }
  ]
}
```

---

#### `GET /api/seats`
Generates a dynamic 2D seat map (10 rows × 10 cols) across 4 zones representing the 350-seat capacity.
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "totalSeats": 350,
    "occupiedSeats": 1,
    "availableSeats": 349,
    "grid": {
      "rows": 10,
      "cols": 10,
      "zones": 4
    },
    "seats": [
      {
        "id": "A1",
        "row": "A",
        "col": 1,
        "zone": 1,
        "isOccupied": true,
        "student": {
          "id": "STU001",
          "name": "Aarav Sharma",
          "course": "B.Tech CSE",
          "entryTime": "2026-08-20T18:00:00.000Z"
        }
      },
      {
        "id": "A2",
        "row": "A",
        "col": 2,
        "zone": 1,
        "isOccupied": false,
        "student": null
      }
    ]
  }
}
```

---

#### `POST /api/reset`
Administrative command resetting occupancy to zero and all students to `OUTSIDE`.
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Library occupancy and student statuses reset successfully",
  "data": {
    "totalSeats": 350,
    "occupiedSeats": 0,
    "availableSeats": 350,
    "occupancyRate": 0.0
  }
}
```

---

## 🧪 Testing & Quality Assurance

The backend incorporates an automated integration test suite utilizing **Jest** and **Supertest**.

```bash
# Run all tests sequentially
npm test -- --runInBand

# Run smoke tests only (for fast CI validation)
npx jest src/tests/simple.test.ts
```

### Test Assertions Covered:
- ✅ Supabase connection initialization and configuration check
- ✅ System health endpoint check (`GET /api/health`)
- ✅ Real-time occupancy calculation & boundary constraints (`GET /api/status`)
- ✅ Automated entry / exit scan toggle & cooldown enforcement (`POST /api/scan`)
- ✅ Dynamic 350-seat floorplan matrix generation (`GET /api/seats`)
- ✅ Student profile lookup and sanitized 404 handler (`GET /api/student/:id`)
- ✅ Emergency system reset execution (`POST /api/reset`)

---

## 🐳 Docker & Containerization

### Build & Run Container Locally:
```bash
# 1. Build Docker image
docker build -t smart-library-backend:latest .

# 2. Run container with environment variables
docker run -d \
  -p 3000:3000 \
  --name smart-library-backend \
  --env-file .env \
  smart-library-backend:latest
```

### Using Docker Compose:
From the repository root:
```bash
# Start backend service
docker-compose up -d

# View live container logs
docker-compose logs -f backend

# Stop container service
docker-compose down
```

---

## 🛠 Troubleshooting & FAQ

### 1. "Supabase connection error: Invalid API key"
- **Cause:** `SUPABASE_SERVICE_ROLE_KEY` or `SUPABASE_URL` in `.env` is incorrect or truncated.
- **Fix:** Copy the `service_role` key from Supabase Dashboard ➔ Project Settings ➔ API.

### 2. "Port 3000 already in use"
- **Windows:**
  ```powershell
  netstat -ano | findstr :3000
  taskkill /PID <PID> /F
  ```
- **Linux/macOS:**
  ```bash
  lsof -ti:3000 | xargs kill -9
  ```

### 3. "relation 'students' does not exist"
- **Cause:** Supabase migrations have not been applied yet.
- **Fix:** Execute the SQL script in [Database Schema Creation](#3-database-schema-creation-ddl) in the Supabase SQL Editor.

---

## 🤝 Contributing Guidelines

1. **Fork the Repository** and create a feature branch (`git checkout -b feature/backend-improvement`).
2. **Adhere to TypeScript Best Practices:** Keep controllers lean and encapsulate database logic in `src/models/`.
3. **Validate Code:**
   ```bash
   npm run type-check
   npm test -- --runInBand
   ```
4. **Commit Changes:** Use structured commit messages (`feat: add webhook event on student scan`).
5. **Submit a Pull Request:** Detail your changes and provide test verification logs.

---

## 📄 License

Distributed under the **ISC License**. See the root [LICENSE](../LICENSE) for more details.
