import Foundation
import Testing

@testable import Shifts

struct ShiftParsingServiceTests {
  let calendar: Calendar

  init() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
    calendar.locale = Locale(identifier: "de_DE")

    self.calendar = calendar
  }

  @Test func parseSeparateDate_ddMMyyyy() throws {
    let shiftParsingService = ShiftParsingService()

    let document =
      """
      von: 01.01.2026 bis: 31.01.2026
      01 Do
      02 Fr Schicht 08:30 16:00
      03 Sa Schicht 12:00 20:15
      04 So
      05 Mo Urlaub
      """

    let parsedShifts = try shiftParsingService.parse(
      from: document,
      entryPattern: #"(?<day>\d{2}).{1,}(?<startTime>\d\d:\d\d) (?<endTime>\d\d:\d\d)"#,
      day: .day(month: .dayMonthYear, monthPattern: #"von: (\d{2}\.\d{2}\.\d{4})"#),
      timeFormat: .hoursMinutes, timeZone: TimeZone(identifier: "Europe/Berlin")!,
      locale: Locale(identifier: "de_DE"))

    try #require(parsedShifts.count == 2)
    #expect(
      parsedShifts[0].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 8, minute: 30)))
    #expect(
      parsedShifts[0].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 16, minute: 0)))
    #expect(
      parsedShifts[1].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 12, minute: 0)))
    #expect(
      parsedShifts[1].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 20, minute: 15)))
  }

  @Test func parseSeparateDate_MMMMyyyy() throws {
    let shiftParsingService = ShiftParsingService()

    let document =
      """
      Januar 2026
      01 Do
      02 Fr Schicht 08:30 16:00
      03 Sa Schicht 12:00 20:15
      04 So
      05 Mo Urlaub
      """

    let parsedShifts = try shiftParsingService.parse(
      from: document,
      entryPattern: #"(?<day>\d{2}).{1,}(?<startTime>\d\d:\d\d) (?<endTime>\d\d:\d\d)"#,
      day: .day(month: .wideMonthYear, monthPattern: #"([A-Za-z]+ \d{4})"#),
      timeFormat: .hoursMinutes,
      timeZone: TimeZone(identifier: "Europe/Berlin")!, locale: Locale(identifier: "de_DE"))

    try #require(parsedShifts.count == 2)
    #expect(
      parsedShifts[0].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 8, minute: 30)))
    #expect(
      parsedShifts[0].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 16, minute: 0)))
    #expect(
      parsedShifts[1].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 12, minute: 0)))
    #expect(
      parsedShifts[1].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 20, minute: 15)))
  }

  @Test func parseSeparateDate_MMyyyy() throws {
    let shiftParsingService = ShiftParsingService()

    let document =
      """
      01.2026
      01 Do
      02 Fr Schicht 08:30 16:00
      03 Sa Schicht 12:00 20:15
      04 So
      05 Mo Urlaub
      """

    let parsedShifts = try shiftParsingService.parse(
      from: document,
      entryPattern: #"(?<day>\d{2}).{1,}(?<startTime>\d\d:\d\d) (?<endTime>\d\d:\d\d)"#,
      day: .day(month: .monthYear, monthPattern: #"(\d{2}\.\d{4})"#), timeFormat: .hoursMinutes,
      timeZone: TimeZone(identifier: "Europe/Berlin")!, locale: Locale(identifier: "de_DE"))

    try #require(parsedShifts.count == 2)
    #expect(
      parsedShifts[0].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 8, minute: 30)))
    #expect(
      parsedShifts[0].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 16, minute: 0)))
    #expect(
      parsedShifts[1].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 12, minute: 0)))
    #expect(
      parsedShifts[1].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 20, minute: 15)))
  }

  @Test func parseDateInRow() throws {
    let shiftParsingService = ShiftParsingService()

    let document =
      """
      01.01.2026 Do
      02.01.2026 Fr Schicht 08:30 16:00
      03.01.2026 Sa Schicht 12:00 20:15
      04.01.2026 So
      05.01.2026 Mo Urlaub
      """

    let parsedShifts = try shiftParsingService.parse(
      from: document,
      entryPattern:
        #"(?<day>\d{2}\.\d{2}\.\d{4}).{1,}(?<startTime>\d\d:\d\d) (?<endTime>\d\d:\d\d)"#,
      day: .dayMonthYear, timeFormat: .hoursMinutes,
      timeZone: TimeZone(identifier: "Europe/Berlin")!,
      locale: Locale(identifier: "de_DE"))

    try #require(parsedShifts.count == 2)
    #expect(
      parsedShifts[0].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 8, minute: 30)))
    #expect(
      parsedShifts[0].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 16, minute: 0)))
    #expect(
      parsedShifts[1].start
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 12, minute: 0)))
    #expect(
      parsedShifts[1].end
        == calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 20, minute: 15)))
  }
}
