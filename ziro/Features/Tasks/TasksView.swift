import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskModel.createdAt, order: .reverse) private var allTasks: [TaskModel]
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .active
    @State private var showNewTask = false

    var filteredTasks: [TaskModel] {
        let sf = searchText.isEmpty ? allTasks : allTasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) || ($0.details ?? "").localizedCaseInsensitiveContains(searchText) }
        switch selectedFilter {
        case .all: return sf
        case .active: return sf.filter { !$0.isCompleted }
        case .completed: return sf.filter { $0.isCompleted }
        case .today: return sf.filter { Calendar.current.isDateInToday($0.dueDate ?? Date()) }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                searchBar
                Spacer()
                Button(action: { showNewTask = true }) {
                    Label("New Task", systemImage: "plus").font(.callout)
                }.buttonStyle(.borderedProminent).controlSize(.small)
                filterPills
            }
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredTasks) { task in
                        TaskRowView(task: task)
                            .contextMenu {
                                Button(task.isCompleted ? "Mark Incomplete" : "Mark Complete") { task.isCompleted.toggle(); task.updatedAt = Date() }
                                Button("Delete", role: .destructive) { modelContext.delete(task) }
                            }
                    }
                    .onDelete { indexSet in
                        for i in indexSet { modelContext.delete(filteredTasks[i]) }
                    }
                }.padding(.vertical, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showNewTask) { NewTaskView() }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary).font(.system(size: 14))
            TextField("Search tasks...", text: $searchText).textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) { Image(systemName: "xmark.circle.fill").foregroundColor(.secondary) }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(NSColor.controlBackgroundColor)))
        .frame(maxWidth: 300)
    }

    private var filterPills: some View {
        HStack(spacing: 8) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Button(action: { selectedFilter = filter }) {
                    Text(filter.title).font(.caption).fontWeight(.medium)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(selectedFilter == filter ? Color.accentColor : Color(NSColor.controlBackgroundColor)))
                        .foregroundColor(selectedFilter == filter ? .white : .secondary)
                }.buttonStyle(.plain)
            }
        }
    }
}

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var details = ""
    @State private var priority: TaskPriority = .medium
    @State private var dueDate = Date()

    var body: some View {
        VStack(spacing: 20) {
            Text("New Task").font(.title2).fontWeight(.semibold)
            TextField("Task title", text: $title).textFieldStyle(.roundedBorder)
            TextField("Details", text: $details).textFieldStyle(.roundedBorder)
            HStack { Text("Priority"); Spacer(); Picker("", selection: $priority) { ForEach(TaskPriority.allCases, id: \.rawValue) { p in Text(p.name).tag(p) } } }
            HStack { Text("Due"); Spacer(); DatePicker("", selection: $dueDate, displayedComponents: .date) }
            HStack(spacing: 16) {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Add") {
                    modelContext.insert(TaskModel(title: title, details: details.isEmpty ? nil : details, priority: priority, dueDate: dueDate))
                    dismiss()
                }.buttonStyle(.borderedProminent).disabled(title.isEmpty)
            }
        }.padding().frame(width: 380, height: 320)
    }
}

struct TaskRowView: View {
    let task: TaskModel

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { task.isCompleted.toggle(); task.updatedAt = Date() }) {
                ZStack {
                    Circle().stroke(task.isCompleted ? Color.green : Color(NSColor.separatorColor), lineWidth: 2).frame(width: 24, height: 24)
                    if task.isCompleted {
                        Circle().fill(Color.green).frame(width: 20, height: 20).overlay(Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                    }
                }
            }.buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title).font(.callout).foregroundColor(task.isCompleted ? .secondary : .primary).strikethrough(task.isCompleted).lineLimit(2)
                if let d = task.details, !d.isEmpty { Text(d).font(.caption).foregroundColor(.secondary).lineLimit(1) }
                HStack(spacing: 8) {
                    if let due = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar").font(.system(size: 10))
                            Text(formatDate(due)).font(.caption2)
                        }.foregroundColor(due < Date() && !task.isCompleted ? .red : .secondary)
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up").font(.system(size: 8))
                        Text(task.priority.name.prefix(1)).font(.system(size: 10, weight: .bold))
                    }.padding(.horizontal, 6).padding(.vertical, 2).background(task.priority.color.opacity(0.15)).foregroundColor(task.priority.color).cornerRadius(4)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(task.isCompleted ? AnyView(Color(NSColor.controlBackgroundColor).opacity(0.3)) : AnyView(VisualEffectView(material: .popover, blendingMode: .withinWindow)))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(task.priority.color.opacity(0.3), lineWidth: 1))
        .padding(.horizontal)
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMM d"; return f.string(from: date)
    }
}

enum TaskFilter: String, CaseIterable {
    case all = "All"; case active = "Active"; case completed = "Completed"; case today = "Today"
    var title: String { rawValue }
}
