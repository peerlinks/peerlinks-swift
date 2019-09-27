import Foundation
import Sodium

class Link {
  let sodium: Sodium
  let trusteePubKey: Data
  let trusteeName: String
  let validity: ValidityRange
  let signature: Data

  static let EXPIRATION_DELTA: TimeInterval = 99 * 24 * 3600.0 // 99 days
  static let EXPIRATION_LEEWAY: TimeInterval  = 2 * 60.0 // 2 minutes
  static let MAX_DISPLAY_NAME_LENGTH: Int = 128

  public typealias ValidityRange = (from: TimeInterval, to: TimeInterval)
  public typealias TBSResult = (tbs: Data, validity: ValidityRange)

  init(sodium: Sodium,
       trusteePubKey: Data,
       trusteeName: String,
       validity: ValidityRange,
       signature: Data) throws {
    if (trusteeName.count == 0 ||
        trusteeName.count > Link.MAX_DISPLAY_NAME_LENGTH) {
      throw BanError.invalidLinkDisplayNameSize(trusteeName.count)
    }

    if (trusteePubKey.count != sodium.sign.PublicKeyBytes) {
      throw BanError.invalidLinkPublicKeySize(trusteePubKey.count)
    }
    if (signature.count != sodium.sign.Bytes) {
      throw BanError.invalidLinkSignatureSize(signature.count)
    }

    self.sodium = sodium
    self.trusteePubKey = trusteePubKey
    self.trusteeName = trusteeName
    self.validity = validity
    self.signature = signature
  }

  func verify(withChannel channel: Channel,
              publicKey: Data,
              andTimestamp timestamp: TimeInterval = Utils.now()) -> Bool {
    if (!isValid(at: timestamp)) {
      return false
    }

    let (tbs: tbs, validity: _) = Link.tbs(trusteePubKey: trusteePubKey,
          trusteeName: trusteeName,
          validity: validity,
          andChannel: channel)

    return sodium.sign.verify(
        message: Bytes(tbs),
        publicKey: Bytes(publicKey),
        signature: Bytes(signature))
  }

  func isValid(at timestamp: TimeInterval = Utils.now()) -> Bool {
    return validity.from <= timestamp && timestamp < validity.to
  }

  //
  // Serialize/Deserialize
  //

  func serialize() -> P_Link {
    return P_Link.with({ (link) in
      link.tbs = P_Link.TBS.with({ (tbs) in
        tbs.trusteePubKey = Data(self.trusteePubKey)
        tbs.trusteeDisplayName = self.trusteeName
        tbs.validFrom = self.validity.from
        tbs.validTo = self.validity.to
        // NOTE: The difference between tbs here and below is absence of
        // channel id
      })
      link.signature = Data(self.signature)
    })
  }

  func serializedData() -> Data {
    return try! serialize().serializedData()
  }

  static func deserialize(sodium: Sodium, link: P_Link) throws -> Link {
    return try Link(
        sodium: sodium,
        trusteePubKey: link.tbs.trusteePubKey,
        trusteeName: link.tbs.trusteeDisplayName,
        validity: (from: link.tbs.validFrom, to: link.tbs.validTo),
        signature: link.signature)
  }

  static func deserializeData(sodium: Sodium, data: Data) throws -> Link {
    let link = try P_Link(serializedData: data)
    return try Link.deserialize(sodium: sodium, link: link)
  }

  //
  // Utils
  //

  static func tbs(trusteePubKey: Data,
      trusteeName: String,
      validity: ValidityRange?,
      andChannel channel: Channel) -> TBSResult {
    let validity = validity ?? ({
      let now = Utils.now()

      return (
        from: now - Link.EXPIRATION_LEEWAY,
        to: now + Link.EXPIRATION_DELTA
      )
    })()

    let tbs = P_Link.TBS.with({ (tbs) in
      tbs.trusteePubKey = Data(trusteePubKey)
      tbs.trusteeDisplayName = trusteeName
      tbs.validFrom = validity.from
      tbs.validTo = validity.to
      tbs.channelID = Data(channel.id)
    })

    return (
      tbs: try! tbs.serializedData(),
      validity: validity
    )
  }
}
