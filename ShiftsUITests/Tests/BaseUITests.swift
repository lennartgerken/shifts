import XCTest

class BaseUITests: XCTestCase {
  let calendar = Calendar.current
  var additionalLaunchArguments: [String] = []
  var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments += [
      "--uitesting"
    ]
    app.launchArguments += additionalLaunchArguments
    app.launch()
  }
}
