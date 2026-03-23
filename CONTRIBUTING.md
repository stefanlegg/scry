# Contributing to Scry

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15+ or Swift 5.9+

## Build and run

```bash
# Menu bar app
swift build --product Scry
.build/debug/Scry

# CLI
swift run scry ls
swift run scry -- ls --json

# Run tests
swift test
```

## Test the MCP server

Pipe JSON-RPC messages over stdin:

```bash
swift build --product scry-mcp

MSG='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"0.1.0"}}}'
CALL='{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"list_dev_servers","arguments":{}}}'

{
  printf "Content-Length: %d\r\n\r\n%s" ${#MSG} "$MSG"
  printf "Content-Length: %d\r\n\r\n%s" ${#CALL} "$CALL"
} | .build/debug/scry-mcp
```

## Create app bundle

```bash
./scripts/build.sh
open .build/Scry.app
```

## Project structure

```
scry/
├── Package.swift
├── Sources/
│   ├── ScryKit/                          # Shared library (Foundation only)
│   │   ├── Models/
│   │   │   ├── DevProcess.swift          # Process data model
│   │   │   └── FrameworkDetector.swift    # Framework detection
│   │   └── Services/
│   │       └── ProcessScanner.swift      # lsof + git detection
│   ├── ScryApp/                          # Menu bar app
│   │   ├── ScryApp.swift                 # Main app entry
│   │   ├── Info.plist                    # LSUIElement (no dock)
│   │   ├── Services/
│   │   │   ├── ProcessManager.swift      # State + actions
│   │   │   ├── PinnedProjectsStore.swift # Favorites persistence
│   │   │   ├── CrashNotifier.swift       # Crash notifications
│   │   │   ├── SettingsStore.swift        # Settings persistence
│   │   │   └── SettingsWindowController.swift
│   │   ├── Theme/
│   │   │   ├── ScryTheme.swift           # Theme protocol
│   │   │   └── Components.swift          # Styled components
│   │   └── Views/
│   │       ├── MenuBarView.swift         # Main menu content
│   │       ├── ProcessRowView.swift      # Process row views
│   │       └── SettingsView.swift        # Settings UI
│   ├── ScryCLI/                          # CLI tool
│   │   └── ScryCLI.swift
│   └── ScryMCP/                          # MCP server
│       ├── main.swift
│       └── ScryMCPServer.swift
├── skills/
│   └── scry.md                           # Claude Code skill
├── raycast-extension/                    # Raycast integration
└── scripts/
    ├── build.sh
    └── run.sh
```

## Architecture

The package is split into four targets:

- **ScryKit** — shared library with the process scanner, models, and framework detector. Foundation only, no AppKit/SwiftUI. This is what the CLI and MCP server depend on.
- **ScryApp** — the menu bar app. Depends on ScryKit + AppKit/SwiftUI.
- **ScryCLI** — the `scry` CLI. Depends on ScryKit + swift-argument-parser.
- **ScryMCP** — the MCP server. Depends on ScryKit only. Implements minimal JSON-RPC over stdio.
