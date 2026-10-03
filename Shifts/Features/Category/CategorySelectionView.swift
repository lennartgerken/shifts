import SwiftData
import SwiftUI

struct CategorySelectionView: View {
  @Binding var selectedCategories: Set<Category?>
  @Query(sort: \Category.name) private var categories: [Category]
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List(selection: $selectedCategories) {
      CategoryRowView(
        category: try! Category(
          name: String(localized: .pickerValueDefault),
          colorRGB: try! ColorRGB(red: 0, green: 0, blue: 0))
      ).tag(nil as Category?)
      ForEach(categories) { category in
        CategoryRowView(category: category)
          .tag(category)
          .accessibilityElement(children: .contain)
          .accessibilityIdentifier("tagSelection.tagRow-\(category.name)")
      }
    }
    .environment(\.editMode, .constant(.active))
    .navigationTitle(.titleSelectCategories)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonDone, systemImage: "checkmark") {
          dismiss()
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    CategorySelectionView(selectedCategories: .constant([]))
      .modelContainer(PreviewSupport.inMemoryContainer())
  }
}
