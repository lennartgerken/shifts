import Foundation
import ImageIO
import Testing

@testable import Shifts

struct TextRecognitionTests {
  @Test func recognizeText() async throws {
    let expectedDocument =
      """
      Von: 01.01.2026 Bis: 31.01.2026
      01 Do
      02 Fr Schicht 08:00 16:00
      03 Sa Schicht 12:00 20:15
      04 So
      05 Mo Schicht 08:00 16:00
      06 Di Urlaub
      07 Mi Urlaub
      08 Do Urlaub
      09 Fr Schicht 12:00 20:15
      """

    let textRecognitionService = await TextRecognitionService()

    let url = Bundle.main.url(forResource: "schedule", withExtension: "png")!
    let data = try Data(Data(contentsOf: url))
    let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
    let cgImage = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))

    let document = try await textRecognitionService.recognize(from: cgImage)
    #expect(document == expectedDocument)
  }
}
