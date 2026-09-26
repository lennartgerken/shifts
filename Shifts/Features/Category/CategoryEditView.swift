import SwiftData
import SwiftUI

enum CategoryEditMode {
  case add
  case edit(category: Category)
}

struct CategoryEditView: View {
  @State private var name: String = ""
  @State private var color: Color = .red
  @State private var error: String?

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.self) private var environment

  private let mode: CategoryEditMode
  private let title: String

  init(mode: CategoryEditMode) {
    self.mode = mode
    switch mode {
    case .add:
      title = String(localized: .titleAddCategory)
    case .edit(let category):
      title = String(localized: .titleEditCategory)
      self._name = State(initialValue: category.name)
      self._color = State(initialValue: category.colorRGB.color)
    }
  }

  var body: some View {
    Form {
      Section {
        TextField(.labelName, text: $name)
          .accessibilityIdentifier("categoeyEdit.nameTextField")
        ColorPicker(.labelColor, selection: $color, supportsOpacity: false)
      } footer: {
        if let error {
          ErrorView(error: error)
        }
      }

    }
    .navigationTitle(title)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(.buttonCancel, systemImage: "xmark") {
          dismiss()
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonSave, systemImage: "checkmark") {
          if save() {
            dismiss()
          }
        }
        .accessibilityIdentifier("categoeyEdit.saveButton")
      }
    }
  }

  private func save() -> Bool {
    do {
      let resolvedColor = color.resolve(in: environment)
      if case .add = mode {
        try modelContext.insert(
          Category(
            name: name,
            colorRGB: try ColorRGB(
              red: Double(resolvedColor.red), green: Double(resolvedColor.green),
              blue: Double(resolvedColor.blue))))
      } else if case .edit(let category) = mode {
        try category.updateValues(
          name: name,
          colorRGB: try ColorRGB(
            red: Double(resolvedColor.red), green: Double(resolvedColor.green),
            blue: Double(resolvedColor.blue)))
      }

      return true
    } catch CategoryCreationError.emptyName {
      self.error = String(localized: .errorEmptyName)
    } catch ColorRGBError.invalidColor {
      self.error = String(localized: .errorInvalidColor)
    } catch {
      self.error = String(localized: .errorGeneral)
    }
    return false
  }
}

#Preview("Add") {
  NavigationStack {
    CategoryEditView(mode: .add)
  }
}

#Preview("Edit") {
  NavigationStack {
    CategoryEditView(
      mode: .edit(
        category: try! Category(
          name: "Some category", colorRGB: ColorRGB(red: 0, green: 1, blue: 1))))
  }
}
