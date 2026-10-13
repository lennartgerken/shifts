import SwiftUI

struct NotificationTimingAddView: View {
  let onSave: (Int, NotificationTimingType) -> Bool

  @Environment(\.dismiss) private var dismiss
  @State private var value: Int = 1
  @State private var timing: NotificationTimingType = .hour

  var body: some View {
    VStack {
      HStack(alignment: .top) {
        Picker(.labelCount, selection: $value) {
          ForEach(1...100, id: \.self) { number in
            Text("\(number)").tag(number)
          }
        }
        .pickerStyle(.wheel)
        .accessibilityIdentifier("notificationTimingAdd.countPicker")
        Picker(.labelType, selection: $timing) {
          Text(.pickerValueMinutes).tag(NotificationTimingType.minute)
          Text(.pickerValueHours).tag(NotificationTimingType.hour)
          Text(.pickerValueDays).tag(NotificationTimingType.day)
        }
        .pickerStyle(.wheel)
        .accessibilityIdentifier("notificationTimingAdd.typePicker")
      }
      Text(.beforeTheShift)
      Spacer()
    }
    .navigationTitle(.titleAddReminder)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(.buttonCancel, systemImage: "xmark") {
          dismiss()
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(.buttonSave, systemImage: "checkmark") {
          if onSave(value, timing) {
            dismiss()
          }
        }
        .accessibilityIdentifier("notificationTimingAdd.saveButton")
      }
    }
  }
}

#Preview {
  NavigationStack {
    NotificationTimingAddView { _, _ in
      true
    }
  }
}
