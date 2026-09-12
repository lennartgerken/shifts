import Foundation
import Observation
import PhotosUI
import SwiftData
import SwiftUI
import Vision

@Observable
final class ShiftsImportViewModel {
  private let calendar = Calendar.current

  private let shiftsImportService: ShiftsImportServicing
  private let notificationService: NotificationServicing

  var isLoading: Bool = false
  var importedShifts: [ParsedShift]?
  var importedDays: [Day]? {
    guard let parsedShifts = importedShifts else { return nil }

    var dates: Set<Date> = []
    for parsedShift in parsedShifts {
      let start = calendar.startOfDay(for: parsedShift.start)
      let end = calendar.startOfDay(for: parsedShift.end)
      dates.insert(start)
      dates.insert(end)
    }

    let shifts = parsedShifts.compactMap({ parsedShift in
      try? Shift(start: parsedShift.start, end: parsedShift.end)
    })

    return dates.map { date in
      Day(date: date, shifts: shifts)
    }.sorted { day1, day2 in
      day1.dateInterval.start < day2.dateInterval.start
    }
  }
  var errorMessage: String?

  init(shiftsImportService: ShiftsImportServicing, notificationService: NotificationServicing) {
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
      do {
        guard let importedShifts else { return }
        let shiftImportResults = try await shiftsImportService.finalize(
          modelContext: modelContext,
          shifts: importedShifts
        )
        for shift in shiftImportResults.deletedShifts {
          notificationService.remove(for: shift)
        }
        if settings.sendNotifications {
          for shift in shiftImportResults.newShifts {
            try await notificationService.schedule(
              for: shift, notificationTimings: settings.notificationTimings)
          }
        }
      } catch {
        print(error)
      }
    }
  }
}
