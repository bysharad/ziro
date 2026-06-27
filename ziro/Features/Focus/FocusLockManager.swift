import Cocoa
import SwiftUI

final class FocusLockManager: NSObject {
    static let shared = FocusLockManager()
    private var lockWindow: NSWindow?
    private var eventMonitors: [Any] = []
    private var deactivateObserver: NSObjectProtocol?
    private var activateObserver: NSObjectProtocol?
    private var currentTaskName = ""

    var isLocked: Bool { lockWindow != nil }

    func lock(taskName: String) {
        guard lockWindow == nil else { return }
        currentTaskName = taskName

        let screenFrame = NSScreen.screens.map(\.frame).reduce(NSRect.zero) { $0.union($1) }
        let view = NSHostingView(rootView: LockView(taskName: taskName, unlock: { [weak self] in self?.unlock() }))
        let window = NSWindow(contentRect: screenFrame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = view
        window.level = .screenSaver + 1
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.makeFirstResponder(view)
        lockWindow = window

        NSApp.presentationOptions = [.hideDock, .hideMenuBar, .autoHideMenuBar]

        installEventMonitors()
        installActivationObservers()

        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }

    func unlock() {
        eventMonitors.forEach { NSEvent.removeMonitor($0) }
        eventMonitors.removeAll()
        if let obs = deactivateObserver { NotificationCenter.default.removeObserver(obs) }
        if let obs = activateObserver { NotificationCenter.default.removeObserver(obs) }
        deactivateObserver = nil
        activateObserver = nil
        lockWindow?.close()
        lockWindow = nil
        NSApp.presentationOptions = []
        NSApp.activate(ignoringOtherApps: true)
    }

    private func installEventMonitors() {
        let consume: (NSEvent) -> NSEvent? = { _ in nil }

        let keyCodes: Set<UInt16> = [
            53,  // Escape
            48,  // Tab (Cmd+Tab)
            49,  // Space
            4,   // H
            12,  // Q
            3,   // F (Cmd+F, Cmd+F3)
            124, // Right arrow (Cmd+Right for Mission Control)
            123, // Left arrow (Cmd+Left)
            126, // Up arrow
            125, // Down arrow
        ]

        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command), keyCodes.contains(event.keyCode) {
                return nil
            }
            if event.keyCode == 53 {
                return nil
            }
            return event
        }
        if let m = localMonitor { eventMonitors.append(m) }

        let flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            if event.modifierFlags.contains(.command) {
                NSApp.activate(ignoringOtherApps: true)
                self.lockWindow?.makeKeyAndOrderFront(nil)
                self.lockWindow?.orderFrontRegardless()
            }
            return event
        }
        if let m = flagsMonitor { eventMonitors.append(m) }

        let mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { event in
            self.lockWindow?.makeKeyAndOrderFront(nil)
            self.lockWindow?.orderFrontRegardless()
            return event
        }
        if let m = mouseMonitor { eventMonitors.append(m) }
    }

    private func installActivationObservers() {
        deactivateObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willResignActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.lockWindow?.makeKeyAndOrderFront(nil)
            self.lockWindow?.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
        }
        activateObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.lockWindow?.makeKeyAndOrderFront(nil)
            self.lockWindow?.orderFrontRegardless()
        }
    }
}

private struct LockView: View {
    let taskName: String
    let unlock: () -> Void
    @State private var elapsed: TimeInterval = 0
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.92).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 8) {
                        Text("LOCKED IN")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(6)
                            .foregroundColor(.white.opacity(0.3))

                        Text(taskName)
                            .font(.system(size: 40, weight: .thin, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 60)

                    Text(elapsedString)
                        .font(.system(size: 100, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .monospacedDigit()

                    Text("elapsed")
                        .font(.system(size: 11, weight: .light, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.top, 4)

                    Spacer().frame(height: 60)

                    VStack(spacing: 8) {
                        Text("NO ESCAPE · ONLY THE TASK")
                            .font(.system(size: 9, weight: .regular, design: .rounded))
                            .tracking(3)
                            .foregroundColor(.white.opacity(0.15))
                    }

                    Spacer()

                    releaseButton
                        .padding(.bottom, 60)
                }
                .frame(width: geo.size.width)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var releaseButton: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 200, height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 200 * holdProgress, height: 8)
                    .animation(.linear(duration: 0.05), value: holdProgress)
            }

            Text(isHolding ? "Hold \(3 - Int(holdProgress * 3))s more..." : "Hold to release")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .tracking(1)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !isHolding else { return }
                    isHolding = true
                    holdProgress = 0
                    startHoldTimer()
                }
                .onEnded { _ in
                    isHolding = false
                    holdProgress = 0
                    holdTimer?.invalidate()
                }
        )
    }

    @State private var holdTimer: Timer?

    private func startHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            holdProgress += 0.05 / 3.0
            if holdProgress >= 1.0 {
                t.invalidate()
                unlock()
            }
        }
    }

    private func startTimer() {
        elapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1
        }
    }

    private var elapsedString: String {
        let h = Int(elapsed) / 3600
        let m = (Int(elapsed) % 3600) / 60
        let s = Int(elapsed) % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}
