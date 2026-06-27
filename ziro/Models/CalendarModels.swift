import Foundation
import SwiftData

@Model final class CalendarEventModel: Identifiable {
    var title: String; var startDate: Date; var endDate: Date; var isAllDay: Bool; var location: String?; var notes: String?; var color: String?; var calendarIdentifier: String; var isCompleted: Bool; var reminderOffset: Int?
    init(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false, location: String? = nil, notes: String? = nil, color: String? = nil, calendarIdentifier: String = "") {
        self.title = title; self.startDate = startDate; self.endDate = endDate; self.isAllDay = isAllDay; self.location = location; self.notes = notes; self.color = color; self.calendarIdentifier = calendarIdentifier; self.isCompleted = false
    }
}

@Model final class StatisticsModel: Identifiable {
    var date: Date; var focusHours: Double; var tasksCompleted: Int; var pomodorosCompleted: Int; var habitCompletions: Int
    init(date: Date = Date(), focusHours: Double = 0, tasksCompleted: Int = 0, pomodorosCompleted: Int = 0, habitCompletions: Int = 0) {
        self.date = date; self.focusHours = focusHours; self.tasksCompleted = tasksCompleted; self.pomodorosCompleted = pomodorosCompleted; self.habitCompletions = habitCompletions
    }
}
