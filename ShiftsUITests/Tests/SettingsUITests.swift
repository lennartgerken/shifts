import XCTest

final class SettingsUITests: BaseUITests {
  var calendarScreen: CalendarScreen!
  var settingsScreen: SettingsScreen!

  override func setUpWithError() throws {
    try super.setUpWithError()
    calendarScreen = CalendarScreen(app: app)
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

  func testRemoveCategoryKeepShifts() throws {
    let shiftDate = getDayOfMonth(day: 1)

    let categoryEditListScreen = CategoryEditListScreen(app: app)
    let categoryRow = categoryEditListScreen.categoryRow(for: "Category 1")
    let shiftDetailsScreen = ShiftDetailsScreen(app: app)

    settingsScreen.editCategoriesButton.tap()

    categoryRow.swipeLeft()
    app.buttons["Löschen"].tap()
    categoryEditListScreen.keepShiftsButton.tap()
    XCTAssert(!categoryRow.exists)

    categoryEditListScreen.doneButton.tap()
    settingsScreen.doneButton.tap()

    calendarScreen.selectDate(shiftDate)
    calendarScreen.dayRow(for: shiftDate).element.tap()

    XCTAssert(shiftDetailsScreen.categoryTextField.label == "Kategorie, Standard")
  }

  func testRemoveCategoryDeleteShifts() throws {
    let shiftDate = getDayOfMonth(day: 1)

    let categoryEditListScreen = CategoryEditListScreen(app: app)
    let categoryRow = categoryEditListScreen.categoryRow(for: "Category 1")
    let shiftDetailsScreen = ShiftDetailsScreen(app: app)

    settingsScreen.editCategoriesButton.tap()

    categoryRow.swipeLeft()
    app.buttons["Löschen"].tap()
    categoryEditListScreen.deleteShiftsButton.tap()
    XCTAssert(!categoryRow.exists)

    categoryEditListScreen.doneButton.tap()
    settingsScreen.doneButton.tap()

    calendarScreen.selectDate(shiftDate)

    calendarScreen.dayRow(for: shiftDate).element.tap()
    XCTAssertFalse(shiftDetailsScreen.startTextField.exists)
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

    settingsScreen.editRemindersButton.tap()
    notificationTimingsListScreen.addButton.tap()

    notificationTimingAddScreen.setCountPicker(to: count)
    notificationTimingAddScreen.setTypePicker(to: type)
    notificationTimingAddScreen.saveButton.tap()

    XCTAssert(notificationTimingsListScreen.getTimingRow(value: count, timing: type).exists)
  }
}
