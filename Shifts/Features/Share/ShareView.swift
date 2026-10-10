import SwiftData
import SwiftUI

struct ShareView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var from: Date = Date()
  @State private var to: Date = Date()
  private var export: ShiftPileExport {
    do {
      let shifts = try modelContext.fetch(
        FetchDescriptor<Shift>(
          predicate: #Predicate {
            $0.start >= from && $0.end <= to
          }
        ))
      return ShiftPileExport(
        shifts: shifts.map({ shift in
          shiftExport(start: shift.start, end: shift.end)
        }))
    } catch {
      print(error)
    }
    return ShiftPileExport(shifts: [])
  }

  var body: some View {
    Form {
      DatePicker(
        .labelFrom,
        selection: $from,
        displayedComponents: [.date]
      )
      DatePicker(
        .labelTo,
        selection: $to,
        displayedComponents: [.date]
      )
      ShareLink(item: export, preview: SharePreview("Shifts"))
    }
    .navigationTitle(.titleShareShifts)
  }
}

#Preview {
  NavigationStack {
    ShareView()
  }
}
