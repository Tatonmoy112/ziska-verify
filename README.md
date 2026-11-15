# Track & Trace (Ziska Pharma)

The mobile app Ziska Pharma's officials use to check that products in shops
are genuine. Built in Flutter on the ProtectB `mobile-app-api`.

| Document | What it is |
|---|---|
| [`final.md`](final.md) | The app's architecture specification (the source of truth for the app) |
| [`docs/protectb-api/`](docs/protectb-api/) | The backend team's API guide, build guide, and Postman files (the source of truth for the backend) |
| [`figma/`](figma/) | Design exports |

## Requirements

- Flutter 3.41.9 (pinned in `.fvmrc`; with FVM run `fvm use`)
- JDK 17 for Android builds
- Xcode on macOS for iOS builds

## Run

Each flavor has its own app ID and its own configuration file. Android does
not allow a flavor named `test`, so the build for the backend's test server is
`staging`.

| Flavor | App ID | Configuration |
|---|---|---|
| `mock` | `com.ziskapharma.trackandtrace.mock` | `config/mock.json` (Postman mock server) |
| `staging` | `com.ziskapharma.trackandtrace.staging` | `config/staging.json` (ProtectB test server, `demo-pharma`) |
| `live` | `com.ziskapharma.trackandtrace` | `config/live.json` |

```sh
flutter pub get
flutter run --flavor mock --dart-define-from-file=config/mock.json
```

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

CI (`.github/workflows/ci.yml`) runs the same checks and a mock build on every
pull request.
