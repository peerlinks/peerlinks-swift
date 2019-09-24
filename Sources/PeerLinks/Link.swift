import Foundation

class Link {
  static let EXPIRATION_DELTA: TimeInterval = 99 * 24 * 3600.0; // 99 days
  static let EXPIRATION_LEEWAY: TimeInterval  = 2 * 60.0; // 2 minutes
}
