import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct EisenhowerMatrixView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskModel.dueDate, order: .forward) private var allTasks: [TaskModel]
    let quadrants: [QuadrantInfo] = [QuadrantInfo(title: "Do", subtitle: "Urgent & Important", color: .red), QuadrantInfo(title: "Schedule", subtitle: "Not Urgent & Important", color: .orange), QuadrantInfo(title: "Delegate", subtitle: "Urgent & Not Important", color: .yellow), QuadrantInfo(title: "Eliminate", subtitle: "Not Urgent & Not Important", color: .blue)]

    var body: some View {
        VStack(spacing: 16) {
            HStack { Text("Eisenhower Matrix").font(.title2).fontWeight(.semibold); Spacer(); Text("\(allTasks.filter { !$0.isCompleted }.count) active tasks").font(.caption).foregroundColor(.secondary) }
            HStack(spacing: 16) { ForEach(Array(quadrants.enumerated()), id: \.offset) { index, quadrant in QuadrantView(quadrant: quadrant, tasks: allTasks.filter { !$0.isCompleted && eisenhowerQuadrant(for: $0) == index }) } }
        }.padding().frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func eisenhowerQuadrant(for task: TaskModel) -> Int {
        let urgent = task.dueDate.map { Calendar.current.isDateInToday($0) || $0 < Date() } ?? false
        switch (urgent, task.priority == .high || task.priority == .urgent) {
        case (true, true): return 0; case (false, true): return 1; case (true, false): return 2; case (false, false): return 3
        }
    }
}

struct QuadrantInfo { let title: String; let subtitle: String; let color: Color }

struct QuadrantView: View {
    let quadrant: QuadrantInfo; let tasks: [TaskModel]; @State private var isHovered = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) { Text(quadrant.title).font(.system(.headline, design: .rounded, weight: .semibold)).foregroundColor(quadrant.color); Text(quadrant.subtitle).font(.caption).foregroundColor(.secondary).lineLimit(2) }.padding(.bottom, 8)
            ScrollView { LazyVStack(spacing: 6) { ForEach(tasks) { task in HStack(spacing: 8) { Circle().fill(task.priority.color).frame(width: 8, height: 8); Text(task.title).font(.caption).foregroundColor(.primary).lineLimit(1); Spacer() }.padding(.horizontal, 8).padding(.vertical, 6).background(RoundedRectangle(cornerRadius: 6).fill(Color(NSColor.controlBackgroundColor))).overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(task.priority.color.opacity(0.3), lineWidth: 0.5)).contextMenu { Button("Mark Complete") { task.isCompleted.toggle() }; Button("Delete", role: .destructive) { let mc = task.modelContext; mc?.delete(task) } } } }.padding(.vertical, 4) }
            if tasks.isEmpty && isHovered { Text("Drop tasks here").font(.caption2).foregroundColor(.secondary).frame(maxWidth: .infinity, minHeight: 60).background(VisualEffectView(material: .popover, blendingMode: .withinWindow)).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(quadrant.color.opacity(0.3), lineWidth: 1)) }
        }.padding(12).background(VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(quadrant.color.opacity(isHovered ? 0.4 : 0.15), lineWidth: 1)).onHover { hovering in withAnimation(.easeInOut(duration: 0.2)) { isHovered = hovering } }
    }
}
