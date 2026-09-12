import SwiftData
import SwiftUI

struct CalendarView: View {
  private let calendar = Calendar.current
  private let shiftsImportService: ShiftsImportServicing
  private let notificationService: NotificationServicing

  @Environment(AppSettings.self) private var settings

  @State private var start: Date
  @State private var showAddShift = false
  @State private var showImport = false
  @State private var showSettings = false
  @State private var showDateSelection = false
  @State private var selectedDate: Date
  @State private var didFirstScroll = false
  @State private var scrollRequest: ScrollRequest?
  @State private var didInitialScroll = false

  var end: Date {
    calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
  }

  init(
    shiftsImportService: ShiftsImportServicing,
    notificationService: NotificationServicing
  ) {
    self.shiftsImportService = shiftsImportService
    self.notificationService = notificationService

    let startOfMonth = calendar.date(
      from: calendar.dateComponents([.year, .month], from: Date())
    )!

    start = startOfMonth
    selectedDate = Date()
  }

  var body: some View {
    NavigationStack {
      CalendarListView(
        start: start,
        end: end,
        scrollRequest: $scrollRequest,
        notificationService: notificationService
      )
      .onChange(of: selectedDate, initial: !didInitialScroll) { _, newValue in
        didInitialScroll = true
        start = calendar.date(
          from: calendar.dateComponents(
            [.year, .month],
            from: newValue
          )
        )!
        scrollRequest = ScrollRequest(
          to: calendar.startOfDay(for: selectedDate)
        )
      }
      .navigationTitle(start.formatted(.dateTime.month(.wide).year()))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItemGroup(placement: .bottomBar) {
          Button(
            .buttonPreviousMonth,
            systemImage: "chevron.backward"
          ) {
            start = calendar.date(
              byAdding: .month,
              value: -1,
              to: start
            )!
            selectedDate = start
          }
          Button(.buttonSelectDate, systemImage: "calendar") {
            showDateSelection = true
          }
          .popover(isPresented: $showDateSelection) {
            VStack {
              DatePicker(
                .labelDate,
                selection: $selectedDate,
                displayedComponents: [.date]
              )
              .datePickerStyle(.wheel)
              .labelsHidden()
              .presentationCompactAdaptation(.none)
              Button(.buttonDone, systemImage: "checkmark") {
                showDateSelection = false
              }
              .accessibilityIdentifier("calendar.selectDateDoneButton")
            }
            .padding()
          }
          .accessibilityIdentifier("calendar.selectDateButton")
          Button(.buttonJumpToToday, systemImage: "\(Date().formatted(.dateTime.day())).calendar") {
            start = calendar.date(
              from: calendar.dateComponents(
                [.year, .month],
                from: Date()
              )
            )!
            selectedDate = calendar.startOfDay(for: Date())
            scrollRequest = ScrollRequest(to: selectedDate)
          }
          Button(.buttonNextMonth, systemImage: "chevron.forward") {
            start = calendar.date(
              byAdding: .month,
              value: 1,
              to: start
            )!
            selectedDate = start
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            Button(.buttonAddShift, systemImage: "plus") {
              showAddShift = true
            }
            .accessibilityIdentifier("calendar.addShiftButton")
            Button(
              .buttonImportShifts,
              systemImage: "photo.badge.magnifyingglass"
            ) {
              showImport = true
            }
            .accessibilityIdentifier("calendar.importShiftsButton")
            Button(
              .buttonSettings,
              systemImage: "gearshape"
            ) {
              showSettings = true
            }
            .accessibilityIdentifier("calendar.settingsButton")
          } label: {
            Label(.buttonOpenMenu, systemImage: "ellipsis")
          }
          .accessibilityIdentifier("calendar.openMenuButton")
        }
      }
      .sheet(isPresented: $showAddShift) {
        NavigationStack {
          ShiftEditView(
            mode: .add(date: nil),
            notificationService: notificationService
          )
        }
      }
      .sheet(isPresented: $showImport) {
        NavigationStack {
          ShiftsImportView(
            shiftsImportService: shiftsImportService,
            notificationService: notificationService
          )
        }
      }
      .sheet(isPresented: $showSettings) {
        NavigationStack {
          SettingsView(notificationService: notificationService)
        }
      }
    }
  }
}

#Preview {
  let container = PreviewSupport.inMemoryContainer()
  let textRecognitionService = TextRecognitionService()
  let shiftParsingService = ShiftParsingService()
  let shiftsImportService = ShiftsImportService(
    textRecognitionService: textRecognitionService,
    shiftParsingService: shiftParsingService,
  )
  let notificationService = NotificationService()
  let settings = AppSettings()

  CalendarView(
    shiftsImportService: shiftsImportService,
    notificationService: notificationService
  )
  .modelContainer(container)
  .environment(settings)
}
