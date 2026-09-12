import SwiftData
import SwiftUI

enum TagEditMode {
  case add
  case edit(tag: Tag)
}

struct TagEditView: View {
  @State private var name: String = ""
  @State private var color: Color = .red
  @State private var error: String?

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.self) private var environment

  private let mode: TagEditMode
  private let title: String

  init(mode: TagEditMode) {
    self.mode = mode
    switch mode {
    case .add:
      title = String(localized: .titleAddTag)
    case .edit(let tag):
      title = String(localized: .titleEditTag)
      self._name = State(initialValue: tag.name)
      self._color = State(initialValue: tag.color)
    }
  }

  var body: some View {
    Form {
      Section {
        TextField(.labelName, text: $name)
          .accessibilityIdentifier("tagEdit.nameTextField")
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
        .accessibilityIdentifier("tagEdit.saveButton")
      }
    }
  }

  private func save() -> Bool {
    do {
      let resolvedColor = color.resolve(in: environment)
      if case .add = mode {
        try modelContext.insert(
          Tag(
            name: name, colorRed: Double(resolvedColor.red), colorBlue: Double(resolvedColor.blue),
            colorGreen: Double(resolvedColor.green)))
      } else if case .edit(let tag) = mode {
        try tag.updateValues(
          name: name, colorRed: Double(resolvedColor.red), colorBlue: Double(resolvedColor.blue),
          colorGreen: Double(resolvedColor.green))
      }

      return true
    } catch let error as TagCreationError {
      switch error {
      case .emptyName:
        self.error = String(localized: .errorEmptyName)
      case .invalidColor:
        self.error = String(localized: .errorInvalidColor)
      }
    } catch {
      self.error = String(localized: .errorGeneral)
    }
    return false
  }
}

#Preview("Add") {
  NavigationStack {
    TagEditView(mode: .add)
  }
}

#Preview("Edit") {
  NavigationStack {
    TagEditView(
      mode: .edit(tag: try! Tag(name: "Some tag", colorRed: 0, colorBlue: 1, colorGreen: 1)))
  }
}
