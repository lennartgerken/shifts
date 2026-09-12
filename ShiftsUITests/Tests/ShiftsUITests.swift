import XCTest

final class ShiftsUITests: BaseUITests {
  var calendarScreen: CalendarScreen!
  var shiftEditScreen: ShiftEditScreen!
  var shiftDetailsScreen: ShiftDetailsScreen!

  override func setUpWithError() throws {
    try super.setUpWithError()
    calendarScreen = CalendarScreen(app: app)
    shiftEditScreen = ShiftEditScreen(app: app)
    shiftDetailsScreen = ShiftDetailsScreen(app: app)
  }

  func testCreateShift() throws {
    let day = 4
    let date = getDayOfMonth(day: day)
    let tagName = "Tag 1"
    let startHour = "10"
    let startMinute = "30"
    let endHour = "15"
    let endMinute = "00"
    let notes = "Some notes"

    let tagsScreen = TagSelectionScreen(app: app)
    let dayRow = calendarScreen.dayRow(for: date)

    calendarScreen.openMenuButton.tap()
    calendarScreen.addShiftButton.tap()

    setDatePicker(shiftEditScreen.dayDatePicker, app: app, day: day)
    setTimePicker(
      shiftEditScreen.startDatePicker,
      app: app,
      hour: startHour,
      minute: startMinute
    )
    setTimePicker(
      shiftEditScreen.endDatePicker,
      app: app,
      hour: endHour,
      minute: endMinute
    )
    shiftEditScreen.notesTextField.tap()
    shiftEditScreen.notesTextField.typeText(notes)

    shiftEditScreen.selectTagsButton.tap()
    tagsScreen.tagRow(for: tagName).tap()
    tagsScreen.doneButton.tap()
    shiftEditScreen.saveButton.tap()

    calendarScreen.selectDate(date)
    dayRow.element.tap()
    XCTAssertEqual(
      shiftDetailsScreen.startTextField.label,
      "Beginn, \(startHour):\(startMinute)"
    )
    XCTAssertEqual(
      shiftDetailsScreen.endTextField.label,
      "Ende, \(endHour):\(endMinute)"
    )
    XCTAssertEqual(shiftDetailsScreen.notesTextField.label, notes)
    XCTAssert(shiftDetailsScreen.tagRow(for: tagName).exists)
  }

  func testEditShift() throws {
    let date = getDayOfMonth(day: 1)
    let dayRow = calendarScreen.dayRow(for: date)

    calendarScreen.selectDate(date)
    dayRow.element.tap()

    shiftDetailsScreen.editButton.tap()
    setTimePicker(
      shiftEditScreen.startDatePicker,
      app: app,
      hour: "10",
      minute: "30"
    )
    shiftEditScreen.saveButton.tap()
    XCTAssertEqual(shiftDetailsScreen.startTextField.label, "Beginn, 10:30")
  }

  func testDeleteShift() throws {
    let date = getDayOfMonth(day: 1)
    let dayRow = calendarScreen.dayRow(for: date)
    let dayRowStartText = dayRow.element.staticTexts["09:00"]

    calendarScreen.selectDate(date)
    XCTAssert(dayRow.element.exists)
    XCTAssert(dayRowStartText.exists)
    dayRow.element.tap()
    shiftDetailsScreen.deleteButton.tap()
    XCTAssert(dayRow.element.exists)
    XCTAssertFalse(dayRowStartText.exists)
  }
}
