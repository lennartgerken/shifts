import SwiftData
import SwiftUI

struct SettingsView: View {
  let notificationService: NotificationServicing

  @Environment(AppSettings.self) private var settings
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @State private var showEditTags = false
  @State private var showEditCategories = false
  @State private var showEditShiftReferences = false

  var body: some View {
    @Bindable var settings = settings

    Form {
      SettingsImportSectionView()
      Section {
        Button(.buttonEditTags, systemImage: "tag") {
          showEditTags = true
        }
        .accessibilityIdentifier("settings.editTagsButton")
        Button(.buttonEditCategories, systemImage: "flag") {
          showEditCategories = true
        }
        .accessibilityIdentifier("settings.editCategoriesButton")
        Button(
          .buttonDeleteShiftReferences,
          systemImage: "document.on.document"
        ) {
          showEditShiftReferences = true
        }
        .accessibilityIdentifier("settings.deleteShiftReferencesButton")
        SettingsNotificationsSectionView(notificationService: notificationService)
      }
    }
    .sheet(
      isPresented: $showEditTags,
      content: {
        NavigationStack {
          TagEditListView(notificationService: notificationService)
        }
      }
    )
    .sheet(
      isPresented: $showEditCategories,
      content: {
        NavigationStack {
          CategoryEditListView(notificationService: notificationService)
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
