import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: "TagEditListView"
)

struct TagEditListView: View {
  let notificationService: NotificationServicing

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(AppSettings.self) private var settings
  @Query(sort: \Tag.name) private var tags: [Tag]
  @State private var tagToEdit: Tag? = nil
  @State private var showAddTag: Bool = false

  var body: some View {
    Group {
      if !tags.isEmpty {
        List {
          ForEach(tags) { tag in
            Button {
              tagToEdit = tag
            } label: {
              TagRowView(tag: tag)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("tagEditList.tagRow-\(tag.name)")
          }
          .onDelete { indexSet in
            for index in indexSet {
              let tag = tags[index]
              let shifts = tag.shifts
              modelContext.delete(tag)
              Task {
                for shift in shifts {
                  do {
                    try await notificationService.update(
                      for: shift, notificationTimings: settings.notificationTimings)
                  } catch {
                    logger.error("Could not update notification: \(error)")
                  }
                }
              }
            }
          }
        }
      } else {
        ContentUnavailableView(
          .titleNoTags, systemImage: "tag", description: Text(.descriptionNoTags))
      }
    }
    .navigationTitle(.titleEditTags)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(.buttonAddTag, systemImage: "plus") {
          showAddTag = true
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonDone, systemImage: "checkmark") {
          dismiss()
        }
      }
    }
    .sheet(item: $tagToEdit) { tag in
      NavigationStack {
        TagEditView(mode: .edit(tag: tag, notificationSercice: notificationService))
      }
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $showAddTag) {
      NavigationStack {
        TagEditView(mode: .add)
      }
      .presentationDetents([.medium])
    }
  }
}

#if DEBUG
  #Preview {
    NavigationStack {
      TagEditListView(notificationService: NotificationService())
        .modelContainer(PreviewSupport.inMemoryContainer())
    }
  }
#endif
