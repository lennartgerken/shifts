import SwiftData
import SwiftUI

enum ShiftEditMode {
  case add(date: Date?)
  case edit(shift: Shift)
}

struct ShiftEditView: View {
  private let mode: ShiftEditMode
  private let notificationService: NotificationServicing

  private let calendar = Calendar.current
  private let title: String

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(AppSettings.self) private var settings

  @State private var sameDay = true
  @State private var day = Date()
  @State private var start = Date()
  @State private var end = Date()
  @State private var notes: String?
  @State private var tags: Set<Tag>
  @State private var useAsReference = false
  @State private var referenceName = ""
  @State private var datesError: String?
  @State private var successMessage: String?

  init(mode: ShiftEditMode, notificationService: NotificationServicing) {
    self.mode = mode
    self.notificationService = notificationService

    switch mode {
    case .add(let date):
      title = String(localized: .titleAddShift)
      let initDate = date ?? Date()
      _day = State(initialValue: initDate)
      _start = State(initialValue: calendar.startOfDay(for: initDate))
      _end = State(initialValue: calendar.startOfDay(for: initDate))
      _tags = State(initialValue: [])
    case .edit(let shift):
      title = String(localized: .titleEditShift)

      let tempSameDay =
        calendar.startOfDay(for: shift.start)
        == calendar.startOfDay(for: shift.end)

      _sameDay = State(initialValue: tempSameDay)

      if tempSameDay {
        _day = State(initialValue: shift.start)
      }

      _start = State(initialValue: shift.start)
      _end = State(initialValue: shift.end)
      _notes = State(initialValue: shift.notes)
      _tags = State(initialValue: Set(shift.tags))
      if let shifReference = shift.shiftReference {
        _useAsReference = State(initialValue: true)
        _referenceName = State(initialValue: shifReference.name)
      }
    }
  }

  var body: some View {
    Form {
      Section {
        Toggle(.labelEndsSameDay, isOn: $sameDay)
        if sameDay {
          DatePicker(
            .labelDay,
            selection: $day,
            displayedComponents: [.date]
          )
          .accessibilityIdentifier("shiftEdit.dayDatePicker")
        }
        DatePicker(
          .labelStart,
          selection: $start,
          displayedComponents: sameDay
            ? [.hourAndMinute] : [.date, .hourAndMinute]
        )
        .accessibilityIdentifier("shiftEdit.startDatePicker")
        DatePicker(
          .labelEnd,
          selection: $end,
          displayedComponents: sameDay
            ? [.hourAndMinute] : [.date, .hourAndMinute]
        )
        .accessibilityIdentifier("shiftEdit.endDatePicker")
      } header: {
        Text(.titleShift)
      } footer: {
        if let error = datesError {
          ErrorView(error: error)
        }
      }
      Section(.titleNotes) {
        TextField(
          .labelNotes,
          text: Binding(
            get: {
              notes ?? ""
            },
            set: { newValue in
              notes = newValue == "" ? nil : newValue
            }
          ),
          axis: .vertical
        )
        .accessibilityIdentifier("shiftEdit.notesTextField")
      }
      TagsView(tags: $tags)
      Section(.titleUseAsReference) {
        Toggle(.labelUseAsReference, isOn: $useAsReference)
          .accessibilityIdentifier("shiftEdit.useAsReferenceToggle")
        if useAsReference {
          TextField(.labelName, text: $referenceName)
            .accessibilityIdentifier("shiftEdit.referenceNameTextField")
        }
      }
    }
    .scrollDismissesKeyboard(.interactively)
    .navigationTitle(title)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(.buttonCancel, systemImage: "xmark") {
          dismiss()
        }
      }
      if case .add = mode {
        ToolbarItem(placement: .confirmationAction) {
          Button(
            .buttonSaveAndNext,
            systemImage:
              "checkmark.arrow.trianglehead.clockwise"
          ) {
            successMessage = nil
            Task {
              if await save() {
                let dateToShow = sameDay ? day : start
                let dateFormatted = dateToShow.formatted(
                  .dateTime.year().month().day()
                )
                successMessage =
                  "\(String(localized: .successShiftSaved))\n\(dateFormatted)"

                day = Calendar.current.date(
                  byAdding: DateComponents(day: 1),
                  to: day
                )!
                start = Calendar.current.date(
                  byAdding: DateComponents(day: 1),
                  to: start
                )!
                end = Calendar.current.date(
                  byAdding: DateComponents(day: 1),
                  to: end
                )!
                useAsReference = false
                referenceName = ""
              }
            }
          }
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(
          .buttonSave,
          systemImage: "checkmark"
        ) {
          Task {
            if await save() {
              dismiss()
            }
          }
        }
        .accessibilityIdentifier("shiftEdit.saveButton")
      }
    }
    .safeAreaInset(edge: .top) {
      if let message = successMessage {
        Label(
          message,
          systemImage: "checkmark.circle.fill"
        )
        .foregroundStyle(.green)
        .bold()
      }
    }
  }

  private func save() async -> Bool {
    datesError = nil
    do {
      var startToSet = start
      var endToSet = end

      if sameDay {
        let startTimeComponents = calendar.dateComponents(
          [.hour, .minute],
          from: start
        )
        let endTimeComponents = calendar.dateComponents(
          [.hour, .minute],
          from: end
        )

        startToSet = calendar.date(
          bySettingHour: startTimeComponents.hour!,
          minute: startTimeComponents.minute!,
          second: 0,
          of: day
        )!
        endToSet = calendar.date(
          bySettingHour: endTimeComponents.hour!,
          minute: endTimeComponents.minute!,
          second: 0,
          of: day
        )!
      }

      if case .add = mode {
        let shift = try Shift(
          start: startToSet,
          end: endToSet,
          notes: notes,
          tags: Array(tags)
        )

        if useAsReference {
          let shiftReference = ShiftReference(
            name: referenceName,
            shift: shift
          )
          modelContext.insert(shiftReference)
        }

        modelContext.insert(shift)

        if settings.sendNotifications {
          do {
            try await notificationService.schedule(
              for: shift, notificationTimings: settings.notificationTimings)
          } catch {
            print("Failed to schedule notification:", error)
          }
        }
      } else if case .edit(let shift) = mode {
        try shift.updateValues(
          start: startToSet,
          end: endToSet,
          notes: notes,
          tags: Array(tags)
        )

        if useAsReference {
          if let shiftReference = shift.shiftReference {
            shiftReference.updateValues(name: referenceName)
          } else {
            let shiftReference = ShiftReference(name: referenceName, shift: shift)
            modelContext.insert(shiftReference)
          }
        } else {
          if let shiftReference = shift.shiftReference {
            modelContext.delete(shiftReference)
          }
        }

        if settings.sendNotifications {
          do {
            try await notificationService.update(
              for: shift, notificationTimings: settings.notificationTimings)
          } catch {
            print("Failed to update notification:", error)
          }
        }
      }
      return true
    } catch let error as ShiftCreationError {
      switch error {
      case .endBeforeStart:
        datesError = String(localized: .errorEndBeforeStart)
      case .startIsEnd:
        datesError = String(localized: .errorStartIsEnd)
      case .moreThanOneDay:
        datesError = String(localized: .errorStartEndMoreThanOneDay)
      }
    } catch {
    }
    return false
  }
}

#Preview {
  NavigationStack {
    ShiftEditView(
      mode: .add(date: Date()),
      notificationService: NotificationService()
    )
  }
  .environment(AppSettings())
}

#Preview {
  let calendar = Calendar.current
  let start = calendar.date(
    from: DateComponents(year: 2020, month: 1, day: 1, hour: 10, minute: 30)
  )!
  let end = calendar.date(
    from: DateComponents(year: 2020, month: 1, day: 1, hour: 15, minute: 30)
  )!

  NavigationStack {
    ShiftEditView(
      mode: .edit(shift: try! Shift(start: start, end: end)),
      notificationService: NotificationService()
    )
  }
  .environment(AppSettings())
}
