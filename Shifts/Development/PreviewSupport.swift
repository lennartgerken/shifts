import Foundation
import SwiftData
import SwiftUI

#if DEBUG
  enum PreviewSupport {
    static func inMemoryContainer() -> ModelContainer {
      let config = ModelConfiguration(isStoredInMemoryOnly: true)
      let container = try! ModelContainer(
        for: Shift.self,
        configurations: config
      )
      let context = container.mainContext

      let calendar = Calendar.current
      let today = calendar.startOfDay(for: Date())
      let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

      let shift = try! Shift(
        start: calendar.date(
          bySettingHour: 21,
          minute: 0,
          second: 0,
          of: yesterday
        )!,
        end: calendar.date(
          bySettingHour: 5,
          minute: 0,
          second: 0,
          of: today
        )!
      )

      context.insert(shift)
      context.insert(
        try! Shift(
          start: calendar.date(
            bySettingHour: 8,
            minute: 0,
            second: 0,
            of: today
          )!,
          end: calendar.date(
            bySettingHour: 13,
            minute: 0,
            second: 0,
            of: today
          )!
        )
      )
      context.insert(
        try! Tag(name: "Tag 1", colorRed: 1, colorBlue: 0, colorGreen: 0)
      )
      context.insert(ShiftReference(name: "Nachtschicht", shift: shift))

      return container
    }
  }
#endif
