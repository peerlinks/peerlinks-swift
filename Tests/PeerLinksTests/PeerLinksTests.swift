import XCTest
@testable import PeerLinks

import Sodium

final class PeerLinksTests: XCTestCase {
  let sodium = Sodium()

  func linkSerializeDeserialize() {
    let idA = Identity(sodium: sodium, name: "a")
    let idB = Identity(sodium: sodium, name: "b")

    let channelA = Channel(sodium: sodium, publicKey: idA.publicKey)

    let link = try! idA.issueLink(
        for: idB.publicKey,
        trusteeName: idB.name,
        validity: nil,
        andChannel: channelA)

    let data = try! link.serializedData()
    let copy = try! Link.deserializeData(sodium: sodium, data: data)

    print("\(copy)")
  }

  static var allTests = [
    ("linkSerializeDeserialize", linkSerializeDeserialize),
  ]
}
