import Foundation
import Observation
import UserNotifications

@Observable
final class AppSettings {
  private enum Key {
    static let importSettings = "importSettings"
    static let lastNotificationStatus = "lastNotificationStatus"
    static let notificationTimings = "notificationTimings"
  }

  private let defaults: UserDefaults

  private func saveEncoded(data: Encodable, key: String) {
    do {
      let dataEncoded = try JSONEncoder().encode(data)
      defaults.set(dataEncoded, forKey: key)
    } catch {
      assertionFailure("Could not encode data: \(error)")
    }
  }

  private static func loadEncoded<T: Decodable>(
    defaults: UserDefaults, key: String, defaultValue: T
  ) -> T {
    guard let data = defaults.data(forKey: key) else {
      return defaultValue
    }
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      assertionFailure("Could not decode data: \(error)")
      return defaultValue
    }
  }

  var importSettings: ImportSettings {
    didSet {
      saveEncoded(data: importSettings, key: Key.importSettings)
    }
  }

  var notificationTimings: Set<NotificationTiming> {
    didSet {
      saveEncoded(data: notificationTimings, key: Key.notificationTimings)
    }
  }

  var lastNotificationStatus: Int? {
    didSet {
      defaults.set(lastNotificationStatus, forKey: Key.lastNotificationStatus)
    }
  }

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults

    importSettings = Self.loadEncoded(
      defaults: defaults, key: Key.importSettings, defaultValue: ImportSettings())
    notificationTimings = Self.loadEncoded(
      defaults: defaults, key: Key.notificationTimings,
      defaultValue: [
        NotificationTiming(value: 1, timing: .day),
        NotificationTiming(value: 1, timing: .hour),
      ]
    )

    self.lastNotificationStatus = defaults.integer(forKey: Key.lastNotificationStatus)
  }
}
