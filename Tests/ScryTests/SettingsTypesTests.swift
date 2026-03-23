import XCTest
@testable import ScryKit

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
