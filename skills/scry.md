---
name: scry
description: List running dev servers on this machine
---

Run `scry ls --json` to discover all running development servers on this machine.

The output includes:
- **servers**: Array of all running dev servers with pid, port, name, displayName, framework, gitRoot, gitBranch, workingDirectory, and command
- **groups**: Servers grouped by git root, so you can see which servers belong to the same repository/monorepo

Use this to:
- Find what port a project is running on
- Discover all servers in a monorepo
- Check which git branch a running server is on
- Identify the framework (next, vite, flask, django, rails, etc.) of each server

You can also filter by port: `scry ls --json --port 3000`
