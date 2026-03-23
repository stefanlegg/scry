import SwiftUI
import ScryKit

struct ProcessRowView: View {
    let process: DevProcess
    let isPinned: Bool
    let isWatched: Bool
    let canRestart: Bool
    let onOpen: () -> Void
    let onCopyURL: () -> Void
    let onKill: () -> Void
    let onRestart: () -> Void
    let onOpenFolder: () -> Void
    let onOpenTerminal: () -> Void
    let onOpenVSCode: () -> Void
    let onTogglePin: () -> Void
    let onToggleWatch: () -> Void
    
    @Environment(\.theme) var theme
    @State private var isHovering = false
    @State private var showCopied = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Status dot + watched indicator
            ZStack {
                StatusDot(isRunning: true)
                
                if isWatched {
                    Circle()
                        .fill(theme.accentSecondary)
                        .frame(width: 4, height: 4)
                        .offset(x: 5, y: -3)
                }
            }
            .frame(width: 12)
            
            // Name / Path (expands on hover)
            Text(isHovering ? expandedName : process.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
                .animation(.easeInOut(duration: 0.15), value: isHovering)

            // Framework badge
            if let fw = process.framework {
                Text(fw.displayName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(theme.textMuted)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(3)
            }

            // Git branch (always visible if present)
            if let branch = process.gitBranch {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 9))
                    Text(branch)
                        .lineLimit(1)
                }
                .font(.system(size: 10))
                .foregroundStyle(theme.accentPrimary)
            }
            
            Spacer()
            
            // Right side: port OR actions (fixed width to prevent layout shift)
            ZStack {
                // Always reserve space for actions
                actionButtons
                    .opacity(isHovering ? 1 : 0)
                
                // Port label fades out on hover
                PortLabel(port: process.port)
                    .opacity(isHovering ? 0 : 1)
            }
            .frame(minWidth: 70, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(minHeight: 28)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovering ? theme.surfaceHover : Color.clear)
                .padding(.horizontal, 6)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
    
    private var expandedName: String {
        guard let dir = process.workingDirectory else { return process.displayName }
        return abbreviatePath(dir, gitRoot: process.gitRoot)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 2) {
            CompactActionButton(icon: "globe", action: onOpen)
            
            CompactActionButton(
                icon: showCopied ? "checkmark" : "doc.on.doc",
                tint: showCopied ? theme.statusRunning : nil
            ) {
                onCopyURL()
                showCopiedFeedback()
            }
            
            Menu {
                Button(action: onOpenFolder) {
                    Label("Open in Finder", systemImage: "folder")
                }
                Button(action: onOpenTerminal) {
                    Label("Open in Terminal", systemImage: "terminal")
                }
                Button(action: onOpenVSCode) {
                    Label("Open in VS Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                
                Divider()
                
                Button(action: onTogglePin) {
                    Label(isPinned ? "Unpin" : "Pin", systemImage: isPinned ? "pin.slash" : "pin")
                }
                
                Button(action: onToggleWatch) {
                    Label(
                        isWatched ? "Stop Watching" : "Watch for Crashes",
                        systemImage: isWatched ? "bell.slash" : "bell"
                    )
                }
                
                Divider()
                
                if canRestart {
                    Button(action: onRestart) {
                        Label("Restart", systemImage: "arrow.clockwise")
                    }
                }
                
                Button(role: .destructive, action: onKill) {
                    Label("Kill Process", systemImage: "xmark.circle")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
    }
    
    private func showCopiedFeedback() {
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
    
    private func abbreviatePath(_ path: String, gitRoot: String? = nil) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        var displayPath = path
        
        // Replace home directory with ~
        if displayPath.hasPrefix(home) {
            displayPath = "~" + displayPath.dropFirst(home.count)
        }
        
        return displayPath
    }
}

// MARK: - Compact Action Button

struct CompactActionButton: View {
    let icon: String
    var tint: Color? = nil
    let action: () -> Void
    
    @Environment(\.theme) var theme
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .frame(width: 22, height: 22)
                .foregroundStyle(tint ?? (isHovering ? theme.textPrimary : theme.textSecondary))
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHovering ? Color.white.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Pinned Project Row (Compact)

struct PinnedProjectRowCompactView: View {
    let project: PinnedProject
    @ObservedObject var processManager: ProcessManager
    @Environment(\.theme) var theme
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Status dot + watched indicator
            ZStack {
                StatusDot(isRunning: project.isRunning)
                
                if project.isWatched {
                    Circle()
                        .fill(theme.accentSecondary)
                        .frame(width: 4, height: 4)
                        .offset(x: 5, y: -3)
                }
            }
            .frame(width: 12)
            
            // Name / Path
            Text(isHovering ? abbreviatePath(project.path) : project.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(project.isRunning ? theme.textPrimary : theme.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .animation(.easeInOut(duration: 0.15), value: isHovering)

            // Framework badge (if running)
            if let fw = project.runningProcess?.framework {
                Text(fw.displayName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(theme.textMuted)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(3)
            }

            // Git branch (if running)
            if let branch = project.runningProcess?.gitBranch {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 9))
                    Text(branch)
                        .lineLimit(1)
                }
                .font(.system(size: 10))
                .foregroundStyle(theme.accentPrimary)
            }
            
            Spacer()
            
            // Right side: port/status OR actions (fixed width to prevent layout shift)
            ZStack {
                // Always reserve space for actions
                actionButtons
                    .opacity(isHovering ? 1 : 0)
                
                // Port/status label fades out on hover
                Group {
                    if let process = project.runningProcess {
                        PortLabel(port: process.port)
                    } else {
                        Text("—")
                            .font(.system(size: 11))
                            .foregroundStyle(theme.textMuted)
                    }
                }
                .opacity(isHovering ? 0 : 1)
            }
            .frame(minWidth: 70, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(minHeight: 28)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovering ? theme.surfaceHover : Color.clear)
                .padding(.horizontal, 6)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 2) {
            if let process = project.runningProcess {
                CompactActionButton(icon: "globe") {
                    processManager.openInBrowser(process)
                }
                
                CompactActionButton(icon: "doc.on.doc") {
                    processManager.copyURL(process)
                }
            } else {
                CompactActionButton(icon: "folder") {
                    processManager.openInFinder(path: project.path)
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
                    
                    if processManager.canRestart(process) {
                        Button(action: { processManager.restart(process) }) {
                            Label("Restart", systemImage: "arrow.clockwise")
                        }
                    }
                    
                    Button(role: .destructive, action: { processManager.kill(process) }) {
                        Label("Kill Process", systemImage: "xmark.circle")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
    }
    
    private func abbreviatePath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}

// MARK: - Legacy support

struct ActionButtonStyle: ButtonStyle {
    @Environment(\.theme) var theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 24, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isPressed ? Color.white.opacity(0.1) : Color.clear)
            )
            .foregroundStyle(Color.white.opacity(0.5))
    }
}

// MARK: - Path Truncation Utilities

extension String {
    /// Truncates a path in the middle, preserving the git root name and leaf folder.
    /// Example: "~/Code/heyblathers/apps/mobile/ios" → "~/Code/heyblathers/…/ios"
    func truncatedPath(maxLength: Int, gitRootName: String? = nil) -> String {
        guard count > maxLength else { return self }
        
        let components = self.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard components.count > 3 else { return self }
        
        // Find the git root component index if provided
        let rootIndex: Int?
        if let rootName = gitRootName {
            rootIndex = components.firstIndex(of: rootName)
        } else {
            rootIndex = nil
        }
        
        // Preserve up to and including git root (or first 2 components), plus the last component
        let preserveStart = rootIndex.map { $0 + 1 } ?? min(2, components.count - 1)
        let preserveEnd = components.count - 1
        
        // If there's nothing to truncate in the middle, return as-is
        guard preserveStart < preserveEnd else { return self }
        
        // Build truncated path
        let startPart = components[0..<preserveStart].joined(separator: "/")
        let endPart = components[preserveEnd]
        let truncated = startPart + "/…/" + endPart
        
        return truncated
    }
}

// Preview requires Xcode
// #Preview {
//     VStack {
//         ProcessRowView(...)
//     }
// }
