import SwiftData
import SwiftUI

struct ShiftDetailsView: View {
  let shift: Shift
  let notificationService: NotificationServicing

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var showEditShift = false

  private let format: Date.FormatStyle

  init(shift: Shift, notificationService: NotificationServicing) {
    self.shift = shift
    self.notificationService = notificationService
    self.format =
      Calendar.current.isDate(shift.start, inSameDayAs: shift.end)
      ? .dateTime.hour().minute() : .dateTime.day().month().year().hour().minute()
  }

  var body: some View {
    Form {
      Section(.titleShift) {
        LabeledContent(.labelStart) {
          Text(shift.start, format: format)
            .accessibilityIdentifier("shiftDetails.startTextField")
        }
        LabeledContent(.labelEnd) {
          Text(shift.end, format: format)
            .accessibilityIdentifier("shiftDetails.endTextField")
        }
      }
      Section(.titleNotes) {
        Text(shift.notes ?? "")
          .accessibilityIdentifier("shiftDetails.notesTextField")
      }
      if !shift.tags.isEmpty {
        Section(.titleTags) {
          TagListView(tags: Set(shift.tags))
        }
      }
      Button(.buttonDeleteShift, role: .destructive) {
        modelContext.delete(shift)
        notificationService.remove(for: shift)
        dismiss()
      }
      .accessibilityIdentifier("shiftDetails.deleteButton")
    }
    .navigationTitle(shift.start.formatted(.dateTime.day().month().year().weekday()))
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(.buttonEdit, systemImage: "pencil") {
          showEditShift = true
        }
        .accessibilityIdentifier("shiftDetails.editButton")
      }
    }
    .sheet(isPresented: $showEditShift) {
      NavigationStack {
        ShiftEditView(mode: .edit(shift: shift), notificationService: notificationService)
      }
    }
  }
}

#Preview {
  let calendar = Calendar.current

  NavigationStack {
    ShiftDetailsView(
      shift: try! Shift(
        start: calendar.date(
          from: DateComponents(year: 2024, month: 08, day: 10, hour: 10, minute: 00))!,
        end: calendar.date(
          from: DateComponents(year: 2024, month: 08, day: 10, hour: 18, minute: 00))!,
        notes: """
          Test 1
          Test 2
          """
      ),
      notificationService: NotificationService()
    )
  }
}
