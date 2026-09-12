import XCUIAutomation

struct TagEditScreen {
  let app: XCUIApplication

  var nameTextField: XCUIElement {
    app.textFields["tagEdit.nameTextField"]
  }

  var saveButton: XCUIElement {
    app.buttons["tagEdit.saveButton"]
  }
}
