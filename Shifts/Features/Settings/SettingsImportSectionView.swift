import SwiftData
import SwiftUI

struct SettingsImportSectionView: View {
  @State private var showImportInfo = false
  @Environment(AppSettings.self) private var settings

  var body: some View {
    @Bindable var settings = settings

    Section {
      Picker(
        .labelDateIdentification,
        selection: $settings.importSettings.day
      ) {
        Text(.pickerValueSeperateDdMmYyyy).tag(
          ShiftParsingDay.day(month: .dayMonthYear)
        )
        Text(.pickerValueSeperateMmYyyy).tag(
          ShiftParsingDay.day(month: .monthYear)
        )
        Text(.pickerValueSeperateMmmmYyyy).tag(
          ShiftParsingDay.day(month: .wideMonthYear)
        )
        Text(.pickerValueWholeDate).tag(
          ShiftParsingDay.dayMonthYear
        )
      }
      PatternView(
        label: String(localized: .patternShiftEntry),
        patternGroup: Binding(
          get: { settings.importSettings.entryPattern },
          set: { settings.importSettings.entryPattern = $0 }
        ),
        additionalPatternValues: settings.importSettings
          .neededEntryPatternValues
      )
      if case .day = settings.importSettings.day {
        PatternView(
          label: String(localized: .patternDate),
          patternGroup: Binding(
            get: { settings.importSettings.monthPattern },
            set: { settings.importSettings.monthPattern = $0 }
          ),
          additionalPatternValues: settings.importSettings
            .neededMonthPatternValues
        )
      }
    } header: {
      HStack {
        Text(.titleImportShifts)
        Spacer()
        Button {
          showImportInfo = true
        } label: {
          Label(.buttonInfo, systemImage: "info.circle")
            .labelStyle(.iconOnly)
        }
        .sheet(
          isPresented: $showImportInfo,
          content: {
            NavigationStack {
              SettingsImportInfoView()
            }
          }
        )
      }
    }
  }
}

#Preview {
  Form {
    SettingsImportSectionView()
      .environment(AppSettings())
      .modelContainer(PreviewSupport.inMemoryContainer())
  }
}
