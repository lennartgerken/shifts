import CoreImage
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
  private func correctImage(_ image: CGImage) async throws -> CIImage {
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate

    let observations = try await request.perform(on: image)
    var totalAngle = 0.0
    var count = 0
    for observation in observations {
      if observation.boundingBox.width < 0.15 {
        continue
      }
      let topLeft = observation.topLeft
      let topRight = observation.topRight
      totalAngle += atan2(topRight.y - topLeft.y, topRight.x - topLeft.x)
      count += 1
    }
    let averageAngle = totalAngle / Double(count)
    let ciImage = CIImage(cgImage: image).transformed(
      by: CGAffineTransform(rotationAngle: -averageAngle))
    return ciImage
  }

  func recognize(from image: CGImage) async throws -> String {
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    let observations = try await request.perform(on: try await correctImage(image))

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
