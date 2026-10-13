import SwiftUI

struct PatternListView: View {
  private let additionalPatternValues: [PatternValue]

  @Environment(\.dismiss) private var dismiss

  @Binding private var patternGroup: PatternGroup

  @State private var tempPatternGroup: PatternGroup
  @State private var validationError: String?
  @State private var addPatterMode: PatternAddMode?

  init(
    patternGroup: Binding<PatternGroup>,
    additionalPatternValues: [PatternValue] = []
  ) {
    self._patternGroup = patternGroup
    self.tempPatternGroup = patternGroup.wrappedValue
    self.additionalPatternValues = additionalPatternValues
  }

  var body: some View {
    Group {
      if !tempPatternGroup.patternValues.isEmpty {
        List {
          ForEach(tempPatternGroup.patternValues, id: \.self) { patternValue in
            Text(patternValue.pattern.toDisplay())
          }
          .onDelete { offset in
            tempPatternGroup.patternValues.remove(atOffsets: offset)
          }
          .onMove { from, to in
            tempPatternGroup.patternValues.move(fromOffsets: from, toOffset: to)
          }
        }
      } else {
        ContentUnavailableView(
          .titleNoPatterns,
          systemImage: "rectangle.pattern.checkered",
          description: Text(.descriptionNoPatterns)
        )
      }
    }
    .navigationTitle(.titleEditPattern)
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .top) {
      if let error = validationError {
        Label(error, systemImage: "exclamationmark.triangle.fill")
          .foregroundStyle(.red)
          .padding()
          .bold()
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Menu {
          ForEach(additionalPatternValues, id: \.self) { patternValue in
            if tempPatternGroup.has(patternValue: patternValue) {
              EmptyView()
            } else {
              Button(patternValue.toDisplay()) {
                tempPatternGroup.patternValues.append(
                  patternValue
                )
              }
            }
          }
          if additionalPatternValues.count > 0 {
            Divider()
          }
          Button(.patternCharacter) {
            addPatterMode = .anyPattern
          }
          Button(.patternNumber) {
            addPatterMode = .numberPattern
          }
          Button(.patternText) {
            addPatterMode = .textPattern
          }
          Button(.patternStaticCharacters) {
            addPatterMode = .staticPattern
          }
        } label: {
          Label(.buttonAddPattern, systemImage: "plus")
        }
      }
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Label(.buttonCancel, systemImage: "xmark")
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button {
          save()
        } label: {
          Label(.buttonSave, systemImage: "checkmark")
        }
      }
    }
    .sheet(item: $addPatterMode) { mode in
      NavigationStack {
        PatternAddView(mode: mode) { pattern in
          tempPatternGroup.patternValues.append(pattern)
        }
      }
    }
  }

  private func save() {
    validationError = validate()

    guard validationError == nil else {
      return
    }

    patternGroup = tempPatternGroup
    dismiss()
  }

  private func validate() -> String? {
    if tempPatternGroup.patternValues.isEmpty {
      return String(localized: .errorEmptyList)
    }

    let missingPatternValues = additionalPatternValues.filter({
      !tempPatternGroup.has(patternValue: $0)
    })

    if !missingPatternValues.isEmpty {
      return
        "\(String(localized: .errorMissingPatterns)) \(missingPatternValues.map({ $0.pattern.toDisplay() }).joined(separator: ", "))"
    }

    return nil
  }
}

#Preview {
  let patternGroup = PatternGroup(patternValues: [])
  let additionalPatternValues: [PatternValue] = [
    .dayPattern(DayPattern(type: .day))
  ]

  NavigationStack {
    PatternListView(
      patternGroup: .constant(patternGroup),
      additionalPatternValues: additionalPatternValues
    )
  }
}
