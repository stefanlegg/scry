import Foundation

/// Represents a running development server process
struct DevProcess: Identifiable, Hashable {
    let id: Int32  // PID
    let name: String  // Process name (node, bun, python, etc.)
    let port: Int
    let workingDirectory: String?
    let gitRoot: String?  // Root of the git repo (may differ from workingDirectory in monorepos)
    let gitBranch: String?
    let command: String?  // Full command line
    
    var displayName: String {
        // Smart monorepo-aware labeling:
        // If workingDirectory differs from gitRoot, show "repoName/leafFolder"
        // Otherwise just show the folder name
        guard let dir = workingDirectory else { return name }
        
        let dirURL = URL(fileURLWithPath: dir)
        let leafFolder = dirURL.lastPathComponent
        
        // If we have a git root and it's different from working directory
        if let root = gitRoot, root != dir {
            let rootName = URL(fileURLWithPath: root).lastPathComponent
            // Avoid duplication if leaf == root name (shouldn't happen, but safety)
            if leafFolder != rootName {
                return "\(rootName)/\(leafFolder)"
            }
        }
        
        return leafFolder
    }
    
    var repoName: String? {
        // Prefer git root name, fall back to working directory
        if let root = gitRoot {
            return URL(fileURLWithPath: root).lastPathComponent
        }
        guard let dir = workingDirectory else { return nil }
        return URL(fileURLWithPath: dir).lastPathComponent
    }
    
    var browserURL: URL? {
        URL(string: "http://localhost:\(port)")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DevProcess, rhs: DevProcess) -> Bool {
        lhs.id == rhs.id
    }
}

/// Known dev process patterns
enum DevProcessType: String, CaseIterable {
    case node = "node"
    case bun = "bun"
    case deno = "deno"
    case python = "python"
    case python3 = "python3"
    case ruby = "ruby"
    case cargo = "cargo"
    case go = "go"
    case java = "java"
    case php = "php"
    
    static func isDevProcess(_ name: String) -> Bool {
        let lowercased = name.lowercased()
        return allCases.contains { lowercased.contains($0.rawValue) }
    }
}
