import XCUIAutomation

struct NotificationTimingAddScreen {
  let app: XCUIApplication

  var countPicker: XCUIElement {
    app.pickers["notificationTimingAdd.countPicker"]
  }

  var typePicker: XCUIElement {
    app.pickers["notificationTimingAdd.typePicker"]
  }

  var saveButton: XCUIElement {
    app.buttons["notificationTimingAdd.saveButton"]
  }

  func setCountPicker(to count: Int) {
    countPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: String(count))
  }

  func setTypePicker(to type: NotificationTimingType) {
    var typeText = "Minute(n)"
    switch type {
    case .minute:
      break
    case .hour:
      typeText = "Stunde(n)"
    case .day:
      typeText = "Tag(e)"
    }
    typePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: typeText)
  }
}
