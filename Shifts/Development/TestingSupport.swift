import Foundation
import SwiftData

#if DEBUG
  private func getDayOfMonth(day: Int) -> Date {
    let calendar = Calendar.current

    var components = calendar.dateComponents([.year, .month], from: Date())
    components.day = day
    return calendar.date(from: components)!
  }

  enum TestingSupport {
    static func clearData(modelContainer: ModelContainer) throws {
      let modelContext = modelContainer.mainContext
      try modelContext.delete(model: ShiftReference.self)
      let tags = try modelContext.fetch(FetchDescriptor<Tag>())
      for tag in tags {
        modelContext.delete(tag)
      }
      let shifts = try modelContext.fetch(FetchDescriptor<Shift>())
      for shift in shifts {
        modelContext.delete(shift)
      }

      try modelContext.save()
    }

    static func addTestData(modelContainer: ModelContainer) throws {
      let calendar = Calendar.current
      let modelContext = modelContainer.mainContext

      struct ShiftToAdd {
        let day: Int
        let startHour: Int
        let startMinute: Int
        let endDay: Int?
        let endHour: Int
        let endMinute: Int
        let notes: String?
        let tags: [Tag]?

        init(
          day: Int,
          startHour: Int,
          startMinute: Int,
          endDay: Int? = nil,
          endHour: Int,
          endMinute: Int,
          notes: String? = nil,
          tags: [Tag] = []
        ) {
          self.day = day
          self.startHour = startHour
          self.startMinute = startMinute
          self.endDay = endDay
          self.endHour = endHour
          self.endMinute = endMinute
          self.notes = notes
          self.tags = tags
        }
      }

      let tags: [Tag] = [
        try Tag(
          name: "Tag 1",
          colorRed: 1,
          colorBlue: 0,
          colorGreen: 0
        ),
        try Tag(
          name: "Tag 2",
          colorRed: 1,
          colorBlue: 0,
          colorGreen: 0
        ),
      ]

      for tag in tags {
        modelContext.insert(tag)
      }

      let shiftsToAdd = [
        ShiftToAdd(
          day: 1,
          startHour: 9,
          startMinute: 0,
          endHour: 15,
          endMinute: 0,
          notes: "Some note",
          tags: [tags[0]]
        ),
        ShiftToAdd(
          day: 2,
          startHour: 8,
          startMinute: 0,
          endHour: 9,
          endMinute: 0,
          notes: "Some note",
          tags: [tags[0]]
        ),
        ShiftToAdd(
          day: 2,
          startHour: 21,
          startMinute: 0,
          endDay: 3,
          endHour: 3,
          endMinute: 0,
          tags: [tags[1]]
        ),
      ]

      var shifts: [Shift] = []
      for shiftToAdd in shiftsToAdd {
        let date = getDayOfMonth(day: shiftToAdd.day)

        let start = calendar.date(
          bySettingHour: shiftToAdd.startHour,
          minute: shiftToAdd.startMinute,
          second: 0,
          of: date
        )!
        let end = calendar.date(
          bySettingHour: shiftToAdd.endHour,
          minute: shiftToAdd.endMinute,
          second: 0,
          of: shiftToAdd.endDay.map { getDayOfMonth(day: $0) } ?? date
        )!

        let shift = try Shift(
          start: start,
          end: end,
          notes: shiftToAdd.notes,
          tags: shiftToAdd.tags ?? []
        )
        modelContext.insert(shift)
        shifts.append(shift)
      }

      modelContext.insert(ShiftReference(name: "Reference 1", shift: shifts[0]))

      try modelContext.save()
    }

    static func reset(modelContainer: ModelContainer) throws {
      try Self.clearData(modelContainer: modelContainer)
      try Self.addTestData(modelContainer: modelContainer)
    }

    static func configureSettings(settings: AppSettings) {
      var importSettings = ImportSettings()
      importSettings.day = .day(month: .dayMonthYear)
      importSettings.entryPattern = PatternGroup(
        patternValues: [
          .dayPattern(DayPattern(type: .day)),
          .anyPattern(AnyPattern(count: 1, orMore: true)),
          .startTimePattern(StartTimePattern(type: .hoursMinutes)),
          .staticPattern(StaticPattern(text: " ")),
          .endTimePattern(EndTimePattern(type: .hoursMinutes)),
        ]
      )
      importSettings.monthPattern = PatternGroup(
        patternValues: [
          .staticPattern(StaticPattern(text: "Von: ")),
          .monthPattern(MonthPattern(type: .dayMonthYear)),
        ]
      )
      settings.importSettings = importSettings
      settings.sendNotifications = false
      settings.notificationTimings = [NotificationTiming(value: 1, timing: .hour)]
    }
  }
#endif
