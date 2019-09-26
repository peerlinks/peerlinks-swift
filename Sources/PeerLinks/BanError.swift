public enum BanError: Error {
  case invalidLinkDisplayNameSize(Int)
  case invalidLinkPublicKeySize(Int)
  case invalidLinkSignatureSize(Int)

  case invalidChainLength(Int)

  case invalidMessageHashSize(Int)
  case invalidMessageHeight(Int64)
  case invalidMessageSignatureSize(Int)
}
