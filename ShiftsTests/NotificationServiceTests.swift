import Testing
import UserNotifications

@testable import Shifts

final class FakeNotificationCenter: NotificationCenterContainer {
  var requests: [UNNotificationRequest] = []

  func add(_ request: UNNotificationRequest) async throws {
    requests.append(request)
  }

  func pendingNotificationRequests() async -> [UNNotificationRequest] {
    requests
  }

  func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
    requests.removeAll(where: { identifiers.contains($0.identifier) })
  }

  func removeAllPendingNotificationRequests() {
    requests.removeAll()
  }

  func authorizationStatus() async -> UNAuthorizationStatus {
    .authorized
  }

  func requestAuthorization() async throws -> Bool {
    return true
  }
}

@MainActor
@Suite(.serialized)
struct NotificationServiceTests {
  let calendar = Calendar.current
  let notificationService: NotificationService
  let notificationCenter: NotificationCenterContainer
  let date1: Date
  let date2: Date
  var shift1: Shift
  var shift2: Shift

  init() async throws {
    let fakeNotificationCenter = FakeNotificationCenter()
    notificationService = NotificationService(notificationCenter: fakeNotificationCenter)
    notificationCenter = fakeNotificationCenter
    notificationCenter.removeAllPendingNotificationRequests()
    date1 = calendar.date(
      byAdding: .day,
      value: 7,
      to: calendar.startOfDay(for: Date())
    )!
    date2 = calendar.date(
      byAdding: .day,
      value: 8,
      to: calendar.startOfDay(for: Date())
    )!
    let start1 = calendar.date(
      bySettingHour: 10,
      minute: 0,
      second: 0,
      of: date1
    )!
    let end1 = calendar.date(
      bySettingHour: 16,
      minute: 0,
      second: 0,
      of: date1
    )!
    let start2 = calendar.date(
      bySettingHour: 15,
      minute: 0,
      second: 0,
      of: date2
    )!
    let end2 = calendar.date(
      bySettingHour: 20,
      minute: 15,
      second: 0,
      of: date2
    )!
    shift1 = try! Shift(start: start1, end: end1)
    shift2 = try! Shift(start: start2, end: end2)
  }

  @Test func scheduleNotifications() async throws {
    let notes = "Notizen zu meiner Schicht."
    let tags = [
      try! Tag(name: "Tag 1", colorRed: 1, colorBlue: 0, colorGreen: 0),
      try! Tag(name: "Tag 2", colorRed: 0, colorBlue: 1, colorGreen: 0),
    ]
    try! shift1.updateValues(start: shift1.start, end: shift1.end, notes: notes, tags: tags)

    let notificationTimings: Set<NotificationTiming> = [
      NotificationTiming(value: 1, timing: .day),
      NotificationTiming(value: 2, timing: .hour),
      NotificationTiming(value: 15, timing: .minute),
    ]

    try await notificationService.schedule(
      for: shift1,
      notificationTimings: notificationTimings
    )

    let pendingNotifications =
      await notificationCenter.pendingNotificationRequests()
    #expect(pendingNotifications.count == 3)

    for notificationTiming in notificationTimings {
      var minutes = notificationTiming.value
      var messageModifier = "Minute(n)"
      switch notificationTiming.timing {
      case .minute:
        break
      case .hour:
        minutes *= 60
        messageModifier = "Stunde(n)"
      case .day:
        minutes = minutes * 24 * 60
        messageModifier = "Tag(en)"
      }

      let dateFromTiming = calendar.date(
        byAdding: DateComponents(minute: -minutes),
        to: shift1.start
      )

      let pendingNotification = pendingNotifications.first(where: { pendingNotifications in
        let trigger =
          pendingNotifications.trigger!
          as! UNCalendarNotificationTrigger
        let dateFromTrigger = calendar.date(
          from: trigger.dateComponents
        )
        return dateFromTiming == dateFromTrigger
      })

      #expect(pendingNotification?.content.title == "Schicht-Erinnerung")
      #expect(
        pendingNotification?.content.body
          == "Deine Schicht beginnt in \(notificationTiming.value) \(messageModifier).\n\(notes)\n\(tags.map(\.name).joined(separator: ", "))"
      )
    }
  }

  @Test func updateNotifications() async throws {
    let notificationTimings: Set<NotificationTiming> = [
      NotificationTiming(value: 2, timing: .hour),
      NotificationTiming(value: 15, timing: .minute),
    ]

    try await notificationService.schedule(
      for: shift1,
      notificationTimings: notificationTimings
    )

    let newStart = calendar.date(
      byAdding: DateComponents(day: -1),
      to: shift1.start
    )!
    let newEnd = calendar.date(
      byAdding: DateComponents(day: -1),
      to: shift1.end
    )!
    try shift1.updateValues(
      start: newStart,
      end: newEnd,
      notes: nil,
      tags: []
    )

    try await notificationService.update(
      for: shift1,
      notificationTimings: notificationTimings
    )

    let pendingNotifications =
      await notificationCenter.pendingNotificationRequests()
    #expect(pendingNotifications.count == 2)

    for pendingNotification in pendingNotifications {
      let trigger =
        pendingNotification.trigger! as! UNCalendarNotificationTrigger
      let dateFromTrigger = calendar.date(
        from: DateComponents(
          year: trigger.dateComponents.year,
          month: trigger.dateComponents.month,
          day: trigger.dateComponents.day
        )
      )!
      #expect(dateFromTrigger == calendar.startOfDay(for: newStart))
    }
  }

  @Test func cutNotifications() async throws {
    let notificationTimings: Set<NotificationTiming> = [
      NotificationTiming(value: 2, timing: .day),
      NotificationTiming(value: 1, timing: .day),
      NotificationTiming(value: 3, timing: .hour),
      NotificationTiming(value: 2, timing: .hour),
      NotificationTiming(value: 1, timing: .hour),
      NotificationTiming(value: 15, timing: .minute),
    ]

    try await notificationService.schedule(
      for: shift1,
      notificationTimings: notificationTimings
    )

    let pendingNotifications =
      await notificationCenter.pendingNotificationRequests()
    #expect(pendingNotifications.count == 5)
  }

  @Test func removeNotifications() async throws {
    let notificationTimings: Set<NotificationTiming> = [
      NotificationTiming(value: 2, timing: .hour),
      NotificationTiming(value: 15, timing: .minute),
    ]

    try await notificationService.schedule(
      for: shift1,
      notificationTimings: notificationTimings
    )
    try await notificationService.schedule(
      for: shift2,
      notificationTimings: notificationTimings
    )
    notificationService.remove(for: shift1)

    let pendingNotifications =
      await notificationCenter.pendingNotificationRequests()
    #expect(pendingNotifications.count == 2)

    for pendingNotification in pendingNotifications {
      #expect(
        pendingNotification.identifier.starts(
          with: "shift_\(shift2.id)_"
        )
      )
    }
  }

  @Test func removeAllNotifications() async throws {
    let notificationTimings: Set<NotificationTiming> = [
      NotificationTiming(value: 2, timing: .hour),
      NotificationTiming(value: 15, timing: .minute),
    ]

    try await notificationService.schedule(
      for: shift1,
      notificationTimings: notificationTimings
    )
    try await notificationService.schedule(
      for: shift2,
      notificationTimings: notificationTimings
    )
    notificationService.removeAll()

    let pendingNotifications =
      await notificationCenter.pendingNotificationRequests()
    #expect(pendingNotifications.count == 0)
  }
}
