import Foundation
import Sodium

public class Message {
  let sodium: Sodium
  let body: P_ChannelMessage.Body
  let signature: Data
  let chain: Chain
  let parents: [Data]
  let height: Int64
  let timestamp: TimeInterval

  var hash: Data!
  var debugID: String!

  static let HASH_SIZE = 32

  init(sodium: Sodium,
       body: P_ChannelMessage.Body,
       signature: Data,
       chain: Chain,
       parents: [Data] = [],
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

    self.hash = Data(sodium.genericHash.hash(
        message: Bytes(serializedData()),
        outputLength: Message.HASH_SIZE)!)
    self.debugID = Debug.toID(sodium: sodium, hash: self.hash)
  }

  var isRoot: Bool {
    switch body.body {
    case .root: return true
    default: return false
    }
  }

  func json<T: Codable>() throws -> T? {
    switch body.body {
    case .json(let json):
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: Data(json.bytes))
    default:
      return nil
    }
  }

  func getAuthor() -> (displayPaths: [String], publicKeys: [Data]) {
    return (
      displayPaths: chain.getDisplayPath(),
      publicKeys: chain.getPublicKeys()
    )
  }

  func verify(
      for channel: Channel,
      andTimestamp timestamp: TimeInterval = Utils.now()) -> Bool {
    let tbs = try! serializeTBS().serializedData()
    guard let leafKey = chain.getLeafKey(
        for: channel, andTimestamp: timestamp) else {
      return false
    }

    return sodium.sign.verify(
        message: Bytes(tbs),
        publicKey: Bytes(leafKey),
        signature: Bytes(signature))
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

  func serializedData() -> Data {
    return try! serialize().serializedData()
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

  static func deserialize(sodium: Sodium,
                          message: P_ChannelMessage) throws -> Message {
    let tbs = message.tbs
    return try Message(sodium: sodium,
        body: tbs.body,
        signature: message.signature,
        chain: try Chain.deserialize(sodium: sodium, chain: tbs.chain),
        parents: tbs.parents,
        height: tbs.height,
        timestamp: tbs.timestamp)
  }

  static func deserializeData(sodium: Sodium, data: Data) throws -> Message {
    let message = try P_ChannelMessage(serializedData: data)
    return try Message.deserialize(sodium: sodium, message: message)
  }

  //
  // Utils
  //

  static func root() -> P_ChannelMessage.Body {
    return P_ChannelMessage.Body.with({ (body) in
      body.root = P_ChannelMessage.Root()
    })
  }

  static func json<T: Codable>(_ value: T) throws -> P_ChannelMessage.Body {
    let encoder = JSONEncoder()
    let json = try encoder.encode(value)

    return P_ChannelMessage.Body.with({ (body) in
      body.json = String(data: json, encoding: .utf8)!
    })
  }

  static func checkHash(_ hash: Data) throws {
    if hash.count != Message.HASH_SIZE {
      throw BanError.invalidMessageHashSize(hash.count)
    }
  }
}
