# CLAUDE.md

## Project Overview

Animal Rescue is a Java Spring Boot sample application demonstrating VMware's opinionated approach to building applications with Tanzu products. It features a reactive Spring WebFlux backend with R2DBC (H2), a Node.js frontend, and Cypress end-to-end tests.

**Owner:** AndriyKalashnykov/animal-rescue

## Tech Stack

- **Backend:** Java 11, Spring Boot 2.5.5, Spring WebFlux, Spring Security (OAuth2 Resource Server), R2DBC with H2
- **Frontend:** Node.js 14.x, served separately
- **E2E Tests:** Cypress
- **Build:** Gradle (multi-project: backend, frontend, e2e)
- **CI:** GitHub Actions (`.github/workflows/main.yml`, `.github/workflows/cleanup-runs.yml`)

## Repository Layout

```
backend/          Spring Boot WebFlux backend (Gradle subproject)
frontend/         Node.js frontend application (Gradle subproject)
e2e/              Cypress end-to-end tests (Gradle subproject)
scripts/          Helper scripts (local.sh for dev lifecycle)
docs/             Documentation images
gradle/           Gradle wrapper files
build.gradle      Root Gradle build
settings.gradle   Multi-project settings (backend, frontend, e2e)
Makefile           Dev commands (build, test, run)
```

## Build & Test Commands

```bash
# Prerequisites: SDKMAN with Java 11.0.11.hs-adpt

# Build backend (skip tests)
make build-backend

# Run backend tests
make test-backend

# Run backend locally (no Tanzu Observability)
make run-backend

# Build frontend
make build-frontend

# Run frontend dev server
make run-frontend

# Run full e2e suite (backend + frontend + Cypress)
make run-e2e

# Start/stop the full app
make start-app
make stop-app

# Alternative script-based commands
./scripts/local.sh init          # install frontend + e2e dependencies
./scripts/local.sh start         # start auth server, frontend, backend
./scripts/local.sh ci            # run backend + e2e tests
./scripts/local.sh backend       # backend tests only
./scripts/local.sh e2e --quiet   # e2e tests headless
./scripts/local.sh stop          # stop all
```

## CI Workflows

- **main.yml** -- runs on push to `main`: backend tests, e2e tests, frontend/e2e lint
- **cleanup-runs.yml** -- weekly (Sunday midnight) + manual: deletes workflow runs older than 7 days

## Key Conventions

- Gradle multi-project build (`backend`, `frontend`, `e2e` subprojects)
- JaCoCo for test coverage reporting (XML + HTML)
- Spring Security with OAuth2 resource server; test accounts: `alice/test`, `bob/test`
- Frontend communicates with backend via REST API (`/animals`, `/animals/{id}/adoption-requests`)
