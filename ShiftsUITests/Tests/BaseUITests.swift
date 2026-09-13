import XCTest

class BaseUITests: XCTestCase {
  let calendar = Calendar.current
  var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments += [
      "--uitesting"
    ]
    app.launch()
  }
}
