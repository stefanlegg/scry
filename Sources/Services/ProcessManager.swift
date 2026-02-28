import Foundation
import SwiftUI

/// Manages the list of dev processes with auto-refresh
@MainActor
class ProcessManager: ObservableObject {
    @Published var processes: [DevProcess] = []
    @Published var pinnedProjects: [PinnedProject] = []
    @Published var isScanning = false
    @Published var lastUpdated: Date?
    
    private let scanner = ProcessScanner()
    private let crashNotifier = CrashNotifier()
    private let pinnedStore = PinnedProjectsStore.shared
    private var refreshTask: Task<Void, Never>?
    private let settings = SettingsStore.shared
    
    init() {
        startAutoRefresh()
    }
    
    deinit {
        refreshTask?.cancel()
    }
    
    /// Manually trigger a refresh
    func refresh() async {
        isScanning = true
        
        let scannedProcesses = await scanner.scan()
        processes = scannedProcesses
        
        // Check for crashes on watched processes
        await crashNotifier.checkForCrashes(currentProcesses: scannedProcesses)
        
        // Update pinned projects with running status
        updatePinnedProjects(with: scannedProcesses)
        
        lastUpdated = Date()
        isScanning = false
    }
    
    /// Updates pinned projects list with current running state
    private func updatePinnedProjects(with runningProcesses: [DevProcess]) {
        let runningByPath = Dictionary(
            runningProcesses.compactMap { process -> (String, DevProcess)? in
                guard let path = process.workingDirectory else { return nil }
                return (path, process)
            },
            uniquingKeysWith: { first, _ in first }
        )
        
        pinnedProjects = pinnedStore.pinnedPaths.map { path in
            PinnedProject(
                path: path,
                isWatched: pinnedStore.isWatched(path),
                runningProcess: runningByPath[path]
            )
        }
    }
    
    /// Starts the auto-refresh timer
    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(settings.refreshInterval))
            }
        }
    }
    
    /// Toggle pin status for a process
    func togglePin(_ process: DevProcess) {
        guard let path = process.workingDirectory else { return }
        pinnedStore.togglePin(path)
        updatePinnedProjects(with: processes)
    }
    
    /// Toggle pin status for a path
    func togglePin(path: String) {
        pinnedStore.togglePin(path)
        updatePinnedProjects(with: processes)
    }
    
    /// Toggle crash watch status for a process
    func toggleWatch(_ process: DevProcess) {
        guard let path = process.workingDirectory else { return }
        pinnedStore.toggleWatch(path)
        updatePinnedProjects(with: processes)
    }
    
    /// Toggle crash watch status for a path
    func toggleWatch(path: String) {
        pinnedStore.toggleWatch(path)
        updatePinnedProjects(with: processes)
    }
    
    /// Check if a process is pinned
    func isPinned(_ process: DevProcess) -> Bool {
        guard let path = process.workingDirectory else { return false }
        return pinnedStore.isPinned(path)
    }
    
    /// Check if a process is watched
    func isWatched(_ process: DevProcess) -> Bool {
        guard let path = process.workingDirectory else { return false }
        return pinnedStore.isWatched(path)
    }
    
    /// Reorder pinned projects
    func movePinned(from source: IndexSet, to destination: Int) {
        pinnedStore.move(from: source, to: destination)
        updatePinnedProjects(with: processes)
    }
    
    /// Kills a process by PID
    func kill(_ process: DevProcess) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/kill")
        task.arguments = ["-9", "\(process.id)"]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // Remove from list immediately for snappy UI
            processes.removeAll { $0.id == process.id }
            updatePinnedProjects(with: processes)
        } catch {
            print("Failed to kill process \(process.id): \(error)")
        }
    }
    
    /// Opens the process in the default browser
    func openInBrowser(_ process: DevProcess) {
        guard let url = process.browserURL else { return }
        NSWorkspace.shared.open(url)
    }
    
    /// Opens a URL in the default browser
    func openInBrowser(port: Int) {
        guard let url = URL(string: "http://localhost:\(port)") else { return }
        NSWorkspace.shared.open(url)
    }
    
    /// Opens the working directory in Finder
    func openInFinder(_ process: DevProcess) {
        guard let dir = process.workingDirectory else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: dir))
    }
    
    /// Opens a path in Finder
    func openInFinder(path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
    
    /// Opens the working directory in Terminal
    func openInTerminal(_ process: DevProcess) {
        guard let dir = process.workingDirectory else { return }
        openInTerminal(path: dir)
    }
    
    /// Opens a path in Terminal
    func openInTerminal(path: String) {
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(path)'"
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }
    
    /// Opens the working directory in VS Code
    func openInVSCode(_ process: DevProcess) {
        guard let dir = process.workingDirectory else { return }
        openInVSCode(path: dir)
    }
    
    /// Opens a path in VS Code
    func openInVSCode(path: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = ["code", path]
        try? task.run()
    }
    
    /// Copy URL to clipboard
    func copyURL(_ process: DevProcess) {
        guard let url = process.browserURL else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
    }
    
    /// Copy URL for a port to clipboard
    func copyURL(port: Int) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("http://localhost:\(port)", forType: .string)
    }
}
