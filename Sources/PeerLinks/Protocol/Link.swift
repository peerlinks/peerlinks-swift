import Foundation
import Sodium

class Link {
  let sodium: Sodium
  let trusteePubKey: Bytes
  let trusteeName: String
  let validity: ValidityRange
  let signature: Bytes

  static let EXPIRATION_DELTA: TimeInterval = 99 * 24 * 3600.0 // 99 days
  static let EXPIRATION_LEEWAY: TimeInterval  = 2 * 60.0 // 2 minutes
  static let MAX_DISPLAY_NAME_LENGTH: Int = 128

  public typealias ValidityRange = (from: TimeInterval, to: TimeInterval)
  public typealias TBSResult = (tbs: Bytes, validity: ValidityRange)

  init(sodium: Sodium,
       trusteePubKey: Bytes,
       trusteeName: String,
       validity: ValidityRange,
       signature: Bytes) throws {
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
              publicKey: Bytes,
              andTimestamp timestamp: TimeInterval = Utils.now()) -> Bool {
    if (!isValid(at: timestamp)) {
      return false
    }

    let (tbs: tbs, validity: _) = try! Link.tbs(trusteePubKey: trusteePubKey,
          trusteeName: trusteeName,
          validity: validity,
          andChannel: channel)

    return sodium.sign.verify(
        message: tbs,
        publicKey: publicKey,
        signature: signature)
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

  func serializedData() throws -> Data {
    return try serialize().serializedData()
  }

  static func deserialize(sodium: Sodium, link: P_Link) throws -> Link {
    return try Link(
        sodium: sodium,
        trusteePubKey: Bytes(link.tbs.trusteePubKey),
        trusteeName: link.tbs.trusteeDisplayName,
        validity: (from: link.tbs.validFrom, to: link.tbs.validTo),
        signature: Bytes(link.signature))
  }

  static func deserializeData(sodium: Sodium, data: Data) throws -> Link {
    let link = try P_Link(serializedData: data)
    return try Link.deserialize(sodium: sodium, link: link)
  }

  //
  // Utils
  //

  static func tbs(trusteePubKey: Bytes,
      trusteeName: String,
      validity: ValidityRange?,
      andChannel channel: Channel) throws -> TBSResult {
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
      tbs: Bytes(try tbs.serializedData()),
      validity: validity
    )
  }
}
