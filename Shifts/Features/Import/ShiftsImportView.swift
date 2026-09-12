import PhotosUI
import SwiftData
import SwiftUI
import Vision

struct ShiftsImportView: View {
  @State private var selectedImage: PhotosPickerItem?
  @State private var viewModel: ShiftsImportViewModel
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(AppSettings.self) private var settings

  @Environment(\.isUITesting) private var isUITesting

  init(
    shiftsImportService: ShiftsImportServicing,
    notificationService: NotificationServicing
  ) {
    self.viewModel = ShiftsImportViewModel(
      shiftsImportService: shiftsImportService,
      notificationService: notificationService
    )
  }

  var body: some View {
    Group {
      if let importedDays = viewModel.importedDays {
        if !importedDays.isEmpty {
          List {
            ForEach(importedDays) { day in
              DayRowView(day: day, style: .fullDate)
                .accessibilityIdentifier(
                  "shiftsImport.dayRow-\(day.id.formatted(.iso8601.year().month().day()))")
            }
          }
        } else {
          ContentUnavailableView(
            .titleNoShifts, systemImage: "calendar", description: Text(.errorParseShiftsFailed))
        }
      } else {
        VStack(alignment: .leading, spacing: 20) {
          Text(.descriptionImport)
          if let importedSettingsValidated = try? ImportSettingsValidated(
            settings: settings.importSettings)
          {
            if let errorMessage = viewModel.errorMessage {
              Text(errorMessage)
            } else {
              Group {
                if viewModel.isLoading {
                  ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                  Group {
                    if isUITesting {
                      Button(.buttonImportSelectImage, systemImage: "photo.badge.magnifyingglass") {
                        let url = Bundle.main.url(forResource: "schedule", withExtension: "png")!
                        let data = try! Data(Data(contentsOf: url))
                        Task {
                          await viewModel.importImage(data, settings: importedSettingsValidated)
                        }
                      }
                      .accessibilityIdentifier("shiftsImport.selectImageButton")
                    } else {
                      PhotosPicker(
                        selection: $selectedImage,
                        matching: .images
                      ) {
                        Label(
                          .buttonImportSelectImage,
                          systemImage: "photo.badge.magnifyingglass"
                        )
                      }
                      .onChange(of: selectedImage) {
                        Task {
                          guard let selectedImage else { return }
                          await viewModel.importImage(
                            selectedImage, settings: importedSettingsValidated)
                        }
                      }
                    }
                  }
                }
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
          } else {
            Text(.errorImportConfigMissing)
            Spacer()
          }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
      }
    }
    .navigationTitle(.titleImportShifts)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(.buttonCancel, systemImage: "xmark") {
          dismiss()
        }
      }
      if let shifts = viewModel.importedDays, !shifts.isEmpty {
        ToolbarItem(placement: .confirmationAction) {
          Button(.buttonSave, systemImage: "checkmark") {
            viewModel.saveShifts(modelContext: modelContext, settings: settings)
            dismiss()
          }
          .accessibilityIdentifier("shiftsImport.saveButton")
        }
      }
    }
  }
}

#Preview {
  let textRecognitionService = TextRecognitionService()
  let shiftParsingService = ShiftParsingService()
  let shiftsImportService = ShiftsImportService(
    textRecognitionService: textRecognitionService,
    shiftParsingService: shiftParsingService,
  )
  let notificationService = NotificationService()

  var importSettings = ImportSettings()
  importSettings.day = .day(month: .dayMonthYear)
  importSettings.entryPattern = PatternGroup(
    patternValues: [
      .dayPattern(DayPattern(type: .day)),
      .anyPattern(AnyPattern(count: 1, orMore: true)),
      .startTimePattern(StartTimePattern(type: .hoursMinutes)),
      .staticPattern(StaticPattern(text: " ")),
      .endTimePattern(EndTimePattern(type: .hoursMinutes)),
    ]
  )
  importSettings.monthPattern = PatternGroup(
    patternValues: [
      .staticPattern(StaticPattern(text: "Von: ")),
      .monthPattern(MonthPattern(type: .dayMonthYear)),
    ]
  )
  let settings = AppSettings()
  settings.importSettings = importSettings

  return NavigationStack {
    ShiftsImportView(
      shiftsImportService: shiftsImportService,
      notificationService: notificationService
    )
    .environment(settings)
    .environment(\.isUITesting, true)
  }
}

#Preview {
  let textRecognitionService = TextRecognitionService()
  let shiftParsingService = ShiftParsingService()
  let shiftsImportService = ShiftsImportService(
    textRecognitionService: textRecognitionService,
    shiftParsingService: shiftParsingService,
  )
  let notificationService = NotificationService()

  let settings = AppSettings()
  settings.importSettings = ImportSettings()

  return NavigationStack {
    ShiftsImportView(
      shiftsImportService: shiftsImportService,
      notificationService: notificationService
    )
    .environment(settings)
  }
}
