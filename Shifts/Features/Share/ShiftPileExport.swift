import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let shiftPile = UTType(exportedAs: "de.lennartgerken.shiftpile")
}

struct ShiftPileExport: Codable, Sendable, Transferable {
  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(exportedContentType: .shiftPile) { export in
      let url = FileManager.default.temporaryDirectory
        .appending(path: "\(UUID().uuidString).shiftpile")

      let data = try JSONEncoder().encode(export)
      try data.write(to: url, options: .atomic)

      return SentTransferredFile(url)
    }
  }
  static let currentVersion = 1

  let version: Int
  let shifts: [ParsedShift]

  init(shifts: [ParsedShift]) {
    self.version = Self.currentVersion
    self.shifts = shifts
  }
}
