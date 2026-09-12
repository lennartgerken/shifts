import XCTest
import XCUIAutomation

struct SettingsScreen {
  let app: XCUIApplication

  var editTagsButton: XCUIElement {
    app.buttons["settings.editTagsButton"]
  }

  var deleteShiftReferencesButton: XCUIElement {
    app.buttons["settings.deleteShiftReferencesButton"]
  }

  var notificationsToggle: XCUIElement {
    app.switches["settings.notificationsToggle"]
  }

  var editRemindersButton: XCUIElement {
    app.buttons["settings.editRemindersButton"]
  }
}
