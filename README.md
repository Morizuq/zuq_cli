# Zuq CLI ⚡

**The flexible, boundary-enforcing scaffold tool for Flutter Clean Architecture.**

[![Pub Version](https://img.shields.io/pub/v/zuq_cli?color=blue)](https://pub.dev/packages/zuq_cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Zuq is a Dart CLI that scaffolds, extends, and audits Clean Architecture Flutter projects. It natively supports **BLoC**, **Riverpod**, and **Provider** for state management, and **GoRouter** or **AutoRoute** for routing — enforcing architectural boundaries through every step of development.

---

## Features

- **Flexible scaffolding** — bootstrap full project skeletons with your preferred state management and router. Includes `fintech` and `ecommerce` presets.
- **Boundary auditing** — `zuq doctor` statically analyzes your codebase and flags any layer that imports what it shouldn't. Designed for Git hooks and CI.
- **Modular installer** — add pre-configured modules (networking, storage, analytics, etc.) with a topological dependency resolver that handles install order and prevents cyclic bugs.
- **Feature generator** — scaffold a complete Clean Architecture slice (domain, data, presentation) with a single command.

---

## Installation

```bash
# Once published
dart pub global activate zuq_cli

# From local source
dart pub global activate --source path .
```

---

## Commands

### `zuq create` — Bootstrap a project

```bash
zuq create <project_name> [flags]
```

| Flag | Short | Values | Default | Description |
| :--- | :---: | :--- | :---: | :--- |
| `--state` | `-s` | `bloc` `riverpod` `provider` `none` | `none` | State management library |
| `--router` | `-r` | `go_router` `auto_route` | `go_router` | Routing solution |
| `--preset` | `-p` | `default` `fintech` `ecommerce` | `default` | Architectural template |
| `--platforms` | | `android` `ios` `web` `macos` `linux` `windows` | `android,ios` | Target platforms |

```bash
zuq create my_app --state bloc --router go_router --platforms android ios web
```

If flags are omitted in an interactive terminal, Zuq will prompt you.

---

### `zuq add feature` — Generate a feature slice

Generates a full Clean Architecture feature under `lib/features/<feature_name>`:

```bash
zuq add feature <feature_name>
```

```
lib/features/auth/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── state/        ← pre-populated with BLoC / Riverpod / Provider boilerplate
    └── widgets/
```

---

### `zuq add module` — Install a core module

Adds a pre-configured architectural module. Zuq reads your `zuq.yaml`, injects the right templates, and runs `flutter pub add` for you.

```bash
zuq add module <module_name>
```

| Module | Depends on | What it sets up |
| :--- | :--- | :--- |
| `networking` | `storage`, `analytics` | Dio client, interceptors, error handling |
| `storage` | — | Secure and local storage utilities |
| `routing` | — | Router setup based on your GoRouter/AutoRoute choice |
| `theme` | — | Dark/light mode token structure |
| `l10n` | — | Localization resource structure |
| `analytics` | — | Core telemetry tracking layout |

> **Topological ordering** — adding `networking` automatically installs `storage` and `analytics` first, in the correct order.

---

### `zuq doctor` — Audit architectural boundaries

Scans your `lib/features` directory and flags any layer importing what it's not allowed to.

```bash
zuq doctor
```

On a violation, Zuq outputs the file path, line number, and the offending import — then exits with code `1`.

**Enforced rules:**

```
Presentation  →  Domain     ✅
Data          →  Domain     ✅
Domain        →  Data        ✗
Domain        →  Presentation ✗
Presentation  →  Data        ✗
Data          →  Presentation ✗
```

- **Domain** must be completely framework-agnostic — no imports from `data` or `presentation`.
- **Presentation** may only import from `domain` (use cases, entities). Direct `data` layer imports are banned.
- **Data** may only import interfaces from `domain`. No `presentation` imports.

---

## Configuration — `zuq.yaml`

Created automatically on `zuq create`. Referenced by all subsequent `zuq add` commands.

```yaml
name: my_app
state_management: bloc
router: go_router
preset: default
modules:
  - storage
  - analytics
  - networking
```

---

## CI Integration

Add `zuq doctor` to your GitHub Actions workflow to block any PR that violates layer boundaries:

```yaml
name: Architecture Audit

on: [push, pull_request]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - name: Install Zuq CLI
        run: dart pub global activate zuq_cli
      - name: Run boundary audit
        run: zuq doctor
```

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push and open a pull request

Issues, state management integration requests, and improvements to the boundary engine are all welcome.

---

## License

MIT — see [LICENSE](./LICENSE) for details.