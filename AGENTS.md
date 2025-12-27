# Repository Guidelines

## Project Structure & Module Organization
- `backend/` contains the Spring Boot API (`src/main/java/com/goalapp/` for controllers, services, repositories, entities, DTOs, and exceptions).
- `backend/src/test/java/com/goalapp/` holds unit and integration tests (tagged `integration`).
- `frontend/` contains the Flutter app:
  - `frontend/lib/core/` (constants, services, theme)
  - `frontend/lib/data/` (models, providers)
  - `frontend/lib/presentation/` (screens, widgets)
  - tests live in `frontend/test/` and `frontend/test/integration/`.
- Root scripts and guides (e.g., `run-all-tests.bat`, `SUPABASE_SETUP.md`) live at the repository root.

## Build, Test, and Development Commands
- Backend run: `cd backend` then `./gradlew bootRun` (Windows: `..\gradlew.bat bootRun`) to start the API on `http://localhost:8080`.
- Backend tests: `./gradlew test`, `./gradlew integrationTest`, `./gradlew jacocoTestReport` for coverage.
- Backend quality gate: `./gradlew check` enforces Jacoco coverage (80% minimum).
- Frontend run: `cd frontend` then `flutter pub get` and `flutter run`.
- Frontend tests: `flutter test` and `flutter test integration_test/`.
- Frontend dev scripts (Windows): `run-dev.bat`, `run-local.bat`, `run-prod.bat`.
- Full suite (Windows): `run-all-tests.bat` at repo root.

## Coding Style & Naming Conventions
- Java: keep packages under `com.goalapp`, classes in `PascalCase`, and follow Spring layering (controller/service/repository/entity).
- Dart: use `lower_snake_case.dart` file names, classes in `PascalCase`, and follow `flutter_lints` (`frontend/analysis_options.yaml`).
- Prefer the default formatters for each stack (`dart format` and IDE/Gradle defaults for Java), and run `flutter analyze` before PRs.

## Testing Guidelines
- Backend uses JUnit 5, Mockito, and Spring Boot Test; integration tests live under `src/test/java/com/goalapp/integration`.
- Frontend uses `flutter_test` and `integration_test` under `frontend/test/` and `frontend/integration_test/`.
- Target coverage is 80%+ on the backend (`jacocoTestReport`).

## Commit & Pull Request Guidelines
- Commit messages in history are short, imperative, and capitalized (e.g., "Add Render sleep prevention..."). Keep subjects concise without prefixes.
- PRs should include a brief summary, testing notes, and screenshots for UI changes.

## Configuration & Deployment Notes
- Environment setup is documented in `ENVIRONMENT_CONFIG_GUIDE.md` and `SUPABASE_SETUP.md`.
- Deployment references: `RAILWAY_DEPLOYMENT_GUIDE.md` and `RENDER_DEPLOYMENT_GUIDE.md`.
- Backend profiles live under `backend/src/main/resources/application-*.yml` (Supabase config in `application-supabase.yml`).
- API base URL for Flutter is defined in `frontend/lib/core/constants/api_endpoints.dart`.
