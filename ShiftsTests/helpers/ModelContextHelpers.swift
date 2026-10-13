import Foundation
import SwiftData

@testable import Shifts

@MainActor func getModelContainerWith(categories: [Shifts.Category] = [], shifts: [Shift] = [])
  throws -> ModelContainer
{
  let container = try ModelContainer(
    for: Shift.self, Tag.self, ShiftReference.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
  )

  let modelContext = container.mainContext

  for category in categories {
    modelContext.insert(category)
  }

  for shift in shifts {
    modelContext.insert(shift)
  }

  try modelContext.save()
  return container
}
