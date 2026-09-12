import XCTest
import XCUIAutomation

func scrollToElement(_ element: XCUIElement, app: XCUIApplication, maxSwipes: Int = 5) {
  for _ in 0..<maxSwipes {
    if element.exists && element.isHittable {
      return
    }

    app.swipeDown()
  }

  XCTFail("Could not find element \(element)")
}
