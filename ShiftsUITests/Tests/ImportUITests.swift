import XCTest

final class ImportUITests: BaseUITests {
  func testImportShifts() throws {
    let date = Calendar.current.date(
      from: DateComponents(year: 2026, month: 1, day: 2)
    )!

    let calendarScreen = CalendarScreen(app: app)
    let importScreen = ImportScreen(app: app)

    let importDayRow = importScreen.dayRow(for: date)
    let calendarDayRow = calendarScreen.dayRow(for: date)

    calendarScreen.openMenuButton.tap()
    calendarScreen.importShiftsButton.tap()

    importScreen.selectImageButton.tap()

    XCTAssert(importDayRow.element.waitForExistence(timeout: 5))
    XCTAssert(importDayRow.element.staticTexts["08:00"].exists)
    XCTAssert(importDayRow.element.staticTexts["16:00"].exists)
    importScreen.saveButton.tap()

    calendarScreen.selectDate(date)
    XCTAssert(calendarDayRow.element.staticTexts["08:00"].exists)
    XCTAssert(calendarDayRow.element.staticTexts["16:00"].exists)
  }
}
