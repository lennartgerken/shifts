import SwiftUI

struct SettingsImportInfoView: View {
  @Environment(\.dismiss) private var dismiss

  private var infoText: AttributedString {
    let text = String(
      localized: .textImportInfo(
        labelDateIdentification: String(localized: .labelDateIdentification),
        patternShiftEntry: String(localized: .patternShiftEntry),
        patternShiftEntryExample:
          """
          \(DayPattern(type: .day).toDisplay())  
          \(AnyPattern(count: 1, orMore: true).toDisplay())  
          \(StartTimePattern(type: .hoursMinutes).toDisplay())  
          \(StaticPattern(text: " ").toDisplay())  
          \(EndTimePattern(type: .hoursMinutes).toDisplay())
          """,
        patternDate: String(localized: .patternDate),
        patternDateExample:
          """
          \(StaticPattern(text: "von: ").toDisplay())  
          \(MonthPattern(type: .dayMonthYear).toDisplay())
          """
      )
    )
    return (try? AttributedString(markdown: text)) ?? AttributedString(text)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text(infoText)
      }
      .padding(20)
    }
    .navigationTitle(.titleImportShifts)
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
    SettingsImportInfoView()
  }
}
