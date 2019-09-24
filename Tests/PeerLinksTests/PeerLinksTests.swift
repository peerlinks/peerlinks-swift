import XCTest
@testable import PeerLinks

import Sodium

final class PeerLinksTests: XCTestCase {
  let sodium = Sodium()

  func testExample() {
    let id = Identity(sodium: sodium)
    print("{}", id.debugID)
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
