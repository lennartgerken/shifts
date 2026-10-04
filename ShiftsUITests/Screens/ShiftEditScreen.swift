import XCUIAutomation

struct ShiftEditScreen {
  let app: XCUIApplication

  var dayDatePicker: XCUIElement {
    app.datePickers["shiftEdit.dayDatePicker"]
  }

  var startDatePicker: XCUIElement {
    app.datePickers["shiftEdit.startDatePicker"]
  }

  var endDatePicker: XCUIElement {
    app.datePickers["shiftEdit.endDatePicker"]
  }

  var categoryPicker: XCUIElement {
    app.buttons["categorySelection.categoryPicker"]
  }

  var addCategoryButton: XCUIElement {
    app.buttons["categorySelection.addCategoryButton"]
  }

  var notesTextField: XCUIElement {
    app.textFields["shiftEdit.notesTextField"]
  }

  var selectTagsButton: XCUIElement {
    app.buttons["tags.selectTagsButton"]
  }

  var saveButton: XCUIElement {
    app.buttons["shiftEdit.saveButton"]
  }
}
