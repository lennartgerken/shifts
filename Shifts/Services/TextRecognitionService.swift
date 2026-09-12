import Foundation
import Vision

struct RecognizedTextBlock {
  let text: String
  let boundingBox: CGRect
}

protocol TextRecognitionServicing {
  func recognize(from image: CGImage) async throws -> String
}

struct TextRecognitionService: TextRecognitionServicing {
  func recognize(from image: CGImage) async throws -> String {
    let request = RecognizeTextRequest()
    let observations = try await request.perform(on: image)

    let textBlocks: [RecognizedTextBlock] = observations.compactMap {
      observation -> RecognizedTextBlock? in
      guard let candidate = observation.topCandidates(1).first else { return nil }
      return RecognizedTextBlock(
        text: candidate.string, boundingBox: observation.boundingBox.cgRect)
    }

    if textBlocks.isEmpty {
      return ""
    }

    let sortedTextBlocks = textBlocks.sorted { block1, block2 in
      block1.boundingBox.midY < block2.boundingBox.midY
    }

    let heights =
      textBlocks
      .map(\.boundingBox.height)
      .sorted()
    let medianHeight = heights[heights.count / 2]
    let tolerance = medianHeight * 0.9

    guard var currentY = sortedTextBlocks.first?.boundingBox.midY else { return "" }
    var allGroups = [[RecognizedTextBlock]]()
    var currentGroup: [RecognizedTextBlock] = []
    for block in sortedTextBlocks {
      if abs(block.boundingBox.midY - currentY) > tolerance {
        currentGroup.sort { block1, block2 in
          block1.boundingBox.midX < block2.boundingBox.midX
        }
        allGroups.append(currentGroup)
        currentY = block.boundingBox.midY
        currentGroup = []
      }
      currentGroup.append(block)
    }

    if !currentGroup.isEmpty { allGroups.append(currentGroup) }
    allGroups.reverse()

    return allGroups.map { currentGroup in
      currentGroup.map(\.text).joined(separator: " ")
    }.joined(separator: "\n")
  }
}
