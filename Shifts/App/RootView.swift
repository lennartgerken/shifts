import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: "RootView"
)

struct RootView: View {
  let shiftsImportService: ShiftsImportServicing
  let notificationService: NotificationServicing

  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.modelContext) private var modelContext
  @Environment(AppSettings.self) private var settings

  var body: some View {
    CalendarView(shiftsImportService: shiftsImportService, notificationService: notificationService)
      .onChange(of: scenePhase) { _, newPhase in
        if newPhase == .active {
          Task {
            let status = await notificationService.authorizationStatus()
            if settings.lastNotificationStatus != nil, settings.lastNotificationStatus != 2,
              status == .authorized
            {
              do {
                try await notificationService.scheduleUpcomingShifts(
                  modelContext: modelContext, notificationTimings: settings.notificationTimings)
              } catch {
                logger.error("Could not schedule notifications: \(error)")
              }
            }
            settings.lastNotificationStatus = await notificationService.authorizationStatus()
              .rawValue
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

  RootView(shiftsImportService: shiftsImportService, notificationService: notificationService)
    .environment(AppSettings())
}
