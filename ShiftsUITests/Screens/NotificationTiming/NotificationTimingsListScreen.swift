import XCUIAutomation

struct NotificationTimingsListScreen {
  let app: XCUIApplication

  var addButton: XCUIElement {
    app.buttons["notificationTimingsList.addButton"]
  }

  func getTimingRow(value: Int, timing: NotificationTimingType) -> XCUIElement {
    app.staticTexts["notificationTimingsList.timingRow-\(value)-\(timing)"]
  }
}
