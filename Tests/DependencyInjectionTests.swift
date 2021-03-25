import XCTest
@testable import DependencyInjection

final class DependencyInjectionTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Container().text, "Hello world!")
    }
}
