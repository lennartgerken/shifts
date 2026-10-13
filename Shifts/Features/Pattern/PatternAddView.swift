import SwiftUI

enum PatternAddMode: Identifiable {
  var id: Self { self }
  case anyPattern
  case numberPattern
  case staticPattern
  case textPattern
}

struct PatternAddView: View {
  let mode: PatternAddMode
  let onFinish: (PatternValue) -> Void

  @Environment(\.dismiss) var dismiss

  @State private var patternCount: Int = 0
  @State private var patternOrMore: Bool = false
  @State private var staticPatternText: String = ""

  var body: some View {
    Form {
      Section {
        switch mode {
        case .anyPattern, .numberPattern, .textPattern:
          LabeledContent(.labelCount) {
            TextField(
              .labelCount,
              value: Binding(
                get: { patternCount },
                set: { patternCount = max(0, $0) }
              ),
              format: .number
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
          }
          Toggle(.labelOrMore, isOn: $patternOrMore)
        case .staticPattern:
          TextField(
            .labelStaticCharacters,
            text: $staticPatternText
          )
        }
      }
    }
    .navigationTitle(.titleAddPattern)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button {
          onFinish(createPattern())
          dismiss()
        } label: {
          Label(.buttonSave, systemImage: "checkmark")
        }
      }
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Label(.buttonCancel, systemImage: "xmark")
        }
      }
    }
  }

  private func createPattern() -> PatternValue {
    switch mode {
    case .anyPattern:
      return .anyPattern(AnyPattern(count: patternCount, orMore: patternOrMore))
    case .numberPattern:
      return .numberPattern(NumberPattern(count: patternCount, orMore: patternOrMore))
    case .staticPattern:
      return .staticPattern(StaticPattern(text: staticPatternText))
    case .textPattern:
      return .textPattern(TextPattern(count: patternCount, orMore: patternOrMore))
    }
  }
}

#Preview {
  NavigationStack {
    PatternAddView(mode: .numberPattern) { pattern in
      print(pattern)
    }
  }
}
