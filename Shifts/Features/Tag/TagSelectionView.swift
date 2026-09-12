import SwiftData
import SwiftUI

struct TagSelectionView: View {
  @Query(sort: \Tag.name)
  private var tags: [Tag]
  @Environment(\.modelContext) private var modelContext
  @Binding private var selectedTags: Set<Tag>
  @State private var showAddTag: Bool = false
  @Environment(\.dismiss) private var dismiss

  init(selectedTags: Binding<Set<Tag>>) {
    self._selectedTags = selectedTags
  }

  var body: some View {
    Group {
      if !tags.isEmpty {
        List(selection: $selectedTags) {
          ForEach(tags) { tag in
            TagRowView(tag: tag)
              .tag(tag)
              .accessibilityElement(children: .contain)
              .accessibilityIdentifier("tagSelection.tagRow-\(tag.name)")
          }
        }
        .accessibilityIdentifier("tagSelection.tagList")
      } else {
        ContentUnavailableView(
          .titleNoTags,
          systemImage: "tag",
          description: Text(.descriptionNoTags)
        )
      }
    }
    .environment(\.editMode, .constant(.active))
    .navigationTitle(.titleSelectTags)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(.buttonAddTag, systemImage: "plus") {
          showAddTag = true
        }
        .accessibilityIdentifier("tagSelection.addTagButton")
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonDone, systemImage: "checkmark") {
          dismiss()
        }
        .accessibilityIdentifier("tagSelection.doneButton")
      }
    }
    .sheet(isPresented: $showAddTag) {
      NavigationStack {
        TagEditView(mode: .add)
      }
    }
  }
}

#Preview {
  NavigationStack {
    TagSelectionView(selectedTags: .constant([]))
      .modelContainer(PreviewSupport.inMemoryContainer())
  }
}
