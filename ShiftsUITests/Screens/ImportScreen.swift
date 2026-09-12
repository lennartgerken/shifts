import XCUIAutomation

struct ImportScreen {
  let app: XCUIApplication

  var selectImageButton: XCUIElement {
    app.buttons["shiftsImport.selectImageButton"]
  }

  var saveButton: XCUIElement {
    app.buttons["shiftsImport.saveButton"]
  }

  func dayRow(for date: Date) -> DayRow {
    let startOfDay = Calendar.current.startOfDay(for: date)
    return DayRow(
      element: app.staticTexts[
        "shiftsImport.dayRow-\(startOfDay.formatted(.iso8601.year().month().day()))"])
  }
}
