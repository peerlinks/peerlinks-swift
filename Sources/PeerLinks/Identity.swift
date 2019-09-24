import Foundation
import Sodium

public class Identity {
  let sodium: Sodium
  let publicKey: Bytes
  let debugID: String

  // TODO(indutny): use some serializable object
  var metadata: [String: String]?

  private var secretKey: Bytes

  init(sodium: Sodium, publicKey: Bytes, secretKey: Bytes) {
    self.sodium = sodium
    self.publicKey = publicKey
    self.secretKey = secretKey

    self.debugID = Debug.toID(sodium: sodium, publicKey: self.publicKey)
  }

  convenience init(sodium: Sodium) {
    let keyPair = sodium.sign.keyPair()!

    self.init(
        sodium: sodium,
        publicKey: keyPair.publicKey,
        secretKey: keyPair.secretKey)
  }

  deinit {
    sodium.utils.zero(&secretKey)
  }

  //
  // Chains
  //

  func issueLink(for trusteePubKey: Bytes,
                 trusteeName: String,
                 validity: (from: TimeInterval, to: TimeInterval),
                 andChannel channel: Channel) -> Link {
    return Link()
  }

  func issueLink(for trusteePubKey: Bytes,
                 trusteeName: String,
                 andChannel channel: Channel) -> Link {
    let now = NSDate().timeIntervalSince1970

    return issueLink(
        for: trusteePubKey,
        trusteeName: trusteeName,
        validity: (
          from: now - Link.EXPIRATION_LEEWAY,
          to: now + Link.EXPIRATION_DELTA
        ),
        andChannel: channel)
  }
}
