import XCUIAutomation

struct ShiftReferenceEditListScreen {
  let app: XCUIApplication

  func referenceRow(for reference: String) -> XCUIElement {
    app.staticTexts["shiftReferenceEditList.referenceRow-\(reference)"]
  }
}
