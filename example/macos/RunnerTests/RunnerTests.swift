import FlutterMacOS
import XCTest

@testable import widgetkit_macos

/// The native half: what reaches UserDefaults and what is refused.
class RunnerTests: XCTestCase {
  private let group = "widgetkit_macos.tests"

  private func call(_ method: String, _ arguments: [String: Any]) -> Any? {
    var answer: Any?
    let done = expectation(description: method)
    WidgetkitMacosPlugin().handle(FlutterMethodCall(methodName: method, arguments: arguments)) {
      answer = $0
      done.fulfill()
    }
    waitForExpectations(timeout: 1)
    return answer
  }

  func testNullRemovesTheKey() {
    XCTAssertNil(call("saveWidgetData", ["appGroup": group, "key": "k", "value": "v"]))
    XCTAssertEqual(call("getWidgetData", ["appGroup": group, "key": "k"]) as? String, "v")
    XCTAssertNil(call("saveWidgetData", ["appGroup": group, "key": "k", "value": NSNull()]))
    XCTAssertNil(call("getWidgetData", ["appGroup": group, "key": "k"]))
  }

  func testNestedValuesAreRefused() {
    let answer = call("saveWidgetData", ["appGroup": group, "key": "k", "value": [NSNull()]])
    XCTAssertEqual((answer as? FlutterError)?.code, "bad-args")
  }

  func testReloadWithoutKindIsRefused() {
    let answer = call("reloadTimelines", ["appGroup": group])
    XCTAssertEqual((answer as? FlutterError)?.code, "bad-args")
  }
}
