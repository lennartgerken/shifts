import SwiftUI

struct ActiveHoursView: View {
  private let day: Day
  private let activeHours: Set<Int>

  init(day: Day) {
    self.day = day
    let calendar = Calendar.current
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
    HStack(spacing: 5) {
      ForEach(0..<24) { hour in
        let isActive = activeHours.contains(hour)
        ZStack {
          Image(
            systemName: isActive ? "circle.fill" : "circle"
          )
          .resizable()
          .scaledToFit()
          .frame(maxWidth: 10, maxHeight: 10)
          .accessibilityIdentifier("activeHours.image-\(isActive ? "active" : "inactive")")
        }
        .frame(maxWidth: .infinity)

      }
    }
  }
}

#Preview {
  ActiveHoursView(day: Day(date: Date(), shifts: []))
}
