# Library Management System - Setup Guide

## Prerequisites
- Docker Desktop only (no Node.js needed!)
- Download: https://www.docker.com/products/docker-desktop/

## Quick Start (Team Members)

```bash
# Clone repository
git clone <repo-url>
cd library-management-system

# Start backend (first time takes 2-3 mins)
docker-compose up

# Backend runs at: http://localhost:3000
```

## Daily Usage

Start backend:
```bash
docker-compose up
```

Stop backend:
```bash
docker-compose down
# or press Ctrl+C
```

View logs:
```bash
docker-compose logs -f backend
```

Rebuild after dependency changes:
```bash
docker-compose up --build
```

## For Flutter Developers

Backend API base URL:
- Localhost: `http://localhost:3000/api` 
- Android Emulator: `http://10.0.2.2:3000/api` 
- Physical Device: `http://YOUR_IP:3000/api` 

Find your IP:
- Windows: `ipconfig` 
- Mac/Linux: `ifconfig | grep inet` 

## Troubleshooting

**Port 3000 already in use:**
```bash
docker-compose down
```

**Fresh start:**
```bash
docker-compose down -v
docker-compose up --build
```

**Code changes not reflecting:**
- Check you're editing files in `backend/src/` 
- Nodemon should auto-restart

---

# 📚 Smart Library Project

The Smart Library project is a modern, technology-driven solution designed to transform traditional libraries into intelligent, efficient, and user-friendly spaces 🚀. By combining IoT hardware, student ID card scanning, and smart data management, this system automates library entry and exit while tracking real-time occupancy with high accuracy.

Each student scans their ID card while entering or leaving the library 🪪➡️⬅️. The system processes this data using a microcontroller-based setup, works offline inside the library, and later syncs securely with a centralized database 💾📡. This allows students and administrators to instantly view occupied and vacant seats through a digital portal 📊.

The Smart Library eliminates manual registers ✍️❌, prevents overcrowding 🚫👥, and ensures optimal space utilization. It improves the overall student experience while helping library staff manage resources more efficiently 🎯. Designed to be scalable, cost-effective, and reliable, this project supports the vision of smart campuses and digital education 🌐🏫.

Overall, the Smart Library project represents a step toward a smarter, faster, and more connected learning environment 💡📖


