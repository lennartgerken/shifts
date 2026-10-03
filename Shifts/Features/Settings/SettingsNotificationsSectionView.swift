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

    Section(.titleNotifications) {
      Toggle(
        .labelSendNotifications,
        isOn: $settings.sendNotifications
      )
      .onChange(of: settings.sendNotifications) { _, newValue in
        updateNotifications(enabled: newValue)
      }
      .alert(.titleEnableNotifications, isPresented: $showNotificationAlert) {
        Button(.buttonClose) {}
      } message: {
        Text(.descriptionEnableNotifications)
      }
      .onChange(of: settings.notificationTimings) { _, _ in
        updateNotifications(enabled: settings.sendNotifications)
      }
      .accessibilityIdentifier("settings.notificationsToggle")

      if settings.sendNotifications {
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
        .accessibilityIdentifier("settings.editRemindersButton")
      }
    }
  }

  private func scheduleUpcomingShifts() async {
    let currentDate = Date()
    let descriptor = FetchDescriptor<Shift>(
      predicate: #Predicate { shift in
        shift.start >= currentDate
      }
    )
    do {
      let upcomingShifts = try modelContext.fetch(descriptor)
      for shift in upcomingShifts {
        do {
          try await notificationService.schedule(
            for: shift,
            notificationTimings: settings.notificationTimings
          )
        } catch {
          logger.error("Could not schedule notification: \(error)")
        }
      }
    } catch {
      logger.error("Could not fetch upcoming shifts: \(error)")
    }
  }

  private func updateNotifications(enabled: Bool) {
    if enabled {
      Task {
        do {
          let status =
            await notificationService.authorizationStatus()
          switch status {
          case .notDetermined:
            let granted =
              try await notificationService
              .requestAuthorization()
            if granted {
              await scheduleUpcomingShifts()
            } else {
              settings.sendNotifications = false
            }
          case .authorized:
            await scheduleUpcomingShifts()
          default:
            settings.sendNotifications = false
            showNotificationAlert = true
          }
        } catch {
          logger.error("Could not request notification authorization: \(error)")
        }
      }
    } else {
      notificationService.removeAll()
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
