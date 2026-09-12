import XCUIAutomation

struct TagSelectionScreen {
  let app: XCUIApplication

  var addTagButton: XCUIElement {
    app.buttons["tagSelection.addTagButton"]
  }

  var doneButton: XCUIElement {
    app.buttons["tagSelection.doneButton"]
  }

  func tagRow(for tag: String) -> XCUIElement {
    app.otherElements["tagSelection.tagRow-\(tag)"]
  }
}
