import SwiftUI
import AppKit

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    init(material: NSVisualEffectView.Material = .underWindowBackground, blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) {
        self.material = material; self.blendingMode = blendingMode
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView(); v.material = material; v.blendingMode = blendingMode; v.state = .active; v.isEmphasized = true; return v
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) { nsView.material = material; nsView.blendingMode = blendingMode }
}
