import SwiftData
import SwiftUI

struct SettingsImportView: View {
  @State private var showImportInfo = false
  @Environment(AppSettings.self) private var settings

  var body: some View {
    @Bindable var settings = settings

    Form {
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
      }
      Section {
        PatternView(
          label: String(localized: .patternShiftEntry),
          patternGroup: Binding(
            get: { settings.importSettings.entryPattern },
            set: { settings.importSettings.entryPattern = $0 }
          ),
          additionalPatternValues: settings.importSettings
            .neededEntryPatternValues
        )
      }
      if case .day = settings.importSettings.day {
        Section {
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
      }
    }
    .navigationTitle(.titleImportSettings)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(.buttonInfo, systemImage: "info.circle") {
          showImportInfo = true
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

#if DEBUG
  #Preview {
    NavigationStack {
      SettingsImportView()
        .environment(AppSettings())
        .modelContainer(PreviewSupport.inMemoryContainer())
    }
  }
#endif
