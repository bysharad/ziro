import Foundation
import SwiftData
import UserNotifications
import AppKit

@MainActor
class DataManager {
    static let shared = DataManager(); private init() {}
    func seedSampleData(modelContext: ModelContext) {
        let request = FetchDescriptor<TaskModel>()
        do { guard try modelContext.fetch(request).isEmpty else { return } } catch { return }
        [TaskModel(title: "Review pull request", priority: .urgent, dueDate: Date()), TaskModel(title: "Write documentation", priority: .high), TaskModel(title: "Update dependencies", priority: .medium, tags: ["maintenance"]), TaskModel(title: "Team meeting", priority: .medium, dueDate: Date().addingTimeInterval(3600))].forEach { modelContext.insert($0) }
        [HabitModel(title: "Morning meditation", icon: "moon.fill", color: "purple"), HabitModel(title: "Exercise", icon: "figure.run", color: "green"), HabitModel(title: "Read 30 min", icon: "book.fill", color: "blue"), HabitModel(title: "Hydration", icon: "drop.fill", color: "blue")].forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}

class NotificationManager {
    static let shared = NotificationManager(); private init() {}
    func schedulePomodoroEndNotification(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent(); content.title = "Pomodoro Complete"; content.body = "Time for a break!"; content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "pomodoro-end", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)))
    }
    func cancelPomodoroNotification() { UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["pomodoro-end"]) }
    func requestPermissions() async -> Bool { (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false }
}

@MainActor
class StatisticsManager {
    static let shared = StatisticsManager(); private init() {}
    func updateDailyStatistics(modelContext: ModelContext, focusSeconds: TimeInterval = 0, tasksCompleted: Int = 0, pomodorosCompleted: Int = 0) {
        let today = Calendar.current.startOfDay(for: Date())
        let request = FetchDescriptor<StatisticsModel>(predicate: #Predicate { $0.date == today })
        do {
            let existing = try modelContext.fetch(request); let stats = existing.first ?? StatisticsModel(date: today)
            stats.focusHours += focusSeconds / 3600; stats.tasksCompleted += tasksCompleted; stats.pomodorosCompleted += pomodorosCompleted
            if existing.isEmpty { modelContext.insert(stats) }
        } catch { print("Failed to update statistics: \(error)") }
    }
    func getWeeklyFocusHours(modelContext: ModelContext) -> [DailyStat] {
        let endDate = Date(); let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        let request = FetchDescriptor<StatisticsModel>(predicate: #Predicate { $0.date >= startDate && $0.date <= endDate }, sortBy: [SortDescriptor(\.date)])
        return (try? modelContext.fetch(request).map { DailyStat(date: $0.date, value: $0.focusHours) }) ?? []
    }
}

struct DailyStat: Identifiable { let date: Date; let value: Double; var id: Date { date } }

class ShortcutManager {
    static let shared = ShortcutManager(); private init() {}
    private var registeredShortcuts: [String: () -> Void] = [:]
    func registerShortcut(_ key: String, action: @escaping () -> Void) { registeredShortcuts[key] = action }
    func handleKeyEvent(with characters: String, modifiers: NSEvent.ModifierFlags) -> Bool {
        guard let action = registeredShortcuts[buildKeyString(characters: characters, modifiers: modifiers)] else { return false }; action(); return true
    }
    private func buildKeyString(characters: String, modifiers: NSEvent.ModifierFlags) -> String {
        var key = ""; if modifiers.contains(.command) { key += "⌘" }; if modifiers.contains(.option) { key += "⌥" }; if modifiers.contains(.control) { key += "⌃" }; if modifiers.contains(.shift) { key += "⇧" }; return key + characters.uppercased()
    }
}
