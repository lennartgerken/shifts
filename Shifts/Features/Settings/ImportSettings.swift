import Foundation

enum ImportSettingsErrors: Error {
  case wrongEntryPattern
  case wrongMonthPattern
}

struct ImportSettings: Codable {
  private var _entryPattern: PatternGroup = PatternGroup(patternValues: [])
  private var _monthPattern: PatternGroup = PatternGroup(patternValues: [])
  var day: ShiftParsingDay = .dayMonthYear {
    didSet {
      guard day != oldValue else { return }
      _entryPattern.patternValues = []
      _monthPattern.patternValues = []
    }
  }

  var dayResolved: ShiftParsingDayResolved {
    get throws {
      switch day {
      case .dayMonthYear:
        return .dayMonthYear
      case .day(let month):
        let monthPattern = try checkMonthPattern()
        return .day(month: month, monthPattern: monthPattern.toRegex())
      }
    }
  }

  var neededEntryPatternValues: [PatternValue] {
    switch day {
    case .dayMonthYear:
      return [
        .dayPattern(DayPattern(type: .dayMonthYear)),
        .startTimePattern(StartTimePattern(type: .hoursMinutes)),
        .endTimePattern(EndTimePattern(type: .hoursMinutes)),
      ]
    case .day:
      return [
        .dayPattern(DayPattern(type: .day)),
        .startTimePattern(StartTimePattern(type: .hoursMinutes)),
        .endTimePattern(EndTimePattern(type: .hoursMinutes)),
      ]
    }
  }

  var neededMonthPatternValues: [PatternValue] {
    switch day {
    case .dayMonthYear:
      return []
    case .day(let month):
      switch month {
      case .dayMonthYear:
        return [.monthPattern(MonthPattern(type: .dayMonthYear))]
      case .monthYear:
        return [.monthPattern(MonthPattern(type: .monthYear))]
      case .wideMonthYear:
        return [.monthPattern(MonthPattern(type: .wideMonthYear))]
      }
    }
  }

  var entryPattern: PatternGroup {
    get { _entryPattern }
    set {
      if Self.checkNeededPatternValues(
        groupToCheck: newValue, neededPatternValues: neededEntryPatternValues)
      {
        _entryPattern = newValue
      }
    }
  }

  var monthPattern: PatternGroup {
    get { _monthPattern }
    set {
      if Self.checkNeededPatternValues(
        groupToCheck: newValue, neededPatternValues: neededMonthPatternValues)
      {
        _monthPattern = newValue
      }
    }
  }

  func checkEntryPattern() throws -> PatternGroup {
    guard
      Self.checkNeededPatternValues(
        groupToCheck: entryPattern, neededPatternValues: neededEntryPatternValues)
    else {
      throw ImportSettingsErrors.wrongEntryPattern
    }
    return entryPattern
  }

  func checkMonthPattern() throws -> PatternGroup {
    guard
      Self.checkNeededPatternValues(
        groupToCheck: monthPattern, neededPatternValues: neededMonthPatternValues)
    else {
      throw ImportSettingsErrors.wrongMonthPattern
    }
    return monthPattern
  }

  func validate() throws {
    _ = try checkEntryPattern()
    _ = try checkMonthPattern()
  }

  private static func checkNeededPatternValues(
    groupToCheck: PatternGroup, neededPatternValues: [PatternValue]
  ) -> Bool {
    let allAllowed = groupToCheck.patternValues.allSatisfy { patternValue in
      switch patternValue {
      case .anyPattern, .numberPattern, .staticPattern, .textPattern:
        true
      default:
        neededPatternValues.contains(patternValue)
      }
    }
    let allIncluded = neededPatternValues.allSatisfy { patternValue in
      return groupToCheck.patternValues.contains(patternValue)
    }
    return allAllowed && allIncluded
  }
}
