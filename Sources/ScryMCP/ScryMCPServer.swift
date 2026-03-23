import Foundation
import ScryKit

/// Minimal MCP (Model Context Protocol) server over stdio.
/// Implements the JSON-RPC subset needed for a single-tool MCP server.
struct ScryMCPServer {
    private let scanner = ProcessScanner()

    func run() async {
        // Read JSON-RPC messages from stdin, write responses to stdout
        let input = FileHandle.standardInput
        let output = FileHandle.standardOutput

        while let message = readMessage(from: input) {
            guard let request = parseRequest(message) else {
                sendError(id: nil, code: -32700, message: "Parse error", to: output)
                continue
            }

            // Notifications (no id) don't get a response
            guard request.id != nil else { continue }

            let response = await handleRequest(request)
            sendMessage(response, to: output)
        }
    }

    // MARK: - Message Framing (Content-Length headers)

    private func readMessage(from handle: FileHandle) -> Data? {
        // Read headers until empty line
        var contentLength = 0
        var headerLine = ""

        while true {
            guard let byte = readByte(from: handle) else { return nil }
            let char = Character(UnicodeScalar(byte))

            if char == "\n" {
                let trimmed = headerLine.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    // End of headers
                    break
                }
                if trimmed.lowercased().hasPrefix("content-length:") {
                    let value = trimmed.dropFirst("content-length:".count).trimmingCharacters(in: .whitespaces)
                    contentLength = Int(value) ?? 0
                }
                headerLine = ""
            } else {
                headerLine.append(char)
            }
        }

        guard contentLength > 0 else { return nil }

        // Read exactly contentLength bytes
        var data = Data()
        for _ in 0..<contentLength {
            guard let byte = readByte(from: handle) else { return nil }
            data.append(byte)
        }
        return data
    }

    private func readByte(from handle: FileHandle) -> UInt8? {
        let data = handle.readData(ofLength: 1)
        return data.first
    }

    private func sendMessage(_ data: Data, to handle: FileHandle) {
        let header = "Content-Length: \(data.count)\r\n\r\n"
        handle.write(header.data(using: .utf8)!)
        handle.write(data)
    }

    private func sendError(id: JSONValue?, code: Int, message: String, to handle: FileHandle) {
        let response: [String: JSONValue] = [
            "jsonrpc": .string("2.0"),
            "id": id ?? .null,
            "error": .object([
                "code": .int(code),
                "message": .string(message)
            ])
        ]
        if let data = try? JSONEncoder().encode(response) {
            sendMessage(data, to: handle)
        }
    }

    // MARK: - Request Handling

    private func parseRequest(_ data: Data) -> JSONRPCRequest? {
        try? JSONDecoder().decode(JSONRPCRequest.self, from: data)
    }

    private func handleRequest(_ request: JSONRPCRequest) async -> Data {
        switch request.method {
        case "initialize":
            return initializeResponse(id: request.id)
        case "tools/list":
            return toolsListResponse(id: request.id)
        case "tools/call":
            return await toolsCallResponse(id: request.id, params: request.params)
        default:
            return errorResponse(id: request.id, code: -32601, message: "Method not found: \(request.method)")
        }
    }

    private func initializeResponse(id: JSONValue?) -> Data {
        let result: [String: JSONValue] = [
            "protocolVersion": .string("2024-11-05"),
            "capabilities": .object([
                "tools": .object([:])
            ]),
            "serverInfo": .object([
                "name": .string("scry"),
                "version": .string("0.2.0")
            ])
        ]
        return jsonRPCResponse(id: id, result: .object(result))
    }

    private func toolsListResponse(id: JSONValue?) -> Data {
        let tool: [String: JSONValue] = [
            "name": .string("list_dev_servers"),
            "description": .string("List all running dev servers on this machine. Returns port, framework, git branch, working directory, and groups servers by git root."),
            "inputSchema": .object([
                "type": .string("object"),
                "properties": .object([
                    "port": .object([
                        "type": .string("integer"),
                        "description": .string("Filter to a specific port")
                    ])
                ])
            ])
        ]
        let result: [String: JSONValue] = [
            "tools": .array([.object(tool)])
        ]
        return jsonRPCResponse(id: id, result: .object(result))
    }

    private func toolsCallResponse(id: JSONValue?, params: JSONValue?) async -> Data {
        // Extract tool name and arguments
        guard case .object(let paramsDict) = params,
              case .string(let toolName) = paramsDict["name"],
              toolName == "list_dev_servers" else {
            return errorResponse(id: id, code: -32602, message: "Unknown tool")
        }

        // Extract optional port filter
        var portFilter: Int?
        if case .object(let args) = paramsDict["arguments"],
           case .int(let port) = args["port"] {
            portFilter = port
        }

        // Scan for dev servers
        var processes = await scanner.scan()
        if let port = portFilter {
            processes = processes.filter { $0.port == port }
        }

        // Build output JSON
        let output = buildOutputJSON(from: processes)

        let result: [String: JSONValue] = [
            "content": .array([
                .object([
                    "type": .string("text"),
                    "text": .string(output)
                ])
            ])
        ]
        return jsonRPCResponse(id: id, result: .object(result))
    }

    // MARK: - Output Building

    private func buildOutputJSON(from processes: [DevProcess]) -> String {
        var servers: [[String: Any]] = []
        var groups: [String: [String: Any]] = [:]

        for process in processes {
            var server: [String: Any] = [
                "pid": process.id,
                "port": process.port,
                "name": process.name,
                "displayName": process.displayName
            ]
            if let fw = process.framework { server["framework"] = fw.rawValue }
            if let root = process.gitRoot { server["gitRoot"] = root }
            if let branch = process.gitBranch { server["gitBranch"] = branch }
            if let dir = process.workingDirectory { server["workingDirectory"] = dir }
            if let cmd = process.command { server["command"] = cmd }
            servers.append(server)

            // Build groups
            if let root = process.gitRoot {
                if groups[root] == nil {
                    groups[root] = [
                        "name": URL(fileURLWithPath: root).lastPathComponent,
                        "branch": process.gitBranch as Any,
                        "servers": [process.id]
                    ]
                } else {
                    var existing = groups[root]!
                    var pids = existing["servers"] as! [Int32]
                    pids.append(process.id)
                    existing["servers"] = pids
                    groups[root] = existing
                }
            }
        }

        let output: [String: Any] = ["servers": servers, "groups": groups]

        guard let data = try? JSONSerialization.data(withJSONObject: output, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    // MARK: - JSON-RPC Helpers

    private func jsonRPCResponse(id: JSONValue?, result: JSONValue) -> Data {
        let response: [String: JSONValue] = [
            "jsonrpc": .string("2.0"),
            "id": id ?? .null,
            "result": result
        ]
        return (try? JSONEncoder().encode(response)) ?? Data()
    }

    private func errorResponse(id: JSONValue?, code: Int, message: String) -> Data {
        let response: [String: JSONValue] = [
            "jsonrpc": .string("2.0"),
            "id": id ?? .null,
            "error": .object([
                "code": .int(code),
                "message": .string(message)
            ])
        ]
        return (try? JSONEncoder().encode(response)) ?? Data()
    }
}

// MARK: - JSON-RPC Types

struct JSONRPCRequest: Decodable {
    let jsonrpc: String
    let id: JSONValue?
    let method: String
    let params: JSONValue?
}

/// Generic JSON value for encoding/decoding JSON-RPC messages
enum JSONValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else {
            throw DecodingError.typeMismatch(JSONValue.self, .init(codingPath: decoder.codingPath, debugDescription: "Unknown JSON type"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .null: try container.encodeNil()
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }
}
