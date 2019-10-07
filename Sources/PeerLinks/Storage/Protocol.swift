import Foundation

public enum Cursor {
  case height(Int64)
  case hash(Data)
}

public struct AbbreviatedMessage {
  var hash: Data
  var parents: [Data]
}

public struct QueryResult {
  var abbreviatedMessages: [AbbreviatedMessage]
  var forwardHash: Data?
  var backwardHash: Data?
}

public protocol Storage {
  //
  // Messages
  //

  func addMessage(
      to channelID: Data,
      hash: Data,
      height: Int64,
      parents: [Data],
      andData content: Data)

  func getMessageCount(for channelID: Data) -> Int

  func getLeafHashes(for channelID: Data) -> [Data]

  func hasMessage(withChannelID channelID: Data, andHash hash: Data) -> Bool

  func getMessage(withChannelID channelID: Data, andHash hash: Data) -> Data?

  func getMessages(
      withChannelID channelID: Data,
      andHashes hashes: [Data]) -> [Data?]

  func getHashesAtOffset(
      for channelID: Data,
      offset: Int64,
      andLimit limit: Int64) -> [Data]

  func getReverseHashesAtOffset(
      for channelID: Data,
      offset: Int64,
      andLimit limit: Int64) -> [Data]

  func query(
      for channelID: Data,
      cursor: Cursor,
      isBackward: Bool,
      andLimit limit: Int64) -> QueryResult

  func removeChannelMessages(for channelID: Data)

  //
  // Entities
  //

  func storeEntity(prefix: String, id: String, blob: Data)
  func retrieveEntity(prefix: String, id: String) -> Data?
  func removeEntity(prefix: String, id: String)
  func getEntityKeys(prefix: String) -> [String]

  //
  // Miscellaneous
  //

  func clear()
}
