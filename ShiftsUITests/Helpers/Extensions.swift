import XCUIAutomation

extension XCUIElement {
  func tapToggle() {
    coordinate(
      withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)
    ).tap()
  }
}
