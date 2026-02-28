import Foundation

/// Stores pinned projects and their order
class PinnedProjectsStore: ObservableObject {
    static let shared = PinnedProjectsStore()
    
    private let userDefaults = UserDefaults.standard
    private let pinnedKey = "pinnedProjects"
    private let watchedKey = "watchedProjects"  // Projects to notify on crash
    
    /// List of pinned project paths (in display order)
    @Published var pinnedPaths: [String] {
        didSet {
            userDefaults.set(pinnedPaths, forKey: pinnedKey)
        }
    }
    
    /// Projects to watch for crashes (notify when they stop)
    @Published var watchedPaths: Set<String> {
        didSet {
            userDefaults.set(Array(watchedPaths), forKey: watchedKey)
        }
    }
    
    private init() {
        self.pinnedPaths = userDefaults.stringArray(forKey: pinnedKey) ?? []
        self.watchedPaths = Set(userDefaults.stringArray(forKey: watchedKey) ?? [])
    }
    
    /// Check if a path is pinned
    func isPinned(_ path: String) -> Bool {
        pinnedPaths.contains(path)
    }
    
    /// Check if a path is watched for crashes
    func isWatched(_ path: String) -> Bool {
        watchedPaths.contains(path)
    }
    
    /// Toggle pin status for a project
    func togglePin(_ path: String) {
        if let index = pinnedPaths.firstIndex(of: path) {
            pinnedPaths.remove(at: index)
        } else {
            pinnedPaths.append(path)
        }
    }
    
    /// Toggle watch status for a project
    func toggleWatch(_ path: String) {
        if watchedPaths.contains(path) {
            watchedPaths.remove(path)
        } else {
            watchedPaths.insert(path)
        }
    }
    
    /// Move a pinned project to a new position
    func move(from source: IndexSet, to destination: Int) {
        pinnedPaths.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Get display name for a path
    func displayName(for path: String) -> String {
        URL(fileURLWithPath: path).lastPathComponent
    }
}

/// Represents a pinned project (may or may not be running)
struct PinnedProject: Identifiable {
    let id: String  // The path
    let path: String
    let displayName: String
    let isWatched: Bool
    var runningProcess: DevProcess?
    
    var isRunning: Bool {
        runningProcess != nil
    }
    
    init(path: String, isWatched: Bool, runningProcess: DevProcess? = nil) {
        self.id = path
        self.path = path
        self.displayName = URL(fileURLWithPath: path).lastPathComponent
        self.isWatched = isWatched
        self.runningProcess = runningProcess
    }
}
