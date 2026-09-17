import SwiftUI

struct NotificationTimingsListView: View {
  @Binding var notificationTimings: Set<NotificationTiming>

  @Environment(\.dismiss) private var dismiss
  @State private var showAddView = false
  private var notificationTimingsArray: [NotificationTiming] {
    Array(notificationTimings).sorted()
  }

  var body: some View {
    Group {
      if !notificationTimings.isEmpty {
        List {
          ForEach(notificationTimingsArray) { notificationTiming in
            Group {
              switch notificationTiming.timing {
              case .minute:
                Text(
                  .minutesBeforeShift(
                    minutes: notificationTiming.value
                  )
                )
              case .hour:
                Text(
                  .hoursBeforeShift(
                    hours: notificationTiming.value
                  )
                )
              case .day:
                Text(
                  .daysBeforeShift(days: notificationTiming.value)
                )
              }
            }
            .accessibilityIdentifier("notificationTimingsList.timingRow-\(notificationTiming.id)")
          }
          .onDelete { indexSet in
            let tempNotificationTimings = notificationTimingsArray
            for index in indexSet {
              let toRemove = tempNotificationTimings[index]
              notificationTimings.remove(toRemove)
            }
          }
        }
      } else {
        ContentUnavailableView(
          .titleNoReminders,
          systemImage: "bell.slash",
          description: Text(.descriptionNoReminders)
        )
      }
    }
    .navigationTitle(.titleEditReminders)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if notificationTimings.count < 5 {
        ToolbarItem(placement: .topBarLeading) {
          Button(.buttonAddReminder, systemImage: "plus") {
            showAddView = true
          }
          .accessibilityIdentifier("notificationTimingsList.addButton")
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonDone, systemImage: "checkmark") {
          dismiss()
        }
      }
    }
    .sheet(isPresented: $showAddView) {
      NavigationStack {
        NotificationTimingAddView { value, timing in
          notificationTimings.insert(
            NotificationTiming(value: value, timing: timing)
          )
          return true
        }
        .presentationDetents([.medium])
      }
    }
  }
}

#Preview {
  NavigationStack {
    NotificationTimingsListView(
      notificationTimings: .constant([
        NotificationTiming(value: 1, timing: .day)
      ]
      )
    )
  }
}

#Preview {
  NavigationStack {
    NotificationTimingsListView(
      notificationTimings: .constant([])
    )
  }
}
