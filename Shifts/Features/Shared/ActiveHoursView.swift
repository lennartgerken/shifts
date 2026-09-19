import SwiftUI

struct ActiveHoursView: View {
  private let calendar = Calendar.current
  private let day: Day
  private let activeHours: Set<Int>

  init(day: Day) {
    self.day = day
    var activeHours: Set<Int> = []
    for shift in day.shifts {
      let startHour =
        shift.start < day.dateInterval.start
        ? 0 : calendar.dateComponents([.hour], from: shift.start).hour!
      let endMinute = calendar.dateComponents([.minute], from: shift.end).minute!
      let endHour =
        shift.end >= day.dateInterval.end
        ? 24 : (calendar.dateComponents([.hour], from: shift.end).hour! + (endMinute > 0 ? 1 : 0))
      for hour in startHour..<endHour {
        activeHours.insert(hour)
      }
    }
    self.activeHours = activeHours
  }

  var body: some View {
    HStack(spacing: 0) {
      let currentHour = calendar.component(.hour, from: Date())
      let isToday = calendar.isDateInToday(day.dateInterval.start)
      ForEach(0..<24) { hour in
        let isActive = activeHours.contains(hour)
        Image(
          systemName: isActive ? "circle.fill" : "circle"
        )
        .font(.system(size: 8))
        .frame(width: 8, height: 8)
        .scaleEffect((isToday && hour == currentHour) ? 1.3 : 1)
        .foregroundStyle((isToday && hour == currentHour) ? .red : .primary)
        .accessibilityIdentifier("activeHours.image-\(isActive ? "active" : "inactive")")
        .frame(maxWidth: .infinity)
      }
    }
    .frame(maxWidth: 450)
  }
}

#Preview {
  ActiveHoursView(day: Day(date: Date(), shifts: []))
}
