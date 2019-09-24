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

  public typealias ValidityRange = (from: TimeInterval, to: TimeInterval)
  public typealias TBSResult = (tbs: Bytes, validity: ValidityRange)

  init(sodium: Sodium,
       trusteePubKey: Bytes,
       trusteeName: String,
       validity: ValidityRange,
       signature: Bytes) {
    self.sodium = sodium
    self.trusteePubKey = trusteePubKey
    self.trusteeName = trusteeName
    self.validity = validity
    self.signature = signature
  }

  static func tbs(trusteePubKey: Bytes,
      trusteeName: String,
      validity maybeValidity: ValidityRange?,
      andChannel channel: Channel) throws -> TBSResult {
    let validity = maybeValidity ?? ({
      let now = NSDate().timeIntervalSince1970

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
