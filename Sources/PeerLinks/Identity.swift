import Foundation
import Sodium

public class Identity {
  let sodium: Sodium
  var name: String
  let publicKey: Bytes
  let debugID: String

  // TODO(indutny): use some serializable object
  var metadata: [String: String]?

  private var secretKey: Bytes

  init(sodium: Sodium, name: String, publicKey: Bytes, secretKey: Bytes) {
    self.sodium = sodium
    self.name = name
    self.publicKey = publicKey
    self.secretKey = secretKey

    self.debugID = Debug.toID(sodium: sodium, publicKey: self.publicKey)
  }

  convenience init(sodium: Sodium, name: String) {
    let keyPair = sodium.sign.keyPair()!

    self.init(
        sodium: sodium,
        name: name,
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
                 validity: Link.ValidityRange? = nil,
                 andChannel channel: Channel) throws -> Link {
    let (tbs, validity) = try Link.tbs(
        trusteePubKey: trusteePubKey,
        trusteeName: trusteeName,
        validity: validity,
        andChannel: channel)
    let signature = sign(tbs: tbs)

    return try Link(
        sodium: sodium,
        trusteePubKey: trusteePubKey,
        trusteeName: trusteeName,
        validity: validity,
        signature: signature)
  }

  //
  // Sign/Verify
  //

  func sign(tbs: Bytes) -> Bytes {
    return sodium.sign.signature(message: tbs, secretKey: secretKey)!
  }
}
