import SwiftData
import SwiftUI

struct ShiftReferenceEditListView: View {
  @Query private var shiftReferences: [ShiftReference]
  @Environment(\.modelContext) private var modelContext

  var body: some View {
    Group {
      if !shiftReferences.isEmpty {
        List {
          ForEach(shiftReferences) { shiftReference in
            let shift = shiftReference.shift
            VStack(alignment: .leading) {
              HStack {
                Text(shiftReference.name)
                Spacer()
                ShiftInfoView(shifts: [shift])
              }
              HStack {
                Text(
                  shift.start,
                  format: .dateTime.hour().minute()
                )
                Image(systemName: "arrow.right")

                let calendar = Calendar.current
                let daysBetween = calendar.dateComponents(
                  [.day],
                  from: calendar.startOfDay(for: shift.start),
                  to: calendar.startOfDay(for: shift.end)
                ).day!
                let endText =
                  "\(shift.end.formatted(.dateTime.hour().minute()))\(daysBetween > 0 ? " + \(daysBetween)d" : "")"

                Text(endText)
              }
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("shiftReferenceEditList.referenceRow-\(shiftReference.name)")
          }
          .onDelete { indexSet in
            for index in indexSet {
              modelContext.delete(shiftReferences[index])
            }
          }
        }
      } else {
        ContentUnavailableView(
          .titleNoShiftReferences,
          systemImage: "document.on.document",
          description: Text(.descriptionNoShiftReferences)
        )
      }
    }
    .navigationTitle(.titleShiftReferences)
  }
}

#if DEBUG
  #Preview {
    NavigationStack {
      ShiftReferenceEditListView()
        .modelContainer(PreviewSupport.inMemoryContainer())
    }
  }
#endif
