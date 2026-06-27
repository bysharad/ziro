import SwiftUI
import AppKit

extension Color {
    static let shiroBackground = Color(NSColor.windowBackgroundColor)
    static let shiroSecondary = Color(NSColor.controlBackgroundColor)
    static let shiroSeparator = Color(NSColor.separatorColor)
}

extension View {
    func shiroCard() -> some View { self.padding(16).background(VisualEffectView(material: .popover, blendingMode: .withinWindow)).cornerRadius(12) }
    func shiroBorder() -> some View { self.overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(NSColor.separatorColor).opacity(0.2), lineWidth: 0.5)) }
}

extension EdgeInsets { static let shiroPadding = EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20) }
extension Animation {
    static let shiroSpring = Animation.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0.8)
    static let shiroSmooth = Animation.easeInOut(duration: 0.35)
}
extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }
}
extension String {
    var capitalizedFirstLetter: String { prefix(1).uppercased() + dropFirst() }
    func truncate(to length: Int, trailing: String = "...") -> String { count > length ? prefix(length) + trailing : self }
}
