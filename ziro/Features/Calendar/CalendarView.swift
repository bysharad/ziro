import SwiftUI
import SwiftData

struct CalendarViewWrapper: View {
    @State private var selectedDate = Date(); @State private var viewMode: CalendarViewMode = .month

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Calendar").font(.title2).fontWeight(.semibold)
                Spacer()
                HStack(spacing: 16) {
                    Picker("", selection: $viewMode) { ForEach(CalendarViewMode.allCases, id: \.self) { mode in Text(mode.rawValue.capitalized).tag(mode) } }.pickerStyle(.segmented).frame(width: 120)
                    Button(action: { adjustDate(-1) }) { Image(systemName: "chevron.left") }.buttonStyle(.plain)
                    Button(action: { adjustDate(1) }) { Image(systemName: "chevron.right") }.buttonStyle(.plain)
                    Button("Today") { selectedDate = Date() }.font(.callout).foregroundColor(.accentColor)
                }
            }.padding(.horizontal, 20).padding(.vertical, 12)
            Divider()
            ScrollView { MonthView(selectedDate: $selectedDate).padding(.horizontal, 16).padding(.vertical, 8) }
        }.background(VisualEffectView().ignoresSafeArea())
    }

    private func adjustDate(_ offset: Int) {
        switch viewMode {
        case .month: selectedDate = Calendar.current.date(byAdding: .month, value: offset, to: selectedDate) ?? selectedDate
        case .week: selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: selectedDate) ?? selectedDate
        case .day: selectedDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
        }
    }
}

enum CalendarViewMode: String, CaseIterable { case month, week, day }

struct MonthView: View {
    @Binding var selectedDate: Date; let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) { ForEach(weekdays, id: \.self) { day in Text(day).font(.caption2).foregroundColor(.secondary).frame(maxWidth: .infinity) } }
            let days = calendarDays
            ForEach(Array(days.chunked(into: 7)), id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            Button(action: { selectedDate = date }) {
                                ZStack {
                                    if Calendar.current.isDate(date, inSameDayAs: selectedDate) { Circle().fill(Color.accentColor) }
                                    else if Calendar.current.isDateInToday(date) { Circle().stroke(Color.accentColor, lineWidth: 1) }
                                    Text("\(Calendar.current.component(.day, from: date))").font(.system(.body)).foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : Calendar.current.isDateInToday(date) ? .accentColor : .primary)
                                }.frame(maxWidth: .infinity, minHeight: 36)
                            }.buttonStyle(.plain)
                        } else { Color.clear.frame(maxWidth: .infinity, minHeight: 36) }
                    }
                }
            }
        }
    }

    private var calendarDays: [Date?] {
        let calendar = Calendar.current; let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: monthStart)!; let firstWeekday = calendar.component(.weekday, from: monthStart)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range { days.append(calendar.date(byAdding: .day, value: day - 1, to: monthStart)) }
        while days.count % 7 != 0 { days.append(nil) }; return days
    }
}

extension Array { func chunked(into size: Int) -> [[Element]] { stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) } } }
