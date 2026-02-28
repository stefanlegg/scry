# Changelog

All notable changes to Scry will be documented in this file.

## [Unreleased]

### Added
- Configurable refresh interval (5s, 10s, 15s, 30s, 60s) — default 15s
- Configurable excluded ports with labels
- Default exclusions for system services (AirPlay, Discord, Raycast, etc.)

### Fixed
- Layout jitter on hover (rows now use stable sizing)
- Refresh button no longer causes layout shift

## [0.1.0] - 2026-02-28

### Added
- Menu bar app showing running dev servers (ports 3000-9999)
- Display working directory and git branch
- Quick actions: Open in browser, copy URL, open in Finder/Terminal/VS Code
- Kill process from menu
- Pin favorite projects (persist across restarts)
- Watch projects for crash notifications
- Global hotkey (⌥⇧S) to toggle menu
- Configurable port range
- Theme support (Default, Minimal)
- Settings window with hotkey recorder
- Launch at login option
