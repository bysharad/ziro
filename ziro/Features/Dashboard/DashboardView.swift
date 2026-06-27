import SwiftUI

struct DashboardView: View {
    @State private var currentQuoteIndex = 0
    @State private var audioStarted = false
    let quotes = [
        "Focus on being productive instead of busy.",
        "The only way to do great work is to love what you do.",
        "Simplicity is the ultimate sophistication.",
        "Quality is not an act, it is a habit.",
        "What gets measured gets managed.",
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                TopInfoView(quoteIndex: $currentQuoteIndex, quotes: quotes)
                    .frame(height: 40)
                    .padding(.bottom, 8)

                AnimeDisplayView()
                    .frame(height: geo.size.height * 0.50)

                MusicPlayerWidget()
                    .frame(height: 40)
                    .padding(.vertical, 6)

                PomodoroWidgetView()
                    .frame(maxHeight: geo.size.height * 0.18)
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 8, trailing: 12))
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if !audioStarted, !AnimeAudioLibrary.shared.tracks.isEmpty {
                audioStarted = true
                if !AnimeAudioLibrary.shared.isPlaying {
                    AnimeAudioLibrary.shared.playTrack(at: 0)
                }
            }
        }
    }
}

struct TopInfoView: View {
    @Binding var quoteIndex: Int; let quotes: [String]
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 1) {
                Text(greetingText)
                    .font(.system(.title3, design: .rounded, weight: .regular))
                    .foregroundColor(.primary)
                Text("Ready to be productive?")
                    .font(.system(.caption, weight: .regular))
                    .foregroundColor(.secondary).tracking(0.3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(quotes[quoteIndex])
                .font(.system(.caption, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center).lineLimit(2)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 1), value: quoteIndex)

            HStack(spacing: 12) {
                StatBadge(icon: "flame.fill", value: "12", label: "days", color: .orange)
                Rectangle().fill(Color(NSColor.separatorColor).opacity(0.3)).frame(width: 1, height: 24)
                StatBadge(icon: nil, value: "85", label: "focus", color: .green)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.8)) { quoteIndex = (quoteIndex + 1) % quotes.count }
            }
        }
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h { case 5..<12: return "Good Morning"; case 12..<17: return "Good Afternoon"; case 17..<22: return "Good Evening"; default: return "Good Night" }
    }
}

struct StatBadge: View {
    let icon: String?; let value: String; let label: String; let color: Color
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon).font(.system(size: 10)).foregroundColor(color.opacity(0.8))
            }
            Text(value).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundColor(.primary)
            Text(label).font(.system(.caption2, weight: .light)).foregroundColor(.secondary)
        }
    }
}
