# Smart Library Management System - Backend API

A robust Node.js + TypeScript backend for the Smart Library management system powered by Express.js and Supabase PostgreSQL.

## Features

- Express.js server with TypeScript
- Cloud database integration with Supabase (PostgreSQL)
- Software-based student entry/exit scan tracking (`POST /api/scan`)
- Real-time library occupancy & seat map matrix (`GET /api/seats`, `GET /api/status`)
- Duplicate scan cooldown protection (5 seconds)
- Automated student registration on first scan
- Access expiry date & status validation
- Admin system reset endpoint (`POST /api/reset`)
- CORS enabled for Admin Web Panel and Flutter Mobile App
- Comprehensive Jest & Supertest integration test suite
- Docker containerization support

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.ts          # Supabase client configuration & initialization
│   ├── models/
│   │   └── library.model.ts     # Data models and database operations
│   ├── controllers/
│   │   └── library.controller.ts # API request handlers
│   ├── routes/
│   │   └── library.routes.ts    # Library API route definitions
│   ├── middleware/
│   │   └── errorHandler.ts      # Global error and 404 handling middleware
│   ├── utils/
│   │   └── access_expiry.ts     # Access expiry calculations and validation
│   ├── types/
│   │   └── library.types.ts     # TypeScript interfaces and types
│   ├── tests/
│   │   ├── library.test.ts      # Comprehensive API integration test suite
│   │   ├── simple.test.ts       # CI smoke test
│   │   └── setup.ts            # Test environment configuration
│   └── server.ts                # Main Express server entry point
├── Dockerfile                   # Production Dockerfile
├── Dockerfile.fresh             # Development/Compose Dockerfile
├── package.json                 # Dependencies and scripts
├── tsconfig.json                # TypeScript configuration
└── README.md                    # Backend documentation
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm ci
```

### 2. Configure Environment Variables

Create `backend/.env` with your Supabase credentials:

```env
PORT=3000
NODE_ENV=development
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-supabase-service-role-key
```

### 3. Run the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Type Check:**
```bash
npm run type-check
```

**Build TypeScript:**
```bash
npm run build
```

**Production mode:**
```bash
npm start
```

The server starts on `http://localhost:3000`.

### 4. Run Tests

```bash
# Run complete test suite
npm test -- --runInBand
```

## API Endpoints

### System & Health

- `GET /` - API index and endpoint catalog
- `GET /api/health` - Server health check and uptime

### Library Operations

- `GET /api/status` - Live occupancy metrics (total, occupied, available seats, occupancy rate)
- `POST /api/scan` - Process software student scan (even scan count = ENTRY, odd = EXIT)
- `GET /api/student/:studentId` - Look up student profile by ID
- `GET /api/students-inside` - List all students currently inside
- `GET /api/scan-logs` - Query recent scan history (supports `?limit=N`)
- `GET /api/seats` - Dynamic 2D seat map grid with occupant details
- `POST /api/reset` - Reset library occupancy and mark all students as outside

## Database Schema (Supabase)

The system utilizes Supabase PostgreSQL with the following core tables:

1. **`library_config`** - Library configuration (total seats, occupied seats, last updated timestamp)
2. **`students`** - Student records (id, name, email, current_status, scan_count, access_expiry_date, is_active)
3. **`scan_logs`** - Historical scan log events (id, student_id, scan_type: ENTRY/EXIT, timestamp)
