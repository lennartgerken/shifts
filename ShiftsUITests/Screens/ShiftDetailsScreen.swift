import XCUIAutomation

struct ShiftDetailsScreen {
  let app: XCUIApplication

  var startTextField: XCUIElement {
    app.staticTexts["shiftDetails.startTextField"]
  }

  var endTextField: XCUIElement {
    app.staticTexts["shiftDetails.endTextField"]
  }

  var notesTextField: XCUIElement {
    app.staticTexts["shiftDetails.notesTextField"]
  }

  func tagRow(for tag: String) -> XCUIElement {
    app.otherElements["tagList.tagRow-\(tag)"]
  }

  var deleteButton: XCUIElement {
    app.buttons["shiftDetails.deleteButton"]
  }

  var editButton: XCUIElement {
    app.buttons["shiftDetails.editButton"]
  }
}
