import Foundation
import SwiftUI
import ServiceManagement
import Carbon

/// Persistence for app settings
class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let showStoppedApps = "showStoppedApps"
        static let showGitBranch = "showGitBranch"
        static let portRangeMin = "portRangeMin"
        static let portRangeMax = "portRangeMax"
        static let refreshInterval = "refreshInterval"
        static let excludedPorts = "excludedPorts"
        static let notificationsEnabled = "notificationsEnabled"
        static let themeName = "themeName"
        static let hotkeyCode = "hotkeyCode"
        static let hotkeyModifiers = "hotkeyModifiers"
        static let showRestartOption = "showRestartOption"
        static let restartMode = "restartMode"
    }
    
    // MARK: - Defaults
    
    /// Default ports to exclude (known system/app ports)
    static let defaultExcludedPorts: [ExcludedPort] = [
        ExcludedPort(port: 3283, label: "Apple Remote Desktop"),
        ExcludedPort(port: 5000, label: "AirPlay Receiver"),
        ExcludedPort(port: 5353, label: "mDNS / Bonjour"),
        ExcludedPort(port: 6463, label: "Discord RPC"),
        ExcludedPort(port: 7000, label: "AirPlay"),
        ExcludedPort(port: 7265, label: "Raycast"),
        ExcludedPort(port: 7768, label: "Spotify"),
    ]
    
    // MARK: - General
    
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLaunchAtLogin()
        }
    }
    
    // MARK: - Display
    
    @Published var showStoppedApps: ShowStoppedMode {
        didSet {
            defaults.set(showStoppedApps.rawValue, forKey: Keys.showStoppedApps)
        }
    }
    
    @Published var showGitBranch: Bool {
        didSet {
            defaults.set(showGitBranch, forKey: Keys.showGitBranch)
        }
    }
    
    // MARK: - Scanning
    
    @Published var portRangeMin: Int {
        didSet {
            defaults.set(portRangeMin, forKey: Keys.portRangeMin)
        }
    }
    
    @Published var portRangeMax: Int {
        didSet {
            defaults.set(portRangeMax, forKey: Keys.portRangeMax)
        }
    }
    
    @Published var refreshInterval: Int {
        didSet {
            defaults.set(refreshInterval, forKey: Keys.refreshInterval)
        }
    }
    
    @Published var excludedPorts: [ExcludedPort] {
        didSet {
            // Store as array of dictionaries
            let encoded = excludedPorts.map { ["port": $0.port, "label": $0.label] }
            defaults.set(encoded, forKey: Keys.excludedPorts)
        }
    }
    
    /// Convenience: just the port numbers for filtering
    var excludedPortNumbers: Set<Int> {
        Set(excludedPorts.map { $0.port })
    }
    
    // MARK: - Notifications
    
    @Published var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    // MARK: - Theme
    
    @Published var themeName: String {
        didSet {
            defaults.set(themeName, forKey: Keys.themeName)
        }
    }
    
    // MARK: - Hotkey
    
    @Published var hotkeyCode: UInt32 {
        didSet {
            defaults.set(hotkeyCode, forKey: Keys.hotkeyCode)
            HotkeyManager.shared.updateHotkey(keyCode: hotkeyCode, modifiers: hotkeyModifiers)
        }
    }
    
    @Published var hotkeyModifiers: UInt32 {
        didSet {
            defaults.set(hotkeyModifiers, forKey: Keys.hotkeyModifiers)
            HotkeyManager.shared.updateHotkey(keyCode: hotkeyCode, modifiers: hotkeyModifiers)
        }
    }
    
    // MARK: - Restart
    
    @Published var showRestartOption: Bool {
        didSet {
            defaults.set(showRestartOption, forKey: Keys.showRestartOption)
        }
    }
    
    @Published var restartMode: RestartMode {
        didSet {
            defaults.set(restartMode.rawValue, forKey: Keys.restartMode)
        }
    }
    
    // MARK: - Init
    
    private init() {
        // Load saved values or use defaults
        // For launch at login, sync with actual SMAppService state
        let savedLaunchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        let actualStatus = SMAppService.mainApp.status
        
        // If there's a mismatch, trust the actual system state
        if actualStatus == .enabled && !savedLaunchAtLogin {
            self.launchAtLogin = true
            defaults.set(true, forKey: Keys.launchAtLogin)
        } else if actualStatus == .notRegistered && savedLaunchAtLogin {
            self.launchAtLogin = false
            defaults.set(false, forKey: Keys.launchAtLogin)
        } else {
            self.launchAtLogin = savedLaunchAtLogin
        }
        self.showGitBranch = defaults.object(forKey: Keys.showGitBranch) as? Bool ?? true
        self.portRangeMin = defaults.object(forKey: Keys.portRangeMin) as? Int ?? 3000
        self.portRangeMax = defaults.object(forKey: Keys.portRangeMax) as? Int ?? 9999
        self.refreshInterval = defaults.object(forKey: Keys.refreshInterval) as? Int ?? 15
        
        if let savedPorts = defaults.array(forKey: Keys.excludedPorts) as? [[String: Any]] {
            self.excludedPorts = savedPorts.compactMap { dict in
                guard let port = dict["port"] as? Int,
                      let label = dict["label"] as? String else { return nil }
                return ExcludedPort(port: port, label: label)
            }
        } else {
            self.excludedPorts = SettingsStore.defaultExcludedPorts
        }
        self.notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.themeName = defaults.string(forKey: Keys.themeName) ?? "default"
        
        // Hotkey defaults: ⌥⇧S (Option + Shift + S)
        // keyCode 0x01 = S, optionKey | shiftKey for modifiers
        self.hotkeyCode = defaults.object(forKey: Keys.hotkeyCode) as? UInt32 ?? 0x01
        self.hotkeyModifiers = defaults.object(forKey: Keys.hotkeyModifiers) as? UInt32 ?? UInt32(optionKey | shiftKey)
        
        if let modeString = defaults.string(forKey: Keys.showStoppedApps),
           let mode = ShowStoppedMode(rawValue: modeString) {
            self.showStoppedApps = mode
        } else {
            self.showStoppedApps = .pinnedOnly
        }
        
        // Restart settings
        self.showRestartOption = defaults.object(forKey: Keys.showRestartOption) as? Bool ?? true
        if let restartModeString = defaults.string(forKey: Keys.restartMode),
           let mode = RestartMode(rawValue: restartModeString) {
            self.restartMode = mode
        } else {
            self.restartMode = .terminal
        }
    }
    
    // MARK: - Launch at Login
    
    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}

// MARK: - Enums

enum ShowStoppedMode: String, CaseIterable {
    case none = "none"
    case pinnedOnly = "pinnedOnly"
    case all = "all"
    
    var displayName: String {
        switch self {
        case .none: return "Never"
        case .pinnedOnly: return "Pinned only"
        case .all: return "All recently seen"
        }
    }
}

enum RestartMode: String, CaseIterable {
    case terminal = "terminal"
    case background = "background"
    
    var displayName: String {
        switch self {
        case .terminal: return "Open in Terminal"
        case .background: return "Run in background"
        }
    }
}

// MARK: - Excluded Port

struct ExcludedPort: Identifiable, Equatable {
    let id = UUID()
    var port: Int
    var label: String
    
    static func == (lhs: ExcludedPort, rhs: ExcludedPort) -> Bool {
        lhs.port == rhs.port
    }
}
