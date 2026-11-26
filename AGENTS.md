# Repository Guidelines

## Project Structure & Module Organization

Track & Trace is Ziska Pharma's Flutter product-verification app. Consult `final.md` for architecture and `docs/protectb-api/` for backend contracts.

- `lib/app/`: bootstrap, dependency injection, routing, and configuration.
- `lib/features/<feature>/`: `data/`, `domain/`, and `presentation/` layers. Keep domain logic pure Dart; presentation depends on domain interfaces, never data implementations.
- `lib/core/`: shared infrastructure and plugin wrappers; `lib/shared/`: design tokens and reusable widgets.
- `lib/l10n/`: English/Bangla ARB files and generated localizations.
- `test/`: mirrors application modules; `test/fakes/` supplies doubles; `test/flow/` exercises complete app flows.
- `android/` and `ios/`: platform projects and native assets; `figma/`: design references; `tool/`: utilities.

## Build, Test, and Development Commands

Use Flutter 3.41.9 (`.fvmrc`), JDK 17 for Android, and Xcode on macOS for iOS. With FVM, run `fvm use` and prefix Flutter/Dart commands with `fvm`.

- `flutter pub get`: install locked dependencies.
- `flutter run --flavor mock --dart-define-from-file=config/mock.json`: launch against the Postman mock server.
- `flutter gen-l10n`: regenerate translations after ARB changes.
- `dart run build_runner build --delete-conflicting-outputs`: regenerate Freezed/JSON code after model changes.
- `dart format --output=none --set-exit-if-changed lib test`: check formatting.
- `flutter analyze`: run static analysis.
- `flutter test`: run automated tests; use `flutter test test/flow/` for flows only.
- `flutter build apk --debug --flavor mock --dart-define-from-file=config/mock.json`: build the CI Android artifact.

## Coding Style & Naming Conventions

Use two-space indentation, `snake_case.dart` filenames, `UpperCamelCase` types, and `lowerCamelCase` members. Format with `dart format lib test`; follow `very_good_analysis` in `analysis_options.yaml`. Reuse shared design tokens and constructor-injected services. Regenerate and commit generated files; do not hand-edit `*.g.dart`, `*.freezed.dart`, or `lib/l10n/generated/`.

## Testing Guidelines

Name tests `*_test.dart`. Use `flutter_test`, `bloc_test`, and existing fakes/mock adapters; automated tests must avoid real networks and plugins. Validate API contracts against Postman examples. Domain services aim for full branch coverage; CI has no numeric coverage gate. Follow `docs/test-plan.md` and `docs/manual-test-checklist.md` for device checks.

## Commit & Pull Request Guidelines

No commits exist yet. Use concise, imperative commit subjects, optionally scoped (e.g., `fix(auth): prevent duplicate submissions`). PRs should explain behavior changes, link relevant issues/spec sections, include test results, and attach screenshots for UI changes. Pass CI formatting, analysis, tests, and mock-build checks.

## Security & Configuration

Match `mock`, `staging`, or `live` flavors with `config/<flavor>.json`. Keep API URLs HTTPS. Never commit credentials or log passwords, tokens, or hidden product codes.
