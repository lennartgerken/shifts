import XCTest

final class SettingsUITests: BaseUITests {
  var settingsScreen: SettingsScreen!

  override func setUpWithError() throws {
    try super.setUpWithError()
    let calendarScreen = CalendarScreen(app: app)
    settingsScreen = SettingsScreen(app: app)

    calendarScreen.openMenuButton.tap()
    calendarScreen.settingsButton.tap()
  }

  func testRemoveTag() throws {
    let tagEditListScreen = TagEditListScreen(app: app)
    let tagRow = tagEditListScreen.tagRow(for: "Tag 1")

    settingsScreen.editTagsButton.tap()

    tagRow.swipeLeft()
    app.buttons["Löschen"].tap()

    XCTAssert(!tagRow.exists)
    XCTAssert(tagEditListScreen.tagRow(for: "Tag 2").exists)
  }

  func testRemoveShiftReference() throws {
    let shiftReferenceEditListScreen = ShiftReferenceEditListScreen(app: app)

    let referenceRow = shiftReferenceEditListScreen.referenceRow(for: "Reference 1")

    settingsScreen.deleteShiftReferencesButton.tap()

    referenceRow.swipeLeft()
    app.buttons["Löschen"].tap()

    XCTAssert(!referenceRow.exists)
  }

  func testRemoveReminder() {
    let notificationTimingsListScreen = NotificationTimingsListScreen(app: app)
    let timingRow = notificationTimingsListScreen.getTimingRow(value: 1, timing: .hour)

    toggleNotifications()
    settingsScreen.editRemindersButton.tap()
    timingRow.swipeLeft()
    app.buttons["Löschen"].tap()

    XCTAssert(!timingRow.exists)
  }

  func testAddReminder() {
    let count = 15
    let type: NotificationTimingType = .minute

    let notificationTimingsListScreen = NotificationTimingsListScreen(app: app)
    let notificationTimingAddScreen = NotificationTimingAddScreen(app: app)

    toggleNotifications()
    settingsScreen.editRemindersButton.tap()
    notificationTimingsListScreen.addButton.tap()

    notificationTimingAddScreen.setCountPicker(to: count)
    notificationTimingAddScreen.setTypePicker(to: type)
    notificationTimingAddScreen.saveButton.tap()

    XCTAssert(notificationTimingsListScreen.getTimingRow(value: count, timing: type).exists)
  }

  func toggleNotifications() {
    addUIInterruptionMonitor(withDescription: "Notification Permission") { alert in
      let allowButton = alert.buttons["Erlauben"]

      if allowButton.exists {
        allowButton.tap()
        return true
      }

      return false
    }
    settingsScreen.notificationsToggle.tapToggle()
  }
}
