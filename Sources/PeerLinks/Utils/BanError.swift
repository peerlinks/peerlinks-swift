public enum BanError: Error {
  case invalidChannelPublicKeySize(Int)

  case invalidLinkDisplayNameSize(Int)
  case invalidLinkPublicKeySize(Int)
  case invalidLinkSignatureSize(Int)

  case invalidChainLength(Int)

  case invalidMessageHashSize(Int)
  case invalidMessageHeight(Int64)
  case invalidMessageSignatureSize(Int)
  case invalidMessageJSON

  case invalidEncryptedBoxSize(Int)
  case invalidEncryptedBox
  case invalidBoxPublicKeySize(Int)
}
