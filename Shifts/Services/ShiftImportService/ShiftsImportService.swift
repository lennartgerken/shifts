import Foundation
import SwiftData
import Vision

enum OverwriteShifts {
  case noOverwrite
  case byTimespan(from: Date, to: Date)
  case byStartDay
}

protocol ShiftsImportServicing {
  func importShifts(from image: CGImage, importSettings: ImportSettingsValidated) async throws
    -> [ParsedShift]

  func finalize(
    modelContext: ModelContext, shifts: [ParsedShift], overwriteShifts: OverwriteShifts,
    category: Category?
  )
    async throws -> ShiftImportResult
}

struct ShiftImportResult {
  let deletedShifts: [Shift]
  let newShifts: [Shift]
}

struct ShiftsImportService: ShiftsImportServicing {
  private let textRecognitionService: TextRecognitionServicing
  private let shiftParsingService: ShiftParsingServicing

  init(textRecognitionService: TextRecognitionServicing, shiftParsingService: ShiftParsingServicing)
  {
    self.textRecognitionService = textRecognitionService
    self.shiftParsingService = shiftParsingService
  }

  func importShifts(from image: CGImage, importSettings: ImportSettingsValidated) async throws
    -> [ParsedShift]
  {
    let document = try await textRecognitionService.recognize(from: image)
    return try shiftParsingService.parse(
      from: document,
      entryPattern: importSettings.entryPattern.toRegex(),
      day: importSettings.day,
      timeFormat: ShiftParsingTimeFormat.hoursMinutes,
      timeZone: TimeZone.current,
      locale: Locale.current
    )
  }

  @MainActor
  func finalize(
    modelContext: ModelContext, shifts parsedShifts: [ParsedShift],
    overwriteShifts: OverwriteShifts, category: Category?
  ) async throws
    -> ShiftImportResult
  {
    let calendar = Calendar.current

    var deletedShifts: [Shift] = []
    var newShifts: [Shift] = []

    if case .byStartDay = overwriteShifts {
      for parsedShift in parsedShifts {
        let startOfStartDate = calendar.startOfDay(for: parsedShift.start)
        let endOfStartDate = calendar.date(
          byAdding: DateComponents(day: 1, minute: -1),
          to: startOfStartDate
        )!
        let descriptor = FetchDescriptor<Shift>(
          predicate: #Predicate { shift in
            shift.start >= startOfStartDate && shift.start <= endOfStartDate
          }
        )
        for shift in try modelContext.fetch(descriptor) {
          modelContext.delete(shift)
          deletedShifts.append(shift)
        }
      }
    } else if case .byTimespan(let from, let to) = overwriteShifts {
      let descriptor = FetchDescriptor<Shift>(
        predicate: #Predicate { shift in
          shift.start > from && shift.start <= to
        }
      )
      for shift in try modelContext.fetch(descriptor) {
        modelContext.delete(shift)
        deletedShifts.append(shift)
      }
    }

    for parsedShift in parsedShifts {
      if let shift = try? Shift(start: parsedShift.start, end: parsedShift.end, category: category)
      {
        modelContext.insert(shift)
        newShifts.append(shift)
      }
    }
    return ShiftImportResult(deletedShifts: deletedShifts, newShifts: newShifts)
  }
}
