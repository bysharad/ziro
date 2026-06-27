import SwiftUI

enum AppTheme {
    static let cornerRadiusSmall: CGFloat = 6; static let cornerRadiusMedium: CGFloat = 10; static let cornerRadiusLarge: CGFloat = 16
    static let spacingSmall: CGFloat = 8; static let spacingMedium: CGFloat = 16; static let spacingLarge: CGFloat = 24
}
enum AppTypography {
    static let displayLarge = Font.system(size: 32, weight: .thin, design: .rounded)
    static let titleLarge = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(.body); static let caption = Font.system(.caption)
}
enum AppAnimation { static let quick = Animation.easeInOut(duration: 0.15); static let spring = Animation.spring(response: 0.45, dampingFraction: 0.85) }
extension View {
    func themeCard() -> some View { self.padding(AppTheme.spacingMedium).background(VisualEffectView(material: .popover, blendingMode: .withinWindow)).cornerRadius(AppTheme.cornerRadiusMedium) }
    func themeButton(color: Color = .accentColor) -> some View { self.padding(.horizontal, 20).padding(.vertical, 10).background(color).foregroundColor(.white).cornerRadius(AppTheme.cornerRadiusMedium) }
}
