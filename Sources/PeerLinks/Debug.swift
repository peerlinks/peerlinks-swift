import Sodium

internal class Debug {
  static func toID(sodium: Sodium, publicKey: Bytes) -> String {
    let hex = sodium.utils.bin2hex(publicKey) ?? ""
    return String(hex.prefix(8))
  }
}
