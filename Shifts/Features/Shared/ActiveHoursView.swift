import SwiftUI

struct ActiveHoursView: View {
  private let calendar = Calendar.current
  private let day: Day
  private var activeHoursByCategory: [Category?: Set<Int>] = [:]

  init(day: Day) {
    self.day = day
    for shift in day.shifts {
      let startHour =
        shift.start < day.dateInterval.start
        ? 0 : calendar.dateComponents([.hour], from: shift.start).hour!
      let endMinute = calendar.dateComponents([.minute], from: shift.end).minute!
      let endHour =
        shift.end >= day.dateInterval.end
        ? 24 : (calendar.dateComponents([.hour], from: shift.end).hour! + (endMinute > 0 ? 1 : 0))
      for hour in startHour..<endHour {
        activeHoursByCategory[shift.category, default: []].insert(hour)
      }
    }

    if activeHoursByCategory.isEmpty {
      activeHoursByCategory[nil] = []
    }
  }

  var body: some View {
    VStack {
      let keys = activeHoursByCategory.keys.sorted {
        activeHoursByCategory[$0]!.min()! < activeHoursByCategory[$1]!.min()!
      }

      ForEach(keys, id: \.self) { key in
        let currentActiveHours = activeHoursByCategory[key]!
        let color = key?.colorRGB.color ?? .primary

        HStack(spacing: 0) {
          let currentHour = calendar.component(.hour, from: Date())
          let isToday = calendar.isDateInToday(day.dateInterval.start)
          ForEach(0..<24) { hour in
            let isActive = currentActiveHours.contains(hour)
            Image(
              systemName: isActive ? "circle.fill" : "circle"
            )
            .font(.system(size: 8))
            .frame(width: 8, height: 8)
            .scaleEffect((isToday && hour == currentHour) ? 1.3 : 1)
            .foregroundStyle((isToday && hour == currentHour) ? .red : isActive ? color : .primary)
            .accessibilityIdentifier("activeHours.image-\(isActive ? "active" : "inactive")")
            .frame(maxWidth: .infinity)
          }
        }
        .frame(maxWidth: 450)
      }
    }
  }
}

#Preview {
  let calendar = Calendar.current
  ActiveHoursView(
    day: Day(
      date: Date(),
      shifts: [
        try! Shift(
          start: calendar.date(bySettingHour: 5, minute: 0, second: 0, of: Date())!,
          end: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!,
          category: try! Category(
            name: "Category 1", colorRGB: try! ColorRGB(red: 0, green: 0.5, blue: 1))
        )
      ]))
}
