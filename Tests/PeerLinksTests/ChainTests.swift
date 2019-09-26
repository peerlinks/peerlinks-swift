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

    channelA = Channel(
        sodium: sodium, publicKey: idA.publicKey, name: "channel-a")
    channelB = Channel(
        sodium: sodium, publicKey: idA.publicKey, name: "channel-b")
  }

  func testIssuedByIdentity() {
  }
}
