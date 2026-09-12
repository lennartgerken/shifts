import XCUIAutomation

struct TagEditListScreen {
  let app: XCUIApplication

  func tagRow(for tag: String) -> XCUIElement {
    app.buttons["tagEditList.tagRow-\(tag)"]
  }
}
