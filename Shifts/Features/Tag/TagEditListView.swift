import SwiftUI
import _SwiftData_SwiftUI

struct TagEditListView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
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
              modelContext.delete(tags[index])
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
        TagEditView(mode: .edit(tag: tag))
      }
    }
    .sheet(isPresented: $showAddTag) {
      NavigationStack {
        TagEditView(mode: .add)
      }
    }
  }
}

#if DEBUG
  #Preview {
    NavigationStack {
      TagEditListView()
        .modelContainer(PreviewSupport.inMemoryContainer())
    }
  }
#endif
