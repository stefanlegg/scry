# Scry - Raycast Extension 🔮

View and manage your running development servers from Raycast.

## Commands

### List Dev Servers
View all running dev servers with full details and actions.

**Actions:**
- ↵ Open in Browser
- ⌘C Copy URL
- ⌘O Open in Finder
- ⌘T Open in Terminal
- ⌘. Open in VS Code
- ⌘K Kill Process
- ⌘R Refresh

### Open Dev Server
Quick picker to open a server in your browser.

### Kill Dev Server
Quick picker to stop a running server.

## Installation

### From Raycast Store
Search for "Scry" in the Raycast Store.

### Manual Installation
```bash
cd raycast-extension
npm install
npm run dev
```

## Features

- 🟢 Real-time detection of dev processes
- 📁 Shows working directory for each process
- 🌿 Displays current git branch
- 🌐 One-click open in browser
- 📋 Copy localhost URL to clipboard
- 💻 Open in Terminal, Finder, or VS Code
- ☠️ Kill processes instantly

## How It Works

The extension scans for processes listening on TCP ports 3000-9999 (common dev server ports) and enriches them with:
- Working directory (via `lsof`)
- Git branch (via `git rev-parse`)

## Related

This extension is part of [Scry](https://github.com/stefanlegg/scry), a macOS menu bar app for dev server management. They share the same process detection logic and can be used together or separately.
