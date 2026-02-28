import SwiftUI

struct MenuBarView: View {
    @ObservedObject var processManager: ProcessManager
    @Environment(\.theme) var theme
    @State private var showingSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            header
            
            Rectangle()
                .fill(theme.divider)
                .frame(height: 1)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Pinned projects section (if any)
                    if !processManager.pinnedProjects.isEmpty {
                        pinnedSection
                        
                        if !unpinnedProcesses.isEmpty {
                            ScryDivider()
                        }
                    }
                    
                    // Running processes (unpinned)
                    if !unpinnedProcesses.isEmpty {
                        runningSection
                    }
                    
                    // Empty state
                    if processManager.pinnedProjects.isEmpty && processManager.processes.isEmpty {
                        emptyState
                    }
                }
            }
            .frame(maxHeight: 350)
            
            Rectangle()
                .fill(theme.divider)
                .frame(height: 1)
            
            // Footer
            footer
        }
        .frame(width: 340)
        .background(theme.surface)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Computed Properties
    
    private var unpinnedProcesses: [DevProcess] {
        let pinnedPaths = Set(processManager.pinnedProjects.map { $0.path })
        return processManager.processes.filter { process in
            guard let path = process.workingDirectory else { return true }
            return !pinnedPaths.contains(path)
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text("Scry")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            
            HotkeyBadge(text: "⌥⇧S")
            
            Spacer()
            
            HStack(spacing: 4) {
                if processManager.isScanning {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 28, height: 28)
                } else {
                    ScryActionButton(icon: "arrow.clockwise") {
                        Task { await processManager.refresh() }
                    }
                }
                
                ScryActionButton(icon: "gearshape") {
                    SettingsWindowController.shared.showSettings()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Pinned Section
    
    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            SectionHeader(
                icon: "📌",
                title: "Pinned",
                iconColor: theme.accentPin
            )
            
            ForEach(processManager.pinnedProjects) { project in
                PinnedProjectRowCompactView(
                    project: project,
                    processManager: processManager
                )
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Running Section
    
    private var runningSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            if !processManager.pinnedProjects.isEmpty {
                SectionHeader(
                    icon: "⚡",
                    title: "Running",
                    iconColor: theme.statusRunning
                )
            }
            
            ForEach(unpinnedProcesses) { process in
                ProcessRowView(
                    process: process,
                    isPinned: false,
                    isWatched: processManager.isWatched(process),
                    onOpen: { processManager.openInBrowser(process) },
                    onCopyURL: { processManager.copyURL(process) },
                    onKill: { processManager.kill(process) },
                    onOpenFolder: { processManager.openInFinder(process) },
                    onOpenTerminal: { processManager.openInTerminal(process) },
                    onOpenVSCode: { processManager.openInVSCode(process) },
                    onTogglePin: { processManager.togglePin(process) },
                    onToggleWatch: { processManager.toggleWatch(process) }
                )
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 32))
                .foregroundStyle(theme.textMuted)
            
            Text("No dev servers running")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            Text("Start a server on ports 3000-9999")
                .font(.system(size: 11))
                .foregroundStyle(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            Spacer()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.system(size: 11))
            .foregroundStyle(theme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// Preview requires Xcode
// #Preview {
//     MenuBarView(processManager: ProcessManager())
//         .environment(\.theme, ScryDefaultTheme())
// }
