import XCTest

final class ShareImportUITests: BaseUITests {
  var importScreen: ImportScreen!

  override func setUpWithError() throws {
    try super.setUpWithError()
    app.open(URL(string: "shiftpile://import-test")!)
    importScreen = ImportScreen(app: app)
  }

  func testShareShifts() throws {
    let shiftStart = Date(timeIntervalSinceReferenceDate: 789_030_000)
    let shiftEnd = Date(timeIntervalSinceReferenceDate: 789_058_800)

    let importDayRow = importScreen.dayRow(for: shiftStart)
    XCTAssert(importDayRow.element.waitForExistence(timeout: 5))
    XCTAssert(
      importDayRow.element.staticTexts[shiftStart.formatted(.dateTime.hour().minute())].exists)
    XCTAssert(
      importDayRow.element.staticTexts[shiftEnd.formatted(.dateTime.hour().minute())].exists)
  }
}
