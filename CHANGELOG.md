## 1.0.6

- Fixed `zuq create .` scaffolding in current directory: resolved broken package imports (`package:///...`) and empty project paths by adding `ProjectNameResolver` with automated Dart package identifier sanitization and discovery.
- Added `--name` (`-n`) flag to `zuq create` to allow overriding the package name when creating in the current directory or a subfolder.
- Decoupled `AppTypography` into an extensible `ThemeExtension` supporting runtime `GoogleFonts` resolvers, local `.ttf`/`.otf` asset fonts, and bidirectional synchronization with Flutter Material 3 `TextTheme`.
- Added `config` module providing type-safe `AppConfig`, `AppEnvironment` (`dev`, `stage`, `prod`), `--dart-define` compilation overrides, and tailored state management providers (`configProvider` for Riverpod, `ConfigCubit` for BLoC, `ConfigNotifier` for Provider, and `ConfigHolder` for None).
- Refactored networking module: removed empty `NetworkService` wrapper and hardcoded URLs in `NetworkConstants`; injected `AppConfig` and `SecureStorageService` into canonical `createDio` and provided idiomatic `dioProvider` across all supported state management solutions.
- Added `--version` (`-v`) global flag to print current CLI version.

## 1.0.5

- Added background update checking and `zuq upgrade` command to simplify CLI updates.
- Added customizable `features_path` config parameter to support alternative directory structures (such as `lib/modules` or `lib/src/features`) for both scaffolding and boundary doctor audits.
- Refactored `zuq init` configuration detection to dynamically parse and preserve existing `modules`, `presets`, and `features_path` properties without overwriting them.

## 1.0.4

- Split feature domain model into a pure domain entity and a serialization-aware model in the data layer.
- Added abstract repository interface to domain, repository implementation to data, and usecase execution to domain for clean architecture layout.
- Added interactive prompts for option flags (`--state`, `--router`, and `--preset`) during project creation if they are not supplied.

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
