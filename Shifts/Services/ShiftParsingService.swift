import Foundation

enum ShiftParsingError: Error {
  case invalidDayFormat
  case invalidMonthFormat
  case invalidMonthPattern
  case invalidTimeFormat
  case monthNotFound
  case monthNotProvided
}

enum ShiftParsingKey: String, Codable {
  case day
  case startTime
  case endTime
}

enum ShiftParsingMonth: Codable {
  case dayMonthYear
  case monthYear
  case wideMonthYear

  var dateFormat: String {
    switch self {
    case .dayMonthYear:
      return "dd.MM.yyyy"
    case .monthYear:
      return "MM.yyyy"
    case .wideMonthYear:
      return "MMMM yyyy"
    }
  }

  var regex: String {
    switch self {
    case .dayMonthYear:
      return #"(\d{2}\.\d{2}\.\d{4})"#
    case .monthYear:
      return #"(\d{2}\.\d{4})"#
    case .wideMonthYear:
      return #"([A-Za-z]+ \d{4})"#
    }
  }
}

enum ShiftParsingDay: Codable, Hashable {
  case day(month: ShiftParsingMonth)
  case dayMonthYear

  var regex: String {
    switch self {
    case .day(month: _):
      return #"(?<\#(ShiftParsingKey.day)>\d{2})"#
    case .dayMonthYear:
      return #"(?<\#(ShiftParsingKey.day)>\d{2}\.\d{2}\.\d{4})"#
    }
  }
}

enum ShiftParsingDayResolved {
  case day(
    month: ShiftParsingMonth,
    monthPattern: String
  )

  case dayMonthYear

  var dateFormat: String {
    switch self {
    case .day(month: _):
      return "dd"
    case .dayMonthYear:
      return "dd.MM.yyyy"
    }
  }
}

enum ShiftParsingTimeFormat: String, Codable {
  case hoursMinutes = "hh:mm"
}

protocol ShiftParsingServicing {
  func parse(
    from document: String,
    entryPattern: String,
    day: ShiftParsingDayResolved,
    timeFormat: ShiftParsingTimeFormat,
    timeZone: TimeZone,
    locale: Locale
  ) throws -> [ParsedShift]
}

struct ShiftParsingService: ShiftParsingServicing {
  private func parseMonthDate(
    from document: String,
    pattern: String,
    dateFormat: String,
    timeZone: TimeZone,
    locale: Locale
  ) throws
    -> Date
  {
    guard let regex = try? Regex(pattern) else {
      throw ShiftParsingError.invalidMonthPattern
    }
    guard let match = try regex.firstMatch(in: document) else {
      throw ShiftParsingError.monthNotFound
    }
    guard let capture = match.output[1].substring else {
      throw ShiftParsingError.monthNotFound
    }
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.timeZone = timeZone
    formatter.locale = locale
    guard let date = formatter.date(from: String(capture)) else {
      throw ShiftParsingError.invalidMonthFormat
    }
    return date
  }

  private func splitTime(_ time: String) throws -> (hour: Int, minute: Int) {
    let parts = time.split(separator: ":")
    guard parts.count == 2,
      let hour = Int(parts[0]),
      let minute = Int(parts[1])
    else { throw ShiftParsingError.invalidTimeFormat }
    return (hour: hour, minute: minute)
  }

  func parse(
    from document: String,
    entryPattern: String,
    day: ShiftParsingDayResolved,
    timeFormat: ShiftParsingTimeFormat,
    timeZone: TimeZone,
    locale: Locale
  ) throws -> [ParsedShift] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    calendar.locale = locale

    var shifts: [ParsedShift] = []

    let dateFormat = day.dateFormat

    let entryRegex = try NSRegularExpression(pattern: entryPattern)
    let entryMatches = entryRegex.matches(
      in: document,
      range: NSRange(document.startIndex..., in: document)
    )
    let entryDayFormatter = DateFormatter()
    entryDayFormatter.dateFormat = dateFormat
    entryDayFormatter.timeZone = timeZone
    entryDayFormatter.locale = locale

    for match in entryMatches {
      guard
        let dayRange = Range(
          match.range(withName: ShiftParsingKey.day.rawValue),
          in: document
        )
      else { continue }
      let dayString = String(document[dayRange])
      guard
        let startRange = Range(
          match.range(withName: ShiftParsingKey.startTime.rawValue),
          in: document
        )
      else { continue }
      let start = String(document[startRange])
      let (startHour, startMinute) = try splitTime(start)

      guard
        let endRange = Range(
          match.range(withName: ShiftParsingKey.endTime.rawValue),
          in: document
        )
      else { continue }
      let end = String(document[endRange])
      let (endHour, endMinute) = try splitTime(end)

      if case .day(let month, let pattern) = day {
        let monthDate = try parseMonthDate(
          from: document,
          pattern: pattern,
          dateFormat: month.dateFormat,
          timeZone: timeZone,
          locale: locale
        )

        let monthComponents = calendar.dateComponents(
          [.year, .month],
          from: monthDate
        )
        guard let year = monthComponents.year,
          let month = monthComponents.month
        else { throw ShiftParsingError.invalidMonthFormat }

        guard let dayInt = Int(dayString) else {
          throw ShiftParsingError.invalidDayFormat
        }

        let startComponents = DateComponents(
          calendar: calendar,
          timeZone: timeZone,
          year: year,
          month: month,
          day: dayInt,
          hour: startHour,
          minute: startMinute
        )

        let endComponents = DateComponents(
          calendar: calendar,
          timeZone: timeZone,
          year: year,
          month: month,
          day: dayInt,
          hour: endHour,
          minute: endMinute
        )

        guard let startDate = calendar.date(from: startComponents)
        else { continue }
        guard let endDate = calendar.date(from: endComponents) else {
          continue
        }

        let shift = ParsedShift(start: startDate, end: endDate)
        shifts.append(shift)
      } else {
        guard let dayDate = entryDayFormatter.date(from: dayString)
        else {
          continue
        }

        guard
          let startDate = calendar.date(
            bySettingHour: startHour,
            minute: startMinute,
            second: 0,
            of: dayDate
          )
        else {
          continue
        }

        guard
          let endDate = calendar.date(
            bySettingHour: endHour,
            minute: endMinute,
            second: 0,
            of: dayDate
          )
        else {
          continue
        }
        let shift = ParsedShift(start: startDate, end: endDate)
        shifts.append(shift)
      }
    }
    return shifts
  }
}
