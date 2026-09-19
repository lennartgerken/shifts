import SwiftUI

enum DayRowStyle {
  case dayOfMonth
  case fullDate
}

struct DayRowView: View {
  private let day: Day
  private let style: DayRowStyle

  init(day: Day, style: DayRowStyle = .dayOfMonth) {
    self.day = day
    self.style = style
  }

  var body: some View {
    HStack(spacing: 8) {
      if style == .dayOfMonth {
        VStack(spacing: 5) {
          Image(systemName: "\(day.dateInterval.start.formatted(.dateTime.day())).calendar")
            .font(.title)
            .accessibilityIdentifier("dayRow.dayImage")
          if Calendar.current.isDateInToday(day.dateInterval.start) {
            Image(systemName: "circle.fill")
              .font(.system(size: 10))
              .foregroundStyle(.red)
          }
        }
      }
      VStack(alignment: .leading, spacing: 5) {
        HStack {
          Text(
            day.dateInterval.start,
            format: style == .dayOfMonth ? .dateTime.weekday(.wide) : .dateTime.year().month().day()
          )
          .font(.title2)
          .accessibilityIdentifier("dayRow.weekdayText")
          Spacer()
          ShiftInfoView(shifts: day.shifts)
        }
        VStack {
          ForEach(day.shifts) { shift in
            let start = shift.start < day.dateInterval.start ? day.dateInterval.start : shift.start
            let end =
              shift.end >= day.dateInterval.end
              ? Calendar.current.date(byAdding: .minute, value: -1, to: day.dateInterval.end)!
              : shift.end
            HStack {
              Text(start, format: .dateTime.hour().minute())

              Image(systemName: "arrow.right")
              Text(end, format: .dateTime.hour().minute())
            }
          }
        }
        ActiveHoursView(day: day)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  let calendar = Calendar.current
  let today = Date()
  DayRowView(
    day: Day(
      date: Date(),
      shifts: [
        try! Shift(
          start: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today)!,
          end: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: today)!
        )
      ]),
    style: .dayOfMonth
  )
}
