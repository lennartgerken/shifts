import SwiftData
import SwiftUI

enum CategoryEditMode {
  case add
  case edit(category: Category, notificationService: NotificationServicing)
}

struct CategoryEditView: View {
  private let mode: CategoryEditMode

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.self) private var environment
  @Environment(AppSettings.self) var settings

  @State private var name: String = ""
  @State private var color: Color = .red
  @State private var sendNotification = false
  @State private var error: String?

  private let title: String

  init(mode: CategoryEditMode) {
    self.mode = mode
    switch mode {
    case .add:
      title = String(localized: .titleAddCategory)
    case .edit(let category, _):
      title = String(localized: .titleEditCategory)
      self._name = State(initialValue: category.name)
      self._color = State(initialValue: category.colorRGB.color)
      self._sendNotification = State(initialValue: category.sendNotification)
    }
  }

  var body: some View {
    Form {
      Section {
        TextField(.labelName, text: $name)
          .accessibilityIdentifier("categoeyEdit.nameTextField")
        ColorPicker(.labelColor, selection: $color, supportsOpacity: false)
        if settings.sendNotifications {
          Toggle(isOn: $sendNotification) {
            Text(.labelSendNotifications)
          }
        }
      } footer: {
        if let error {
          ErrorView(error: error)
        }
      }

    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(.buttonCancel, systemImage: "xmark") {
          dismiss()
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonSave, systemImage: "checkmark") {
          Task {
            if await save() {
              dismiss()
            }
          }
        }
        .accessibilityIdentifier("categoeyEdit.saveButton")
      }
    }
  }

  private func save() async -> Bool {
    do {
      let resolvedColor = color.resolve(in: environment)
      if case .add = mode {
        try modelContext.insert(
          Category(
            name: name,
            colorRGB: try ColorRGB(
              red: Double(resolvedColor.red), green: Double(resolvedColor.green),
              blue: Double(resolvedColor.blue)), sendNotification: sendNotification))
      } else if case .edit(let category, let notificationService) = mode {
        try category.updateValues(
          name: name,
          colorRGB: try ColorRGB(
            red: Double(resolvedColor.red), green: Double(resolvedColor.green),
            blue: Double(resolvedColor.blue)), sendNotification: sendNotification)
        for shift in category.shifts {
          try await notificationService.update(
            for: shift, notificationTimings: settings.notificationTimings)
        }
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
          name: "Some category", colorRGB: ColorRGB(red: 0, green: 1, blue: 1)),
        notificationService: NotificationService())
    )
  }
}
