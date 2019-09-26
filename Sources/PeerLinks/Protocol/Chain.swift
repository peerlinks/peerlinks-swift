import Foundation
import Sodium

public class Chain {
  let links: [Link]

  static let MAX_LENGTH = 3

  init(links: [Link]) throws {
    if links.count > Chain.MAX_LENGTH {
      throw BanError.invalidChainLength(links.count)
    }

    self.links = links
  }

  func getLeafKey(
      for channel: Channel,
      andTimestamp timestamp: TimeInterval = Utils.now()) -> Bytes? {
    var leafKey: Bytes = channel.publicKey
    for link in links {
      let isValid = link.verify(
          withChannel: channel,
          publicKey: leafKey,
          andTimestamp: timestamp)
      if !isValid {
        return nil
      }
      leafKey = link.trusteePubKey
    }
    return leafKey
  }

  func getPublicKeys() -> [Bytes] {
    return links.map({ (link) in
      return link.trusteePubKey
    })
  }

  func getDisplayPath() -> [String] {
    return links.map({ (link) in
      return link.trusteeName
    })
  }

  func verify(for channel: Channel,
              andTimestamp timestamp: TimeInterval = Utils.now()) -> Bool {
    return getLeafKey(for: channel, andTimestamp: timestamp) != nil
  }

  func isValid(at timestamp: TimeInterval = Utils.now()) -> Bool {
    return links.allSatisfy({ (link) in
      return link.isValid(at: timestamp)
    })
  }

  func canAppend() -> Bool {
    return links.count < Chain.MAX_LENGTH
  }

  func isBetterThan(_ other: Chain) -> Bool {
    if other.links.isEmpty {
      return false
    }

    // Root chain should not be replaced
    if links.isEmpty {
      return true
    }

    // TODO(indutny): heuristic comparison of lengths and expirations?
    return false
  }

  func serialize() -> [P_Link] {
    return links.map({ (link) in
      return link.serialize()
    })
  }

  static func append(chain: Chain, link: Link) throws -> Chain {
    return try Chain(links: chain.links + [ link ])
  }
}
