# Tomate

Pomodoro timer in the macOS menu bar (macOS 26+). Blocking full-screen popup at the end of each phase.

Website: https://nairod22.github.io/tomate/

## Install

Tomate is in public beta (0.x) while it ships without an Apple Developer ID.

Download `Tomate.zip` from the [latest release](https://github.com/nairod22/tomate/releases/latest), unzip it, and move `Tomate.app` to `/Applications`. Tomate is not signed with an Apple Developer ID, so macOS blocks it the first time you open it. To allow it:

1. Try to open the app. A warning dialog says it can't be opened because it comes from an unidentified developer. Click **OK** or **Done**.
2. Open **System Settings** (Apple menu or Applications folder).
3. Click **Privacy & Security** in the sidebar.
4. Scroll down to the **Security** section. A message says Tomate was blocked.
5. Click **Open Anyway**.

You only need to do this once.

Or, from Terminal, remove the quarantine flag instead:

```bash
xattr -dr com.apple.quarantine /Applications/Tomate.app
```

## Build from source

Requires macOS 26 and Xcode 26 (Swift 6.2). No dependencies.

```bash
./build.sh --install
open /Applications/Tomate.app
```

Tests: `swift test`. Background cost: `scripts/measure-idle.sh`.

## Usage

- Click the tomato in the menu bar → pick a mode → **Démarrer** (Start). A blue dot means a session is running; pause bars mean it is paused. The menu bar shows the minutes left ("25 min").
- End of phase: sound + popup → **Passer à la pause** (Start break) / **Reprendre** (Resume) or **Snooze**.
- Settings (sliders icon): durations, cycles, sound, snooze, open at login.
- Shortcuts: Space = pause/resume, Return = popup action.

## Structure

```
Sources/TomateCore/     # no AppKit, fully unit-tested
  Timer/      # PomodoroSession (pure state machine), TimerEngine, clock + scheduler
  MenuBar/    # MenuBarFace, MenuBarSchedule (when to redraw), MenuBarRefresher
  Settings/   # Preset, AppSettings (UserDefaults)
  Format/     # display strings
Sources/Tomate/         # menu bar app
  App/        # main, AppDelegate, MenuBarController, debug env
  MenuBar/    # status icon rendering
  Popover/    # home and timer screens
  Settings/   # settings screen
  Overlay/    # full-screen popup at phase end
  Components/, Theme/, Services/ (sound, login item), Debug/ (PNG snapshots)
Tests/
  TomateCoreTests/   # transitions, sleep/wake, rapid actions, wake-up budgets
  TomatePerfTests/   # menu bar icon render cost
scripts/measure-idle.sh  # background CPU/memory, appended to scripts/measurements.csv
build.sh      # release build → build/Tomate.app
landingpage/  # static landing page (GitHub Pages)
```

## Website

`landingpage/index.html`: static landing page, no build step. Every push to `main` touching `landingpage/` deploys it to GitHub Pages (`.github/workflows/pages.yml`).

## Releases

Bump `CFBundleShortVersionString` in `Resources/Info.plist`, commit, then push a matching tag (`git tag v0.2.0 && git push origin v0.2.0`). `.github/workflows/release.yml` builds the app, zips it as `Tomate.zip` and publishes the GitHub Release. The landing page always links to the latest release's `Tomate.zip`.

## License

[MIT](LICENSE) © 2026 Dorian Kury
