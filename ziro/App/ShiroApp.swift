import SwiftUI
import SwiftData

@main
struct ShiroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000, minHeight: 650)
                .modelContainer(ModelContainerProvider.container)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Shiro") { NSApplication.shared.orderFrontStandardAboutPanel(nil) }
            }
            CommandGroup(replacing: .newItem) {
                Button("New Note") { }
                Button("New Task") { }
                Divider()
                Button("New Habit") { }
            }
            CommandMenu("Focus") {
                Button("Start Pomodoro") { }.keyboardShortcut(".", modifiers: .command)
                Button("Start Focus Session") { }
            }
            CommandMenu("View") {
                Button("Toggle Sidebar") { }.keyboardShortcut("s", modifiers: [.command, .option])
                Button("Toggle Right Panel") { }.keyboardShortcut("p", modifiers: [.command, .option])
                Divider()
                Button("Dashboard") { }
                Button("Tasks") { }
                Button("Calendar") { }
                Button("Settings") { }.keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
