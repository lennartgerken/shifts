import SwiftUI

struct CategoryRowView: View {
  let category: Category

  var body: some View {
    HStack {
      Image(systemName: "circle.fill")
        .foregroundStyle(category.colorRGB.color)
        .font(.system(size: 10))
      Text(category.name)
    }
  }
}

#Preview {
  CategoryRowView(
    category: try! Category(
      name: "Some category", colorRGB: try ColorRGB(red: 0, green: 1, blue: 0)))
}
