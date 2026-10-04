import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: "SettingsNotificationsSectionView"
)

struct SettingsNotificationsSectionView: View {
  let notificationService: NotificationServicing

  @Environment(AppSettings.self) private var settings
  @Environment(\.modelContext) private var modelContext

  @State private var showEditNotification = false
  @State private var showNotificationAlert = false

  var body: some View {
    @Bindable var settings = settings

    Section {
      Button(.buttonEditReminders, systemImage: "bell") {
        showEditNotification = true
      }
      .sheet(isPresented: $showEditNotification) {
        NavigationStack {
          NotificationTimingsListView(
            notificationTimings: $settings.notificationTimings
          )
        }
        .presentationDetents([.medium])
      }
      .onChange(of: settings.notificationTimings) { _, _ in
        Task {
          do {
            try await notificationService.scheduleUpcomingShifts(
              modelContext: modelContext, notificationTimings: settings.notificationTimings)
          } catch {
            logger.error("Could not schedule notifications: \(error)")
          }
        }
      }
      .accessibilityIdentifier("settings.editRemindersButton")
    }
  }
}

#Preview {
  Form {
    SettingsNotificationsSectionView(notificationService: NotificationService())
      .environment(AppSettings())
      .modelContainer(PreviewSupport.inMemoryContainer())
  }
}
