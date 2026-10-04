import XCTest
import XCUIAutomation

struct SettingsScreen {
  let app: XCUIApplication

  var doneButton: XCUIElement {
    app.buttons["settings.doneButton"]
  }

  var editTagsButton: XCUIElement {
    app.buttons["settings.editTagsButton"]
  }

  var editCategoriesButton: XCUIElement {
    app.buttons["settings.editCategoriesButton"]
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
