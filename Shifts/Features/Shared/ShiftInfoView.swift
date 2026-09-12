import SwiftUI

struct ShiftInfoView: View {
  private let shifts: [Shift]

  init(shifts: [Shift]) {
    self.shifts = shifts
  }

  var body: some View {
    let tags = Array(Set(shifts.flatMap(\.tags)))
    HStack {
      if tags.count > 3 {
        Image(systemName: "ellipsis")
      }
      ForEach(tags.prefix(3)) { tag in
        Image(systemName: "tag")
          .foregroundStyle(tag.color)
          .accessibilityIdentifier("shiftInfo.tagImage-\(tag.name)")
      }
      if shifts.first(where: { shift in
        shift.notes != nil
      }) != nil {
        Image(systemName: "text.document")
          .accessibilityIdentifier("shiftInfo.notesImage")
      }
    }
  }
}

#Preview {
  let calendar = Calendar.current

  ShiftInfoView(shifts: [
    try! Shift(
      start: calendar.date(
        from: DateComponents(year: 2023, month: 1, day: 1, hour: 10, minute: 30))!,
      end: calendar.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 11, minute: 30))!,
      notes: "Test",
      tags: [try! Tag(name: "Tag 1", colorRed: 1, colorBlue: 0, colorGreen: 0)]
    )
  ])
}
