## 1.0.3

- Moved the template `HomeScreen` from `lib/presentation/home_screen.dart` directly into `main.dart` with a warning comment.
- Removed the top-level `presentation` directory from the scaffold project to keep `lib` aligned with core directories (`core`, `features`, `shared`).
- Updated the router module template to import `HomeScreen` from `main.dart`.

## 1.0.2

- Resolved path issues for global activation by dynamically tracking the package root from the library entry point.
- Kept the templates folder at the root of the project to prevent package compilation and static analysis issues.

## 1.0.1

- Mapped global executable to `zuq`.
- Added usage example.

## 1.0.0

- Initial version.
