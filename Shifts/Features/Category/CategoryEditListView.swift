import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: "CategoryEditListView"
)

struct CategoryEditListView: View {
  let notificationService: NotificationServicing

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(AppSettings.self) private var settings
  @Query private var categories: [Category]

  @State private var deleteCategory: Category?
  @State private var showAddCategory = false
  @State private var editCategory: Category?

  var body: some View {
    Group {
      if !categories.isEmpty {
        List {
          ForEach(categories) { category in
            Button {
              editCategory = category
            } label: {
              CategoryRowView(category: category)
            }
            .buttonStyle(.plain)
          }
          .onDelete { indexSet in
            if indexSet.count == 1, let index = indexSet.first {
              deleteCategory = categories[index]
            }
          }
        }
      } else {
        ContentUnavailableView(
          .titleNoCategories, systemImage: "flag", description: Text(.descriptionNoCategories))
      }
    }
    .navigationTitle(.titleEditCategories)
    .alert(.titleDeleteCategory, item: $deleteCategory) { category in
      Button(.buttonKeepShifts) {
        let shifts = category.shifts
        modelContext.delete(category)
        for shift in shifts {
          Task {
            do {
              try await notificationService.update(
                for: shift, notificationTimings: settings.notificationTimings)
            } catch {
              logger.error("Could not update notifications: \(error)")
            }
          }
        }
      }
      Button(.buttonDeleteShifts, role: .destructive) {
        for shift in category.shifts {
          modelContext.delete(shift)
          notificationService.remove(for: shift)
        }
        modelContext.delete(category)
      }
    } message: { category in
      Text(.descriptionDeleteCategory(name: category.name))
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(.buttonAddCategory, systemImage: "plus") {
          showAddCategory = true
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonDone, systemImage: "checkmark") {
          dismiss()
        }
      }
    }
    .sheet(isPresented: $showAddCategory) {
      NavigationStack {
        CategoryEditView(mode: .add)
      }
      .presentationDetents([.medium])
    }
    .sheet(item: $editCategory) { category in
      NavigationStack {
        CategoryEditView(
          mode: .edit(category: category, notificationService: NotificationService()))
      }
      .presentationDetents([.medium])
    }
  }
}

#Preview {
  NavigationStack {
    CategoryEditListView(notificationService: NotificationService())
  }
  .modelContainer(PreviewSupport.inMemoryContainer())
}

#Preview {
  NavigationStack {
    CategoryEditListView(notificationService: NotificationService())
  }
}
