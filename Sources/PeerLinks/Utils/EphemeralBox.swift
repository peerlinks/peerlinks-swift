import Sodium
import Foundation

internal class EphemeralBox {
  let sodium: Sodium
  let publicKey: Data
  private var secretKey: Bytes

  init(sodium: Sodium) {
    self.sodium = sodium

    let keyPair = sodium.box.keyPair()!
    publicKey = Data(keyPair.publicKey)
    secretKey = keyPair.secretKey
  }

  deinit {
    sodium.utils.zero(&secretKey)
  }

  func decrypt(box: Data) throws -> Data {
    if (box.count < sodium.box.SealBytes) {
      throw BanError.invalidEncryptedBoxSize(box.count)
    }

    guard let cleartext = sodium.box.open(
        anonymousCipherText: Bytes(box),
        recipientPublicKey: Bytes(publicKey),
        recipientSecretKey: secretKey) else {
      throw BanError.invalidEncryptedBox
    }

    return Data(cleartext)
  }

  static func encrypt(
      for publicKey: Data,
      data: Data,
      andSodium sodium: Sodium) throws -> Data {
    if publicKey.count != sodium.box.PublicKeyBytes {
      throw BanError.invalidBoxPublicKeySize(publicKey.count)
    }

    return Data(sodium.box.seal(
        message: Bytes(data),
        recipientPublicKey: Bytes(publicKey))!)
  }
}
