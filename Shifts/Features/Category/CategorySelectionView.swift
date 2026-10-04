import SwiftData
import SwiftUI

struct CategorySelectionView: View {
  @Binding var category: Category?
  @Query(sort: \Category.name) private var categories: [Category]
  @State private var showAddCategory = false

  var body: some View {
    Section {
      Picker(.labelCategory, selection: $category) {
        Text(.pickerValueDefault).tag(nil as Category?)
        ForEach(categories) { category in
          Text(category.name).tag(category)
        }
      }
      .accessibilityIdentifier("categorySelection.categoryPicker")
      Button(.buttonAddCategory) {
        showAddCategory = true
      }
      .sheet(isPresented: $showAddCategory) {
        NavigationStack {
          CategoryEditView(mode: .add)
        }
        .presentationDetents([.medium])
      }
      .accessibilityIdentifier("categorySelection.addCategoryButton")
    }
  }
}

#if DEBUG
  #Preview {
    Form {
      CategorySelectionView(category: .constant(nil))
        .modelContainer(PreviewSupport.inMemoryContainer())
        .environment(AppSettings())
    }
  }
#endif
