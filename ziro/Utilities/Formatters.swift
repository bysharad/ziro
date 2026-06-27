import Foundation
import SwiftUI

struct DateFormatters {
    static let shortDate: DateFormatter = { let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .none; return f }()
    static let shortTime: DateFormatter = { let f = DateFormatter(); f.dateStyle = .none; f.timeStyle = .short; return f }()
    static let fullDate: DateFormatter = { let f = DateFormatter(); f.dateStyle = .full; f.timeStyle = .none; return f }()
    static let monthDay: DateFormatter = { let f = DateFormatter(); f.dateFormat = "MMM d"; return f }()
    static let dayOfWeek: DateFormatter = { let f = DateFormatter(); f.dateFormat = "EEEE"; return f }()
}

struct NumberFormatters {
    static let percent: NumberFormatter = { let f = NumberFormatter(); f.numberStyle = .percent; f.minimumFractionDigits = 0; f.maximumFractionDigits = 1; return f }()
    static let decimal: NumberFormatter = { let f = NumberFormatter(); f.numberStyle = .decimal; f.minimumFractionDigits = 0; f.maximumFractionDigits = 2; return f }()
}

struct DurationFormatter {
    static func format(_ seconds: TimeInterval, style: Style = .short) -> String {
        let hours = Int(seconds) / 3600; let minutes = (Int(seconds) % 3600) / 60; let secs = Int(seconds) % 60
        switch style {
        case .full: return hours > 0 ? String(format: "%dh %dm", hours, minutes) : (minutes > 0 ? String(format: "%dm %ds", minutes, secs) : String(format: "%ds", secs))
        case .short: return hours > 0 ? String(format: "%02d:%02d:%02d", hours, minutes, secs) : String(format: "%02d:%02d", minutes, secs)
        case .compact: return hours > 0 ? String(format: "%dh", hours) : (minutes > 0 ? String(format: "%dm", minutes) : String(format: "%ds", secs))
        }
    }
    enum Style { case full, short, compact }
}

struct FileSizeFormatter {
    static func format(_ bytes: Int64) -> String { ByteCountFormatter().string(fromByteCount: bytes) }
}

extension Color {
    static func from(name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red; case "orange": return .orange; case "yellow": return .yellow; case "green": return .green
        case "blue": return .blue; case "purple": return .purple; case "pink": return .pink; case "teal": return .teal
        case "indigo": return .indigo; case "cyan": return .cyan; case "mint": return .mint; case "white": return .white
        case "black": return .black; case "gray": return .gray; default: return .accentColor
        }
    }
}
