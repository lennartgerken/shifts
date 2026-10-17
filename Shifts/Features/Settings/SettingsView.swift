import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: "SettingsView"
)

struct SettingsView: View {
  let notificationService: NotificationServicing

  @Environment(AppSettings.self) private var settings
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @State private var showEditNotification = false

  var body: some View {
    @Bindable var settings = settings

    Form {
      NavigationLink(.buttonImportSettings) {
        SettingsImportView()
      }
      Section {
        NavigationLink(.buttonEditTags) {
          TagEditListView(notificationService: notificationService)
        }
        .accessibilityIdentifier("settings.editTagsButton")
        NavigationLink(.buttonEditCategories) {
          CategoryEditListView(notificationService: notificationService)
        }
        .accessibilityIdentifier("settings.editCategoriesButton")
        NavigationLink(.buttonDeleteShiftReferences) {
          ShiftReferenceEditListView()
        }
        .accessibilityIdentifier("settings.deleteShiftReferencesButton")
        NavigationLink(.buttonEditReminders) {
          NotificationTimingsListView(
            notificationTimings: $settings.notificationTimings
          )
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
    .navigationTitle(.titleSettings)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button {
          dismiss()
        } label: {
          Label(.buttonDone, systemImage: "checkmark")
        }
        .accessibilityIdentifier("settings.doneButton")
      }
    }
  }
}

#if DEBUG
  #Preview {
    let settings = AppSettings()

    NavigationStack {
      SettingsView(notificationService: NotificationService())
    }
    .environment(settings)
    .modelContainer(PreviewSupport.inMemoryContainer())
  }
#endif
