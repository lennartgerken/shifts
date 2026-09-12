import Foundation
import SwiftData

@Model
final class ShiftReference {
  private(set) var name: String
  private(set) var shift: Shift

  init(name: String, shift: Shift) {
    self.name = name
    self.shift = shift
  }

  func updateValues(name: String) {
    self.name = name
  }

  func createShift(for date: Date) throws -> Shift {
    let calendar = Calendar.current

    let startTimeComponets = calendar.dateComponents([.hour, .minute], from: shift.start)
    let endTimeComponents = calendar.dateComponents([.hour, .minute], from: shift.end)

    let startToSet = calendar.date(
      bySettingHour: startTimeComponets.hour!, minute: startTimeComponets.minute!, second: 0,
      of: date)!

    let daysApart = calendar.dateComponents(
      [.day], from: calendar.startOfDay(for: shift.start), to: calendar.startOfDay(for: shift.end)
    ).day!
    let baseEnd = calendar.date(
      bySettingHour: endTimeComponents.hour!, minute: endTimeComponents.minute!, second: 0, of: date
    )!
    let endToSet = calendar.date(byAdding: .day, value: daysApart, to: baseEnd)!

    return try Shift(start: startToSet, end: endToSet, notes: shift.notes, tags: shift.tags)
  }
}
