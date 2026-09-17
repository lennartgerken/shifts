import XCTest

final class CalendarUITests: BaseUITests {
  var calendarScreen: CalendarScreen!

  override func setUpWithError() throws {
    try super.setUpWithError()
    calendarScreen = CalendarScreen(app: app)

  }

  func testShowCalendarRow() throws {
    let date = getDayOfMonth(day: 1)
    let dayRow = calendarScreen.dayRow(for: date)

    calendarScreen.selectDate(date)

    XCTAssertEqual(dayRow.dayImage.label, "Zahl Eins Auf Einer Kalenderseite")
    XCTAssertEqual(
      dayRow.weekdayText.label,
      date.formatted(.dateTime.weekday(.wide))
    )
    XCTAssert(dayRow.tagImage(for: "Tag 1").exists)
    XCTAssert(dayRow.notesImage.exists)
    XCTAssert(dayRow.element.staticTexts["09:00"].exists)
    XCTAssert(dayRow.element.staticTexts["15:00"].exists)

    for index in (0..<24) {
      let image = dayRow.activeHoursImage(for: index)
      if (9...14).contains(index) {
        XCTAssert(image.identifier == "activeHours.image-active")
      } else {
        XCTAssert(image.identifier == "activeHours.image-inactive")
      }
    }
  }

  func testShowCalendarRowMultipleShifts() throws {
    let date = getDayOfMonth(day: 2)
    let dayRow = calendarScreen.dayRow(for: date)

    calendarScreen.selectDate(date)

    XCTAssert(dayRow.tagImage(for: "Tag 1").exists)
    XCTAssert(dayRow.tagImage(for: "Tag 2").exists)
    XCTAssert(dayRow.notesImage.exists)
    XCTAssert(dayRow.element.staticTexts["08:00"].exists)
    XCTAssert(dayRow.element.staticTexts["09:00"].exists)
    XCTAssert(dayRow.element.staticTexts["21:00"].exists)
    XCTAssert(dayRow.element.staticTexts["23:59"].exists)

    for index in (0..<24) {
      let image = dayRow.activeHoursImage(for: index)
      if index == 8 || (21...23).contains(index) {
        XCTAssertEqual(image.identifier, "activeHours.image-active")
      } else {
        XCTAssertEqual(image.identifier, "activeHours.image-inactive")
      }
    }
  }

  func testUseShiftReference() throws {
    let date = getDayOfMonth(day: 4)
    let dayRow = calendarScreen.dayRow(for: date)

    calendarScreen.selectDate(date)
    dayRow.element.press(forDuration: 1)
    calendarScreen.referenceButton(for: "Reference 1").tap()

    XCTAssert(dayRow.element.staticTexts["09:00"].exists)
    XCTAssert(dayRow.element.staticTexts["15:00"].exists)
  }
}
