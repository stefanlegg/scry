# Scry

You have 5 dev servers running across 3 repos and you can't remember which port is which. Scry finds them all and tells you what's running, where, and on what framework — from your menu bar, the terminal, or your AI coding agent.

One install, multiple interfaces. Use whichever fits your workflow.

## Install

```bash
brew install --cask stefanlegg/tap/scry
```

## Use it your way

### Menu bar app

Best for: always-on visibility without leaving your current context.

The app lives in your menu bar and shows every running dev server with its port, git branch, framework, and project name. Pin favorites, get crash notifications, open in browser, kill processes — all from the menu.

Launches automatically after install. No configuration needed.

### CLI

Best for: terminal workflows, scripts, automation, and piping into other tools.

```bash
scry ls
```

```
PORT    FRAMEWORK     NAME                      BRANCH            DIRECTORY
───────────────────────────────────────────────────────────────────────────
:4321   astro         stefanlegg.com            main              ~/Code/stefanlegg.com
:3000   next          myapp/web                 feat/dashboard    ~/Code/myapp/apps/web
:8000   django        backend                   main              ~/Code/backend
```

```bash
scry ls --json          # structured JSON, grouped by git root
scry ls --port 3000     # filter to a specific port
```

### MCP server

Best for: giving AI coding agents (Claude Code, Cursor, Windsurf, etc.) awareness of your running dev servers.

The MCP server exposes a `list_dev_servers` tool that returns the same structured data as `scry ls --json`. Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "scry": {
      "command": "scry-mcp"
    }
  }
}
```

Your agent can now ask "what's running?" and get back ports, frameworks, branches, and working directories in a single tool call.

### Claude Code skill

Best for: Claude Code users who want a quick `/scry` command.

Copy `skills/scry.md` to `.claude/commands/` and you get a `/scry` slash command that wraps the CLI.

## What it detects

**Runtimes:** Node.js, Bun, Deno, Python, Ruby, Go, Rust, Java, PHP

**Frameworks:** Next.js, Vite, Remix, Nuxt, Astro, SvelteKit, Gatsby, Express, Fastify, Flask, Django, FastAPI, Rails, Laravel, Phoenix, and more

**Context:** git branch, git root (monorepo-aware naming), working directory, full command

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local development setup, build instructions, and project structure.

## License

MIT
