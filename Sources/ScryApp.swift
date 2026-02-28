import SwiftUI
import UserNotifications

@main
struct ScryApp: App {
    @StateObject private var processManager = ProcessManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Theme selection (could be persisted to UserDefaults)
    @State private var currentTheme: ScryTheme = ScryDefaultTheme()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(processManager: processManager)
                .environment(\.theme, currentTheme)
        } label: {
            // Menu bar icon - crystal ball emoji or SF Symbol
            Image(systemName: "eye.circle.fill")
        }
        .menuBarExtraStyle(.window)
        
        Window("Scry Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
    
    init() {
        // Register global hotkey on launch
        setupHotkey()
    }
    
    private func setupHotkey() {
        HotkeyManager.shared.onHotkeyPressed = {
            // Toggle menu visibility
            DispatchQueue.main.async {
                // Find the status bar window and simulate a click
                for window in NSApp.windows {
                    if window.className.contains("NSStatusBarWindow"),
                       let button = window.contentView?.subviews.first as? NSButton {
                        button.performClick(button)
                        break
                    }
                }
            }
        }
        HotkeyManager.shared.register()
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Only set up notifications if we're running as a proper app bundle
        guard Bundle.main.bundleIdentifier != nil else {
            print("Running in dev mode - notifications disabled")
            return
        }
        
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permission
        Task {
            try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        }
    }
    
    // Handle notification clicks
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let path = response.notification.request.content.userInfo["path"] as? String {
            // Open the project folder when notification is clicked
            NSWorkspace.shared.open(URL(fileURLWithPath: path))
        }
        completionHandler()
    }
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
