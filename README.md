# Scry

A dev server detective for macOS — menu bar app, CLI, and MCP server.

Scry finds running dev servers on your machine and surfaces them through three interfaces: a menu bar app for humans, a CLI for scripts and agents, and an MCP server for AI coding tools.

## Install

```bash
brew install --cask stefanlegg/tap/scry
```

This installs the menu bar app, `scry` CLI, and `scry-mcp` server.

## Menu Bar App

- Live status for all running dev processes (node, bun, deno, python, ruby, go, etc.)
- Framework detection (Next.js, Vite, Astro, Flask, Django, Rails, and 30+ more)
- Git branch and monorepo-aware labeling ("acme-store/web" not just "web")
- Pin favorites, crash notifications, one-click open/kill/restart
- Configurable refresh interval and port filters

## CLI

```bash
# Human-readable table
scry ls

# Structured JSON (grouped by git root)
scry ls --json

# Filter by port
scry ls --port 3000
```

Example output:

```
PORT    FRAMEWORK     NAME                      BRANCH            DIRECTORY
───────────────────────────────────────────────────────────────────────────
:4321   astro         stefanlegg.com            main              ~/Code/stefanlegg.com
:3000   next          myapp/web                 feat/dashboard    ~/Code/myapp/apps/web
:8000   django        backend                   main              ~/Code/backend
```

## MCP Server

The MCP server exposes a `list_dev_servers` tool that returns the same structured JSON as `scry ls --json`. Add to your Claude Code config (`.mcp.json`):

```json
{
  "mcpServers": {
    "scry": {
      "command": "scry-mcp"
    }
  }
}
```

Or for Cursor/other MCP clients, point to the binary path directly.

## Claude Code Skill

Copy `skills/scry.md` to your `.claude/commands/` directory to add a `/scry` command that wraps the CLI.

## How It Works

Scry detects dev processes by:
1. Scanning for processes listening on TCP ports (3000-9999 range) via `lsof`
2. Identifying dev-related processes (node, bun, deno, python, ruby, cargo, go)
3. Looking up the working directory via `lsof -p`
4. Getting the git repo root and branch via `git rev-parse`
5. Pattern-matching the command string to detect the framework

## Local Development

### Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15+ or Swift 5.9+

### Build and run

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

### Test the MCP server

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

### Create app bundle

```bash
./scripts/build.sh
open .build/Scry.app
```

## Project Structure

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

## License

MIT
