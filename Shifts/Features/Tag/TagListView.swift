import SwiftData
import SwiftUI

struct TagListView: View {
  private var tags: Set<Tag>

  private var sortedTags: [Tag] { tags.sorted { $0.name < $1.name } }

  init(tags: Set<Tag>) {
    self.tags = tags
  }

  var body: some View {
    Group {
      ForEach(sortedTags) { tag in
        TagRowView(tag: tag)
          .accessibilityElement(children: .contain)
          .accessibilityIdentifier("tagList.tagRow-\(tag.name)")
      }
    }
  }
}

#Preview {
  Form {
    TagListView(
      tags: [try! Tag(name: "Test", colorRed: 1, colorBlue: 0, colorGreen: 0)]
    )
  }
}
