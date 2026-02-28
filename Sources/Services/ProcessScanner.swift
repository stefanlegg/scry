import Foundation

/// Scans for running dev server processes
actor ProcessScanner {
    
    /// Port range to consider as "dev server" ports
    private let devPortRange = 3000...9999
    
    /// Additional ports commonly used for dev
    private let additionalDevPorts: Set<Int> = [80, 443, 8080, 8443]
    
    /// Gets excluded ports from settings
    private var excludedPorts: Set<Int> {
        SettingsStore.shared.excludedPortNumbers
    }
    
    /// Known non-dev processes to exclude (system services, desktop apps)
    private let excludedProcesses: Set<String> = [
        "Spotify", "Discord", "Raycast", "ControlCe", "ARDAgent",
        "rapportd", "Google", "Slack", "Figma", "Notion", "Obsidian",
        "1Password", "Dropbox", "zoom.us", "Microsoft", "Code\\x20H"
    ]
    
    /// Scans for running dev processes
    func scan() async -> [DevProcess] {
        // Get all listening TCP processes
        guard let lsofOutput = runCommand("/usr/sbin/lsof", arguments: ["-iTCP", "-sTCP:LISTEN", "-P", "-n"]) else {
            return []
        }
        
        var processes: [Int32: (name: String, port: Int, command: String?)] = [:]
        
        // Parse lsof output
        // Format: COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
        let lines = lsofOutput.components(separatedBy: "\n")
        for line in lines.dropFirst() {  // Skip header
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 9 else { continue }
            
            let command = String(parts[0])
            guard let pid = Int32(parts[1]) else { continue }
            
            // NAME column can be followed by (LISTEN), so find the address:port part
            // Format: *:3000 or 127.0.0.1:3000 or [::1]:3000
            // It's usually second-to-last when (LISTEN) is present, or last otherwise
            let nameField: String
            if parts.count >= 10 && String(parts[parts.count - 1]).contains("LISTEN") {
                nameField = String(parts[parts.count - 2])
            } else {
                nameField = String(parts[parts.count - 1])
            }
            
            // Extract port from NAME - handle both IPv4 and IPv6
            // IPv4: *:3000, 127.0.0.1:3000
            // IPv6: [::1]:3000, *:3000
            guard let colonIndex = nameField.lastIndex(of: ":") else { continue }
            let portString = nameField[nameField.index(after: colonIndex)...]
            guard let port = Int(portString) else { continue }
            
            // Filter to dev-ish ports, excluding known system ports
            let inDevRange = devPortRange.contains(port) || additionalDevPorts.contains(port)
            let isExcludedPort = excludedPorts.contains(port)
            
            if inDevRange && !isExcludedPort {
                // Skip known non-dev processes
                let isExcluded = excludedProcesses.contains { command.contains($0) }
                guard !isExcluded else { continue }
                
                // Only track if it's a dev-ish process or on a dev port
                if DevProcessType.isDevProcess(command) || devPortRange.contains(port) {
                    processes[pid] = (command, port, nil)
                }
            }
        }
        
        // Enrich with working directory and git info
        var devProcesses: [DevProcess] = []
        
        for (pid, info) in processes {
            let workingDir = getWorkingDirectory(for: pid)
            
            // Skip processes with root "/" as working directory (system services)
            // unless they're known dev process types
            if workingDir == "/" && !DevProcessType.isDevProcess(info.name) {
                continue
            }
            
            let gitBranch: String? = if let dir = workingDir {
                getGitBranch(for: dir)
            } else {
                nil
            }
            
            let gitRoot: String? = if let dir = workingDir {
                getGitRoot(for: dir)
            } else {
                nil
            }
            
            let process = DevProcess(
                id: pid,
                name: info.name,
                port: info.port,
                workingDirectory: workingDir,
                gitRoot: gitRoot,
                gitBranch: gitBranch,
                command: info.command
            )
            devProcesses.append(process)
        }
        
        // Sort by port
        return devProcesses.sorted { $0.port < $1.port }
    }
    
    /// Gets the working directory for a process
    private func getWorkingDirectory(for pid: Int32) -> String? {
        // Use lsof to get cwd
        guard let output = runCommand("/usr/sbin/lsof", arguments: ["-p", "\(pid)", "-Fn"]) else {
            return nil
        }
        
        // Look for cwd entry (format: "ncwd" then "n/path/to/dir")
        let lines = output.components(separatedBy: "\n")
        var foundCwd = false
        
        for line in lines {
            if line == "fcwd" {
                foundCwd = true
                continue
            }
            if foundCwd && line.hasPrefix("n") {
                return String(line.dropFirst())
            }
        }
        
        return nil
    }
    
    /// Gets the git branch for a directory
    private func getGitBranch(for directory: String) -> String? {
        guard let output = runCommand("/usr/bin/git", arguments: ["-C", directory, "rev-parse", "--abbrev-ref", "HEAD"]) else {
            return nil
        }
        let branch = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return branch.isEmpty ? nil : branch
    }
    
    /// Gets the git repository root for a directory
    private func getGitRoot(for directory: String) -> String? {
        guard let output = runCommand("/usr/bin/git", arguments: ["-C", directory, "rev-parse", "--show-toplevel"]) else {
            return nil
        }
        let root = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return root.isEmpty ? nil : root
    }
    
    /// Runs a shell command and returns stdout
    private func runCommand(_ path: String, arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
