# 🖥️ Smart Library Admin Web Dashboard

A responsive, high-performance web dashboard engineered for library front-desk administrators, supervisors, and campus staff. Built with modern **HTML5**, **Vanilla ES6+ JavaScript**, **Tailwind CSS**, and **Glassmorphism CSS3 aesthetics**, this client provides real-time occupancy monitoring, an interactive 350-seat 2D floorplan visualization, high-speed software scan processing, live student duration tracking, and comprehensive administrative controls.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
- [System Architecture & File Structure](#-system-architecture--file-structure)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [Configuration Settings](#-configuration-settings)
- [Usage / Quickstart Guide](#-usage--quickstart-guide)
  - [Live Dashboard & Occupancy Metrics](#-live-dashboard--occupancy-metrics)
  - [Interactive 350-Seat Map Floorplan](#-interactive-350-seat-map-floorplan)
  - [Software Scan Station](#-software-scan-station)
  - [Live Student Occupants Table](#-live-student-occupants-table)
  - [System Reset](#-system-reset)
  - [Dark / Light Theme Toggle](#-dark--light-theme-toggle)
- [Offline Demo Fallback Mode](#-offline-demo-fallback-mode)
- [Troubleshooting & CORS Setup](#-troubleshooting--cors-setup)
- [Contributing Guidelines](#-contributing-guidelines)
- [License](#-license)

---

## 📖 Project Overview

The **Admin Web Dashboard** provides real-time visibility and management capabilities for the **Smart Library Management System**. Designed for seamless front-desk operations on desktop monitors, tablets, and kiosks, it communicates directly with the Node.js REST API while featuring an automatic 5-second polling loop and resilient offline demo capabilities.

### Core Objectives:
1. **Instant Occupancy Telemetry:** Monitor real-time occupied vs. available seats across the 350-seat library capacity.
2. **Interactive 2D Floorplan:** Inspect desk-level occupancy in real time with hover tooltips and rich student profile modals.
3. **Rapid Check-In/Out Scanning:** Process student entries and exits via software barcode/QR scanners or direct keyboard input.
4. **Audit Trail & Active Durations:** Track dynamic ticking study session elapsed times and chronological scan event logs.

---

## ✨ Key Features

- **📊 Live Hero Metrics Cards:** Displays Total Capacity (350), Occupied Seats, Available Seats, and a dynamically styled Occupancy Percentage bar.
- **🗺️ Interactive 10×10 Seat Map Grid (350 Seats):**
  - Divided into 4 distinct library study zones (Zones 1–4).
  - Desk coordinate system (Rows A–J, Columns 1–10).
  - Cubic-bezier spring physics on hover (`translateY(-5px) scale(1.10)`).
  - Interactive Filter Tabs: `All (350)`, `Available (X)`, `Occupied (Y)`.
  - Floating high-performance popover tooltip (`#seatTooltip`) showing desk ID, zone, student name, and study duration.
  - Interactive **Seat Details Modal** displaying full student profiles and a "Select in Scanner" shortcut.
- **⚡ Fast Software Scan Station:**
  - Autofocused scan input supporting optical barcode/QR scanners and manual keyboard entry.
  - Instant audio-visual confirmation toasts for `ENTRY` (emerald) and `EXIT` (amber).
  - Duplicate scan cooldown detection and informative error messaging.
- **⏱️ Live Student Occupants Directory:**
  - Real-time table listing all students currently inside the library.
  - Student avatar generation with dynamic course badges (e.g., `B.Tech CSE`, `MBA`, `BCA`).
  - Real-time ticking elapsed study timers.
  - Fast search filter by Student Name or ID.
- **📜 Chronological Scan Activity Feed:** Live stream of recent check-in/out events with relative timestamps.
- **🌓 Modern Glassmorphism & Dark Mode:** Sleek design with backdrop blur, tailored dark/light color palettes, and persistent theme preferences.
- **🔄 Auto-Sync & Dual-Mode Resilience:** Auto-refreshes every 5 seconds; seamlessly degrades to a local demo simulation if the backend API is temporarily offline.

---

## 🏗 System Architecture & File Structure

```
admin-web/
├── index.html              # Main single-page web dashboard markup
├── css/
│   └── custom.css          # Custom Glassmorphism, animations, seat grid, & dark mode styles
├── js/
│   ├── config.js           # Central configuration, timing intervals, endpoints, & demo mock data
│   ├── api.js              # Fetch API HTTP client, error handlers, and offline demo fallback
│   ├── ui.js               # DOM manipulation, seat map rendering, modals, tooltips, & themes
│   └── main.js             # Application lifecycle, polling loop, event listeners, & initialization
├── assets/                 # Icons, illustrations, and static visual assets
└── README.md               # Comprehensive Admin Web Panel documentation
```

### Module Responsibilities:
```
┌────────────────────────────────────────────────────────────────────────┐
│                        index.html (Single Page App)                    │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         ▼                           ▼                           ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   config.js      │       │     api.js       │       │      ui.js       │
│ - API Base URL   │       │ - HTTP Requests  │       │ - DOM Rendering  │
│ - Endpoints      │◀──────│ - Fallback Engine│◀──────│ - Seat Map Grid  │
│ - Timer Speeds   │       │ - Error Handling │       │ - Modals/Toasts  │
└──────────────────┘       └──────────────────┘       └──────────────────┘
                                     ▲
                                     │ Event Loop & Auto-Poll
                           ┌─────────┴────────┐
                           │     main.js      │
                           │ - Lifecycle Init │
                           │ - 5s Polling     │
                           │ - Event Bindings │
                           └──────────────────┘
```

---

## 💻 Tech Stack

- **Markup & Layout:** HTML5 Semantic Structure
- **Styling Framework:** [Tailwind CSS](https://tailwindcss.com/) (loaded via CDN with customized color tokens)
- **Typography & Icons:** [Google Fonts Inter](https://fonts.google.com/specimen/Inter) & [Font Awesome 6](https://fontawesome.com/)
- **Core Logic:** Vanilla JavaScript (Modern ES6+ Classes, Async/Await, Modular Pattern)
- **Design Enhancements:** Custom CSS3 Glassmorphism (`backdrop-filter: blur`), Spring Animations, and Dark Mode CSS Variables

---

## 📋 Prerequisites

The Admin Web Panel is a static web application and requires no build tools or package managers to execute.

You only need:
- A modern web browser: **Google Chrome**, **Mozilla Firefox**, **Apple Safari**, or **Microsoft Edge**.
- A local lightweight static HTTP server (e.g., Python 3, Node.js `serve`, or VS Code Live Server).

---

## ⚙️ Installation & Setup

### 1. Navigate to the Admin Web Directory
```bash
# From the repository root
cd admin-web
```

### 2. Launch a Local Web Server

Choose any of the following lightweight CLI commands to serve the static files:

#### Option A: Using Python 3 (Built-in)
```bash
python -m http.server 8080
```

#### Option B: Using Node.js `npx serve` (Zero install)
```bash
npx serve -l 8080 .
```

#### Option C: Using Node.js `http-server`
```bash
npx http-server -p 8080 -c-1
```

#### Option D: Using PHP (Built-in)
```bash
php -S localhost:8080
```

### 3. Open in Your Browser
Navigate to:
```
http://localhost:8080
```

---

## 🔧 Configuration Settings

All runtime parameters are centralized in [`admin-web/js/config.js`](file:///d:/SLproject/Smart-Library/admin-web/js/config.js).

```javascript
const CONFIG = {
    // Backend API Base URL
    API_BASE_URL: 'http://localhost:3000/api',

    // Timing Intervals (in milliseconds)
    REFRESH_INTERVAL: 5000,          // 5 seconds auto-refresh loop
    TOAST_DURATION: 3000,             // Toast notification visibility
    SCAN_RESULT_DURATION: 5000,       // Duration to display scan banner
    CLOCK_UPDATE_INTERVAL: 1000,      // 1-second live clock update

    // Capacity & Grid Matrix Configuration
    TOTAL_SEATS: 350,                 // Library total capacity
    SEAT_GRID_ROWS: 10,               // Grid rows (A–J)
    SEAT_GRID_COLS: 10,               // Grid columns (1–10)

    // API Route Endpoints
    ENDPOINTS: {
        LIBRARY_STATUS: '/status',
        SCAN: '/scan',
        STUDENTS_INSIDE: '/students-inside',
        SCAN_LOGS: '/scan-logs',
        ADMIN_RESET: '/reset',
        HEALTH: '/health',
        SEATS: '/seats'
    }
};
```

---

## 🚦 Usage / Quickstart Guide

### 📊 Live Dashboard & Occupancy Metrics
- The top hero cards dynamically display **Total Capacity (350)**, **Occupied Seats**, and **Available Seats**.
- The occupancy percentage badge updates its color dynamically:
  - 🟢 **Green (< 60%):** Ample seating available.
  - 🟡 **Yellow (60% - 85%):** Moderate capacity.
  - 🔴 **Red (> 85%):** High occupancy / Near capacity.

### 🗺️ Interactive 350-Seat Map Floorplan
- **Zone Navigation:** Click zone tabs (Zone 1, Zone 2, Zone 3, Zone 4) to navigate across the library floorplan.
- **Seat Filtering:** Click **All (350)**, **Available (X)**, or **Occupied (Y)** to highlight specific seats.
- **Hover Inspection:** Hover over any seat to reveal a floating tooltip with student information and session duration.
- **Detailed Modal:** Click any occupied seat to open the modal containing full student enrollment details and session duration.

### ⚡ Software Scan Station
1. Click the **Scan Input Field** (or scan with a USB/Bluetooth barcode reader).
2. Enter a student ID (e.g. `STU001` or `25101210443`) and press <kbd>Enter</kbd> or click **Submit Scan**.
3. **First Scan:** Registers student as `INSIDE` (`ENTRY` confirmed).
4. **Second Scan:** Registers student as `OUTSIDE` (`EXIT` confirmed).

### 👥 Live Student Occupants Table
- Displays student avatars, names, IDs, courses, and check-in timestamps.
- **Live Duration Ticker:** Ticking elapsed time displays how long each student has been studying.
- **Search Bar:** Type in the search box to filter active occupants in real time.

### 🔄 System Reset
- Click the **Emergency Reset** button in the header or control card.
- Confirm the modal prompt to reset library occupancy to zero and mark all students as `OUTSIDE`.

### 🌓 Dark / Light Theme Toggle
- Click the **Theme Toggle Button** in the top navigation bar to switch between Dark and Light modes instantly. Preferences are saved automatically in `localStorage`.

---

## 🛡️ Offline Demo Fallback Mode

If the backend server (`http://localhost:3000/api`) is offline or unreachable:
1. The **System Status** indicator will transition to **System Offline (Demo Mode)**.
2. The dashboard automatically switches to simulated local state, allowing administrators to test scans, seat map interactions, and search filters without throwing unhandled exceptions.
3. Once the backend comes online, the system automatically detects the connection and synchronizes with real cloud data.

---

## 🛠 Troubleshooting & CORS Setup

### 1. "Failed to fetch" or CORS Error in Console
- **Cause:** The backend API at `http://localhost:3000` is blocking requests from `http://localhost:8080`.
- **Solution:** Ensure the backend `server.ts` includes `cors` middleware allowing origin `http://localhost:8080`:
  ```typescript
  app.use(cors({
    origin: ['http://localhost:8080', 'http://127.0.0.1:8080'],
    credentials: true
  }));
  ```

### 2. Live Occupancy Not Updating
- Verify the backend server is running:
  ```bash
  curl http://localhost:3000/api/health
  ```
- Check the browser Developer Tools Console (<kbd>F12</kbd>) for network error codes.
- Perform a hard refresh: <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> (Windows) or <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> (macOS).

---

## 🤝 Contributing Guidelines

1. **Fork the Repository** and create a feature branch (`git checkout -b feature/admin-ui-enhancement`).
2. **Follow Vanilla ES6 Clean Architecture:**
   - Keep API logic in `js/api.js`.
   - Keep DOM and render logic in `js/ui.js`.
   - Keep lifecycle management in `js/main.js`.
   - Avoid inline JavaScript event handlers in HTML.
3. **Validate Responsiveness & Themes:** Test across mobile, tablet, and desktop viewports in both Light and Dark modes.
4. **Submit a Pull Request:** Provide a clear description and UI screenshots of your improvements.

---

## 📄 License

This project is licensed under the **ISC License**. See the root [LICENSE](../LICENSE) file for details.
