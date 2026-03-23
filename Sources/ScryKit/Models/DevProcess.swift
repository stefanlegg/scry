import Foundation

/// Represents a running development server process
public struct DevProcess: Identifiable, Hashable {
    public let id: Int32  // PID
    public let name: String  // Process name (node, bun, python, etc.)
    public let port: Int
    public let workingDirectory: String?
    public let gitRoot: String?  // Root of the git repo (may differ from workingDirectory in monorepos)
    public let gitBranch: String?
    public let command: String?  // Full command line

    public init(id: Int32, name: String, port: Int, workingDirectory: String?, gitRoot: String?, gitBranch: String?, command: String?) {
        self.id = id
        self.name = name
        self.port = port
        self.workingDirectory = workingDirectory
        self.gitRoot = gitRoot
        self.gitBranch = gitBranch
        self.command = command
    }

    public var displayName: String {
        guard let dir = workingDirectory else { return name }

        let dirURL = URL(fileURLWithPath: dir)
        let leafFolder = dirURL.lastPathComponent

        if let root = gitRoot, root != dir {
            let rootName = URL(fileURLWithPath: root).lastPathComponent
            if leafFolder != rootName {
                return "\(rootName)/\(leafFolder)"
            }
        }

        return leafFolder
    }

    public var repoName: String? {
        if let root = gitRoot {
            return URL(fileURLWithPath: root).lastPathComponent
        }
        guard let dir = workingDirectory else { return nil }
        return URL(fileURLWithPath: dir).lastPathComponent
    }

    public var browserURL: URL? {
        URL(string: "http://localhost:\(port)")
    }

    /// Detected framework based on the command string
    public var framework: DevFramework? {
        FrameworkDetector.detect(from: command)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DevProcess, rhs: DevProcess) -> Bool {
        lhs.id == rhs.id
    }
}

/// Known dev process patterns
public enum DevProcessType: String, CaseIterable {
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

    public static func isDevProcess(_ name: String) -> Bool {
        let lowercased = name.lowercased()
        return allCases.contains { lowercased.contains($0.rawValue) }
    }
}
