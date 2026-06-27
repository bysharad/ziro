import SwiftUI
import AppKit

struct FocusView: View {
    @State private var focusDuration: TimeInterval = 3600; @State private var timeRemaining: TimeInterval = 3600; @State private var isRunning = false
    @State private var completedFocusSessions = 3; @State private var dailyGoal = 8; @State private var currentFocusTask = "Write Shiro MVP"
    @State private var focusTimer: Timer?

    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 60)
            VStack(spacing: 12) {
                Text("Currently Focusing On").font(.callout).foregroundColor(.secondary)
                Text(currentFocusTask).font(.system(.largeTitle, design: .rounded, weight: .semibold)).foregroundColor(.primary).minimumScaleFactor(0.7)
                ProgressView(value: Double(completedFocusSessions), total: Double(dailyGoal)).progressViewStyle(LinearProgressViewStyle(tint: .accentColor)).frame(width: 200).padding(.top, 8)
            }
            VStack(spacing: 24) {
                Text(timeString).font(.system(size: 120, weight: .thin, design: .rounded)).foregroundColor(isRunning ? .primary : .accentColor).contentTransition(.numericText())
                Text(isRunning ? "Focusing..." : "Ready to focus").font(.title3).foregroundColor(.secondary)
            }
            HStack(spacing: 20) {
                Button(action: toggleFocus) { Label(isRunning ? "Pause" : "Start Focus", systemImage: isRunning ? "pause.circle.fill" : "play.circle.fill").font(.title2).foregroundColor(.white).padding(.horizontal, 40).padding(.vertical, 16).background(isRunning ? Color.orange : Color.accentColor).cornerRadius(30) }.buttonStyle(.plain)
                Button(action: resetFocus) { Image(systemName: "arrow.counterclockwise").font(.title2).foregroundColor(.secondary).frame(width: 56, height: 56).background(VisualEffectView(material: .popover, blendingMode: .withinWindow)).cornerRadius(28) }.buttonStyle(.plain).disabled(!isRunning && timeRemaining == focusDuration)
                Button(action: { FocusLockManager.shared.lock(taskName: currentFocusTask) }) {
                    Image(systemName: "lock.shield.fill").font(.title2).foregroundColor(.white).frame(width: 56, height: 56).background(.black.opacity(0.8)).cornerRadius(28)
                        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                }.buttonStyle(.plain).help("Lock In — block everything")
            }
            Spacer(minLength: 100)
            HStack(spacing: 30) { AmbientToggle(title: "Sound", icon: "speaker.wave.2.fill", isOn: .constant(true)); AmbientToggle(title: "Distraction Free", icon: "eye.slash.fill", isOn: .constant(true)); AmbientToggle(title: "Ambient", icon: "cloud.rain.fill", isOn: .constant(false)) }.padding(.bottom, 40)
        }.padding(.horizontal, 60).frame(maxWidth: .infinity, maxHeight: .infinity).onDisappear { focusTimer?.invalidate() }
    }
    private var timeString: String { let h = Int(timeRemaining) / 3600; let m = (Int(timeRemaining) % 3600) / 60; let s = Int(timeRemaining) % 60; return String(format: "%02d:%02d:%02d", h, m, s) }
    private func toggleFocus() { isRunning.toggle(); if isRunning { startTimer() } else { stopTimer() } }
    private func startTimer() {
        focusTimer?.invalidate()
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            if timeRemaining > 0 { timeRemaining -= 1 } else { completeFocusSession() }
        }
    }
    private func stopTimer() { focusTimer?.invalidate(); focusTimer = nil }
    private func completeFocusSession() { stopTimer(); isRunning = false; completedFocusSessions += 1; NSSound.beep(); timeRemaining = focusDuration }
    private func resetFocus() { stopTimer(); isRunning = false; timeRemaining = focusDuration }
}

struct AmbientToggle: View {
    let title: String; let icon: String; @Binding var isOn: Bool; @State private var isHovered = false
    var body: some View {
        Button(action: { isOn.toggle() }) {
            VStack(spacing: 6) { Image(systemName: icon).font(.system(size: 24)).foregroundColor(isOn ? .accentColor : .secondary); Text(title).font(.caption).foregroundColor(isHovered || isOn ? .primary : .secondary) }
                .frame(width: 80).padding(.vertical, 12).background(RoundedRectangle(cornerRadius: 10).fill(isOn ? Color.accentColor.opacity(0.15) : Color(NSColor.controlBackgroundColor)))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(isOn ? Color.accentColor.opacity(0.4) : Color(NSColor.separatorColor), lineWidth: 1))
        }.buttonStyle(.plain).onHover { hovering in withAnimation(.easeInOut(duration: 0.2)) { isHovered = hovering } }
    }
}
