import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsStore.shared
    @State private var newExcludedPort: String = ""
    @State private var newExcludedLabel: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button(action: { 
                    SettingsWindowController.shared.hideSettings()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Settings content
            Form {
                // General
                Section("General") {
                    Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    
                    HStack {
                        Text("Hotkey")
                        Spacer()
                        HotkeyRecorderView(
                            keyCode: $settings.hotkeyCode,
                            modifiers: $settings.hotkeyModifiers
                        )
                    }
                }
                
                // Display
                Section("Display") {
                    Picker("Show stopped apps", selection: $settings.showStoppedApps) {
                        ForEach(ShowStoppedMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    
                    Toggle("Show git branch", isOn: $settings.showGitBranch)
                }
                
                // Scanning
                Section("Scanning") {
                    Picker("Refresh interval", selection: $settings.refreshInterval) {
                        Text("5 seconds").tag(5)
                        Text("10 seconds").tag(10)
                        Text("15 seconds").tag(15)
                        Text("30 seconds").tag(30)
                        Text("60 seconds").tag(60)
                    }
                    
                    HStack {
                        Text("Port range")
                        Spacer()
                        TextField("Min", value: $settings.portRangeMin, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)
                        Text("to")
                            .foregroundStyle(.secondary)
                        TextField("Max", value: $settings.portRangeMax, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Excluded ports")
                            Spacer()
                            Button("Reset to Defaults") {
                                settings.excludedPorts = SettingsStore.defaultExcludedPorts
                            }
                            .font(.caption)
                        }
                        
                        // List of excluded ports
                        VStack(spacing: 0) {
                            ForEach(settings.excludedPorts.sorted(by: { $0.port < $1.port })) { excluded in
                                HStack {
                                    Text("\(excluded.port)")
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(width: 50, alignment: .leading)
                                    Text(excluded.label)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Button(action: {
                                        settings.excludedPorts.removeAll { $0.port == excluded.port }
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                
                                if excluded.port != settings.excludedPorts.sorted(by: { $0.port < $1.port }).last?.port {
                                    Divider()
                                }
                            }
                        }
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                        
                        // Add new port
                        HStack(spacing: 8) {
                            TextField("Port", text: $newExcludedPort)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)
                            TextField("Label (optional)", text: $newExcludedLabel)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                if let port = Int(newExcludedPort), port > 0, port < 65536 {
                                    let label = newExcludedLabel.isEmpty ? "Custom" : newExcludedLabel
                                    settings.excludedPorts.append(ExcludedPort(port: port, label: label))
                                    newExcludedPort = ""
                                    newExcludedLabel = ""
                                }
                            }
                            .disabled(Int(newExcludedPort) == nil)
                        }
                    }
                }
                
                // Notifications
                Section("Notifications") {
                    Toggle("Enable crash notifications", isOn: $settings.notificationsEnabled)
                    
                    Text("Watch specific projects via the ••• menu")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Restart
                Section("Restart") {
                    Toggle("Show restart option", isOn: $settings.showRestartOption)
                    
                    if settings.showRestartOption {
                        Picker("Restart mode", selection: $settings.restartMode) {
                            ForEach(RestartMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        
                        Text("Note: Environment variables from your shell session won't be preserved on restart.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            // Footer
            HStack {
                Text("Scry v1.0")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button("Done") {
                    SettingsWindowController.shared.hideSettings()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 380, height: 580)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

// Preview requires Xcode
// #Preview {
//     SettingsView()
// }
