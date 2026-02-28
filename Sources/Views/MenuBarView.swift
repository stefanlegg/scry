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
                    showingSettings = true
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Pinned Section
    
    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(
                icon: "📌",
                title: "Pinned",
                iconColor: theme.accentPin
            )
            
            ForEach(processManager.pinnedProjects) { project in
                PinnedProjectRowView(
                    project: project,
                    processManager: processManager
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Running Section
    
    private var runningSection: some View {
        VStack(alignment: .leading, spacing: 0) {
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
        .padding(.vertical, 8)
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

// MARK: - Pinned Project Row

struct PinnedProjectRowView: View {
    let project: PinnedProject
    @ObservedObject var processManager: ProcessManager
    @Environment(\.theme) var theme
    @State private var isHovering = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            StatusDot(isRunning: project.isRunning)
            
            VStack(alignment: .leading, spacing: 3) {
                // Title row
                HStack(spacing: 8) {
                    Text(project.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.textPrimary)
                    
                    if let process = project.runningProcess {
                        PortLabel(port: process.port)
                    } else {
                        Text("not running")
                            .font(.system(size: 11))
                            .foregroundStyle(theme.textMuted)
                            .italic()
                    }
                    
                    if project.isWatched {
                        WatchedBadge()
                    }
                }
                
                // Meta row
                HStack(spacing: 8) {
                    PathLabel(path: project.path)
                    
                    if let branch = project.runningProcess?.gitBranch {
                        GitBranchLabel(branch: branch)
                    }
                }
            }
            
            Spacer()
            
            if isHovering {
                rowActions
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? theme.surfaceHover : Color.clear)
                .padding(.horizontal, 8)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
    
    private var rowActions: some View {
        HStack(spacing: 2) {
            if let process = project.runningProcess {
                EmojiActionButton(emoji: "🌐") {
                    processManager.openInBrowser(process)
                }
            }
            
            Menu {
                if let process = project.runningProcess {
                    Button(action: { processManager.copyURL(process) }) {
                        Label("Copy URL", systemImage: "doc.on.doc")
                    }
                    Divider()
                }
                
                Button(action: { processManager.openInFinder(path: project.path) }) {
                    Label("Open in Finder", systemImage: "folder")
                }
                Button(action: { processManager.openInTerminal(path: project.path) }) {
                    Label("Open in Terminal", systemImage: "terminal")
                }
                Button(action: { processManager.openInVSCode(path: project.path) }) {
                    Label("Open in VS Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                
                Divider()
                
                Button(action: { processManager.toggleWatch(path: project.path) }) {
                    Label(
                        project.isWatched ? "Stop Watching" : "Watch for Crashes",
                        systemImage: project.isWatched ? "bell.slash" : "bell"
                    )
                }
                
                Button(action: { processManager.togglePin(path: project.path) }) {
                    Label("Unpin", systemImage: "pin.slash")
                }
                
                if let process = project.runningProcess {
                    Divider()
                    Button(role: .destructive, action: { processManager.kill(process) }) {
                        Label("Kill Process", systemImage: "xmark.circle")
                    }
                }
            } label: {
                Text("⋯")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
    }
}

// Preview requires Xcode
// #Preview {
//     MenuBarView(processManager: ProcessManager())
//         .environment(\.theme, ScryDefaultTheme())
// }
