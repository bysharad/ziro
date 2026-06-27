import SwiftUI

struct MainContentView: View {
    @Binding var selectedItem: SidebarItem
    var body: some View {
        ZStack {
            switch selectedItem {
            case .dashboard: DashboardView(); case .focus: FocusView(); case .tasks: TasksView()
            case .eisenhower: EisenhowerMatrixView(); case .calendar: CalendarViewWrapper(); case .notes: NotesView()
            case .habits: HabitsView(); case .statistics: StatisticsView(); case .videos: VideosView(); case .music: MusicView(); case .settings: SettingsView()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(VisualEffectView().ignoresSafeArea())
    }
}
