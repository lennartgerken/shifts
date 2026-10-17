import Foundation
import SwiftData
import Vision

enum OverwriteShifts {
  case noOverwrite
  case byTimespan(from: Date, to: Date, overwriteAllCategories: Bool)
  case byStartDay(overwriteAllCategories: Bool)
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

    if case .byStartDay(let overwriteAllCategories) = overwriteShifts {
      for parsedShift in parsedShifts {
        let startOfStartDate = calendar.startOfDay(for: parsedShift.start)
        let endOfStartDate = calendar.date(
          byAdding: DateComponents(day: 1, minute: -1),
          to: startOfStartDate
        )!

        var predicate: Predicate<Shift>
        if overwriteAllCategories {
          predicate = #Predicate { shift in
            shift.start >= startOfStartDate && shift.start <= endOfStartDate
          }
        } else {
          if let category {
            let categoryID = category.persistentModelID
            predicate = #Predicate<Shift> { shift in
              shift.category?.persistentModelID == categoryID && shift.start >= startOfStartDate
                && shift.start <= endOfStartDate
            }
          } else {
            predicate = #Predicate<Shift> { shift in
              shift.category == nil && shift.start >= startOfStartDate
                && shift.start <= endOfStartDate
            }
          }
        }

        for shift in try modelContext.fetch(FetchDescriptor<Shift>(predicate: predicate)) {
          modelContext.delete(shift)
          deletedShifts.append(shift)
        }
      }
    } else if case .byTimespan(let from, let to, let overwriteAllCategories) = overwriteShifts {
      var predicate: Predicate<Shift>
      if overwriteAllCategories {
        predicate = #Predicate { shift in
          shift.start > from && shift.start <= to
        }
      } else {
        if let category {
          let categoryID = category.persistentModelID
          predicate = #Predicate<Shift> { shift in
            shift.category?.persistentModelID == categoryID && shift.start > from
              && shift.start <= to
          }
        } else {
          predicate = #Predicate<Shift> { shift in
            shift.category == nil && shift.start > from && shift.start <= to
          }
        }
      }

      for shift in try modelContext.fetch(
        FetchDescriptor<Shift>(
          predicate: predicate
        ))
      {
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
