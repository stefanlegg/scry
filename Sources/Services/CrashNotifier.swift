import Foundation
import UserNotifications

/// Monitors watched processes and sends notifications when they crash
actor CrashNotifier {
    private var previouslyRunning: Set<String> = []
    private let store = PinnedProjectsStore.shared
    private var notificationsAvailable = false
    
    init() {
        // Defer notification setup - don't block init
    }
    
    /// Request notification permission (call after app is fully initialized)
    func setupNotifications() async {
        // Check if we're in a proper app bundle
        guard Bundle.main.bundleIdentifier != nil else {
            print("Notifications unavailable - not running as app bundle")
            return
        }
        
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            notificationsAvailable = granted
            if !granted {
                print("Notification permission denied")
            }
        } catch {
            print("Failed to request notification permission: \(error)")
            notificationsAvailable = false
        }
    }
    
    /// Check for crashed processes and send notifications
    func checkForCrashes(currentProcesses: [DevProcess]) async {
        let currentPaths = Set(currentProcesses.compactMap { $0.workingDirectory })
        let watchedPaths = await MainActor.run { store.watchedPaths }
        
        // Find processes that were running but are now gone
        let crashed = previouslyRunning
            .intersection(watchedPaths)
            .subtracting(currentPaths)
        
        for path in crashed {
            await sendCrashNotification(for: path)
        }
        
        // Update state for next check
        previouslyRunning = currentPaths
    }
    
    /// Send a notification that a process crashed
    private func sendCrashNotification(for path: String) async {
        guard notificationsAvailable else { return }
        
        let projectName = URL(fileURLWithPath: path).lastPathComponent
        
        let content = UNMutableNotificationContent()
        content.title = "Dev Server Stopped"
        content.body = "\(projectName) is no longer running"
        content.sound = .default
        
        // Add action to restart (handled by notification delegate)
        content.userInfo = ["path": path]
        
        let request = UNNotificationRequest(
            identifier: "crash-\(path.hashValue)",
            content: content,
            trigger: nil  // Deliver immediately
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send notification: \(error)")
        }
    }
}
