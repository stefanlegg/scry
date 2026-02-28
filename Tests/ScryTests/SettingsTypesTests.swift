import XCTest
@testable import Scry

final class ShowStoppedModeTests: XCTestCase {
    
    func testDisplayNames() {
        XCTAssertEqual(ShowStoppedMode.none.displayName, "Never")
        XCTAssertEqual(ShowStoppedMode.pinnedOnly.displayName, "Pinned only")
        XCTAssertEqual(ShowStoppedMode.all.displayName, "All recently seen")
    }
    
    func testRawValues() {
        XCTAssertEqual(ShowStoppedMode.none.rawValue, "none")
        XCTAssertEqual(ShowStoppedMode.pinnedOnly.rawValue, "pinnedOnly")
        XCTAssertEqual(ShowStoppedMode.all.rawValue, "all")
    }
    
    func testInitFromRawValue() {
        XCTAssertEqual(ShowStoppedMode(rawValue: "none"), ShowStoppedMode.none)
        XCTAssertEqual(ShowStoppedMode(rawValue: "pinnedOnly"), ShowStoppedMode.pinnedOnly)
        XCTAssertEqual(ShowStoppedMode(rawValue: "all"), ShowStoppedMode.all)
        XCTAssertNil(ShowStoppedMode(rawValue: "invalid"))
    }
}

final class RestartModeTests: XCTestCase {
    
    func testDisplayNames() {
        XCTAssertEqual(RestartMode.terminal.displayName, "Open in Terminal")
        XCTAssertEqual(RestartMode.background.displayName, "Run in background")
    }
    
    func testRawValues() {
        XCTAssertEqual(RestartMode.terminal.rawValue, "terminal")
        XCTAssertEqual(RestartMode.background.rawValue, "background")
    }
    
    func testInitFromRawValue() {
        XCTAssertEqual(RestartMode(rawValue: "terminal"), .terminal)
        XCTAssertEqual(RestartMode(rawValue: "background"), .background)
        XCTAssertNil(RestartMode(rawValue: "invalid"))
    }
}

final class ExcludedPortTests: XCTestCase {
    
    func testEquality_samePort() {
        let port1 = ExcludedPort(port: 3000, label: "Dev Server")
        let port2 = ExcludedPort(port: 3000, label: "Different Label")
        
        XCTAssertEqual(port1, port2)
    }
    
    func testEquality_differentPort() {
        let port1 = ExcludedPort(port: 3000, label: "Dev Server")
        let port2 = ExcludedPort(port: 3001, label: "Dev Server")
        
        XCTAssertNotEqual(port1, port2)
    }
}

final class DevProcessTypeTests: XCTestCase {
    
    func testIsDevProcess_knownTypes() {
        XCTAssertTrue(DevProcessType.isDevProcess("node"))
        XCTAssertTrue(DevProcessType.isDevProcess("bun"))
        XCTAssertTrue(DevProcessType.isDevProcess("deno"))
        XCTAssertTrue(DevProcessType.isDevProcess("python"))
        XCTAssertTrue(DevProcessType.isDevProcess("python3"))
        XCTAssertTrue(DevProcessType.isDevProcess("ruby"))
        XCTAssertTrue(DevProcessType.isDevProcess("cargo"))
        XCTAssertTrue(DevProcessType.isDevProcess("go"))
        XCTAssertTrue(DevProcessType.isDevProcess("java"))
        XCTAssertTrue(DevProcessType.isDevProcess("php"))
    }
    
    func testIsDevProcess_caseInsensitive() {
        XCTAssertTrue(DevProcessType.isDevProcess("NODE"))
        XCTAssertTrue(DevProcessType.isDevProcess("Node"))
        XCTAssertTrue(DevProcessType.isDevProcess("PYTHON"))
    }
    
    func testIsDevProcess_partialMatch() {
        XCTAssertTrue(DevProcessType.isDevProcess("node-server"))
        XCTAssertTrue(DevProcessType.isDevProcess("/usr/bin/python3"))
    }
    
    func testIsDevProcess_unknownTypes() {
        XCTAssertFalse(DevProcessType.isDevProcess("Spotify"))
        XCTAssertFalse(DevProcessType.isDevProcess("Discord"))
        XCTAssertFalse(DevProcessType.isDevProcess("Safari"))
    }
}
