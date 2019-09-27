import Foundation
import Sodium

public class Identity {
  let sodium: Sodium
  var name: String
  let publicKey: Data
  let debugID: String

  // TODO(indutny): use some serializable object
  var metadata: [String: String]?

  private var secretKey: Bytes

  init(sodium: Sodium, name: String, publicKey: Data, secretKey: Data) {
    self.sodium = sodium
    self.name = name
    self.publicKey = publicKey
    self.secretKey = Bytes(secretKey)

    self.debugID = Debug.toID(sodium: sodium, publicKey: self.publicKey)
  }

  convenience init(sodium: Sodium, name: String) {
    let keyPair = sodium.sign.keyPair()!

    self.init(
        sodium: sodium,
        name: name,
        publicKey: Data(keyPair.publicKey),
        secretKey: Data(keyPair.secretKey))
  }

  deinit {
    sodium.utils.zero(&secretKey)
  }

  //
  // Chains
  //

  func issueLink(for trusteePubKey: Data,
                 trusteeName: String,
                 validity: Link.ValidityRange? = nil,
                 andChannel channel: Channel) throws -> Link {
    let (tbs, validity) = Link.tbs(
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

  func sign(tbs: Data) -> Data {
    return Data(sodium.sign.signature(
        message: Bytes(tbs),
        secretKey: secretKey)!)
  }
}
