import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var mainWindow: NSWindow?
    private var menuTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        setupStatusBar()
        menuTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in self?.updateStatusMenu() }
        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: nil, queue: .main) { [weak self] notif in
            guard let window = notif.object as? NSWindow else { return }
            self?.mainWindow = window
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert([.miniaturizable, .closable, .resizable, .titled])
            let screenFrame = window.screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
            let w = min(1200, screenFrame.width - 40)
            let h = min(800, screenFrame.height - 40)
            window.setFrame(NSRect(x: screenFrame.midX - w/2, y: screenFrame.midY - h/2, width: w, height: h), display: true)
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
    }

    func applicationWillTerminate(_ notification: Notification) { menuTimer?.invalidate() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }
        if let image = NSImage(systemSymbolName: "square.fill.on.circle.fill", accessibilityDescription: "ziro") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "Z"
        }
        button.action = #selector(toggleWindow)
        button.target = self
        updateStatusMenu()
    }

    private func updateStatusMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show ziro", action: #selector(showWindow), keyEquivalent: ""))

        menu.addItem(NSMenuItem.separator())

        let videoLib = AnimeVideoLibrary.shared
        let currentVideo = videoLib.dashboardVideo?.title ?? (videoLib.availableVideos.count > 0 ? "\(videoLib.availableVideos.count) videos" : "No videos")
        let videoItem = NSMenuItem(title: "🎬 \(currentVideo)", action: nil, keyEquivalent: "")
        videoItem.isEnabled = false
        menu.addItem(videoItem)

        let focusItem = NSMenuItem(title: "Start Focus Session", action: #selector(startFocus), keyEquivalent: "f")
        focusItem.keyEquivalentModifierMask = .command
        menu.addItem(focusItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func startFocus() { NotificationCenter.default.post(name: .init("StartFocusSession"), object: nil) }

    @objc func toggleWindow() {
        guard let window = mainWindow else { return }
        if window.isVisible { window.orderOut(nil) } else { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
    }

    @objc func showWindow() {
        guard let window = mainWindow else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
