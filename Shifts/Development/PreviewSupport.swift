import Foundation
import SwiftData
import SwiftUI

#if DEBUG
  enum PreviewSupport {
    static func inMemoryContainer() -> ModelContainer {
      let config = ModelConfiguration(isStoredInMemoryOnly: true)
      let modelContainer = try! ModelContainer(
        for: Shift.self, Tag.self, ShiftReference.self, Category.self,
        configurations: config
      )
      try! TestingSupport.reset(modelContainer: modelContainer)
      return modelContainer
    }
  }
#endif
