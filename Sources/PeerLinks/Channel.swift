import Sodium

public class Channel {
  let sodium: Sodium
  let publicKey: Bytes
  let debugID: String
  let id: Bytes

  static let ID_SIZE = 32
  static let ID_KEY = "peerlinks-channel-id".bytes

  init(sodium: Sodium, publicKey: Bytes) {
    self.sodium = sodium
    self.publicKey = publicKey
    self.id = sodium.genericHash.hash(message: publicKey,
                                      key: Channel.ID_KEY,
                                      outputLength: Channel.ID_SIZE)!

    debugID = Debug.toID(sodium: sodium, publicKey: publicKey)
  }
}
