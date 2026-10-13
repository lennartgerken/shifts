import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: "ShareView"
)

struct ShareView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(\.isUITesting) private var isUITesting
  @Query(sort: \Category.name) private var categories: [Category]

  @State private var category: Category? = nil
  @State private var from: Date
  @State private var to: Date
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
  private var export: ShiftPileExport {
    ShiftPileExport(
      shifts: shiftsToExport.map({ shift in
        ShiftExport(start: shift.start, end: shift.end)
      }))
  }

  @State private var exportBase64: String?

  init() {
    let interval = Calendar.current.dateInterval(of: .month, for: Date())!
    self.from = interval.start
    self.to = Calendar.current.date(byAdding: .minute, value: -1, to: interval.end)!
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
        if !isUITesting {
          ShareLink(
            item: export,
            preview: SharePreview(
              "\(from.formatted(.dateTime.month().year().day())) - \(to.formatted(.dateTime.month().year().day()))",
              image: Image("ShareIcon")))
        } else {
          Button(.buttonShare) {
            Task {
              do {
                let data = try await export.exported(as: .shiftPile)
                exportBase64 = data.base64EncodedString()
              } catch {
                logger.error("Could not create exported shifts: \(error)")
              }
            }
          }
          .accessibilityIdentifier("share.shareButton")
          if let exportBase64 {
            Text(exportBase64)
              .accessibilityIdentifier("share.base64Text")
              .accessibilityValue(exportBase64)
          }
        }
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
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonDone, systemImage: "checkmark") {
          dismiss()
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    ShareView()
  }
}
