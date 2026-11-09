# Tomate

Pomodoro menu bar app, SwiftUI + AppKit, Swift Package, macOS 26+, no dependencies.

- Build: `swift build` · app: `./build.sh [--install]`
- Reference design: https://claude.ai/artifact/UjT7bxUwUCefHzjQi9NUb3 (capsule = proposal B)
- Everything `@MainActor`, strict Swift 6: zero warnings.
- UI strings in French.
- Landing page: `landingpage/index.html` (static, English), deployed to GitHub Pages by `.github/workflows/pages.yml` on push to `main`.
- Documentation (README, CLAUDE.md, docs) and code comments are always in English.

## Debug (env vars)

- `TOMATE_SECONDS_PER_MINUTE=1`: 1 min = 1 s
- `TOMATE_AUTOSTART=1`: starts the active mode
- `TOMATE_SNAPSHOT_DIR=/path`: renders every view to PNG then quits (only reliable way to check the UI: screencapture blurs other apps)
