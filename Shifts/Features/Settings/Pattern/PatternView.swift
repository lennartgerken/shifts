import SwiftUI

struct PatternView: View {
  let label: String
  @Binding var patternGroup: PatternGroup
  let additionalPatternValues: [PatternValue]

  @State private var showEditor: Bool = false

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(label)
        if !patternGroup.patternValues.isEmpty {
          Text(patternGroup.toDisplay())
            .lineLimit(1)
            .truncationMode(.middle)
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
      Button {
        showEditor = true
      } label: {
        Image(systemName: "pencil")
      }
    }
    .sheet(isPresented: $showEditor) {
      NavigationStack {
        PatternListView(
          patternGroup: $patternGroup, additionalPatternValues: additionalPatternValues)
      }
    }
  }
}

#Preview {
  let patternGroup = PatternGroup(patternValues: [])
  let additionalPatternValues: [PatternValue] = [
    .dayPattern(DayPattern(type: .day))
  ]

  Form {
    PatternView(
      label: "Some pattern", patternGroup: .constant(patternGroup),
      additionalPatternValues: additionalPatternValues)
  }
}
