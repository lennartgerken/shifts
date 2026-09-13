import SwiftData
import SwiftUI

struct DayDetailsView: View {
  private let dateInterval: DateInterval
  private let notificationService: NotificationServicing

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Query private var shifts: [Shift]
  @State private var showAddShift: Bool = false

  init(dateInterval: DateInterval, notificationService: NotificationServicing) {
    self.dateInterval = dateInterval
    self.notificationService = notificationService

    let start = dateInterval.start
    let end = dateInterval.end

    let predicate: Predicate<Shift> = #Predicate {
      ($0.start >= start && $0.start < end)
        || ($0.end >= start && $0.end < end)
    }
    let sortDescriptors: [SortDescriptor<Shift>] = [
      SortDescriptor(\Shift.start, order: .forward)
    ]
    _shifts = Query(
      filter: predicate,
      sort: sortDescriptors
    )
  }

  var body: some View {
    Group {
      if shifts.count == 1, let shift = shifts.first {
        ShiftDetailsView(shift: shift, notificationService: notificationService)
      } else {
        if !shifts.isEmpty {
          List {
            ForEach(shifts) { shift in
              NavigationLink {
                ShiftDetailsView(shift: shift, notificationService: notificationService)
              } label: {
                let calendar = Calendar.current
                let start =
                  shift.start < dateInterval.start
                  ? calendar.startOfDay(for: shift.start) : shift.start
                let end =
                  shift.end >= dateInterval.end
                  ? calendar.date(byAdding: DateComponents(minute: -1), to: dateInterval.end)!
                  : shift.end
                HStack {
                  HStack {
                    Text(start, style: .time)
                    Image(systemName: "arrow.right")
                    Text(end, style: .time)
                  }
                  Spacer()
                  ShiftInfoView(shifts: [shift])
                }
              }
            }
            .onDelete { indexSet in
              for index in indexSet {
                modelContext.delete(shifts[index])
                notificationService.remove(for: shifts[index])
              }
            }
          }
        } else {
          ContentUnavailableView(
            .titleNoShifts,
            systemImage: "calendar",
            description: Text(.descriptionNoShifts)
          )
        }
      }
    }
    .navigationTitle(
      dateInterval.start.formatted(
        .dateTime.day().month().year().weekday()
      )
    )
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          showAddShift = true
        } label: {
          Label(.buttonAddShift, systemImage: "plus")
        }
      }
    }
    .sheet(isPresented: $showAddShift) {
      NavigationStack {
        ShiftEditView(
          mode: .add(date: dateInterval.start), notificationService: notificationService)
      }
    }
  }
}

#if DEBUG
  #Preview {
    NavigationStack {
      DayDetailsView(
        dateInterval: Calendar.current.dateInterval(of: .day, for: Date())!,
        notificationService: NotificationService()
      )
    }.modelContainer(PreviewSupport.inMemoryContainer())
  }
#endif
