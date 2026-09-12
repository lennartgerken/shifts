import SwiftData
import SwiftUI

struct TagsView: View {
  @Binding private var tags: Set<Tag>
  @State private var showTagList: Bool = false

  private var sortedTags: [Tag] { tags.sorted { $0.name < $1.name } }

  init(tags: Binding<Set<Tag>>) {
    self._tags = tags
  }

  var body: some View {
    Section(.titleTags) {
      TagListView(tags: tags)
      Button(.buttonSelectTags, systemImage: "checkmark.circle") {
        showTagList = true
      }
      .accessibilityIdentifier("tags.selectTagsButton")
      .sheet(isPresented: $showTagList) {
        NavigationStack {
          TagSelectionView(selectedTags: $tags)
        }
      }
    }
  }
}

#Preview {
  Form {
    TagsView(
      tags: .constant([])
    )
    .modelContainer(PreviewSupport.inMemoryContainer())
  }
}
