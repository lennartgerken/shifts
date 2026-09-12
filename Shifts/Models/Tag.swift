import Foundation
import SwiftData
import SwiftUI

enum TagCreationError: Error {
  case emptyName
  case invalidColor
}

@Model
final class Tag {
  private(set) var name: String
  private(set) var colorRed: Double
  private(set) var colorBlue: Double
  private(set) var colorGreen: Double

  var color: Color {
    Color(red: colorRed, green: colorGreen, blue: colorBlue)
  }

  private(set) var shifts: [Shift] = []

  init(name: String, colorRed: Double, colorBlue: Double, colorGreen: Double) throws {
    try Self.checkValues(
      name: name, colorRed: colorRed, colorBlue: colorBlue, colorGreen: colorGreen)

    self.name = name
    self.colorRed = colorRed
    self.colorBlue = colorBlue
    self.colorGreen = colorGreen
  }

  func updateValues(name: String, colorRed: Double, colorBlue: Double, colorGreen: Double) throws {
    try Self.checkValues(
      name: name, colorRed: colorRed, colorBlue: colorBlue, colorGreen: colorGreen)

    self.name = name
    self.colorRed = colorRed
    self.colorBlue = colorBlue
    self.colorGreen = colorGreen
  }

  private static func checkValues(
    name: String, colorRed: Double, colorBlue: Double, colorGreen: Double
  ) throws {
    guard !name.isEmpty else {
      throw TagCreationError.emptyName
    }
    guard
      (0...1).contains(colorRed),
      (0...1).contains(colorBlue),
      (0...1).contains(colorGreen)
    else {
      throw TagCreationError.invalidColor
    }
  }
}
