# 📱 Smart Library Mobile App (Flutter)

A cross-platform mobile application built with **Flutter** and **Dart** for the **Smart Library Management System**. The app delivers a modern, reactive experience featuring real-time seat occupancy tracking, an interactive 350-seat 2D floorplan visualization, mobile QR/barcode scanning, dynamic session timers, personal attendance histories, and dual role-based workflows for **Students** and **Library Administrators**.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
  - [Student Portal](#-student-portal)
  - [Admin Portal](#-admin-portal)
- [App Architecture & Navigation](#-app-architecture--navigation)
- [Tech Stack & Dependencies](#-tech-stack--dependencies)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [Environment Configuration & Network Setup](#-environment-configuration--network-setup)
- [Usage / Quickstart Guide](#-usage--quickstart-guide)
  - [Login Credentials & Roles](#-login-credentials--roles)
  - [Screen Walkthrough](#-screen-walkthrough)
- [State Management & Provider Structure](#-state-management--provider-structure)
- [Building for Production](#-building-for-production)
- [Testing & Code Quality](#-testing--code-quality)
- [Troubleshooting & FAQ](#-troubleshooting--faq)
- [Contributing Guidelines](#-contributing-guidelines)
- [License](#-license)

---

## 📖 Project Overview

The **Smart Library Flutter App** bridges library patrons and administrative staff with instant, real-time insights into library capacity and seating availability. By replacing manual check-in queues with camera-driven QR code scanning and direct cloud synchronization via Supabase and Node.js REST APIs, the app eliminates library overcrowding and streamlines campus access.

### Core Value Propositions:
- **For Students:** Check library availability before visiting, find open study desks across 4 floor zones, view personal attendance logs, and track real-time study session durations.
- **For Staff & Admins:** Monitor live occupancy thresholds, scan student IDs/QRs at library entry/exit gates, inspect detailed occupant profiles, and manage system states on the go.

---

## ✨ Key Features

### 🎓 Student Portal
- **Live Occupancy Dashboard:** Displays real-time occupied vs. available seats, occupancy percentage ring indicator, and library operational status.
- **Interactive 350-Seat Map (`StudentSeatsScreen`):** Explore a 10×10 desk matrix across 4 zones with live status coloring (Available, Occupied, Selected).
- **Interactive Seat Bottom Sheet:** Tap on any desk to view occupant details, course information, and live ticking elapsed study session durations.
- **Dynamic Session Tracker:** When checked in (`INSIDE`), the home screen displays an animated live timer showing active library time.
- **Personal Scan History:** Chronological history of all check-ins and check-outs with date badges, timestamps, and duration metrics.
- **Student Profile & Expiry Guards:** View student enrollment profile, degree/course, semester, and access expiry status.
- **Dark Mode Support:** Instant app-wide theme toggle (Light / Dark) with persistent preference storage.

### 🛡️ Admin Portal
- **Live Overview Dashboard:** Comprehensive telemetry showing total capacity (350), active occupants, available seats, and connection health.
- **Live Occupants List:** Searchable directory of all students currently inside with course badges, check-in timestamps, and elapsed times.
- **Camera QR Scanner (`AdminManualScannerScreen`):** High-speed optical QR code scanner with camera flip, torch control, and scan cooldown guards.
- **Manual Student ID Scanner:** Manual input fallback for quick check-in/out processing with instant visual feedback toasts.
- **Full Interactive Admin Seat Map:** Complete floorplan overview with quick-action triggers to inspect or scan specific desks.
- **System Controls & Emergency Reset:** Trigger system occupancy reset and configure operational thresholds directly from the app.

---

## 🏗 App Architecture & Navigation

```
                               ┌───────────────────────────┐
                               │   main.dart (Entry Point) │
                               │  - Supabase Initialization│
                               │  - MultiProvider Setup    │
                               └─────────────┬─────────────┘
                                             │
                                             ▼
                               ┌───────────────────────────┐
                               │        AuthWrapper        │
                               │  (Reactive Session State) │
                               └──────┬─────────────┬──────┘
                                      │             │
                User == null          │             │ User Authenticated
       ┌──────────────────────────────┘             └─────────────────────────────┐
       ▼                                                                          ▼
┌───────────────────────────┐                                      ┌───────────────────────────┐
│       LoginScreen         │                                      │       AppNavigation       │
│ - Student ID Login        │                                      │ (Bottom Navigation Bar)   │
│ - Admin Login Option      │                                      └──────┬─────────────┬──────┘
└───────────────────────────┘                                             │             │
                                              isAdmin == false            │             │ isAdmin == true
                                     ┌────────────────────────────────────┘             └────────────────────────────────────┐
                                     ▼                                                                                       ▼
                        ┌───────────────────────────────┐                                               ┌─────────────────────────────────┐
                        │        Student Screens        │                                               │          Admin Screens          │
                        ├───────────────────────────────┤                                               ├─────────────────────────────────┤
                        │ 1. StudentDashboardScreen     │                                               │ 1. AdminOverviewScreen          │
                        │ 2. StudentSeatsScreen         │                                               │ 2. AdminStudentsScreen          │
                        │ 3. StudentHistoryScreen       │                                               │ 3. AdminManualScannerScreen     │
                        │ 4. StudentProfileScreen       │                                               │ 4. AdminSeatMapScreen           │
                        └───────────────────────────────┘                                               │ 5. AdminSettingsScreen          │
                                                                                                        └─────────────────────────────────┘
```

---

## 💻 Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev/) (SDK `>=3.0.0 <4.0.0`)
- **Language:** [Dart](https://dart.dev/) (v3.x)
- **State Management:** [Provider](https://pub.dev/packages/provider) (`^6.1.1`)
- **Backend & Cloud:**
  - [supabase_flutter](https://pub.dev/packages/supabase_flutter) (`^2.3.0`)
  - [http](https://pub.dev/packages/http) (`^1.1.0`)
- **Camera & Scanning:** [mobile_scanner](https://pub.dev/packages/mobile_scanner) (`^3.5.2`)
- **Local Persistence:** [shared_preferences](https://pub.dev/packages/shared_preferences) (`^2.2.2`)
- **UI & Design System:**
  - [google_fonts](https://pub.dev/packages/google_fonts) (`^6.1.0`) — Modern Inter typography
  - [flutter_animate](https://pub.dev/packages/flutter_animate) (`^4.3.0`) — Smooth micro-interactions
  - [shimmer](https://pub.dev/packages/shimmer) (`^3.0.0`) — Content skeleton loaders
  - [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) (`^10.6.0`) & [cupertino_icons](https://pub.dev/packages/cupertino_icons)
  - [intl](https://pub.dev/packages/intl) (`^0.18.1`) — Date formatting
  - [flutter_svg](https://pub.dev/packages/flutter_svg) (`^2.0.9`)

---

## 📋 Prerequisites

Before running the Flutter application, ensure you have:

1. **Flutter SDK:** Version `3.16.0` or higher installed and added to your system `PATH`.
2. **Dart SDK:** Bundled with Flutter.
3. **IDE:** [VS Code](https://code.visualstudio.com/) (with Flutter & Dart extensions) or [Android Studio](https://developer.android.com/studio).
4. **Android / iOS Target:**
   - For Android: Android Studio with Android SDK, Command-line Tools, and an Android Emulator or physical device with USB Debugging enabled.
   - For iOS: macOS with Xcode 15+ and CocoaPods (`sudo gem install cocoapods`).
   - For Web: Google Chrome browser.

Run the Flutter health check:
```bash
flutter doctor
```
Ensure all required checkmarks (Flutter, Android toolchain, VS Code/Android Studio, Connected devices) are green.

---

## ⚙️ Installation & Setup

### 1. Navigate to the Flutter App Directory
```bash
cd flutter_app
```

### 2. Fetch Packages & Dependencies
```bash
flutter pub get
```

### 3. Verify Target Devices
Check which physical devices, simulators, or browser targets are detected:
```bash
flutter devices
```

---

## 🌐 Environment Configuration & Network Setup

The app connects to the Backend API and Supabase. You need to configure the correct base URL depending on your target device.

### 1. Configure Backend API Endpoint
Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // -------------------------------------------------------------
  // Set baseUrl based on your target platform:
  // -------------------------------------------------------------
  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  //
  // For iOS Simulator / Web / Desktop:
  // static const String baseUrl = 'http://localhost:3000/api';
  //
  // For Physical Mobile Devices (same Wi-Fi network as backend):
  static const String baseUrl = 'http://192.168.1.100:3000/api'; // Replace with your computer's IP

  static const String status = '/status';
  static const String scan = '/scan';
  static const String studentsInside = '/students-inside';
  static const String scanLogs = '/scan-logs';
  static const String seats = '/seats';
  static const String reset = '/reset';
  static const String health = '/health';

  static const Duration timeout = Duration(seconds: 10);
  static const Duration refreshInterval = Duration(seconds: 5);
}
```

> [!TIP]
> **Find your computer's Local IP:**
> - **Windows:** Run `ipconfig` in Command Prompt (look for IPv4 Address e.g. `192.168.x.x` or `172.x.x.x`).
> - **macOS / Linux:** Run `ifconfig` or `ip a` (look for `inet` under `en0` or `wlan0`).

### 2. Supabase Configuration
Verify `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'https://your-project-id.supabase.co';
  static const String anonKey = 'your-supabase-anon-key';

  static const String studentsTable = 'students';
  static const String scanLogsTable = 'scan_logs';
  static const String libraryConfigTable = 'library_config';
}
```

---

## 🚦 Usage / Quickstart Guide

### 1. Start the App via CLI

```bash
# Run on default connected device
flutter run

# Run specifically on Chrome (Web)
flutter run -d chrome

# Run specifically on Android Emulator
flutter run -d emulator-5554

# Run specifically on Windows Desktop
flutter run -d windows
```

---

### 🔑 Login Credentials & Roles

The app supports two authentication modes on the login screen:

| Role | Username / ID | Description |
| :--- | :--- | :--- |
| **Student** | `25101210443` *(or any 11-digit roll number)* | Automatically queries or auto-registers the student profile, loading their personal dashboard and scan history. |
| **Admin** | `ADMIN` *(case-insensitive)* | Unlocks administrative telemetry, high-speed camera QR scanner, student management, and system reset controls. |

---

### 📱 Screen Walkthrough

#### 🎓 Student Navigation Flow:
1. **Home Tab (`StudentDashboardScreen`):**
   - Live library capacity metrics ring.
   - Active study session duration timer with ticking clock.
   - Quick action to jump to seat reservations and view floor map.
2. **Seats Tab (`StudentSeatsScreen`):**
   - 10×10 Grid floorplan representing 350 seats across 4 zones.
   - Tap any seat to open the **Seat Details Bottom Sheet** with occupant information, student course, and entry timestamps.
3. **History Tab (`StudentHistoryScreen`):**
   - Chronological list of check-in (`ENTRY`) and check-out (`EXIT`) events with duration elapsed per visit.
4. **Profile Tab (`StudentProfileScreen`):**
   - Student ID, Name, Degree, Semester, Access Expiry date, and Theme Mode toggle.

#### 🛡️ Admin Navigation Flow:
1. **Overview Tab (`AdminOverviewScreen`):**
   - Global occupancy statistics, quick metrics, and live polling connection monitor.
2. **Students Tab (`AdminStudentsScreen`):**
   - Live list of students currently inside the library with dynamic session durations and course tags.
3. **Scanner Tab (`AdminManualScannerScreen`):**
   - Live optical camera scanner with instant QR recognition and manual student ID entry input.
4. **Seats Tab (`AdminSeatMapScreen`):**
   - Visual floorplan management and seat allocation status.
5. **Settings Tab (`AdminSettingsScreen`):**
   - Refresh intervals, connection test utilities, and Emergency System Reset trigger.

---

## 🧩 State Management & Provider Structure

The app leverages the `Provider` pattern for decoupled, reactive state management:

```
MultiProvider
├── ThemeProvider     -> Manages Light/Dark ThemeMode and SharedPreferences persistence.
├── AuthProvider      -> Manages active User session, role validation, and login/logout state.
└── LibraryProvider   -> Manages live occupancy metrics, seat map matrix, student lists, and auto-polling timers.
```

---

## 📦 Building for Production

### Android (APK & App Bundle)
```bash
# Build standalone release APK
flutter build apk --release

# Build Google Play App Bundle (.aab)
flutter build appbundle --release
```
*Output location:* `build/app/outputs/flutter-apk/app-release.apk`

### Web
```bash
flutter build web --release
```
*Output location:* `build/web/`

### iOS (macOS required)
```bash
flutter build ios --release
```

---

## 🧪 Testing & Code Quality

### Static Code Analysis
Run Flutter linter to verify code adherence to best practices:
```bash
flutter analyze
```

### Unit & Widget Tests
Execute Flutter unit and widget test suites:
```bash
flutter test
```

---

## 🛠 Troubleshooting & FAQ

### 1. "Connection refused" or `SocketException` on Mobile Device
- **Cause:** Mobile device cannot reach `localhost`.
- **Fix:** Update `lib/config/api_config.dart` with your machine's local Wi-Fi IP address (e.g. `http://192.168.1.100:3000/api`) and ensure your mobile device is connected to the exact same Wi-Fi network.

### 2. Camera scanner displays black screen on Android
- **Cause:** Missing camera permissions in Android Manifest.
- **Fix:** Ensure `android/app/src/main/AndroidManifest.xml` includes:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  ```

### 3. Gradle build errors on Android
- Clean and rebuild the Flutter workspace:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

---

## 🤝 Contributing Guidelines

1. **Fork the Repository** and branch off `main` (`git checkout -b feature/mobile-feature`).
2. **Adhere to Dart Style Guide:** Ensure formatting is clean (`dart format .`).
3. **Validate Code Quality:**
   ```bash
   flutter analyze
   flutter test
   ```
4. **Commit Changes:** Use descriptive commit messages (`feat: add seat search filter in student floorplan`).
5. **Submit a Pull Request:** Outline the UI/logic modifications and attach screenshots/recordings where applicable.

---

## 📄 License

Distributed under the **ISC License**. See the root [LICENSE](../LICENSE) for more details.
