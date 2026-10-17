import XCTest

final class ShareImportUITests: BaseUITests {
  var importScreen: ImportScreen!

  override func setUpWithError() throws {
    try super.setUpWithError()
    app.open(URL(string: "shiftpile://import-test")!)
    importScreen = ImportScreen(app: app)
  }

  func testShareShifts() throws {
    let importDayRow = importScreen.dayRow(
      for: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 2))!)
    XCTAssert(importDayRow.element.waitForExistence(timeout: 5))
    print(app.debugDescription)
    XCTAssert(importDayRow.element.staticTexts["08:00"].exists)
    XCTAssert(importDayRow.element.staticTexts["16:00"].exists)
  }
}
