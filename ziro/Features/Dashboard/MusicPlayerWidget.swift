import SwiftUI

let audioSpeedOptions: [(label: String, rate: Float)] = [("0.5x", 0.5), ("0.75x", 0.75), ("1x", 1.0), ("1.25x", 1.25), ("1.5x", 1.5), ("2x", 2.0)]

struct MusicPlayerWidget: View {
    @ObservedObject private var library = AnimeAudioLibrary.shared
    @State private var showSpeedPicker = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: library.isPlaying ? "speaker.wave.2.fill" : "music.note")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(library.currentTrack != nil ? .accentColor : .secondary.opacity(0.6))
                .frame(width: 16)

            if let track = library.currentTrack {
                Text(track.title)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .lineLimit(1)
                    .frame(maxWidth: 90, alignment: .leading)

                Text("\(formatTime(library.currentTime))")
                    .font(.system(.caption2, design: .monospaced, weight: .light))
                    .foregroundColor(.secondary)
                    .monospacedDigit()

                Slider(value: Binding(get: { library.currentTime }, set: { library.seek(to: $0) }), in: 0...max(library.duration, 1))
                    .frame(maxWidth: 80)
                    .accentColor(.secondary)
                    .controlSize(.small)

                Text("\(formatTime(library.duration))")
                    .font(.system(.caption2, design: .monospaced, weight: .light))
                    .foregroundColor(.secondary)
                    .monospacedDigit()

                HStack(spacing: 5) {
                    Button(action: { library.previousTrack() }) { Image(systemName: "backward.fill").font(.system(size: 9)) }.buttonStyle(.plain)
                    Button(action: { library.togglePlayPause() }) {
                        Image(systemName: library.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 14))
                    }.buttonStyle(.plain)
                    Button(action: { library.nextTrack() }) { Image(systemName: "forward.fill").font(.system(size: 9)) }.buttonStyle(.plain)
                }
                .foregroundColor(.primary)

                Button(action: { showSpeedPicker.toggle() }) {
                    Text("\(library.playbackRate, specifier: "%.2f")x")
                        .font(.system(.caption2, design: .monospaced, weight: .light))
                        .foregroundColor(.secondary)
                }.buttonStyle(.plain)
                .popover(isPresented: $showSpeedPicker) {
                    VStack(spacing: 1) {
                        ForEach(audioSpeedOptions, id: \.label) { opt in
                            Button(action: { library.setRate(opt.rate); showSpeedPicker = false }) {
                                Text(opt.label)
                                    .font(.system(.caption2, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(library.playbackRate == opt.rate ? Color.accentColor.opacity(0.15) : Color.clear)
                                    .cornerRadius(3)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(5)
                    .frame(width: 60)
                }
            } else {
                Text(library.tracks.isEmpty ? "No music" : "Tap to play")
                    .font(.system(.caption2, weight: .regular)).foregroundColor(.secondary)
                Spacer()
                if !library.tracks.isEmpty {
                    Button(action: { library.playTrack(at: 0) }) {
                        Image(systemName: "play.fill").font(.system(size: 12))
                    }.buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
                .cornerRadius(6)
        )
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(NSColor.separatorColor).opacity(0.12), lineWidth: 0.5))
    }

    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let m = Int(t) / 60; let s = Int(t) % 60
        return "\(m):\(String(format: "%02d", s))"
    }
}
