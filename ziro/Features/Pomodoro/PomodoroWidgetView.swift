import SwiftUI
import AppKit

struct PomodoroWidgetView: View {
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var isRunning = false
    @State private var mode: PomodoroMode = .work
    @State private var timer: Timer?
    @State private var showSettings = false

    @State private var workDuration: TimeInterval = 25 * 60
    @State private var shortBreakDuration: TimeInterval = 5 * 60
    @State private var longBreakDuration: TimeInterval = 15 * 60

    var body: some View {
        HStack(spacing: 30) {
            VStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 56, weight: .thin))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                Text(mode.title)
                    .font(.callout)
                    .foregroundColor(mode.color)
                    .padding(.horizontal, 12).padding(.vertical, 4)
                    .background(mode.color.opacity(0.15))
                    .cornerRadius(6)
            }
            .frame(width: 180)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    controlButton(icon: isRunning ? "pause.fill" : "play.fill", action: toggleTimer)
                    controlButton(icon: "arrow.counterclockwise", action: skipSession)
                    controlButton(icon: "gear", action: { showSettings = true })
                }
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text("Work"); Text(formatTime(workDuration)).monospacedDigit()
                    }.font(.caption2).foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("Break"); Text(formatTime(shortBreakDuration)).monospacedDigit()
                    }.font(.caption2).foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
        .cornerRadius(12)
        .sheet(isPresented: $showSettings) {
            PomodoroSettingsView(
                workMinutes: Binding(get: { Int(workDuration / 60) }, set: { applyWork(minutes: $0) }),
                shortBreakMinutes: Binding(get: { Int(shortBreakDuration / 60) }, set: { applyShortBreak(minutes: $0) }),
                longBreakMinutes: Binding(get: { Int(longBreakDuration / 60) }, set: { applyLongBreak(minutes: $0) })
            )
        }
        .onDisappear { timer?.invalidate() }
    }

    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 36, height: 36)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
        }.buttonStyle(.plain)
    }

    private var timeString: String {
        let m = Int(timeRemaining) / 60
        let s = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        String(format: "%d:%02d", Int(interval) / 60, Int(interval) % 60)
    }

    private func toggleTimer() {
        isRunning.toggle()
        isRunning ? startTimer() : stopTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 { timeRemaining -= 1 } else { completeSession() }
        }
    }

    private func stopTimer() { timer?.invalidate(); timer = nil }

    private func completeSession() {
        stopTimer(); NSSound.beep()
        switch mode {
        case .work:
            mode = .shortBreak; timeRemaining = shortBreakDuration
        case .shortBreak, .longBreak:
            mode = .work; timeRemaining = workDuration
        }
        if mode != .work { isRunning = true; startTimer() }
    }

    private func skipSession() {
        stopTimer()
        switch mode {
        case .work:
            mode = .shortBreak; timeRemaining = shortBreakDuration
        case .shortBreak, .longBreak:
            mode = .work; timeRemaining = workDuration
        }
    }

    private func applyWork(minutes: Int) {
        workDuration = TimeInterval(minutes * 60)
        if !isRunning, mode == .work { timeRemaining = workDuration }
    }

    private func applyShortBreak(minutes: Int) {
        shortBreakDuration = TimeInterval(minutes * 60)
        if !isRunning, mode == .shortBreak { timeRemaining = shortBreakDuration }
    }

    private func applyLongBreak(minutes: Int) {
        longBreakDuration = TimeInterval(minutes * 60)
        if !isRunning, mode == .longBreak { timeRemaining = longBreakDuration }
    }
}

enum PomodoroMode {
    case work, shortBreak, longBreak
    var title: String {
        switch self {
        case .work: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
    var color: Color {
        switch self {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}

struct PomodoroSettingsView: View {
    @Binding var workMinutes: Int
    @Binding var shortBreakMinutes: Int
    @Binding var longBreakMinutes: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Pomodoro Settings").font(.title2).fontWeight(.semibold)
            VStack(spacing: 16) {
                HStack { Text("Work Duration"); Spacer(); Text("\(workMinutes) min").foregroundColor(.secondary) }
                Slider(value: Binding(get: { Double(workMinutes) }, set: { workMinutes = Int($0) }), in: 1...60, step: 1).padding(.horizontal)
                Divider()
                HStack { Text("Short Break"); Spacer(); Text("\(shortBreakMinutes) min").foregroundColor(.secondary) }
                Slider(value: Binding(get: { Double(shortBreakMinutes) }, set: { shortBreakMinutes = Int($0) }), in: 1...30, step: 1).padding(.horizontal)
                Divider()
                HStack { Text("Long Break"); Spacer(); Text("\(longBreakMinutes) min").foregroundColor(.secondary) }
                Slider(value: Binding(get: { Double(longBreakMinutes) }, set: { longBreakMinutes = Int($0) }), in: 5...45, step: 1).padding(.horizontal)
            }.padding()
            Spacer()
            Button("Done") { dismiss() }.buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}
