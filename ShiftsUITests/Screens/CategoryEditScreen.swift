import XCUIAutomation

struct CategoryEditScreen {
  let app: XCUIApplication

  var nameTextField: XCUIElement {
    app.textFields["categoryEdit.nameTextField"]
  }

  var saveButton: XCUIElement {
    app.buttons["categoryEdit.saveButton"]
  }
}
