import Foundation
import Sodium

public class Message {
  let sodium: Sodium
  let body: P_ChannelMessage.Body
  let signature: Bytes
  let parents: [Bytes]
  let height: Int64
  let timestamp: TimeInterval

  static let HASH_SIZE = 32

  init(sodium: Sodium,
       body: P_ChannelMessage.Body,
       signature: Bytes,
       parents: [Bytes] = [],
       height: Int64 = 0,
       timestamp: TimeInterval = Utils.now()) throws {
    for parent in parents {
      try Message.checkHash(parent)
    }
    if height < 0 {
      throw BanError.invalidMessageHeight(height)
    }
    if signature.count != sodium.sign.Bytes {
      throw BanError.invalidMessageSignatureSize(signature.count)
    }

    self.sodium = sodium
    self.body = body
    self.signature = signature
    self.parents = parents
    self.height = height
    self.timestamp = timestamp
  }

  static func checkHash(_ hash: Bytes) throws {
    if hash.count != Message.HASH_SIZE {
      throw BanError.invalidMessageHashSize(hash.count)
    }
  }
}
