import SwiftUI

struct ErrorView: View {
  private let error: String

  init(error: String) {
    self.error = error
  }

  var body: some View {
    Label(
      error,
      systemImage: "exclamationmark.triangle.fill"
    )
    .foregroundStyle(.red)
    .bold()
  }
}

#Preview {
  ErrorView(error: "Some error")
}
