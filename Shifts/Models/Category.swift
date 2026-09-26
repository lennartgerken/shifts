import Foundation
import SwiftData

enum CategoryCreationError: Error {
  case emptyName
}

@Model
final class Category {
  private(set) var name: String
  private(set) var colorRGB: ColorRGB
  private(set) var shifts: [Shift]

  init(name: String, colorRGB: ColorRGB, shifts: [Shift] = []) throws {
    try Self.checkValues(name: name)

    self.name = name
    self.shifts = shifts
    self.colorRGB = colorRGB
  }

  func updateValues(name: String, colorRGB: ColorRGB) throws {
    try Self.checkValues(name: name)

    self.name = name
    self.colorRGB = colorRGB
  }

  private static func checkValues(
    name: String
  ) throws {
    guard !name.isEmpty else {
      throw CategoryCreationError.emptyName
    }
  }
}
