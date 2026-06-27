import Foundation
import SwiftData
import SwiftUI

@Model
final class TaskModel: Identifiable {
    var title: String; var details: String?; var isCompleted: Bool; var priority: TaskPriority
    var dueDate: Date?; var createdAt: Date; var updatedAt: Date; var tags: [String]; var isRecurring: Bool; var recurringPattern: String?
    init(title: String, details: String? = nil, isCompleted: Bool = false, priority: TaskPriority = .medium, dueDate: Date? = nil, tags: [String] = [], isRecurring: Bool = false, recurringPattern: String? = nil) {
        self.title = title; self.details = details; self.isCompleted = isCompleted; self.priority = priority; self.dueDate = dueDate
        self.createdAt = Date(); self.updatedAt = Date(); self.tags = tags; self.isRecurring = isRecurring; self.recurringPattern = recurringPattern
    }
}

enum TaskPriority: Int, CaseIterable, Codable {
    case low = 0, medium = 1, high = 2, urgent = 3
    var color: Color { switch self { case .low: return .blue; case .medium: return .orange; case .high: return .red.opacity(0.8); case .urgent: return .red } }
    var name: String { ["Low", "Medium", "High", "Urgent"][rawValue] }
}

@Model final class NoteModel: Identifiable {
    var title: String; var content: String; var isPinned: Bool; var createdAt: Date; var updatedAt: Date; var folder: String?; var tags: [String]
    init(title: String = "New Note", content: String = "", isPinned: Bool = false, folder: String? = nil, tags: [String] = []) { self.title = title; self.content = content; self.isPinned = isPinned; self.createdAt = Date(); self.updatedAt = Date(); self.folder = folder; self.tags = tags }
}

@Model final class HabitModel: Identifiable {
    var title: String; var icon: String; var color: String; var completedDates: [Date]; var currentStreak: Int; var longestStreak: Int; var createdAt: Date; var weeklyGoal: Int; var isArchived: Bool
    init(title: String = "New Habit", icon: String = "star.fill", color: String = "blue", completedDates: [Date] = [], weeklyGoal: Int = 7) {
        self.title = title; self.icon = icon; self.color = color; self.completedDates = completedDates; self.currentStreak = 0; self.longestStreak = 0; self.createdAt = Date(); self.weeklyGoal = weeklyGoal; self.isArchived = false
    }
}

@Model final class PomodoroSessionModel: Identifiable {
    var startTime: Date; var endTime: Date?; var type: PomodoroSessionType; var completed: Bool
    init(startTime: Date = Date(), endTime: Date? = nil, type: PomodoroSessionType = .work, completed: Bool = false) { self.startTime = startTime; self.endTime = endTime; self.type = type; self.completed = completed }
}
enum PomodoroSessionType: String, CaseIterable, Codable { case work, shortBreak, longBreak }

@Model final class AppSettingsModel: Identifiable {
    var themeMode: ThemeMode; var accentColor: String; var animePlaylist: [String]; var shuffleAnime: Bool; var fadeTransition: Bool
    var ambientSoundsEnabled: Bool; var selectedAmbientSound: String?; var soundVolume: Double; var notificationsEnabled: Bool; var keyboardShortcutsEnabled: Bool; var dataExportDate: Date?
    init() { self.themeMode = .system; self.accentColor = "blue"; self.animePlaylist = ["rain.mp4", "coffee_shop.mp4", "library.mp4"]; self.shuffleAnime = false; self.fadeTransition = true; self.ambientSoundsEnabled = false; self.selectedAmbientSound = nil; self.soundVolume = 0.5; self.notificationsEnabled = true; self.keyboardShortcutsEnabled = true; self.dataExportDate = nil }
}
enum ThemeMode: String, CaseIterable, Codable { case system, light, dark }
