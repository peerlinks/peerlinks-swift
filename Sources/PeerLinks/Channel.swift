import Sodium

public class Channel {
  let sodium: Sodium
  let publicKey: Bytes
  let name: String
  let debugID: String
  let id: Bytes

  static let ID_SIZE = 32
  static let ID_KEY = "peerlinks-channel-id".bytes

  init(sodium: Sodium, publicKey: Bytes, name: String) {
    self.sodium = sodium
    self.publicKey = publicKey
    self.name = name
    self.id = sodium.genericHash.hash(message: publicKey,
                                      key: Channel.ID_KEY,
                                      outputLength: Channel.ID_SIZE)!

    debugID = "\(Debug.toID(sodium: sodium, publicKey: publicKey))/\(name)"
  }
}
