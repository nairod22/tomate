# Tomate

Pomodoro menu bar app, SwiftUI + AppKit, Swift Package, macOS 26+, no dependencies.

- Build: `swift build` · app: `./build.sh [--install]` · tests: `swift test`, run locally before every push and tag. CI does not run them: GitHub's macOS runners top out at Xcode 26.6 / Swift 6.3, whose compiler crashes building the app target in test mode.
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

## Toolchain workarounds (GitHub runner: Xcode 26.6 / Swift 6.3.3)

The release runner compiles with Swift 6.3.3, older than the local toolchain (Xcode 27 / Swift 6.4). Code below is written the way 6.3 accepts; restore the intended form once the `macos` runner ships Xcode 27 (check with `ls /Applications/Xcode*` in a workflow step). Search the code for `TOOLCHAIN WORKAROUND`.

- Passing a `@MainActor` view method as a `(Bool) -> Void` callback crashes 6.3 in IRGen (`SyncCallEmission::setArgs`, reabstraction thunk `$sSbScA_pSgIeAghyg_SbIeAghn_TR`), even in release builds. Wrap it in a closure instead.
  - `Settings/GeneralSection.swift`: intended `Binding(get: { launchAtLogin }, set: setLaunchAtLogin)`, workaround `set: { setLaunchAtLogin($0) }`.
  - `Settings/SoundSection.swift`: intended `Slider(..., onEditingChanged: volumeEditingChanged)`, workaround `onEditingChanged: { volumeEditingChanged($0) }`.
- `swift test` also crashes 6.3 (the app executable is rebuilt in test mode), so tests run locally only, never in CI.
