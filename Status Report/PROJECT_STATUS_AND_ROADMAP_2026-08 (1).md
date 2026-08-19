# Smart Library Project Status and Roadmap (August 2026)

## Snapshot (Main Branch Baseline)

- **Date:** 2026-08
- **Repository:** `Smart-Library`
- **Current branch (now):** `main`
- **Main sync status (local):** `main` is currently **behind `origin/main` by 9 commits** and can be fast-forwarded.
- **Historical note:** Earlier in this session, switching to `main` initially failed with: **"Permission denied and could not request permission from user"**. This was later resolved and checkout to `main` succeeded.

---

## 1) What is Completed

### Backend API foundation is implemented (Express + TypeScript)

Backend routes and controllers are in place for core operations, including:

- `GET /api/health`
- `GET /api/status`
- `POST /api/scan`
- `GET /api/students-inside`
- `GET /api/scan-logs`
- `GET /api/student/:studentId`
- `GET /api/seats`
- `POST /api/reset`

Key implementation points observed:
- API bootstrap in `backend/src/server.ts`
- Route wiring in `backend/src/routes/library.routes.ts`
- Core logic (scan processing, reset, seat map generation) in `backend/src/controllers/library.controller.ts`

### Supabase-backed backend is active

- Backend DB layer uses Supabase client (`@supabase/supabase-js`) in `backend/src/config/database.ts`.
- Startup validates/initializes `library_config`.
- Main data model and runtime behavior are aligned with Supabase usage.

### Admin web panel is present and integrated with backend

`admin-web/` includes:
- `index.html`
- `js/main.js`, `js/api.js`, `js/ui.js`, `js/config.js`
- `css/custom.css`

Operational status from code:
- Pulls live data from backend (`status`, `students-inside`, `scan-logs`)
- Supports scan action and reset action
- Periodic refresh logic present
- Health/check and online/offline signaling logic included

### Flutter app base + role-based UX are implemented

App structure is substantial and includes:
- **Screens:** login, student dashboard/history/profile, multiple admin screens (overview, students, scanner, seat map, settings, etc.)
- **Providers:** `auth_provider.dart`, `library_provider.dart`, `theme_provider.dart`
- **Models/services/widgets** for status, logs, students, seat map, navigation

Seat-map-related implementation is already in code:
- Seat map endpoint constant (`/seats`) in Flutter API config
- `AdminSeatMapScreen` + `SeatMapWidget`
- `LibraryProvider.fetchSeatMap()`
- Supabase service method to generate seat-map data model

### CI/CD workflows exist

Detected workflows:
- `.github/workflows/ci.yml` (type-check, build, tests; smoke fallback if Supabase secrets absent)
- `.github/workflows/cd-backend-docker.yml` (build/push backend Docker image to GHCR on `main`)

### Main-branch framing

- This document is now written as a **main-branch restart brief**.
- Some implementation details in the repo indicate active feature-branch work had been happening in parallel before the pause; roadmap items below consolidate that work into a single continuation plan from `main`.

---

## 2) What Was In Progress

### Seat map navigation and pictograph flow

Seat map support is implemented but clearly in an active refinement phase (to be finalized through mainline merges/cleanup):
- Admin bottom navigation already includes a **Seats** tab.
- Admin overview includes a **“View Seat Map” quick-access** card navigating to that tab.
- Branch name (`feature/add-pictograpgh`) suggests current feature focus is pictograph/seat-map UX polish and completion.

### Cross-client alignment and stabilization

The project contains both:
- TypeScript backend route/controller architecture, and
- `backend/simple-server.js` fallback/debug path

This indicates ongoing convergence/stabilization work between modern TS backend and legacy/simple runtime mode that should be resolved in the next main-branch stabilization cycle.

---

## 3) What Needs To Be Done Next

### A. Documentation accuracy (high priority)

There is a **backend README drift risk**:
- `backend/README.md` currently mentions SQLite/better-sqlite3.
- Actual backend code is Supabase-based.

This mismatch can mislead setup, CI assumptions, and onboarding.

### B. Flutter analyzer cleanup (high priority)

`flutter_app/TODO_FIX.md` lists unresolved analyzer/lint tasks across multiple files (const usage, async context safety, deprecated APIs, etc.).

This should be completed before feature expansion to reduce regression risk.

### C. API contract consistency across clients (high priority)

Ensure all client surfaces (admin-web + Flutter) consistently consume:
- `/api/student/:studentId`
- `/api/seats`
- `/api/reset`
and reflect current response structures.

### D. Testing depth and reliability (medium-high)

- Expand endpoint coverage (especially seat map + reset + student detail flows).
- Validate behavior with/without Supabase CI secrets.
- Confirm branch-based workflow behavior and Docker publishing assumptions.

### E. Production hardening (medium)

- Error normalization and retry patterns in clients.
- Observability and operational docs (health checks, troubleshooting, failure modes).
- Security review for admin actions (e.g., reset endpoint guard strategy).

---

## 4) Prioritized Backlog

## P0 (Do first)
1. **Fix backend README Supabase/SQLite drift** and align all setup docs.
2. **Finish Flutter analyzer TODO list** (`flutter_app/TODO_FIX.md`) and run clean analyze.
3. **Validate and document full API contract** including `/api/student/:studentId` and `/api/seats`.
4. **Stabilize seat-map/pictograph user flow** in admin and Flutter UX.

## P1
5. Add/strengthen automated tests for reset, seat map, student detail, duplicate scan edge cases.
6. Improve CI feedback granularity and artifacts for failing suites.
7. Confirm CD readiness and release notes flow for backend image publishing.

## P2
8. Add role/permission strategy for privileged admin operations.
9. Improve real-time sync/refresh UX indicators across clients.
10. Prepare deployment runbook for staging/production lifecycle.

---

## 5) First-Week Restart Plan (Execution Plan)

### Day 1 — Repository and docs sanity pass
- Resolve branch context and access constraints (current branch remains `feature/add-pictograpgh`).
- Update backend docs to Supabase-first setup.
- Publish canonical endpoint table with request/response examples.

### Day 2 — Flutter quality cleanup
- Work through `flutter_app/TODO_FIX.md` by file group.
- Run analyzer until zero pending issues in current checklist.

### Day 3 — Seat map/pictograph completion sprint
- Finalize admin-seat navigation and seat details behavior.
- Verify provider/service paths and empty/error/loading states.

### Day 4 — API + integration test hardening
- Add/repair tests for student detail, seats, reset, and scan edge cases.
- Verify CI behavior with secret-present and secret-absent modes.

### Day 5 — Release readiness checkpoint
- Smoke-test backend + admin-web + Flutter integration.
- Update root README with latest architecture and supported workflows.
- Create a tagged status checkpoint for team handoff.

---

## 6) Four-Month Continuation Roadmap

## Month 1 — Stabilize and align
- Close documentation drift (backend + root docs).
- Complete Flutter analyzer cleanup and baseline quality gates.
- Lock API contracts and regression tests for all core endpoints.

**Exit criteria:** clean analyzer status, consistent docs, green CI on core backend paths.

## Month 2 — UX and feature completion
- Finalize seat-map pictograph interaction quality (admin + mobile parity where intended).
- Improve admin operational workflows (scan handling, reset confirmations, error transparency).
- Strengthen offline/connection handling paths in clients.

**Exit criteria:** stable seat-map experience and improved operator confidence in admin flows.

## Month 3 — Reliability and deployment maturity
- Expand automated tests (integration and high-value scenarios).
- Improve observability/troubleshooting docs and runtime diagnostics.
- Harden Docker/CD release process and rollback guidance.

**Exit criteria:** reproducible release flow and clear incident response playbook.

## Month 4 — Scale and governance
- Add stronger authorization policy around sensitive endpoints.
- Introduce environment-specific configuration standards (dev/staging/prod).
- Prepare pilot/rollout checklist for wider deployment.

**Exit criteria:** production governance baseline ready for broader adoption.

---

## 7) Current Risk Register (Short)

1. **Branch/access risk:** cannot switch to `main` currently due to permission barrier.
2. **Doc drift risk:** backend README still references SQLite while runtime uses Supabase.
3. **Quality debt risk:** Flutter analyzer TODO list still open.
4. **Consistency risk:** multiple backend runtime paths (TS server + simple server) require clear intended usage guidance.

---

## 8) Immediate Recommendation

Treat the next cycle as a **stabilization + alignment sprint**: docs correctness, analyzer cleanup, and seat-map feature completion first; then expand tests and release maturity.
