import XCTest
@testable import Scry

final class DevProcessTests: XCTestCase {
    
    // MARK: - Display Name Tests
    
    func testDisplayName_singleProject_returnsLeafFolder() {
        let process = DevProcess(
            id: 1234,
            name: "node",
            port: 3000,
            workingDirectory: "/Users/test/Code/scry",
            gitRoot: "/Users/test/Code/scry",
            gitBranch: "main",
            command: "node server.js"
        )
        
        XCTAssertEqual(process.displayName, "scry")
    }
    
    func testDisplayName_monorepo_returnsRepoSlashLeaf() {
        let process = DevProcess(
            id: 1234,
            name: "node",
            port: 3000,
            workingDirectory: "/Users/test/Code/heyblathers/apps/web",
            gitRoot: "/Users/test/Code/heyblathers",
            gitBranch: "main",
            command: "next dev"
        )
        
        XCTAssertEqual(process.displayName, "heyblathers/web")
    }
    
    func testDisplayName_monorepoDeepNesting_returnsRepoSlashLeaf() {
        let process = DevProcess(
            id: 1234,
            name: "node",
            port: 3000,
            workingDirectory: "/Users/test/Code/myproject/packages/apps/mobile/ios",
            gitRoot: "/Users/test/Code/myproject",
            gitBranch: "develop",
            command: "expo start"
        )
        
        XCTAssertEqual(process.displayName, "myproject/ios")
    }
    
    func testDisplayName_noGitRoot_returnsLeafFolder() {
        let process = DevProcess(
            id: 1234,
            name: "python",
            port: 8000,
            workingDirectory: "/Users/test/scripts/server",
            gitRoot: nil,
            gitBranch: nil,
            command: "python -m http.server"
        )
        
        XCTAssertEqual(process.displayName, "server")
    }
    
    func testDisplayName_noWorkingDir_returnsProcessName() {
        let process = DevProcess(
            id: 1234,
            name: "node",
            port: 3000,
            workingDirectory: nil,
            gitRoot: nil,
            gitBranch: nil,
            command: nil
        )
        
        XCTAssertEqual(process.displayName, "node")
    }
    
    // MARK: - Repo Name Tests
    
    func testRepoName_withGitRoot_returnsRootName() {
        let process = DevProcess(
            id: 1234,
            name: "node",
            port: 3000,
            workingDirectory: "/Users/test/Code/heyblathers/apps/web",
            gitRoot: "/Users/test/Code/heyblathers",
            gitBranch: "main",
            command: nil
        )
        
        XCTAssertEqual(process.repoName, "heyblathers")
    }
    
    func testRepoName_noGitRoot_returnsWorkingDirName() {
        let process = DevProcess(
            id: 1234,
            name: "node",
            port: 3000,
            workingDirectory: "/Users/test/Code/myapp",
            gitRoot: nil,
            gitBranch: nil,
            command: nil
        )
        
        XCTAssertEqual(process.repoName, "myapp")
    }
    
    // MARK: - Browser URL Tests
    
    func testBrowserURL_returnsLocalhostWithPort() {
        let process = DevProcess(
            id: 1234,
            name: "node",
            port: 3456,
            workingDirectory: nil,
            gitRoot: nil,
            gitBranch: nil,
            command: nil
        )
        
        XCTAssertEqual(process.browserURL?.absoluteString, "http://localhost:3456")
    }
    
    // MARK: - Equality Tests
    
    func testEquality_sameId_areEqual() {
        let process1 = DevProcess(id: 100, name: "node", port: 3000, workingDirectory: nil, gitRoot: nil, gitBranch: nil, command: nil)
        let process2 = DevProcess(id: 100, name: "bun", port: 4000, workingDirectory: "/different", gitRoot: nil, gitBranch: nil, command: nil)
        
        XCTAssertEqual(process1, process2)
    }
    
    func testEquality_differentId_areNotEqual() {
        let process1 = DevProcess(id: 100, name: "node", port: 3000, workingDirectory: nil, gitRoot: nil, gitBranch: nil, command: nil)
        let process2 = DevProcess(id: 101, name: "node", port: 3000, workingDirectory: nil, gitRoot: nil, gitBranch: nil, command: nil)
        
        XCTAssertNotEqual(process1, process2)
    }
}
