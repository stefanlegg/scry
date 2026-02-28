import Foundation

/// Represents a running development server process
struct DevProcess: Identifiable, Hashable {
    let id: Int32  // PID
    let name: String  // Process name (node, bun, python, etc.)
    let port: Int
    let workingDirectory: String?
    let gitBranch: String?
    let command: String?  // Full command line
    
    var displayName: String {
        // Try to extract a meaningful name from the command or directory
        if let dir = workingDirectory {
            return URL(fileURLWithPath: dir).lastPathComponent
        }
        return name
    }
    
    var repoName: String? {
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
