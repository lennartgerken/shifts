import Foundation

struct ImportSettingsValidated {
  let entryPattern: PatternGroup
  let monthPattern: PatternGroup
  let day: ShiftParsingDayResolved

  init(settings: ImportSettings) throws {
    try settings.validate()
    self.entryPattern = settings.entryPattern
    self.monthPattern = settings.monthPattern
    self.day = try settings.dayResolved
  }
}
