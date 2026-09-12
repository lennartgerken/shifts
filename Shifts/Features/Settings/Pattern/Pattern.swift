import Foundation

protocol Pattern: Codable, Equatable, Hashable {
  func toRegex() -> String
  func toDisplay() -> String
}

//Core patterns
protocol CountedPattern: Pattern {
  var count: Int { get }
  var orMore: Bool { get }
  static var regexValue: String { get }
  static var displayName: String { get }
}

extension CountedPattern {
  func toRegex() -> String {
    let quantifier = "{\(count)\(orMore ? "," : "")}"
    return Self.regexValue + quantifier
  }

  func toDisplay() -> String {
    let quantifier = "\(count)\(orMore ? "+" : "")"
    return "\(Self.displayName) (\(quantifier))"
  }
}

struct StaticPattern: Pattern {
  let text: String

  func toRegex() -> String {
    NSRegularExpression.escapedPattern(for: text)
  }

  func toDisplay() -> String {
    let replaced = text.replacingOccurrences(of: " ", with: "·")
    return
      "\(String(localized: .patternStaticCharacters)) (\"\(replaced)\")"
  }
}

struct NumberPattern: CountedPattern {
  let count: Int
  let orMore: Bool
  static let regexValue = #"\d"#
  static let displayName = String(localized: .patternNumber)
}

struct TextPattern: CountedPattern {
  let count: Int
  let orMore: Bool
  static let regexValue = #"\w"#
  static let displayName = String(localized: .patternText)
}

struct AnyPattern: CountedPattern {
  let count: Int
  let orMore: Bool
  static let regexValue = #"."#
  static let displayName = String(localized: .patternCharacter)
}

//Custom patterns
enum DayPatterType: String, Codable {
  case day
  case dayMonthYear
}

struct DayPattern: Pattern {
  let type: DayPatterType

  func toRegex() -> String {
    switch type {
    case .day:
      ShiftParsingDay.day(month: .dayMonthYear).regex
    case .dayMonthYear:
      ShiftParsingDay.dayMonthYear.regex
    }
  }

  func toDisplay() -> String {
    switch type {
    case .day:
      String(localized: .patternImportDayDd)
    case .dayMonthYear:
      String(localized: .patternImportDayDdMmYyyy)
    }
  }
}

enum TimePatternType: String, Codable {
  case hoursMinutes
}

struct StartTimePattern: Pattern {
  let type: TimePatternType

  func toRegex() -> String {
    switch type {
    case .hoursMinutes:
      #"(?<\#(ShiftParsingKey.startTime.rawValue)>\d\d:\d\d)"#
    }
  }

  func toDisplay() -> String {
    switch type {
    case .hoursMinutes:
      String(localized: .patternImportStartHhMm)
    }
  }
}

struct EndTimePattern: Pattern {
  let type: TimePatternType

  func toRegex() -> String {
    switch type {
    case .hoursMinutes:
      #"(?<\#(ShiftParsingKey.endTime.rawValue)>\d\d:\d\d)"#
    }
  }

  func toDisplay() -> String {
    switch type {
    case .hoursMinutes:
      String(localized: .patternImportEndHhMm)
    }
  }
}

enum MonthPatternType: String, Codable {
  case dayMonthYear
  case monthYear
  case wideMonthYear
}

struct MonthPattern: Pattern {
  let type: MonthPatternType

  func toRegex() -> String {
    switch type {
    case .dayMonthYear:
      ShiftParsingMonth.dayMonthYear.regex
    case .monthYear:
      ShiftParsingMonth.monthYear.regex
    case .wideMonthYear:
      ShiftParsingMonth.wideMonthYear.regex
    }
  }

  func toDisplay() -> String {
    switch type {
    case .dayMonthYear:
      String(localized: .patternImportMonthDdMmYyyy)
    case .monthYear:
      String(localized: .patternImportMonthMmYyyy)
    case .wideMonthYear:
      String(localized: .patternImportMonthMmmmYyyy)
    }
  }
}

enum PatternValue: Codable, Pattern, Hashable {
  //Core patterns
  case textPattern(TextPattern)
  case numberPattern(NumberPattern)
  case anyPattern(AnyPattern)
  case staticPattern(StaticPattern)

  //Custom patterns
  case dayPattern(DayPattern)
  case monthPattern(MonthPattern)
  case startTimePattern(StartTimePattern)
  case endTimePattern(EndTimePattern)

  var pattern: any Pattern {
    switch self {
    //Core patterns
    case .textPattern(let pattern):
      return pattern
    case .numberPattern(let pattern):
      return pattern
    case .anyPattern(let pattern):
      return pattern
    case .staticPattern(let pattern):
      return pattern

    //Custom patterns
    case .dayPattern(let pattern):
      return pattern
    case .monthPattern(let pattern):
      return pattern
    case .startTimePattern(let pattern):
      return pattern
    case .endTimePattern(let pattern):
      return pattern
    }
  }

  func isCorePattern() -> Bool {
    switch self {
    case .textPattern, .numberPattern, .anyPattern, .staticPattern:
      return true
    default:
      return false
    }
  }

  func toRegex() -> String {
    pattern.toRegex()
  }

  func toDisplay() -> String {
    pattern.toDisplay()
  }
}

struct PatternGroup: Codable {
  var patternValues: [PatternValue]

  func toRegex() -> String {
    return patternValues.map { $0.pattern.toRegex() }.joined()
  }

  func toDisplay() -> String {
    return patternValues.map { $0.pattern.toDisplay() }.joined(separator: " ")
  }

  func has(patternValue: PatternValue) -> Bool {
    patternValues.contains(patternValue)
  }
}
