import XCUIAutomation

struct CategoryEditListScreen {
  let app: XCUIApplication

  var doneButton: XCUIElement {
    app.buttons["categoryEditList.doneButton"]
  }

  var keepShiftsButton: XCUIElement {
    app.buttons["categoryEditList.keepShiftsButton"].firstMatch
  }

  var deleteShiftsButton: XCUIElement {
    app.buttons["categoryEditList.deleteShiftsButton"].firstMatch
  }

  func categoryRow(for category: String) -> XCUIElement {
    app.buttons["categoryEditList.categoryRow-\(category)"]
  }
}
