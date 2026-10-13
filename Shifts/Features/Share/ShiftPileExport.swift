import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let shiftPile = UTType(exportedAs: "de.lennartgerken.shiftpile")
}

struct ShiftPileExport: Codable, Sendable, Transferable {
  static var transferRepresentation: some TransferRepresentation {
    CodableRepresentation(
      contentType: .shiftPile
    )
    .suggestedFileName("shifts.shiftpile")
  }
  static let currentVersion = 1

  let version: Int
  let shifts: [ShiftExport]

  init(shifts: [ShiftExport]) {
    self.version = Self.currentVersion
    self.shifts = shifts
  }
}

struct ShiftExport: Codable, Sendable {
  let start: Date
  let end: Date
}
