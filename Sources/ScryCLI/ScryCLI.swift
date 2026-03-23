import ArgumentParser
import ScryKit
import Foundation

@main
struct ScryCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "scry",
        abstract: "Dev server detective — find running dev servers on your machine",
        subcommands: [List.self],
        defaultSubcommand: List.self
    )
}

// MARK: - List Command

struct List: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ls",
        abstract: "List running dev servers"
    )

    @Flag(name: .long, help: "Output as JSON (grouped by git root)")
    var json = false

    @Option(name: .long, help: "Filter to a specific port")
    var port: Int?

    func run() async throws {
        let scanner = ProcessScanner()
        var processes = await scanner.scan()

        if let port = port {
            processes = processes.filter { $0.port == port }
        }

        if json {
            printJSON(processes)
        } else {
            printTable(processes)
        }
    }
}

// MARK: - Table Output

private func printTable(_ processes: [DevProcess]) {
    if processes.isEmpty {
        print("No dev servers running.")
        return
    }

    // Column widths
    let portWidth = 6
    let fwWidth = 12
    let nameWidth = 24
    let branchWidth = 16

    // Header
    let header = [
        "PORT".padding(toLength: portWidth, withPad: " ", startingAt: 0),
        "FRAMEWORK".padding(toLength: fwWidth, withPad: " ", startingAt: 0),
        "NAME".padding(toLength: nameWidth, withPad: " ", startingAt: 0),
        "BRANCH".padding(toLength: branchWidth, withPad: " ", startingAt: 0),
        "DIRECTORY"
    ].joined(separator: "  ")

    print(header)
    print(String(repeating: "─", count: header.count))

    for process in processes {
        let port = ":\(process.port)".padding(toLength: portWidth, withPad: " ", startingAt: 0)
        let fw = (process.framework?.displayName ?? "—").padding(toLength: fwWidth, withPad: " ", startingAt: 0)
        let name = process.displayName.padding(toLength: nameWidth, withPad: " ", startingAt: 0)
        let branch = (process.gitBranch ?? "—").padding(toLength: branchWidth, withPad: " ", startingAt: 0)
        let dir = abbreviatePath(process.workingDirectory ?? "—")

        print([port, fw, name, branch, dir].joined(separator: "  "))
    }
}

// MARK: - JSON Output

private func printJSON(_ processes: [DevProcess]) {
    let output = ScryCLIOutput(from: processes)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    guard let data = try? encoder.encode(output),
          let jsonString = String(data: data, encoding: .utf8) else {
        print("{}")
        return
    }
    print(jsonString)
}

/// JSON output structure
struct ScryCLIOutput: Encodable {
    let servers: [ServerInfo]
    let groups: [String: GroupInfo]

    init(from processes: [DevProcess]) {
        self.servers = processes.map { ServerInfo(from: $0) }

        // Group by git root
        var groupMap: [String: GroupInfo] = [:]
        for process in processes {
            guard let root = process.gitRoot else { continue }
            if groupMap[root] == nil {
                let name = URL(fileURLWithPath: root).lastPathComponent
                groupMap[root] = GroupInfo(
                    name: name,
                    branch: process.gitBranch,
                    servers: [process.id]
                )
            } else {
                groupMap[root]?.servers.append(process.id)
            }
        }
        self.groups = groupMap
    }
}

struct ServerInfo: Encodable {
    let pid: Int32
    let port: Int
    let name: String
    let displayName: String
    let framework: String?
    let gitRoot: String?
    let gitBranch: String?
    let workingDirectory: String?
    let command: String?

    init(from process: DevProcess) {
        self.pid = process.id
        self.port = process.port
        self.name = process.name
        self.displayName = process.displayName
        self.framework = process.framework?.rawValue
        self.gitRoot = process.gitRoot
        self.gitBranch = process.gitBranch
        self.workingDirectory = process.workingDirectory
        self.command = process.command
    }
}

struct GroupInfo: Encodable {
    let name: String
    let branch: String?
    var servers: [Int32]
}

// MARK: - Utilities

private func abbreviatePath(_ path: String) -> String {
    let home = FileManager.default.homeDirectoryForCurrentUser.path
    if path.hasPrefix(home) {
        return "~" + path.dropFirst(home.count)
    }
    return path
}
