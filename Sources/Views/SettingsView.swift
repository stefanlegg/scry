import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsStore.shared
    
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
                }
                
                // Notifications
                Section("Notifications") {
                    Toggle("Enable crash notifications", isOn: $settings.notificationsEnabled)
                    
                    Text("Watch specific projects via the ••• menu")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        .frame(width: 380, height: 420)
    }
}

// Preview requires Xcode
// #Preview {
//     SettingsView()
// }
