import Foundation

let server = ScryMCPServer()

// Run the MCP server event loop
let semaphore = DispatchSemaphore(value: 0)
Task {
    await server.run()
    semaphore.signal()
}
semaphore.wait()
