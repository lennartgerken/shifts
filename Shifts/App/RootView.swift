import SwiftData
import SwiftUI

struct RootView: View {
  let shiftsImportService: ShiftsImportServicing
  let notificationService: NotificationServicing

  var body: some View {
    CalendarView(shiftsImportService: shiftsImportService, notificationService: notificationService)
  }
}

#Preview {
  let textRecognitionService = TextRecognitionService()
  let shiftParsingService = ShiftParsingService()
  let shiftsImportService = ShiftsImportService(
    textRecognitionService: textRecognitionService,
    shiftParsingService: shiftParsingService,
  )
  let notificationService = NotificationService()

  RootView(shiftsImportService: shiftsImportService, notificationService: notificationService)
    .environment(AppSettings())
}
