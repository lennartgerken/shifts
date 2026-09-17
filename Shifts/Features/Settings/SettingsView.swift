import SwiftData
import SwiftUI

struct SettingsView: View {
  let notificationService: NotificationServicing

  @Environment(AppSettings.self) private var settings
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @State private var showImportInfo = false
  @State private var showEditTags = false
  @State private var showEditShiftReferences = false
  @State private var showAddNotification = false

  @State private var newNotificationValue = 1

  var body: some View {
    @Bindable var settings = settings

    Form {
      Section {
        Picker(
          .labelDateIdentification,
          selection: $settings.importSettings.day
        ) {
          Text(.pickerValueSeperateDdMmYyyy).tag(
            ShiftParsingDay.day(month: .dayMonthYear)
          )
          Text(.pickerValueSeperateMmYyyy).tag(
            ShiftParsingDay.day(month: .monthYear)
          )
          Text(.pickerValueSeperateMmmmYyyy).tag(
            ShiftParsingDay.day(month: .wideMonthYear)
          )
          Text(.pickerValueWholeDate).tag(
            ShiftParsingDay.dayMonthYear
          )
        }
        PatternView(
          label: String(localized: .patternShiftEntry),
          patternGroup: Binding(
            get: { settings.importSettings.entryPattern },
            set: { settings.importSettings.entryPattern = $0 }
          ),
          additionalPatternValues: settings.importSettings
            .neededEntryPatternValues
        )
        if case .day = settings.importSettings.day {
          PatternView(
            label: String(localized: .patternDate),
            patternGroup: Binding(
              get: { settings.importSettings.monthPattern },
              set: { settings.importSettings.monthPattern = $0 }
            ),
            additionalPatternValues: settings.importSettings
              .neededMonthPatternValues
          )
        }
      } header: {
        HStack {
          Text(.titleImportShifts)
          Spacer()
          Button {
            showImportInfo = true
          } label: {
            Label(.buttonInfo, systemImage: "info.circle")
              .labelStyle(.iconOnly)
          }
        }
      }
      Section(.titleTags) {
        Button(.buttonEditTags, systemImage: "tag") {
          showEditTags = true
        }
        .accessibilityIdentifier("settings.editTagsButton")
      }
      Section(.titleShiftReferences) {
        Button(
          .buttonDeleteShiftReferences,
          systemImage: "document.on.document"
        ) {
          showEditShiftReferences = true
        }
        .accessibilityIdentifier("settings.deleteShiftReferencesButton")
      }
      Section(.titleNotifications) {
        Toggle(
          .labelSendNotifications,
          isOn: $settings.sendNotifications
        )
        .onChange(of: settings.sendNotifications) { _, newValue in
          updateNotifications(enabled: newValue)
        }
        .accessibilityIdentifier("settings.notificationsToggle")
        if settings.sendNotifications {
          Button(.buttonEditReminders, systemImage: "bell") {
            showAddNotification = true
          }
          .accessibilityIdentifier("settings.editRemindersButton")
        }
      }

    }
    .sheet(
      isPresented: $showImportInfo,
      content: {
        NavigationStack {
          SettingsImportInfoView()
        }
      }
    )
    .sheet(
      isPresented: $showEditTags,
      content: {
        NavigationStack {
          TagEditListView()
        }
      }
    )
    .sheet(
      isPresented: $showEditShiftReferences,
      content: {
        NavigationStack {
          ShiftReferenceEditListView()
        }
      }
    )
    .sheet(isPresented: $showAddNotification) {
      NavigationStack {
        NotificationTimingsList(
          notificationTimings: $settings.notificationTimings
        )
      }
      .presentationDetents([.medium])
    }
    .onChange(of: settings.notificationTimings) { _, _ in
      updateNotifications(enabled: settings.sendNotifications)
    }
    .navigationTitle(.titleSettings)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button {
          dismiss()
        } label: {
          Label(.buttonDone, systemImage: "checkmark")
        }
      }
    }
  }

  private func scheduleUpcomingShifts() async throws {
    let currentDate = Date()
    let descriptor = FetchDescriptor<Shift>(
      predicate: #Predicate { shift in
        shift.start >= currentDate
      }
    )
    let upcomingShifts = try modelContext.fetch(descriptor)
    for shift in upcomingShifts {
      try await notificationService.schedule(
        for: shift,
        notificationTimings: settings.notificationTimings
      )
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
              try await scheduleUpcomingShifts()
            } else {
              settings.sendNotifications = false
            }
          case .authorized:
            try await scheduleUpcomingShifts()
          default:
            settings.sendNotifications = false
          }
        } catch {
          print(error)
        }
      }
    } else {
      notificationService.removeAll()
    }
  }
}

#Preview {
  let settings = AppSettings()

  NavigationStack {
    SettingsView(notificationService: NotificationService())
  }
  .environment(settings)
}
