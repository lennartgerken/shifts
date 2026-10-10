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

  @State private var export: ShiftPileExport?

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
      .onOpenURL { url in
        do {
          let data = try Data(contentsOf: url)
          export = try JSONDecoder().decode(ShiftPileExport.self, from: data)
        } catch {
          print(error)
        }
      }
      .sheet(
        isPresented: Binding(
          get: { export != nil },
          set: { if !$0 { export = nil } }
        )
      ) {
        if let export {
          NavigationStack {
            ShiftsImportView(
              export: export, shiftsImportService: shiftsImportService,
              notificationService: notificationService)
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
