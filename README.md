# Scry 🔮

A lightweight macOS menu bar app that shows your running dev servers at a glance.

**Etymology:** From Magic: The Gathering's *scry* mechanic — look at the top of your library and see what's coming.

## Features

- 🟢 **Live status** — See all running dev processes (node, bun, deno, python, ruby, go, etc.)
- 📁 **Project context** — Shows the git repo folder for each process
- 🌿 **Branch awareness** — Displays current git branch
- ⌨️ **Global hotkey** — Press `⌥⇧S` to toggle the menu from anywhere
- 📌 **Pin favorites** — Keep important projects at the top, reorderable
- 🔔 **Crash notifications** — Get notified when watched servers stop
- 🌐 **One-click open** — Launch in browser instantly
- 📋 **Copy URL** — Clipboard the localhost URL
- 💻 **Open anywhere** — Finder, Terminal, or VS Code
- ☠️ **Quick kill** — Stop processes without hunting for terminals
- 🔄 **Auto-refresh** — Configurable polling (5s-60s, default 15s)
- 🏷️ **Monorepo-aware** — Shows "heyblathers/web" not just "web"
- ⚙️ **Configurable filters** — Exclude ports/processes from detection

## Screenshots

```
┌─────────────────────────────────────────────────────┐
│  🔮 Scry                    ⌥⇧S         ⟳         │
├─────────────────────────────────────────────────────┤
│  📌 Pinned                                          │
│  ● heyblathers              :3000        🌐  ⋯     │
│    ~/Code/heyblathers  ·  🌿 main                  │
│                                                     │
│  ○ scry                    not running              │
│    ~/Code/scry                                      │
├─────────────────────────────────────────────────────┤
│  ⚡ Running                                         │
│  ● clawdbot-gateway         :8080        🌐  ⋯     │
│    ~/Code/clawdbot  ·  🌿 feat/import              │
├─────────────────────────────────────────────────────┤
│  Updated 5s ago                              Quit   │
└─────────────────────────────────────────────────────┘
```

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15+ or Swift 5.9+

## Building

### With Swift Package Manager

```bash
cd ~/Code/scry
swift build -c release

# Binary at .build/release/Scry
```

### Create App Bundle

```bash
./scripts/build.sh
open .build/Scry.app

# Install to Applications
cp -r .build/Scry.app /Applications/
```

### Development

```bash
swift run
```

## Raycast Extension

Scry also includes a Raycast extension for keyboard-driven workflow:

```bash
cd raycast-extension
npm install
npm run dev
```

**Commands:**
- `List Dev Servers` — Full list with all actions
- `Open Dev Server` — Quick open in browser
- `Kill Dev Server` — Quick stop a process

## How It Works

Scry detects dev processes by:
1. Scanning for processes listening on TCP ports (3000-9999 range)
2. Identifying dev-related processes (node, bun, deno, python, ruby, cargo, go)
3. Looking up the working directory for each process via `lsof`
4. Getting the git repo root via `git rev-parse --show-toplevel` (for monorepo-aware naming)
5. Getting the current branch via `git rev-parse --abbrev-ref HEAD`
6. Polling at configurable intervals (default 15 seconds)

## Project Structure

```
scry/
├── Package.swift
├── Sources/
│   ├── ScryApp.swift                     # Main app entry
│   ├── Info.plist                        # LSUIElement (no dock)
│   ├── Models/
│   │   └── DevProcess.swift              # Process data model
│   ├── Services/
│   │   ├── ProcessScanner.swift          # lsof + git detection
│   │   ├── ProcessManager.swift          # State + actions
│   │   ├── HotkeyManager.swift           # Global ⌥⇧S hotkey
│   │   ├── PinnedProjectsStore.swift     # Favorites persistence
│   │   ├── CrashNotifier.swift           # Crash notifications
│   │   ├── SettingsStore.swift           # Settings persistence
│   │   └── SettingsWindowController.swift
│   ├── Theme/
│   │   ├── ScryTheme.swift               # Theme protocol + implementations
│   │   └── Components.swift              # Styled components (StatusDot, etc.)
│   └── Views/
│       ├── MenuBarView.swift             # Main menu content
│       ├── ProcessRowView.swift          # Process + pinned row views
│       ├── SettingsView.swift            # Settings UI
│       └── HotkeyRecorderView.swift      # Hotkey capture UI
├── raycast-extension/                    # Raycast integration
│   ├── src/
│   │   ├── list-servers.tsx
│   │   ├── open-server.tsx
│   │   ├── kill-server.tsx
│   │   └── scanner.ts
│   └── package.json
├── docs/
│   ├── DESIGN_DIRECTION.md               # Design philosophy
│   └── SETTINGS_DESIGN.md                # Settings architecture
└── scripts/
    ├── build.sh
    └── run.sh
```

## License

MIT
