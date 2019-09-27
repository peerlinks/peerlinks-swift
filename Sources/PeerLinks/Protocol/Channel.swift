import Sodium
import Foundation

public class Channel: Hashable {
  let sodium: Sodium
  let publicKey: Data
  let name: String
  let debugID: String
  let id: Data

  private var encryptionKey: Data

  static let ID_SIZE = 32
  static let ID_KEY = "peerlinks-channel-id".bytes
  static let ENC_KEY = "peerlinks-symmetric".bytes

  init(sodium: Sodium, publicKey: Data, name: String) {
    self.sodium = sodium
    self.publicKey = publicKey
    self.name = name
    id = Data(sodium.genericHash.hash(
        message: Bytes(publicKey),
        key: Channel.ID_KEY,
        outputLength: Channel.ID_SIZE)!)

    encryptionKey = Data(sodium.genericHash.hash(
        message: Bytes(publicKey),
        key: Channel.ENC_KEY,
        outputLength: sodium.secretBox.KeyBytes)!)

    debugID = "\(Debug.toID(sodium: sodium, publicKey: publicKey))/\(name)"
  }

  //
  // Hashable
  //

  public func hash(into hasher: inout Hasher) {
    hasher.combine(publicKey)
  }

  public static func == (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.publicKey == rhs.publicKey
  }
}
