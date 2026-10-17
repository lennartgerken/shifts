import Foundation
import OSLog
import Observation
import PhotosUI
import SwiftData
import SwiftUI
import Vision

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: "ShiftsImportViewModel"
)

enum ShiftsImportViewOverwriteShifts {
  case noOverwrite
  case byTimespan
  case byStartDay
}

@Observable
final class ShiftsImportViewModel {
  private let calendar = Calendar.current

  private let shiftsImportService: ShiftsImportServicing
  private let notificationService: NotificationServicing

  var isLoading: Bool = false
  var importedShifts: [ParsedShift]?
  var errorMessage: String?

  var category: Category?
  var overwriteShifts: ShiftsImportViewOverwriteShifts = .byTimespan
  var overwriteShiftsTimespanStart: Date = Date()
  var overwriteShiftsTimespanEnd: Date = Date()
  var overwriteAllCategories = false

  init(
    export: ShiftPileExport? = nil, shiftsImportService: ShiftsImportServicing,
    notificationService: NotificationServicing
  ) {
    if let export {
      self.importedShifts = export.shifts.map({ shiftExport in
        ParsedShift(start: shiftExport.start, end: shiftExport.end)
      })
      if let firstShiftExport = export.shifts.first {
        let interval = calendar.dateInterval(of: .month, for: firstShiftExport.start)!
        overwriteShiftsTimespanStart = interval.start
        overwriteShiftsTimespanEnd = calendar.date(byAdding: .minute, value: -1, to: interval.end)!
      }
    }
    self.shiftsImportService = shiftsImportService
    self.notificationService = notificationService
  }

  func importImage(_ image: Data, settings: ImportSettingsValidated) async {
    isLoading = true
    defer { isLoading = false }

    guard
      let image = UIImage(data: image),
      let cgImage = image.cgImage
    else {
      errorMessage = String(localized: .errorImportImageFailed)
      return
    }

    guard
      let parsedShifts = try? await shiftsImportService.importShifts(
        from: cgImage,
        importSettings: settings
      )
    else {
      errorMessage = String(localized: .errorParseShiftsFailed)
      return
    }

    if let firstShift = parsedShifts.sorted(by: { shift1, shift2 in
      shift1.start < shift2.start
    }).first {
      let interval = calendar.dateInterval(of: .month, for: firstShift.start)!
      overwriteShiftsTimespanStart = interval.start
      overwriteShiftsTimespanEnd = calendar.date(byAdding: .minute, value: -1, to: interval.end)!
    }
    importedShifts = parsedShifts
  }

  func importImage(_ selectedImage: PhotosPickerItem, settings: ImportSettingsValidated) async {
    isLoading = true
    defer { isLoading = false }

    guard
      let data = try? await selectedImage.loadTransferable(
        type: Data.self
      )
    else {
      errorMessage = String(localized: .errorImportImageFailed)
      return
    }

    await importImage(data, settings: settings)
  }

  func saveShifts(modelContext: ModelContext, settings: AppSettings) {
    Task {
      var overwriteToSet: OverwriteShifts = .noOverwrite
      switch overwriteShifts {
      case .noOverwrite:
        break
      case .byTimespan:
        overwriteToSet = .byTimespan(
          from: calendar.startOfDay(for: overwriteShiftsTimespanStart),
          to: calendar.date(
            byAdding: DateComponents(day: 1, minute: -1),
            to: calendar.date(
              from: calendar.dateComponents(
                [.year, .month, .day], from: overwriteShiftsTimespanEnd))!)!,
          overwriteAllCategories: overwriteAllCategories)
      case .byStartDay:
        overwriteToSet = .byStartDay(overwriteAllCategories: overwriteAllCategories)
      }

      guard let importedShifts else { return }

      do {
        let shiftImportResults = try await shiftsImportService.finalize(
          modelContext: modelContext,
          shifts: importedShifts,
          overwriteShifts: overwriteToSet,
          category: category
        )
        for shift in shiftImportResults.deletedShifts {
          notificationService.remove(for: shift)
        }
        for shift in shiftImportResults.newShifts {
          do {
            try await notificationService.schedule(
              for: shift, notificationTimings: settings.notificationTimings)
          } catch {
            logger.error("Could not schedule notification: \(error)")
          }
        }
      } catch {
        logger.error("Could not finalize import: \(error)")
      }
    }
  }
}
