import XCTest
@testable import Scry

final class PathTruncationTests: XCTestCase {
    
    func testTruncatedPath_shortPath_returnsUnchanged() {
        let path = "~/Code/scry"
        XCTAssertEqual(path.truncatedPath(maxLength: 50), path)
    }
    
    func testTruncatedPath_longPath_truncatesMiddle() {
        let path = "~/Code/heyblathers/apps/mobile/ios/src/components"
        let truncated = path.truncatedPath(maxLength: 30, gitRootName: "heyblathers")
        
        XCTAssertTrue(truncated.contains("heyblathers"))
        XCTAssertTrue(truncated.contains("components"))
        XCTAssertTrue(truncated.contains("…"))
    }
    
    func testTruncatedPath_withGitRoot_preservesRoot() {
        let path = "~/Code/myproject/packages/deep/nested/folder"
        let truncated = path.truncatedPath(maxLength: 30, gitRootName: "myproject")
        
        XCTAssertTrue(truncated.hasPrefix("~/Code/myproject"))
        XCTAssertTrue(truncated.hasSuffix("folder"))
    }
    
    func testTruncatedPath_veryShortComponents_returnsAsIs() {
        let path = "~/a/b"
        XCTAssertEqual(path.truncatedPath(maxLength: 5), path)
    }
}
