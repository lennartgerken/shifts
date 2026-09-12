import SwiftData
import SwiftUI

struct ScrollRequest: Equatable {
  let id = UUID()
  let to: Day.ID
}

private struct Week: Identifiable {
  let days: [Day]
  let id: Date

  init?(days: [Day]) {
    guard let firstDay = days.first else {
      return nil
    }

    self.days = days
    self.id = firstDay.dateInterval.start
  }
}

struct CalendarListView: View {
  private let calendar = Calendar.current
  private let start: Date
  private let end: Date
  private let notificationService: NotificationServicing

  @Environment(\.modelContext) private var modelContext

  @Query private var shifts: [Shift]
  @Query private var shiftReferences: [ShiftReference]
  @State private var didFirstScroll: Bool = false
  @Binding private var scrollRequest: ScrollRequest?

  private var days: [Day] {
    getDates(from: start, to: end).map { date in
      Day(date: date, shifts: shifts)
    }
  }

  private var weeks: [Week] {
    var weeks: [Week] = []
    var currentDays: [Day] = []
    for day in days {
      let currentWeekday = calendar.component(
        .weekday,
        from: day.dateInterval.start
      )
      let currentWeekdayIndex =
        (currentWeekday - calendar.firstWeekday + 7) % 7
      if let lastDay = currentDays.last {
        let lastWeekday = calendar.component(
          .weekday,
          from: lastDay.dateInterval.start
        )
        let lastWeekdayIndex =
          (lastWeekday - calendar.firstWeekday + 7) % 7
        if currentWeekdayIndex
          > lastWeekdayIndex
        {
          currentDays.append(day)
        } else {
          if let week = Week(days: currentDays) {
            weeks.append(week)
          }
          currentDays = [day]
        }
      } else {
        currentDays = [day]
      }
    }
    if let week = Week(days: currentDays) {
      weeks.append(week)
    }

    return weeks
  }

  init(
    start: Date,
    end: Date,
    scrollRequest: Binding<ScrollRequest?>,
    notificationService: NotificationServicing
  ) {
    self.notificationService = notificationService

    let start = calendar.dateInterval(of: .day, for: start)!.start
    let end = calendar.dateInterval(of: .day, for: end)!.end
    self.start = start
    self.end = end
    self._scrollRequest = scrollRequest

    _shifts = Query(
      filter: #Predicate<Shift> {
        ($0.start >= start && $0.start < end)
          || ($0.end >= start && $0.end < end)
      },
      sort: [SortDescriptor(\.start, order: .forward)]
    )
  }

  var body: some View {
    ScrollViewReader { proxy in
      List {
        ForEach(weeks) { week in
          Section {
            ForEach(week.days) { day in
              NavigationLink {
                DayDetailsView(
                  dateInterval: day.dateInterval,
                  notificationService: notificationService
                )
              } label: {
                DayRowView(day: day)
              }
              .accessibilityIdentifier(
                "calendarList.dayRow-\(day.id.formatted(.iso8601.year().month().day()))"
              )
              .contextMenu {
                ForEach(shiftReferences) { shiftReference in
                  Button(shiftReference.name) {
                    let shift =
                      try? shiftReference.createShift(
                        for: day.dateInterval.start
                      )

                    if let shift {
                      modelContext.insert(shift)
                    }
                  }
                  .accessibilityIdentifier("calendarList.referenceButton-\(shiftReference.name)")
                }
              }
            }
          }
        }
      }
      .onChange(of: scrollRequest) {
        if let scrollRequest {
          withAnimation {
            proxy.scrollTo(scrollRequest.to, anchor: .center)
          }
        }
      }
    }
  }
}

private func getDates(from start: Date, to end: Date) -> [Date] {
  let calendar = Calendar.current
  var days: [Date] = []
  var current = calendar.startOfDay(for: start)
  let end = calendar.startOfDay(for: end)

  while current < end {
    days.append(current)
    current = calendar.date(byAdding: .day, value: 1, to: current)!
  }

  return days
}

#Preview {
  let start = Calendar.current.date(
    from: Calendar.current.dateComponents([.year, .month], from: Date())
  )!
  let end = Calendar.current.date(
    byAdding: DateComponents(month: 1, day: -1),
    to: start
  )!

  NavigationStack {
    CalendarListView(
      start: start,
      end: end,
      scrollRequest: .constant(ScrollRequest(to: Date())),
      notificationService: NotificationService()
    )
  }
  .modelContainer(PreviewSupport.inMemoryContainer())
}
