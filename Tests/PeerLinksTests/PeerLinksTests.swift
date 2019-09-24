import XCTest
@testable import PeerLinks

import Sodium

final class PeerLinksTests: XCTestCase {
  let sodium = Sodium()

  func testExample() {
    let idA = Identity(sodium: sodium, name: "a")
    let idB = Identity(sodium: sodium, name: "b")

    let channelA = Channel(sodium: sodium, publicKey: idA.publicKey)

    let link = try! idA.issueLink(
        for: idB.publicKey,
        trusteeName: idB.name,
        validity: nil,
        andChannel: channelA)

    print("\(link)")
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
