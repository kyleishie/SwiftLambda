import XCTest
@testable import SwiftLambda

final class SwiftLambdaTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftLambda().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
