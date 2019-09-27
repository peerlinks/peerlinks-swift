import Foundation
import Sodium

public enum IdentityError: Error {
  case invalidChain(Chain)
  case noLeafKeyInChain(Chain)
  case invalidLeafKey(Chain)
  case noChainFoundFor(Channel)
  case cannotPost(Channel)
}

public class Identity {
  let sodium: Sodium
  var name: String
  let publicKey: Data
  let debugID: String

  var chains = [Channel: Chain]()

  var metadata = [String: String]()

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

  func addChain(_ chain: Chain, for channel: Channel) throws {
    if !chain.isValid() {
      throw IdentityError.invalidChain(chain)
    }

    guard let leafKey = chain.getLeafKey(for: channel) else {
      throw IdentityError.noLeafKeyInChain(chain)
    }

    if leafKey == publicKey {
      throw IdentityError.invalidLeafKey(chain)
    }

    if let existing = chains[channel] {
      if existing.isBetterThan(chain) {
        return
      }
    }

    chains[channel] = chain
  }

  func getChain(
      for channel: Channel,
      andTimestamp timestamp: TimeInterval = Utils.now()) -> Chain? {
    guard let chain = chains[channel] else {
      return nil
    }

    if !chain.isValid(at: timestamp) {
      return nil
    }

    return chain
  }

  func removeChain(for channel: Channel) {
    chains.removeValue(forKey: channel)
  }

  func getChannelIds(at timestamp: TimeInterval = Utils.now()) -> [Data] {
    var result = [Data]()
    for (channel, chain) in chains {
      if chain.isValid(at: timestamp + Link.EXPIRATION_LEEWAY) {
        result.append(channel.id)
      }
    }
    return result
  }

  //
  // Messages
  //

  func sign(
      body: P_ChannelMessage.Body,
      for channel: Channel,
      height: Int64 = 0,
      parents: [Data] = [],
      andTimestamp timestamp: TimeInterval = Utils.now())
      throws -> (tbs: P_ChannelMessage.TBS, signature: Data) {
    guard let chain = getChain(for: channel) else {
      throw IdentityError.noChainFoundFor(channel)
    }

    if (!canPost(to: channel, at: timestamp)) {
      throw IdentityError.cannotPost(channel)
    }

    let tbs = Message.tbs(
        for: body,
        chain: chain,
        height: height,
        parents: parents,
        andTimestamp: timestamp)

    let signature = sign(tbs: try! tbs.serializedData())

    return (tbs: tbs, signature: signature)
  }

  //
  // Sign/Verify
  //

  func sign(tbs: Data) -> Data {
    return Data(sodium.sign.signature(
        message: Bytes(tbs),
        secretKey: secretKey)!)
  }

  //
  // Invites
  //

  func canPost(to channel: Channel,
               at timestamp: TimeInterval = Utils.now()) -> Bool {
    guard let chain = getChain(for: channel) else {
      return false
    }

    return chain.verify(for: channel, andTimestamp: timestamp)
  }
}
