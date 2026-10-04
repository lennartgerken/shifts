import SwiftUI

struct TagRowView: View {
  private let tag: Tag

  init(tag: Tag) {
    self.tag = tag
  }

  var body: some View {
    HStack {
      Image(systemName: "tag")
        .foregroundStyle(tag.colorRGB.color)
      Text(tag.name)
    }
  }
}

#Preview {
  TagRowView(tag: try! Tag(name: "Tag 1", colorRGB: ColorRGB(red: 1, green: 0, blue: 0)))
}
