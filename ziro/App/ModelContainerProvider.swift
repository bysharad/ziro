import SwiftData

struct ModelContainerProvider {
    static let container: ModelContainer = {
        do {
            let schema = Schema([
                TaskModel.self, NoteModel.self, HabitModel.self,
                PomodoroSessionModel.self, AppSettingsModel.self,
                CalendarEventModel.self, StatisticsModel.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
            return try ModelContainer(for: schema, configurations: [config])
        } catch { fatalError("Failed to create ModelContainer: \(error)") }
    }()
}
