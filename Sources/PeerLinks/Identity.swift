import Sodium

public class Identity {
  let sodium: Sodium
  let publicKey: Bytes
  private let secretKey: Bytes

  init(sodium: Sodium) {
    self.sodium = sodium
    let keyPair = sodium.sign.keyPair()!

    publicKey = keyPair.publicKey
    secretKey = keyPair.secretKey
  }
}
