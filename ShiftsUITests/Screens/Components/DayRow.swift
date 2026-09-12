import XCUIAutomation

struct DayRow {
  let element: XCUIElement

  var dayImage: XCUIElement {
    element.images["dayRow.dayImage"]
  }

  var weekdayText: XCUIElement {
    element.staticTexts["dayRow.weekdayText"]
  }

  var notesImage: XCUIElement {
    element.images["shiftInfo.notesImage"]
  }

  func tagImage(for tagName: String) -> XCUIElement {
    element.images["shiftInfo.tagImage-\(tagName)"]
  }

  func activeHoursImage(for index: Int) -> XCUIElement {
    element.images.matching(NSPredicate(format: "identifier BEGINSWITH %@", "activeHours.image-"))
      .element(boundBy: index)
  }
}
