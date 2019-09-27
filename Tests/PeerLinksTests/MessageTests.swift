import XCTest
@testable import PeerLinks

import Foundation
import Sodium

final class MessageTests: XCTestCase {
  let sodium = Sodium()
  var id: Identity!
  var channel: Channel!

  override func setUp() {
    id = Identity(sodium: sodium, name: "test")
    channel = try! Channel(
        sodium: sodium,
        publicKey: id.publicKey,
        name: "test-channel")

    try! id.add(chain: try! Chain(links: []), for: channel)
  }

  func testSignedVerified() {
    let second = Identity(sodium: sodium, name: "second")

    let link = try! id.issueLink(
        for: second.publicKey,
        trusteeName: second.name,
        andChannel: channel)

    let chain = try! Chain(links: [ link ])

    try! second.add(chain: chain, for: channel)

    let (tbs: tbs, signature: signature) = try! second.sign(
        messageBody: Message.json([ "okay": "ohai" ]),
        for: channel,
        height: 0,
        parents: [])

    let message = try! Message(sodium: sodium, tbs: tbs, signature: signature)
    XCTAssertTrue(message.verify(for: channel))

    XCTAssertEqual(message.chain.getLeafKey(for: channel),
        second.publicKey)
  }

  func testSerializedDeserialized() {
    let (tbs: tbs, signature: signature) = try! id.sign(
        messageBody: Message.json([ "okay": "ohai" ]),
        for: channel,
        height: 0,
        parents: [])

    let message = try! Message(sodium: sodium, tbs: tbs, signature: signature)

    let data = message.serializedData()
    let copy = try! Message.deserializeData(sodium: sodium, data: data)

    XCTAssertEqual(copy.height, message.height);
    XCTAssertEqual(copy.parents, message.parents);
  }
}
