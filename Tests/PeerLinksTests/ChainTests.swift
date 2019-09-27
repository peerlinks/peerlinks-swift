import XCTest
@testable import PeerLinks

import Foundation
import Sodium

final class ChainTests: XCTestCase {
  let sodium = Sodium()

  var idA: Identity!
  var idB: Identity!
  var idC: Identity!
  var idD: Identity!

  var channelA: Channel!
  var channelB: Channel!

  override func setUp() {
    idA = Identity(sodium: sodium, name: "a")
    idB = Identity(sodium: sodium, name: "b")
    idC = Identity(sodium: sodium, name: "c")
    idD = Identity(sodium: sodium, name: "d")

    channelA = try! Channel(
        sodium: sodium, publicKey: idA.publicKey, name: "channel-a")
    channelB = try! Channel(
        sodium: sodium, publicKey: idA.publicKey, name: "channel-b")
  }

  func testLengthCheck() {
    let links = [
      try! idA.issueLink(
          for: idB.publicKey, trusteeName: "b", andChannel: channelA),
      try! idB.issueLink(
          for: idC.publicKey, trusteeName: "c", andChannel: channelA),
      try! idC.issueLink(
          for: idD.publicKey, trusteeName: "d", andChannel: channelA),
      try! idD.issueLink(
          for: idA.publicKey, trusteeName: "a", andChannel: channelA),
    ]

    do {
      let _ = try Chain(links: links)
      XCTFail()
    } catch BanError.invalidChainLength(let size) {
      XCTAssertEqual(size, 4)
    } catch {
      XCTFail()
    }
  }
}
