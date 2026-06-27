import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PomodoroSessionModel.startTime, order: .reverse) private var pomodoroSessions: [PomodoroSessionModel]
    @Query(sort: \TaskModel.createdAt, order: .reverse) private var allTasks: [TaskModel]
    @Query(sort: \HabitModel.createdAt, order: .reverse) private var allHabits: [HabitModel]

    var completedPomodoros: Int { pomodoroSessions.filter { $0.completed }.count }
    var completedTasks: Int { allTasks.filter { $0.isCompleted }.count }
    var totalHabits: Int { allHabits.filter { !$0.isArchived }.count }
    var bestStreak: Int { allHabits.map(\.longestStreak).max() ?? 0 }

    var body: some View {
        VStack(spacing: 24) {
            Text("Statistics").font(.title2).fontWeight(.semibold)
            HStack(spacing: 16) {
                StatCard(title: "Completed Tasks", value: "\(completedTasks)", icon: "checkmark.circle.fill", color: .green)
                StatCard(title: "Pomodoros", value: "\(completedPomodoros)", icon: "timer", color: .orange)
                StatCard(title: "Active Habits", value: "\(totalHabits)", icon: "repeat", color: .blue)
                StatCard(title: "Best Streak", value: "\(bestStreak)d", icon: "flame.fill", color: .red)
            }.padding(.horizontal)
            Spacer()
        }.padding().frame(maxWidth: .infinity, maxHeight: .infinity).background(VisualEffectView())
    }
}

struct StatCard: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).font(.title2).foregroundColor(color); Text(value).font(.system(.title3, design: .rounded, weight: .bold)).foregroundColor(.primary); Text(title).font(.caption).foregroundColor(.secondary) }
            .padding().frame(maxWidth: .infinity, alignment: .leading).background(VisualEffectView(material: .popover, blendingMode: .withinWindow)).cornerRadius(12)
    }
}
