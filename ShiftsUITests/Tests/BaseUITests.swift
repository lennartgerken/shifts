import XCTest

class BaseUITests: XCTestCase {
  let calendar = Calendar.current
  var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments += [
      "-AppleLanguages", "(de)",
      "-AppleLocale", "de_DE",
      "--uitesting",
    ]
    app.launch()
  }
}
