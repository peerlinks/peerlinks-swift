import XCTest
@testable import PeerLinks

import Foundation
import Sodium

final class LinkTests: XCTestCase {
  let sodium = Sodium()
  var issuer: Identity!

  override func setUp() {
    issuer = Identity(sodium: sodium, name: "issuer")
  }

  func testIssuedByIdentity() {
    let channel = Channel(
        sodium: sodium,
        publicKey: issuer.publicKey,
        name: "test-channel")

    let trustee = Identity(sodium: sodium, name: "trustee")

    let link = try! issuer.issueLink(
        for: trustee.publicKey,
        trusteeName: trustee.name,
        andChannel: channel)

    XCTAssertTrue(
        link.verify(withChannel: channel, publicKey: issuer.publicKey))
    XCTAssertTrue(link.isValid())
    XCTAssertFalse(
        link.verify(withChannel: channel, publicKey: trustee.publicKey))

    // Invalid because of timestamp
    let ONE_YEAR: TimeInterval = 365 * 24 * 3600.0

    XCTAssertFalse(link.verify(
          withChannel: channel,
          publicKey: issuer.publicKey,
          andTimestamp: Utils.now() + ONE_YEAR))
    XCTAssertFalse(link.isValid(at: Utils.now() + ONE_YEAR))
  }

  func testThrowsOnInvalidNameLength() {
    let channel = Channel(
        sodium: sodium, publicKey: issuer.publicKey, name: "test-channel")

    let trustee = Identity(sodium: sodium, name: "trustee")

    do {
      let _ = try issuer.issueLink(
          for: trustee.publicKey,
          trusteeName: String(repeating: "trustee", count: 100),
          andChannel: channel)
      XCTFail()
    } catch BanError.invalidLinkDisplayNameSize(let size) {
      XCTAssertEqual(size, 700)
    } catch {
      XCTFail()
    }
  }
}
