import Sodium

public class Channel {
  let sodium: Sodium
  let publicKey: Bytes

  init(sodium: Sodium, publicKey: Bytes) {
    self.sodium = sodium
    self.publicKey = publicKey
  }
}
