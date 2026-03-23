import XCTest
@testable import ScryKit

final class FrameworkDetectorTests: XCTestCase {

    func testDetectsNext() {
        XCTAssertEqual(FrameworkDetector.detect(from: "node /app/.next/server"), .next)
        XCTAssertEqual(FrameworkDetector.detect(from: "node next-server"), .next)
        XCTAssertEqual(FrameworkDetector.detect(from: "node node_modules/.bin/next dev"), .next)
    }

    func testDetectsVite() {
        XCTAssertEqual(FrameworkDetector.detect(from: "node node_modules/.bin/vite"), .vite)
    }

    func testDetectsRemix() {
        XCTAssertEqual(FrameworkDetector.detect(from: "node node_modules/.bin/remix dev"), .remix)
    }

    func testDetectsNuxt() {
        XCTAssertEqual(FrameworkDetector.detect(from: "node .output/server/index.mjs nuxt"), .nuxt)
    }

    func testDetectsFlask() {
        XCTAssertEqual(FrameworkDetector.detect(from: "python -m flask run"), .flask)
    }

    func testDetectsDjango() {
        XCTAssertEqual(FrameworkDetector.detect(from: "python manage.py runserver"), .django)
    }

    func testDetectsFastAPI() {
        XCTAssertEqual(FrameworkDetector.detect(from: "uvicorn main:app --reload"), .uvicorn)
        XCTAssertEqual(FrameworkDetector.detect(from: "python -m fastapi dev"), .fastapi)
    }

    func testDetectsRails() {
        XCTAssertEqual(FrameworkDetector.detect(from: "ruby bin/rails server"), .rails)
    }

    func testDetectsLaravel() {
        XCTAssertEqual(FrameworkDetector.detect(from: "php artisan serve"), .laravel)
    }

    func testDetectsPhoenix() {
        XCTAssertEqual(FrameworkDetector.detect(from: "elixir --no-halt phx.server"), .phoenix)
    }

    func testDetectsCRA() {
        XCTAssertEqual(FrameworkDetector.detect(from: "node node_modules/react-scripts/scripts/start.js"), .cra)
    }

    func testNilForUnknownCommand() {
        XCTAssertNil(FrameworkDetector.detect(from: "node server.js"))
        XCTAssertNil(FrameworkDetector.detect(from: "python app.py"))
    }

    func testNilForNilCommand() {
        XCTAssertNil(FrameworkDetector.detect(from: nil))
    }

    func testDisplayName() {
        XCTAssertEqual(DevFramework.next.displayName, "next")
        XCTAssertEqual(DevFramework.cra.displayName, "react")
        XCTAssertEqual(DevFramework.fastapi.displayName, "fastapi")
    }
}
