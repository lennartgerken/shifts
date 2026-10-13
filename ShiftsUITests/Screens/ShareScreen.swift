import XCUIAutomation

struct ShareScreen {
  let app: XCUIApplication

  var shareButton: XCUIElement {
    app.buttons["share.shareButton"]
  }

  var base64Text: XCUIElement {
    app.staticTexts["share.base64Text"]
  }
}
