import CoreGraphics
import Foundation
import SwiftData
import Testing

@testable import Shifts

struct FakeTextRecognitionService: TextRecognitionServicing {
  func recognize(from image: CGImage) async throws -> String {
    return ""
  }
}

struct FakeShiftParsingService: ShiftParsingServicing {
  let parsedShifts: [ParsedShift]

  func parse(
    from document: String, entryPattern: String, day: Shifts.ShiftParsingDayResolved,
    timeFormat: Shifts.ShiftParsingTimeFormat, timeZone: TimeZone, locale: Locale
  ) throws -> [Shifts.ParsedShift] {
    return parsedShifts
  }
}

@MainActor
struct ShiftsImportServiceTests {
  let parsedShifts = [
    ParsedShift(
      start: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 1, hour: 10, minute: 0))!,
      end: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 1, hour: 15, minute: 30))!
    ),
    ParsedShift(
      start: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 2, hour: 10, minute: 0))!,
      end: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 2, hour: 15, minute: 30))!
    ),
    ParsedShift(
      start: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 3, hour: 10, minute: 0))!,
      end: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 3, hour: 15, minute: 30))!
    ),
  ]
  let existingShift1: Shift
  let existingShift2: Shift
  let modelContainer: ModelContainer
  let modelContext: ModelContext
  let shiftsImportService: ShiftsImportServicing
  let importSettings: ImportSettings

  init() throws {
    existingShift1 = try Shift(
      start: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 1, hour: 8, minute: 0))!,
      end: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 1, hour: 12, minute: 0))!
    )
    existingShift2 = try Shift(
      start: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 31, hour: 8, minute: 0))!,
      end: Calendar.current.date(
        from: DateComponents(year: 2026, month: 1, day: 31, hour: 12, minute: 0))!
    )
    modelContainer = try getModelContainerWith(shifts: [existingShift1, existingShift2])
    modelContext = modelContainer.mainContext
    shiftsImportService = ShiftsImportService(
      textRecognitionService: FakeTextRecognitionService(),
      shiftParsingService: FakeShiftParsingService(parsedShifts: parsedShifts))

    let entryPattern = PatternGroup(patternValues: [
      .dayPattern(DayPattern(type: .dayMonthYear)),
      .startTimePattern(StartTimePattern(type: .hoursMinutes)),
      .endTimePattern(EndTimePattern(type: .hoursMinutes)),
    ])
    var importSettings = ImportSettings()
    importSettings.day = .dayMonthYear
    importSettings.entryPattern = entryPattern
    self.importSettings = importSettings
  }

  @Test func overrideByStartDay() async throws {
    let parsedShifts = try await shiftsImportService.importShifts(
      from: try getCGImage(fromResource: "schedule", withExtension: "png"),
      importSettings: ImportSettingsValidated(settings: importSettings))
    let shiftImportResults = try await shiftsImportService.finalize(
      modelContext: modelContext, shifts: parsedShifts, overwriteShifts: .byStartDay)

    let fetchedShifts = try modelContext.fetch(FetchDescriptor<Shift>())

    #expect(shiftImportResults.newShifts.count == parsedShifts.count)
    #expect(fetchedShifts.count == parsedShifts.count + 1)
    for parsedShift in parsedShifts {
      #expect(
        shiftImportResults.newShifts.contains(where: {
          $0.start == parsedShift.start && $0.end == parsedShift.end
        }))
      #expect(
        fetchedShifts.contains(where: {
          $0.start == parsedShift.start && $0.end == parsedShift.end
        }))
    }
    #expect(
      fetchedShifts.contains(where: {
        $0.start == existingShift2.start && $0.end == existingShift2.end
      }))

    #expect(shiftImportResults.deletedShifts.count == 1)
    #expect(shiftImportResults.deletedShifts.contains(existingShift1))
  }

  @Test func overrideByTimespan() async throws {
    let parsedShifts = try await shiftsImportService.importShifts(
      from: try getCGImage(fromResource: "schedule", withExtension: "png"),
      importSettings: ImportSettingsValidated(settings: importSettings))
    let shiftImportResults = try await shiftsImportService.finalize(
      modelContext: modelContext, shifts: parsedShifts,
      overwriteShifts: .byTimespan(
        from: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1))!,
        to: Calendar.current.date(
          from: DateComponents(year: 2026, month: 1, day: 31, hour: 23, minute: 59))!))

    let fetchedShifts = try modelContext.fetch(FetchDescriptor<Shift>())

    #expect(shiftImportResults.newShifts.count == parsedShifts.count)
    #expect(fetchedShifts.count == parsedShifts.count)
    for parsedShift in parsedShifts {
      #expect(
        shiftImportResults.newShifts.contains(where: {
          $0.start == parsedShift.start && $0.end == parsedShift.end
        }))
      #expect(
        fetchedShifts.contains(where: {
          $0.start == parsedShift.start && $0.end == parsedShift.end
        }))
    }

    #expect(shiftImportResults.deletedShifts.count == 2)
    #expect(shiftImportResults.deletedShifts.contains(existingShift1))
    #expect(shiftImportResults.deletedShifts.contains(existingShift2))
  }

  @Test func noOverride() async throws {
    let allShifts =
      parsedShifts.map({ parsedShift in
        try! Shift(start: parsedShift.start, end: parsedShift.end)
      }) + [existingShift1, existingShift2]

    let parsedShifts = try await shiftsImportService.importShifts(
      from: try getCGImage(fromResource: "schedule", withExtension: "png"),
      importSettings: ImportSettingsValidated(settings: importSettings))
    let shiftImportResults = try await shiftsImportService.finalize(
      modelContext: modelContext, shifts: parsedShifts, overwriteShifts: .noOverwrite)

    let fetchedShifts = try modelContext.fetch(FetchDescriptor<Shift>())

    #expect(shiftImportResults.newShifts.count == parsedShifts.count)
    #expect(fetchedShifts.count == allShifts.count)
    for parsedShift in parsedShifts {
      #expect(
        shiftImportResults.newShifts.contains(where: {
          $0.start == parsedShift.start && $0.end == parsedShift.end
        }))
    }
    for shift in allShifts {
      #expect(
        fetchedShifts.contains(where: {
          $0.start == shift.start && $0.end == shift.end
        }))
    }

    #expect(shiftImportResults.deletedShifts.count == 0)
  }
}
