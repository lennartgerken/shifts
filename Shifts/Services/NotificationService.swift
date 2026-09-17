import Foundation
import UserNotifications

enum NotificationTimingType: Encodable, Decodable {
  case minute
  case hour
  case day
}

struct NotificationTiming: Identifiable, Hashable, Encodable, Decodable, Comparable {
  static func < (lhs: borrowing NotificationTiming, rhs: borrowing NotificationTiming) -> Bool {
    switch lhs.timing {
    case .minute:
      if rhs.timing != .minute { return true }
    case .hour:
      switch rhs.timing {
      case .minute:
        return false
      case .hour:
        break
      case .day:
        return true
      }
    case .day:
      switch rhs.timing {
      case .minute:
        return false
      case .hour:
        return false
      case .day:
        break
      }
    }
    return lhs.value < rhs.value
  }

  var id: String {
    "\(value)-\(timing)"
  }
  let value: Int
  let timing: NotificationTimingType
}

protocol NotificationServicing {
  func authorizationStatus() async -> UNAuthorizationStatus
  func requestAuthorization() async throws -> Bool
  func schedule(for shift: Shift, notificationTimings: Set<NotificationTiming>)
    async throws
  func update(for shift: Shift, notificationTimings: Set<NotificationTiming>)
    async throws
  func remove(for shift: Shift)
  func removeAll()
}

protocol NotificationCenterContainer {
  func add(_ request: UNNotificationRequest) async throws
  func pendingNotificationRequests() async -> [UNNotificationRequest]
  func removePendingNotificationRequests(withIdentifiers identifiers: [String])
  func removeAllPendingNotificationRequests()
  func authorizationStatus() async -> UNAuthorizationStatus
  func requestAuthorization() async throws -> Bool
}

struct SystemNotificationCenter: NotificationCenterContainer {
  private let notificationCenter: UNUserNotificationCenter = .current()

  func add(_ request: UNNotificationRequest) async throws {
    try await notificationCenter.add(request)
  }

  func pendingNotificationRequests() async -> [UNNotificationRequest] {
    await notificationCenter.pendingNotificationRequests()
  }

  func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
    notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
  }

  func removeAllPendingNotificationRequests() {
    notificationCenter.removeAllPendingNotificationRequests()
  }

  func authorizationStatus() async -> UNAuthorizationStatus {
    await notificationCenter.notificationSettings().authorizationStatus
  }

  func requestAuthorization() async throws -> Bool {
    try await notificationCenter.requestAuthorization(options: [
      .alert, .sound,
    ])
  }
}

struct NotificationService: NotificationServicing {
  private let notificationCenter: NotificationCenterContainer
  private let calendar = Calendar.current

  init(notificationCenter: NotificationCenterContainer = SystemNotificationCenter()) {
    self.notificationCenter = notificationCenter
  }

  func authorizationStatus() async -> UNAuthorizationStatus {
    await notificationCenter.authorizationStatus()
  }

  func requestAuthorization() async throws -> Bool {
    try await notificationCenter.requestAuthorization()
  }

  @MainActor
  func schedule(for shift: Shift, notificationTimings: Set<NotificationTiming>)
    async throws
  {
    let ids = Self.getNotificationIDs(for: shift)
    let notificationTimingsArray = Array(notificationTimings).prefix(ids.count)

    for (index, notificationTiming) in notificationTimingsArray.enumerated() {
      var minutes = notificationTiming.value
      var message = String(
        localized: .notificationBodyShiftReminderMinutes(
          minutes: minutes
        )
      )
      switch notificationTiming.timing {
      case .minute:
        break
      case .hour:
        minutes *= 60
        message = String(
          localized: .notificationBodyShiftReminderHours(
            hours: notificationTiming.value
          )
        )
      case .day:
        minutes *= 24 * 60
        message = String(
          localized: .notificationBodyShiftReminderDays(
            days: notificationTiming.value
          )
        )
      }
      let id = ids[index]

      let minutesToStart = shift.start.timeIntervalSinceNow / 60
      if minutesToStart > Double(minutes) {
        let content = UNMutableNotificationContent()
        content.title = String(
          localized: .notificationsTitleShiftReminder
        )

        if let notes = shift.notes, !notes.isEmpty {
          message.append("\n\(notes)")
        }
        if !shift.tags.isEmpty {
          message.append("\n\(shift.tags.map(\.name).sorted().joined(separator: ", "))")
        }
        content.body = message

        content.sound = .default

        let dateComponents = calendar.dateComponents(
          [.year, .month, .day, .hour, .minute],
          from: calendar.date(
            byAdding: DateComponents(minute: -minutes),
            to: shift.start
          )!
        )

        let trigger = UNCalendarNotificationTrigger(
          dateMatching: dateComponents,
          repeats: false
        )

        let request = UNNotificationRequest(
          identifier: id,
          content: content,
          trigger: trigger
        )

        try await notificationCenter.add(request)
      }
    }
  }

  @MainActor
  func update(for shift: Shift, notificationTimings: Set<NotificationTiming>)
    async throws
  {
    remove(for: shift)
    try await schedule(for: shift, notificationTimings: notificationTimings)
  }

  func remove(for shift: Shift) {
    notificationCenter.removePendingNotificationRequests(
      withIdentifiers: Self.getNotificationIDs(for: shift)
    )
  }

  func removeAll() {
    notificationCenter.removeAllPendingNotificationRequests()
  }

  private static func getNotificationIDs(for shift: Shift) -> [String] {
    return (0..<5).map { index in
      "shift_\(shift.id)_\(index)"
    }
  }
}
