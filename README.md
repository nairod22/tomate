# Tomate

Pomodoro timer in the macOS menu bar (macOS 26+). Blocking full-screen popup at the end of each phase.

Website: https://nairod22.github.io/tomate/

## Build from source

Requires macOS 26 and Xcode 26 (Swift 6.2). No dependencies.

```bash
./build.sh --install
open /Applications/Tomate.app
```

## Usage

- Click the capsule → pick a mode → **Démarrer** (Start).
- End of phase: sound + popup → **Passer à la pause** (Start break) / **Reprendre** (Resume) or **Snooze**.
- Settings (sliders icon): durations, cycles, sound, snooze, open at login.
- Shortcuts: Space = pause/resume, Return = popup action.

## Structure

```
Sources/Tomate/
  main.swift, AppDelegate.swift   # status item, popover, wiring
  Model/      # Preset, AppSettings (UserDefaults), TimerEngine
  Services/   # SoundPlayer, LoginItem
  UI/         # capsule, home, timer, settings, overlay
  Debug.swift # PNG rendering of views
build.sh      # release build → build/Tomate.app
landingpage/  # static landing page (GitHub Pages)
```

## Website

`landingpage/index.html`: static landing page, no build step. Every push to `main` touching `landingpage/` deploys it to GitHub Pages (`.github/workflows/pages.yml`).

## License

[MIT](LICENSE) © 2026 Dorian Kury
