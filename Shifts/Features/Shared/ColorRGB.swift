import Foundation
import SwiftUI

enum ColorRGBError: Error {
  case invalidColor
}

nonisolated struct ColorRGB: Codable {
  let red: Double
  let green: Double
  let blue: Double

  init(red: Double, green: Double, blue: Double) throws {
    guard
      (0...1).contains(red),
      (0...1).contains(green),
      (0...1).contains(blue)
    else {
      throw ColorRGBError.invalidColor
    }

    self.red = red
    self.blue = blue
    self.green = green
  }

  var color: Color {
    Color(red: red, green: green, blue: blue)
  }
}
