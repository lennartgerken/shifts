import SwiftData
import SwiftUI

private struct ISUITestingKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var isUITesting: Bool {
    get { self[ISUITestingKey.self] }
    set { self[ISUITestingKey.self] = newValue }
  }
}

@main
struct Example_AppApp: App {
  @State private var settings: AppSettings

  private let textRecognitionService: TextRecognitionServicing
  private let shiftParsingService: ShiftParsingServicing
  private let shiftsImportService: ShiftsImportServicing
  private let notificationService: NotificationServicing
  private let modelContainer: ModelContainer

  private let isUITesting = ProcessInfo.processInfo.arguments.contains("--uitesting")

  init() {
    settings = AppSettings()
    textRecognitionService = TextRecognitionService()
    shiftParsingService = ShiftParsingService()
    shiftsImportService = ShiftsImportService(
      textRecognitionService: textRecognitionService, shiftParsingService: shiftParsingService
    )
    notificationService = NotificationService()

    do {
      modelContainer = try ModelContainer(for: Shift.self, Tag.self, ShiftReference.self)
    } catch {
      fatalError("Failed to create model container: \(error)")
    }

    if isUITesting {
      do {
        try TestingSupport.reset(modelContainer: modelContainer)
      } catch {
        fatalError("Failed to insert test data into model container: \(error)")
      }

      TestingSupport.configureSettings(settings: settings)
    }
  }

  var body: some Scene {
    WindowGroup {
      RootView(shiftsImportService: shiftsImportService, notificationService: notificationService)
        .modelContainer(modelContainer)
        .environment(settings)
        .environment(\.isUITesting, isUITesting)
    }
  }
}
