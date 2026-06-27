import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettingsModel]

    var body: some View {
        VStack(spacing: 28) {
            Text("Settings").font(.title2).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .leading)
            ScrollView {
                VStack(spacing: 20) {
                    GroupBox(label: Label("Appearance", systemImage: "paintpalette").font(.headline)) {
                        VStack(spacing: 12) {
                            HStack { Text("Theme"); Spacer(); Picker("", selection: Binding(get: { settings.first?.themeMode ?? .system }, set: { settings.first?.themeMode = $0 })) { Text("System").tag(ThemeMode.system); Text("Light").tag(ThemeMode.light); Text("Dark").tag(ThemeMode.dark) }.pickerStyle(.segmented).frame(width: 200) }
                        }.padding(.vertical, 8)
                    }
                    GroupBox(label: Label("Notifications", systemImage: "bell.badge.fill").font(.headline)) { VStack(spacing: 12) { Toggle("Enable notifications", isOn: Binding(get: { settings.first?.notificationsEnabled ?? true }, set: { settings.first?.notificationsEnabled = $0 })) }.padding(.vertical, 8) }
                    GroupBox(label: Label("Keyboard Shortcuts", systemImage: "keyboard").font(.headline)) { VStack(spacing: 12) { Toggle("Enable keyboard shortcuts", isOn: Binding(get: { settings.first?.keyboardShortcutsEnabled ?? true }, set: { settings.first?.keyboardShortcutsEnabled = $0 })) }.padding(.vertical, 8) }
                    GroupBox(label: Label("Data", systemImage: "externaldrive.fill").font(.headline)) { VStack(spacing: 12) { Button("Export Data") {}; Button("Import Data") {} }.padding(.vertical, 8) }
                }
            }
        }.padding().frame(maxWidth: .infinity, maxHeight: .infinity).background(VisualEffectView())
    }
}
