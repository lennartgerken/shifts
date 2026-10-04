import Foundation
import SwiftData

enum CategoryCreationError: Error {
  case emptyName
}

@Model
final class Category {
  private(set) var name: String
  private(set) var colorRGB: ColorRGB
  private(set) var shifts: [Shift] = []
  private(set) var sendNotification: Bool

  init(name: String, colorRGB: ColorRGB, sendNotification: Bool = false) throws {
    try Self.checkValues(name: name)

    self.name = name
    self.colorRGB = colorRGB
    self.sendNotification = sendNotification
  }

  func updateValues(name: String, colorRGB: ColorRGB, sendNotification: Bool) throws {
    try Self.checkValues(name: name)

    self.name = name
    self.colorRGB = colorRGB
    self.sendNotification = sendNotification
  }

  private static func checkValues(
    name: String
  ) throws {
    guard !name.isEmpty else {
      throw CategoryCreationError.emptyName
    }
  }
}
