import { execSync } from "child_process";
import type { DevProcess } from "./types";

const DEV_PORT_RANGE = { min: 3000, max: 9999 };
const ADDITIONAL_DEV_PORTS = new Set([80, 443, 8080, 8443]);

const DEV_PROCESS_TYPES = new Set([
  "node",
  "bun",
  "deno",
  "python",
  "python3",
  "ruby",
  "cargo",
  "go",
  "java",
  "php",
]);

function isDevProcess(name: string): boolean {
  const lower = name.toLowerCase();
  return Array.from(DEV_PROCESS_TYPES).some((type) => lower.includes(type));
}

function runCommand(command: string): string | null {
  try {
    return execSync(command, { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] });
  } catch {
    return null;
  }
}

function getWorkingDirectory(pid: number): string | undefined {
  const output = runCommand(`/usr/sbin/lsof -p ${pid} -Fn 2>/dev/null`);
  if (!output) return undefined;

  const lines = output.split("\n");
  let foundCwd = false;

  for (const line of lines) {
    if (line === "fcwd") {
      foundCwd = true;
      continue;
    }
    if (foundCwd && line.startsWith("n")) {
      return line.slice(1);
    }
  }

  return undefined;
}

function getGitBranch(directory: string): string | undefined {
  const output = runCommand(`/usr/bin/git -C "${directory}" rev-parse --abbrev-ref HEAD 2>/dev/null`);
  if (!output) return undefined;
  const branch = output.trim();
  return branch || undefined;
}

export function scanDevProcesses(): DevProcess[] {
  const lsofOutput = runCommand("/usr/sbin/lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null");
  if (!lsofOutput) return [];

  const processes = new Map<number, { name: string; port: number }>();

  // Parse lsof output
  const lines = lsofOutput.split("\n").slice(1); // Skip header
  for (const line of lines) {
    const parts = line.split(/\s+/);
    if (parts.length < 9) continue;

    const command = parts[0];
    const pid = parseInt(parts[1], 10);
    if (isNaN(pid)) continue;

    const nameField = parts[parts.length - 1]; // Last column is NAME (e.g., *:3000)
    const colonIndex = nameField.lastIndexOf(":");
    if (colonIndex === -1) continue;

    const port = parseInt(nameField.slice(colonIndex + 1), 10);
    if (isNaN(port)) continue;

    // Filter to dev-ish ports
    const isDevPort =
      (port >= DEV_PORT_RANGE.min && port <= DEV_PORT_RANGE.max) ||
      ADDITIONAL_DEV_PORTS.has(port);

    if (isDevPort && (isDevProcess(command) || isDevPort)) {
      processes.set(pid, { name: command, port });
    }
  }

  // Enrich with working directory and git info
  const devProcesses: DevProcess[] = [];

  for (const [pid, info] of processes) {
    const workingDirectory = getWorkingDirectory(pid);
    const gitBranch = workingDirectory ? getGitBranch(workingDirectory) : undefined;

    devProcesses.push({
      pid,
      name: info.name,
      port: info.port,
      workingDirectory,
      gitBranch,
    });
  }

  // Sort by port
  return devProcesses.sort((a, b) => a.port - b.port);
}

export function killProcess(pid: number): boolean {
  try {
    execSync(`kill -9 ${pid}`);
    return true;
  } catch {
    return false;
  }
}

export function getDisplayName(process: DevProcess): string {
  if (process.workingDirectory) {
    return process.workingDirectory.split("/").pop() || process.name;
  }
  return process.name;
}

export function abbreviatePath(path: string): string {
  const home = process.env.HOME || "";
  if (path.startsWith(home)) {
    return "~" + path.slice(home.length);
  }
  return path;
}
