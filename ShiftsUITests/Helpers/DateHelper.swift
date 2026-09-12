import Foundation

func getDayOfMonth(day: Int) -> Date {
  let calendar = Calendar.current

  var components = calendar.dateComponents([.year, .month], from: Date())
  components.day = day
  return calendar.date(from: components)!
}
