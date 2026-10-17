import XCTest

struct ShiftPileExport: Decodable {
  let version: Int
  let shifts: [ShiftExport]
}

struct ShiftExport: Codable, Sendable {
  let start: Date
  let end: Date
}

final class ShareUITests: BaseUITests {
  var shareScreen: ShareScreen!

  override func setUpWithError() throws {
    try super.setUpWithError()
    shareScreen = ShareScreen(app: app)
    let calendarScreen = CalendarScreen(app: app)

    calendarScreen.openMenuButton.tap()
    calendarScreen.shareButton.tap()
  }

  func testShareShifts() throws {
    let date = getDayOfMonth(day: 2)
    let shiftStart = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: date)!
    let shiftEnd = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: date)!

    shareScreen.shareButton.tap()
    let base64 = shareScreen.base64Text.value as! String
    let data = try XCTUnwrap(Data(base64Encoded: base64))
    let export = try JSONDecoder().decode(ShiftPileExport.self, from: data)
    XCTAssert(export.shifts.count == 2)
    XCTAssert(
      export.shifts.contains(where: { shift in
        shift.start == shiftStart && shift.end == shiftEnd
      }))
  }
}
