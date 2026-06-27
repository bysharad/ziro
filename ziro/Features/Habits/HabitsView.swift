import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HabitModel.createdAt, order: .reverse) private var allHabits: [HabitModel]
    @State private var selectedDate = Date()
    @State private var showNewHabit = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Habits").font(.title2).fontWeight(.semibold)
                Spacer()
                Button(action: { showNewHabit = true }) { Label("New Habit", systemImage: "plus").font(.callout) }.buttonStyle(.borderedProminent).controlSize(.small)
            }.padding(.horizontal)
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(allHabits.filter { !$0.isArchived }) { habit in
                        HStack(spacing: 12) {
                            ZStack { RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.15)).frame(width: 40, height: 40); Image(systemName: habit.icon).font(.system(size: 16)).foregroundColor(.blue) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.title).font(.callout).foregroundColor(.primary)
                                HStack(spacing: 8) {
                                    HStack(spacing: 4) { Image(systemName: "flame.fill").font(.system(size: 10)).foregroundColor(.orange); Text("\(habit.currentStreak)").font(.caption2).foregroundColor(.secondary) }
                                    Text("\(habit.completedDates.count) total").font(.caption2).foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            let isCompleted = habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: selectedDate) }
                            Button(action: {
                                if isCompleted { habit.completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: selectedDate) } }
                                else { habit.completedDates.append(Calendar.current.startOfDay(for: selectedDate)) }
                                habit.longestStreak = max(habit.longestStreak, habit.currentStreak)
                            }) { Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle").font(.title3).foregroundColor(isCompleted ? .green : .secondary) }.buttonStyle(.plain)
                        }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color(NSColor.controlBackgroundColor).opacity(0.5))).overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(NSColor.separatorColor).opacity(0.2), lineWidth: 0.5)).padding(.horizontal)
                            .contextMenu { Button("Archive", action: { habit.isArchived = true }); Button("Delete", role: .destructive) { modelContext.delete(habit) } }
                    }
                }
            }
        }.padding(.vertical).frame(maxWidth: .infinity, maxHeight: .infinity).sheet(isPresented: $showNewHabit) { NewHabitView() }
    }
}

struct NewHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var icon = "star.fill"
    let icons = ["star.fill", "moon.fill", "figure.run", "book.fill", "drop.fill", "heart.fill", "flame.fill", "leaf.fill"]

    var body: some View {
        VStack(spacing: 20) {
            Text("New Habit").font(.title2).fontWeight(.semibold)
            TextField("Habit name", text: $title).textFieldStyle(.roundedBorder)
            HStack { Text("Icon"); Spacer(); Picker("", selection: $icon) { ForEach(icons, id: \.self) { i in Image(systemName: i).tag(i) } } }
            HStack(spacing: 16) {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Create") { modelContext.insert(HabitModel(title: title, icon: icon)); dismiss() }.buttonStyle(.borderedProminent).disabled(title.isEmpty)
            }
        }.padding().frame(width: 300, height: 220)
    }
}
