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
}
