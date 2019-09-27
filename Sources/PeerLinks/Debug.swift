import Foundation
import Sodium

internal class Debug {
  static func toID(sodium: Sodium, publicKey: Data) -> String {
    let hex = sodium.utils.bin2hex(Bytes(publicKey)) ?? ""
    return String(hex.prefix(8))
  }

  static func toID(sodium: Sodium, hash: Data) -> String {
    let hex = sodium.utils.bin2hex(Bytes(hash)) ?? ""
    return String(hex.prefix(8))
  }
}
