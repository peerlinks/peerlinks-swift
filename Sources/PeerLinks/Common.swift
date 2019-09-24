public enum BanError: Error {
  case invalidLinkPublicKeySize(Int)
  case invalidLinkSignatureSize(Int)
}
