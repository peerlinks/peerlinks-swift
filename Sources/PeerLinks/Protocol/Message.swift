import Foundation
import Sodium

public class Message {
  let sodium: Sodium
  let body: P_ChannelMessage.Body
  let signature: Bytes
  let chain: Chain
  let parents: [Bytes]
  let height: Int64
  let timestamp: TimeInterval

  var hash: Bytes!
  var debugID: String!

  static let HASH_SIZE = 32

  init(sodium: Sodium,
       body: P_ChannelMessage.Body,
       signature: Bytes,
       chain: Chain,
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

    if case .json(let json) = body.body {
      do {
        try JSONSerialization.jsonObject(with: Data(json.bytes), options: [])
      } catch {
        throw BanError.invalidMessageJSON
      }
    }

    self.sodium = sodium
    self.body = body
    self.signature = signature
    self.chain = chain
    self.parents = parents
    self.height = height
    self.timestamp = timestamp

    self.hash = sodium.genericHash.hash(
        message: Bytes(try serializedData()),
        outputLength: Message.HASH_SIZE)!
    self.debugID = Debug.toID(sodium: sodium, hash: self.hash)
  }

  //
  // Serialize/Deserialize
  //

  func serialize() -> P_ChannelMessage {
    return P_ChannelMessage.with({ (message) in
      message.tbs = self.serializeTBS()
      message.signature = Data(self.signature)
    })
  }

  func serializedData() throws -> Data {
    return try serialize().serializedData()
  }

  func serializeTBS() -> P_ChannelMessage.TBS {
    return P_ChannelMessage.TBS.with({ (tbs) in
      tbs.parents = self.parents.map({ (hash) in Data(hash) })
      tbs.height = self.height
      tbs.chain = self.chain.serialize()
      tbs.timestamp = self.timestamp
      tbs.body = self.body
    })
  }

  //
  // Utils
  //

  static func checkHash(_ hash: Bytes) throws {
    if hash.count != Message.HASH_SIZE {
      throw BanError.invalidMessageHashSize(hash.count)
    }
  }
}
