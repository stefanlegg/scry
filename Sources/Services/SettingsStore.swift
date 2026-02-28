import Foundation
import SwiftUI
import ServiceManagement

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
        static let notificationsEnabled = "notificationsEnabled"
        static let themeName = "themeName"
    }
    
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
    
    // MARK: - Init
    
    private init() {
        // Load saved values or use defaults
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.showGitBranch = defaults.object(forKey: Keys.showGitBranch) as? Bool ?? true
        self.portRangeMin = defaults.object(forKey: Keys.portRangeMin) as? Int ?? 3000
        self.portRangeMax = defaults.object(forKey: Keys.portRangeMax) as? Int ?? 9999
        self.notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.themeName = defaults.string(forKey: Keys.themeName) ?? "default"
        
        if let modeString = defaults.string(forKey: Keys.showStoppedApps),
           let mode = ShowStoppedMode(rawValue: modeString) {
            self.showStoppedApps = mode
        } else {
            self.showStoppedApps = .pinnedOnly
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
