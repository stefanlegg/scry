# Scry Settings Design

## Core Concepts

### Project Identity
A "project" is identified by its **working directory path**. Port is a runtime attribute that can change.

This means:
- `~/Code/heyblathers` on `:3000` today
- `~/Code/heyblathers` on `:3001` tomorrow
- → Same project, different port

### Port Reuse Problem
If two different projects run on `:3000` at different times:
- We detect them as different projects (different working dirs)
- Each gets its own entry, settings, label, etc.
- No conflict

If the SAME project runs on different ports:
- Still same identity (same working dir)
- We show whichever port it's currently on
- History could track "last seen on port X"

---

## Settings Structure

### Global Settings

```swift
struct GlobalSettings: Codable {
    // Persistence
    var showStoppedApps: ShowStoppedMode = .pinnedOnly
    
    // Notifications
    var notificationsEnabled: Bool = true
    var notifyOnCrash: NotifyMode = .watchedOnly
    var notifyOnStart: Bool = false
    
    // Scanning
    var portRangeMin: Int = 3000
    var portRangeMax: Int = 9999
    var refreshInterval: TimeInterval = 5.0
    
    // UI
    var showGitBranch: Bool = true
    var abbreviatePaths: Bool = true
    var groupByMonorepo: Bool = false
    
    // Behavior
    var launchAtLogin: Bool = false
    var globalHotkey: String = "⌥⇧S"
}

enum ShowStoppedMode: String, Codable {
    case none           // Only show running processes
    case pinnedOnly     // Show pinned even when stopped (current behavior)
    case recent         // Show recently-seen (last 24h) even when stopped
    case all            // Show all ever-seen projects
}

enum NotifyMode: String, Codable {
    case none           // Never notify
    case watchedOnly    // Only notify for explicitly watched (current behavior)
    case pinned         // Notify for all pinned projects
    case all            // Notify for any stopped process
}
```

### Per-Project Settings

```swift
struct ProjectSettings: Codable, Identifiable {
    let id: String  // The working directory path (normalized)
    
    // Display
    var customLabel: String?        // Override display name
    var customIcon: String?         // SF Symbol name or emoji
    var colorTag: String?           // Color coding
    
    // Behavior
    var isPinned: Bool = false      // Show in pinned section
    var isWatched: Bool = false     // Notify on crash
    var persistWhenStopped: Bool?   // nil = use global setting
    
    // Metadata (auto-updated)
    var lastSeenPort: Int?
    var lastSeenAt: Date?
    var runCount: Int = 0
    
    // Computed
    var displayName: String {
        customLabel ?? URL(fileURLWithPath: id).lastPathComponent
    }
}
```

---

## Feature Interplay Matrix

| Setting | Pinned | Watched | Persist | Effect |
|---------|--------|---------|---------|--------|
| Pin only | ✅ | ❌ | auto | Shows at top, no crash notify, visible when stopped |
| Watch only | ❌ | ✅ | ❌ | Normal position, crash notify, hidden when stopped |
| Pin + Watch | ✅ | ✅ | auto | Top, crash notify, visible when stopped |
| Persist override | ❌ | ❌ | ✅ | Normal position, no notify, but stays visible when stopped |

**Key insight:** Pinned implies persistence, but persistence doesn't imply pinned.

---

## UI Flow

### Settings Window (⌘,)

```
┌─────────────────────────────────────────────────────┐
│  Scry Settings                                      │
├─────────────────────────────────────────────────────┤
│  General                                            │
│  ├─ [ ] Launch at login                             │
│  ├─ Hotkey: [⌥⇧S] [Record]                         │
│  └─ Refresh interval: [5] seconds                   │
│                                                     │
│  Display                                            │
│  ├─ Show stopped apps: [Pinned only ▾]             │
│  ├─ [✓] Show git branch                            │
│  ├─ [✓] Abbreviate paths (~/...)                   │
│  └─ [ ] Group by monorepo                          │
│                                                     │
│  Notifications                                      │
│  ├─ [✓] Enable notifications                        │
│  ├─ Notify on crash: [Watched only ▾]              │
│  └─ [ ] Notify when server starts                  │
│                                                     │
│  Scanning                                           │
│  ├─ Port range: [3000] to [9999]                   │
│  └─ Additional ports: [8080, 80, 443]              │
└─────────────────────────────────────────────────────┘
```

### Per-Project Settings (via context menu)

```
┌─────────────────────────────────────────────────────┐
│  heyblathers                              ✕        │
├─────────────────────────────────────────────────────┤
│  Label: [heyblathers        ]                      │
│  Path:  ~/Code/heyblathers (readonly)              │
│                                                     │
│  [✓] Pin to top                                    │
│  [✓] Notify when stopped                           │
│  [ ] Always show (even when stopped)               │
│                                                     │
│  Stats                                              │
│  ├─ Last seen: 2 minutes ago on :3000              │
│  └─ Run count: 47 times                            │
└─────────────────────────────────────────────────────┘
```

---

## Storage

All settings stored in UserDefaults (or a JSON file in `~/Library/Application Support/Scry/`):

```
~/Library/Application Support/Scry/
├── settings.json       # Global settings
├── projects.json       # Per-project settings (keyed by path)
└── history.json        # Optional: run history for stats
```

---

## Migration from Current Implementation

Current `PinnedProjectsStore` stores:
- `pinnedPaths: [String]` — paths in display order
- `watchedPaths: Set<String>` — paths to notify on crash

Migration:
1. Read existing data
2. Create `ProjectSettings` for each path
3. Set `isPinned` and `isWatched` accordingly
4. Write to new format
5. Delete old keys

---

## Open Questions

1. **Drag-drop reorder for pinned** — Already conceptually supported, need UI
2. **Custom icons** — SF Symbols picker? Emoji picker? Both?
3. **Color tags** — Predefined palette or custom?
4. **Export/import** — JSON export of all settings for backup/sync?
5. **iCloud sync** — Worth the complexity?
