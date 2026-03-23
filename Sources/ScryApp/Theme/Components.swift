import SwiftUI

// MARK: - Status Dot with Glow

struct StatusDot: View {
    let isRunning: Bool
    @Environment(\.theme) var theme
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(isRunning ? theme.statusRunning : theme.statusStopped)
            .frame(width: 8, height: 8)
            .shadow(
                color: isRunning ? theme.statusRunningGlow.opacity(isPulsing ? 0.7 : 0.4) : .clear,
                radius: isRunning ? theme.glowRadius : 0
            )
            .animation(
                isRunning ? .easeInOut(duration: 2).repeatForever(autoreverses: true) : .default,
                value: isPulsing
            )
            .onAppear {
                if isRunning {
                    isPulsing = true
                }
            }
            .onChange(of: isRunning) { newValue in
                isPulsing = newValue
            }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let icon: String
    let title: String
    let iconColor: Color
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 9))
            
            Text(title.uppercased())
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(theme.textMuted)
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
    }
}

// MARK: - Hotkey Badge

struct HotkeyBadge: View {
    let text: String
    @Environment(\.theme) var theme
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(theme.textMuted)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.06))
            .cornerRadius(4)
    }
}

// MARK: - Watched Badge

struct WatchedBadge: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "bell.fill")
                .font(.system(size: 8))
        }
        .font(.system(size: 9))
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(theme.accentSecondary.opacity(0.15))
        .foregroundStyle(theme.accentSecondary)
        .cornerRadius(3)
    }
}

// MARK: - Git Branch Label

struct GitBranchLabel: View {
    let branch: String
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 10))
            
            Text(branch)
                .lineLimit(1)
        }
        .font(.system(size: 11))
        .foregroundStyle(theme.accentPrimary)
    }
}

// MARK: - Path Label

struct PathLabel: View {
    let path: String
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "folder.fill")
                .font(.system(size: 10))
                .opacity(0.7)
            
            Text(abbreviatePath(path))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(.system(size: 11))
        .foregroundStyle(theme.textMuted)
    }
    
    private func abbreviatePath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}

// MARK: - Port Label

struct PortLabel: View {
    let port: Int
    @Environment(\.theme) var theme
    
    var body: some View {
        Text(":\(port)")
            .font(.system(size: 12, design: .monospaced))
            .foregroundStyle(theme.textSecondary)
    }
}

// MARK: - Action Button

struct ScryActionButton: View {
    let icon: String
    let action: () -> Void
    @Environment(\.theme) var theme
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovering ? Color.white.opacity(0.1) : Color.clear)
                )
                .foregroundStyle(isHovering ? theme.textPrimary : theme.textSecondary)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Icon Action Button (Emoji version)

struct EmojiActionButton: View {
    let emoji: String
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: 12))
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovering ? Color.white.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Divider

struct ScryDivider: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        Rectangle()
            .fill(theme.divider)
            .frame(height: 1)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
    }
}
