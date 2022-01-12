import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OktaSwiftUIModuleTests.allTests),
    ]
}
#endif
