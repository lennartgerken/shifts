import Foundation
import SwiftData

struct Day: Identifiable, Hashable {
  var id: Date { dateInterval.start }
  let dateInterval: DateInterval
  let shifts: [Shift]

  init(date: Date, shifts: [Shift] = []) {

    let dateInterval = Calendar.current.dateInterval(of: .day, for: date)!
    self.dateInterval = dateInterval
    self.shifts = shifts.filter({ shift in
      shift.start >= dateInterval.start && shift.start < dateInterval.end
        || shift.end > dateInterval.start && shift.end <= dateInterval.end
    })
  }
}
