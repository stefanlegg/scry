import SwiftUI

struct ProcessRowView: View {
    let process: DevProcess
    let isPinned: Bool
    let isWatched: Bool
    let onOpen: () -> Void
    let onCopyURL: () -> Void
    let onKill: () -> Void
    let onOpenFolder: () -> Void
    let onOpenTerminal: () -> Void
    let onOpenVSCode: () -> Void
    let onTogglePin: () -> Void
    let onToggleWatch: () -> Void
    
    @Environment(\.theme) var theme
    @State private var isHovering = false
    @State private var showCopied = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            StatusDot(isRunning: true)
            
            VStack(alignment: .leading, spacing: 3) {
                // Title row
                HStack(spacing: 8) {
                    Text(process.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                    
                    PortLabel(port: process.port)
                    
                    if isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(theme.accentPin)
                    }
                    
                    if isWatched {
                        WatchedBadge()
                    }
                }
                
                // Meta row
                HStack(spacing: 8) {
                    if let dir = process.workingDirectory {
                        PathLabel(path: dir)
                    }
                    
                    if let branch = process.gitBranch {
                        GitBranchLabel(branch: branch)
                    }
                }
            }
            
            Spacer()
            
            if isHovering {
                actionButtons
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
    
    private var actionButtons: some View {
        HStack(spacing: 2) {
            // Open in browser
            EmojiActionButton(emoji: "🌐", action: onOpen)
            
            // Copy URL
            Button(action: {
                onCopyURL()
                showCopiedFeedback()
            }) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 11))
                    .frame(width: 26, height: 26)
                    .foregroundStyle(showCopied ? theme.statusRunning : theme.textSecondary)
            }
            .buttonStyle(.plain)
            
            // More actions menu
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
                
                Button(role: .destructive, action: onKill) {
                    Label("Kill Process", systemImage: "xmark.circle")
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
    
    private func showCopiedFeedback() {
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
}

// MARK: - Legacy Action Button Style (for compatibility)

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

// Preview requires Xcode
// #Preview {
//     VStack {
//         ProcessRowView(...)
//     }
// }
