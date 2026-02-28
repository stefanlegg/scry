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
- 🔄 **Auto-refreshes** — Updates every 5 seconds

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
4. Checking if it's a git repo and getting the branch name
5. Polling every 5 seconds for changes

## Project Structure

```
scry/
├── Package.swift
├── Sources/
│   ├── ScryApp.swift                 # Main app entry
│   ├── Info.plist                    # LSUIElement (no dock)
│   ├── Models/
│   │   └── DevProcess.swift
│   ├── Services/
│   │   ├── ProcessScanner.swift      # lsof + git detection
│   │   ├── ProcessManager.swift      # State + actions
│   │   ├── HotkeyManager.swift       # Global ⌥⇧S hotkey
│   │   ├── PinnedProjectsStore.swift # Favorites persistence
│   │   └── CrashNotifier.swift       # Crash notifications
│   └── Views/
│       ├── MenuBarView.swift
│       └── ProcessRowView.swift
├── raycast-extension/                # Raycast integration
│   ├── src/
│   │   ├── list-servers.tsx
│   │   ├── open-server.tsx
│   │   ├── kill-server.tsx
│   │   └── scanner.ts
│   └── package.json
└── scripts/
    ├── build.sh
    └── run.sh
```

## License

MIT
