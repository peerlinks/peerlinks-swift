import Sodium

public class Channel {
  let sodium: Sodium
  let publicKey: Bytes
  let name: String
  let debugID: String
  let id: Bytes

  private var encryptionKey: Bytes

  static let ID_SIZE = 32
  static let ID_KEY = "peerlinks-channel-id".bytes
  static let ENC_KEY = "peerlinks-symmetric".bytes

  init(sodium: Sodium, publicKey: Bytes, name: String) {
    self.sodium = sodium
    self.publicKey = publicKey
    self.name = name
    id = sodium.genericHash.hash(message: publicKey,
                                 key: Channel.ID_KEY,
                                 outputLength: Channel.ID_SIZE)!

    encryptionKey = sodium.genericHash.hash(
        message: publicKey,
        key: Channel.ENC_KEY,
        outputLength: sodium.secretBox.KeyBytes)!

    debugID = "\(Debug.toID(sodium: sodium, publicKey: publicKey))/\(name)"
  }

  deinit {
    sodium.utils.zero(&encryptionKey)
  }
}
