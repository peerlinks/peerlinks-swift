import Sodium

public class Channel {
  let sodium: Sodium
  let publicKey: Bytes
  let debugID: String

  init(sodium: Sodium, publicKey: Bytes) {
    self.sodium = sodium
    self.publicKey = publicKey

    debugID = Debug.toID(sodium: sodium, publicKey: publicKey)
  }
}
