import SwiftUI

struct TagRowView: View {
  private let tag: Tag

  init(tag: Tag) {
    self.tag = tag
  }

  var body: some View {
    HStack {
      Image(systemName: "tag")
        .foregroundStyle(tag.color)
      Text(tag.name)
    }
  }
}

#Preview {
  TagRowView(tag: try! Tag(name: "Tag 1", colorRed: 1, colorBlue: 0, colorGreen: 0))
}
