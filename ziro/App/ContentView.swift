import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appSettings: [AppSettingsModel]
    @State private var selectedSidebarItem: SidebarItem = .dashboard
    @State private var sidebarWidth: CGFloat = 200
    @State private var rightPanelWidth: CGFloat = 280
    @State private var hasSeededData = false

    var currentTheme: ColorScheme? {
        switch appSettings.first?.themeMode ?? .system {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedItem: $selectedSidebarItem, width: $sidebarWidth)
                .frame(width: sidebarWidth)
                .background(VisualEffectView())
            MainContentView(selectedItem: $selectedSidebarItem)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            RightPanelView()
                .frame(width: rightPanelWidth)
                .background(VisualEffectView())
        }
        .background(Color(NSColor.windowBackgroundColor))
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(currentTheme)
        .onAppear { seedDataIfNeeded() }
    }

    private func seedDataIfNeeded() {
        guard !hasSeededData else { return }
        if appSettings.isEmpty {
            modelContext.insert(AppSettingsModel())
        }
        DataManager.shared.seedSampleData(modelContext: modelContext)
        hasSeededData = true
    }
}

enum SidebarItem: String, CaseIterable {
    case dashboard = "Dashboard"; case focus = "Focus"; case tasks = "Tasks"
    case eisenhower = "Eisenhower"; case calendar = "Calendar"; case notes = "Notes"
    case habits = "Habits"; case statistics = "Statistics"; case videos = "Videos"; case music = "Music"; case settings = "Settings"
    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"; case .focus: return "circle.dotted.circle"
        case .tasks: return "checklist"; case .eisenhower: return "chart.bar"
        case .calendar: return "calendar"; case .notes: return "note.text"
        case .habits: return "repeat"; case .statistics: return "chart.line.uptrend.xyaxis"
        case .videos: return "video.fill"; case .music: return "music.note.list"; case .settings: return "gear"
        }
    }
}
