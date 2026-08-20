# 📚 Smart Library Management System

A modern, software-driven solution that transforms traditional libraries into intelligent, efficient spaces using student ID and QR code scanning, real-time data management, and automated entry/exit tracking.

## Overview

The Smart Library system automates library entry/exit tracking while monitoring real-time occupancy. Students check in/out using mobile or web-based software scanning, and the system processes this data to provide instant visibility of occupied and vacant seats through digital dashboards.

### Key Features
- Software Scan Flow - Automated student entry/exit tracking via HTTP API
- Real-time Dashboard - Live occupancy monitoring
- Auto-sync - Centralized cloud database sync
- Multi-platform - Web admin panel + Flutter mobile app
- Cloud-based - Supabase database integration
- Scalable - Cost-effective, containerized, and reliable architecture

## Architecture

```
┌─────────────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Web / Mobile Scan Flow  │───▶│   Backend API    │───▶│   Supabase DB   │
│ (Admin Web / Flutter)   │    │   (Node.js)      │    │   (Cloud)       │
└─────────────────────────┘    └──────────────────┘    └─────────────────┘
                                        │
                                        ▼
                               ┌──────────────────┐
                               │   Admin Panel    │
                               │   (Web UI)       │
                               └──────────────────┘
```

## Quick Start

### Prerequisites
- Docker Desktop (recommended)
- Node.js 18+ (for local development)
- Supabase account and project

### Option 1: Docker Setup (Recommended)
```bash
# Clone repository
git clone https://github.com/AnubhavKiroula/Smart-Library.git
cd Smart-Library

# Start backend with Docker
docker-compose up

# Backend runs at: http://localhost:3000
```

### Option 2: Local Development
```bash
# Clone repository
git clone https://github.com/AnubhavKiroula/Smart-Library.git
cd Smart-Library

# Setup backend
cd backend
npm install
cp .env.example .env
# Edit .env with your Supabase credentials
npm run dev

# Setup admin panel (new terminal)
cd admin-web
python -m http.server 8080

# Access points:
# Backend API: http://localhost:3000/api
# Admin Panel: http://localhost:8080
```

## Admin Panel Setup

The admin panel provides real-time monitoring and management capabilities:

### Features
- Live Dashboard - Real-time library statistics
- Student Tracking - Monitor students inside library
- Scan History - View entry/exit logs
- System Management - Reset and configuration options
- Auto-refresh - Updates every 5 seconds

### Quick Setup
```bash
# Start admin panel
cd admin-web
python -m http.server 8080

# Visit: http://localhost:8080
# Should see "System Online" with real data
```

### Admin Panel URLs
- Local Development: `http://localhost:8080`
- Production: Deploy to your web server

## Flutter App Integration

### API Configuration
```dart
// Local development
const String API_BASE_URL = 'http://localhost:3000/api';

// Android Emulator
const String API_BASE_URL = 'http://10.0.2.2:3000/api';

// Physical Device
const String API_BASE_URL = 'http://YOUR_IP:3000/api';
```

### Find Your IP
- Windows: `ipconfig`
- Mac/Linux: `ifconfig | grep inet`

## Environment Configuration

### Backend Environment Variables
Create `backend/.env`:
```env
# Server Configuration
NODE_ENV=development
PORT=3000

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key
```

### Admin Panel Configuration
Edit `admin-web/js/config.js`:
```javascript
const CONFIG = {
    API_BASE_URL: 'http://localhost:3000/api',
    REFRESH_INTERVAL: 5000,
    // ... other settings
};
```

## API Endpoints

### Core Endpoints
- `GET /api/health` - Health check
- `GET /api/status` - Library statistics
- `POST /api/scan` - Process student scan
- `GET /api/students-inside` - Current occupants
- `GET /api/scan-logs` - Scan history
- `POST /api/reset` - Reset system

### Example Usage
```javascript
// Get library status
fetch('http://localhost:3000/api/status')
  .then(res => res.json())
  .then(data => {
    console.log('Library status:', data.data);
  });
```

## Development Guide

### Backend Development
```bash
cd backend
npm install
npm run dev          # Development mode
npm run build        # Build for production
npm start           # Run built version
```

### Admin Panel Development
```bash
cd admin-web
python -m http.server 8080
# Edit files in admin-web/js/ directory
# Browser auto-refreshes on changes
```

### Database Schema
The system uses Supabase with these main tables:
- `library_config` - Library settings
- `students` - Student records
- `scan_logs` - Entry/exit history

## Troubleshooting

### Common Issues

**Port 3000 already in use:**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill -9
```

**CORS Issues:**
- Ensure backend CORS allows your frontend origin
- Check `backend/src/server.ts` CORS configuration

**Supabase Connection:**
- Verify `.env` file has correct credentials
- Test connection: `node backend/test-supabase.js`

**Admin Panel Not Connecting:**
1. Check backend is running: `curl http://localhost:3000/api/health`
2. Verify CORS configuration
3. Check browser console for errors
4. Hard refresh: `Ctrl+Shift+R`

### Debug Mode
```bash
# Use simplified backend for debugging
cd backend
node simple-server.js
```

## Deployment

### CI/CD (GitHub Actions)

- **CI workflow**: `.github/workflows/ci.yml`
  - Runs on push and pull requests.
  - Executes backend install, type-check, build, and tests.
  - If `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` secrets are present, it runs the full backend tests.
  - If those secrets are missing, it runs a smoke test (`src/tests/simple.test.ts`) so CI remains stable.

- **CD workflow**: `.github/workflows/cd-backend-docker.yml`
  - Runs on pushes to `main` affecting `backend/**` (or manual trigger).
  - Builds and publishes backend Docker image to GHCR:
    - `ghcr.io/<owner>/smart-library-backend:latest` (default branch)
    - `ghcr.io/<owner>/smart-library-backend:sha-<commit>`

#### Required repository secrets

- `SUPABASE_URL` (required for full backend integration tests in CI)
- `SUPABASE_SERVICE_KEY` (required for full backend integration tests in CI)

### Docker Deployment
```bash
# Production build
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose logs -f backend
```

### Environment Setup
- Development: Use `npm run dev`
- Production: Use `npm start` with built files
- Database: Supabase handles scaling and backups

## ✅ Validation & Testing Results

The Smart Library system has been migrated to software-only operation and validated across all subsystems:

| Subsystem | Scope / Commands | Status | Details |
| :--- | :--- | :--- | :--- |
| **Backend Types & Build** | `npm run type-check && npm run build` | ✅ PASSED | 0 TypeScript errors, clean compilation |
| **API Test Suite** | `npm test -- --runInBand` | ✅ PASSED | 20/20 test cases passing across all 13 core endpoints & edge cases |
| **Flutter Mobile Client** | `flutter analyze && flutter test` | ✅ PASSED | 0 analyzer issues, all widget/unit tests passing |
| **Docker Container** | `docker compose build && docker compose up -d` | ✅ PASSED | Built on `node:20-alpine`, `/api/health` returned HTTP 200 `healthy` |
| **Admin Web Panel** | `GET /api/status`, `/api/seats`, `/api/scan-logs` | ✅ PASSED | Real-time live polling, seat pictograph, and manual scan operational |
| **Hardware Removal** | `git grep -i "hardware\|iot\|gpio\|serial"` | ✅ PASSED | 0 active hardware/device dependencies remain |


## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Create Pull Request

### Code Standards
- Follow existing code style
- Add comments for complex logic
- Test all API endpoints
- Update documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Supabase - Backend database and authentication
- Express.js - Web framework
- Flutter - Mobile app framework
- Docker - Containerization platform

---

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section above
- Review the API documentation

Built with for smart libraries! 
