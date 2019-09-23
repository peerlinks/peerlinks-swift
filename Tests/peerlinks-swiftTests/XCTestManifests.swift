import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(peerlinks_swiftTests.allTests),
    ]
}
#endif
