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

## Releases

Bump `CFBundleShortVersionString` in `Resources/Info.plist`, commit, then push a matching tag (`git tag v0.2.0 && git push origin v0.2.0`). `.github/workflows/release.yml` builds the app, zips it as `Tomate.zip` and publishes the GitHub Release. The landing page always links to the latest release's `Tomate.zip`.

## License

[MIT](LICENSE) © 2026 Dorian Kury
