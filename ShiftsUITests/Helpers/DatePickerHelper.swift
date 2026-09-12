import XCUIAutomation

func setTimePicker(_ picker: XCUIElement, app: XCUIApplication, hour: String, minute: String) {
  picker.tap()
  app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: hour)
  app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: minute)
  picker.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
}

func setDatePicker(_ picker: XCUIElement, app: XCUIApplication, day: Int) {
  picker.tap()
  app.staticTexts[String(day)].tap()
  picker.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
}
