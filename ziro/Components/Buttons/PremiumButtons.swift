import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let color: Color; init(color: Color = .accentColor) { self.color = color }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.body, design: .rounded, weight: .medium)).foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 8).fill(color).opacity(configuration.isPressed ? 0.8 : 1.0))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0).animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.body, design: .rounded, weight: .medium)).foregroundColor(.primary)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(NSColor.separatorColor), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0).animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.body, design: .rounded, weight: .medium)).foregroundColor(.accentColor)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor.opacity(0.1)))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0).opacity(configuration.isPressed ? 0.7 : 1.0).animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
