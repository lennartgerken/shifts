import SwiftUI

struct ParsedShiftListView: View {
  let parsedShifts: [ParsedShift]

  private let calendar = Calendar.current
  private var days: [Day] {
    var dates: Set<Date> = []
    for parsedShift in parsedShifts {
      let start = calendar.startOfDay(for: parsedShift.start)
      let end = calendar.startOfDay(for: parsedShift.end)
      dates.insert(start)
      dates.insert(end)
    }

    let shifts = parsedShifts.compactMap({ parsedShift in
      try? Shift(start: parsedShift.start, end: parsedShift.end)
    })

    return dates.map { date in
      Day(date: date, shifts: shifts)
    }.sorted { day1, day2 in
      day1.dateInterval.start < day2.dateInterval.start
    }
  }

  var body: some View {
    Group {
      ForEach(days) { day in
        DayRowView(day: day, style: .fullDate)
          .accessibilityIdentifier(
            "parsedShiftList.dayRow-\(day.id.formatted(.iso8601.year().month().day()))"
          )
      }
    }
  }
}

#Preview {
  List {
    ParsedShiftListView(parsedShifts: [
      ParsedShift(
        start: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!,
        end: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!
      )
    ])
  }
}
