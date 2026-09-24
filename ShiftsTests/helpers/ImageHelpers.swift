import Foundation
import ImageIO
import Testing

func getCGImage(fromResource: String, withExtension: String) throws -> CGImage {
  let url = Bundle.main.url(forResource: fromResource, withExtension: withExtension)!
  let data = try Data(Data(contentsOf: url))
  let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
  let cgImage = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
  return cgImage
}
