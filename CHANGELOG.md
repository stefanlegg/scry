# Changelog

All notable changes to Scry will be documented in this file.

## [Unreleased]

## [0.1.0] - 2026-02-28

### Added
- Menu bar app showing running dev servers (ports 3000-9999)
- Display working directory and git branch
- **Monorepo-aware labeling** — shows "heyblathers/web" not just "web"
- Quick actions: Open in browser, copy URL, open in Finder/Terminal/VS Code
- Kill process from menu
- **Restart process** — kill and re-run with Terminal or background mode
- Pin favorite projects (persist across restarts)
- Watch projects for crash notifications
- Global hotkey (⌥⇧S) to toggle menu
- Configurable refresh interval (5s-60s, default 15s)
- Configurable excluded ports with labels (AirPlay, Discord, Raycast, etc.)
- Configurable port range
- Theme support (Default, Minimal)
- Settings window with hotkey recorder
- Launch at login option (with SMAppService sync)
- GitHub Actions CI with test suite (28 tests)
- Raycast extension (list/open/kill commands)

### Fixed
- Layout jitter on hover (rows now use stable sizing)
- Refresh button no longer causes layout shift
