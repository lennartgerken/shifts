import XCUIAutomation

struct CalendarScreen {
  let app: XCUIApplication

  var openMenuButton: XCUIElement {
    app.buttons["calendar.openMenuButton"]
  }

  var addShiftButton: XCUIElement {
    app.buttons["calendar.addShiftButton"]
  }

  var importShiftsButton: XCUIElement {
    app.buttons["calendar.importShiftsButton"]
  }

  var settingsButton: XCUIElement {
    app.buttons["calendar.settingsButton"]
  }

  func dayRow(for date: Date) -> DayRow {
    let startOfDay = Calendar.current.startOfDay(for: date)
    return DayRow(
      element: app.buttons[
        "calendarList.dayRow-\(startOfDay.formatted(.iso8601.year().month().day()))"])
  }

  func referenceButton(for name: String) -> XCUIElement {
    app.buttons["calendarList.referenceButton-\(name)"]
  }

  func selectDate(_ date: Date) {
    let day = "\(date.formatted(.dateTime.day()))."
    let month = date.formatted(.dateTime.month(.wide))
    let year = date.formatted(.dateTime.year())

    app.buttons["calendar.selectDateButton"].tap()
    app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: day)
    app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: month)
    app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: year)
    app.buttons["calendar.selectDateDoneButton"].tap()
  }
}
