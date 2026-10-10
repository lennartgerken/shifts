import SwiftData
import SwiftUI

struct ShareView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Category.name) private var categories: [Category]

  @State private var category: Category? = nil
  @State private var from: Date = Date()
  @State private var to: Date = Date()
  private var shiftsToExport: [Shift] {
    do {
      var predicate: Predicate<Shift>
      if let category {
        let categoryID = category.persistentModelID

        predicate = #Predicate<Shift> { shift in
          shift.category?.persistentModelID == categoryID && shift.start >= from
            && shift.start <= to
        }
      } else {
        predicate = #Predicate<Shift> { shift in
          shift.category == nil && shift.start >= from && shift.start <= to
        }
      }
      return try modelContext.fetch(
        FetchDescriptor<Shift>(
          predicate: predicate,
          sortBy: [SortDescriptor(\.start, order: .forward)]
        ))
    } catch {
      print(error)
    }
    return []
  }
  var body: some View {
    List {
      Section {
        Picker(.labelCategory, selection: $category) {
          Text(.pickerValueDefault).tag(nil as Category?)
          ForEach(categories) { category in
            Text(category.name).tag(category)
          }
        }
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
      }
      Section {
        ShareLink(
          item: ShiftPileExport(
            shifts: shiftsToExport.map({ shift in
              shiftExport(start: shift.start, end: shift.end)
            })), preview: SharePreview(.shareTitleShifts))
      }
      if shiftsToExport.count > 0 {
        Section(.titlePreview) {
          ForEach(shiftsToExport) { shift in
            DayRowView(day: Day(date: shift.start, shifts: shiftsToExport), style: .fullDate)
          }
        }
      }
    }
    .navigationTitle(.titleShareShifts)
  }
}

#Preview {
  NavigationStack {
    ShareView()
  }
}
