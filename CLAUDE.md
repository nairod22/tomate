# Tomate

Pomodoro menu bar app, SwiftUI + AppKit, Swift Package, macOS 26+, no dependencies.

- Build: `swift build` · app: `./build.sh [--install]` · tests: `swift test`
- Targets: `TomateCore` (timer state machine, scheduling, settings, formatting; no AppKit), `Tomate` (menu bar app), `TomateCoreTests` (Swift Testing, fake clock), `TomatePerfTests` (XCTest `measure` of the icon render).
- Energy rule: nothing ticks in the background. `TimerEngine` plans one wake-up per phase end on `ContinuousClock`; `MenuBarRefresher` redraws only when `MenuBarFace` changes (whole minutes, 40 wedge steps), zero wake-ups while idle/paused/awaiting. Per-second UI lives in `TimelineView` (popover only). Wake-up budgets in `WakeBudgetTests` guard this.
- Idle cost: `scripts/measure-idle.sh [label]` appends CPU/footprint per scenario to `scripts/measurements.csv`.
- Theme follows the landing page: blue `#009FE3` = work, ink = pause, no orange/red. Menu bar = landing tomato glyph (progress wedge, blue dot while running, pause bars when paused) + remaining whole minutes ("25 min", no seconds).
- Everything `@MainActor`, strict Swift 6: zero warnings.
- UI strings in French.
- Landing page: `landingpage/index.html` (static, English), deployed to GitHub Pages by `.github/workflows/pages.yml` on push to `main`.
- Documentation (README, CLAUDE.md, docs) and code comments are always in English.
- Distribution: no Apple Developer account, by choice. The app stays ad-hoc signed (`codesign --sign -`), with no Developer ID and no notarization. Users allow it once through System Settings → Privacy & Security → Open Anyway (steps in the README). Don't propose paid signing or notarization.
- Versioning: 0.x = public beta. Release = bump `CFBundleShortVersionString` in `Resources/Info.plist`, push tag `vX.Y.Z` (must match) → `.github/workflows/release.yml` builds and publishes `Tomate.zip`. Landing buttons link to `releases/latest/download/Tomate.zip`; keep that asset name.

## Debug (env vars)

- `TOMATE_SECONDS_PER_MINUTE=1`: 1 min = 1 s
- `TOMATE_AUTOSTART=1`: starts the active mode
- `TOMATE_AUTOPAUSE=1`: with autostart, pauses right away (idle measurements)
- `TOMATE_SNAPSHOT_DIR=/path`: renders every view to PNG then quits (only reliable way to check the UI: screencapture blurs other apps)
