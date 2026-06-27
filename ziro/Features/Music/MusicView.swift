import SwiftUI
import AVKit
import UniformTypeIdentifiers

let audioFileTypes: [UTType] = [
    .mp3, .wav, .aiff,
    UTType(filenameExtension: "aac") ?? .audio,
    UTType(filenameExtension: "m4a") ?? .audio,
    UTType(filenameExtension: "flac") ?? .audio,
    UTType(filenameExtension: "ogg") ?? .audio,
    UTType(filenameExtension: "wma") ?? .audio,
]

let musicSpeedOptions: [(label: String, rate: Float)] = [("0.5x", 0.5), ("0.75x", 0.75), ("1x", 1.0), ("1.25x", 1.25), ("1.5x", 1.5), ("2x", 2.0)]

struct MusicView: View {
    @ObservedObject private var library = AnimeAudioLibrary.shared
    @State private var showingFilePicker = false

    var body: some View {
        HSplitView {
            trackList
            trackPlayer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectView().ignoresSafeArea())
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: audioFileTypes, allowsMultipleSelection: true) { result in
            guard case .success(let urls) = result else { return }
            for url in urls { library.addTrack(from: url) }
        }
        .onAppear { library.loadTracks() }
    }

    private var trackList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tracks")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .tracking(0.5)
                Spacer()
                Button(action: { showingFilePicker = true }) {
                    Image(systemName: "plus").font(.system(size: 11, weight: .regular))
                }
                .buttonStyle(.plain)
                .help("Import audio from Mac")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Rectangle().fill(Color(NSColor.separatorColor).opacity(0.15)).frame(height: 1)

            if library.tracks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list").font(.system(size: 28)).foregroundColor(.secondary.opacity(0.5))
                    Text("No music found").font(.system(.caption, weight: .regular)).foregroundColor(.secondary)
                    Text("Click + to import MP3s from your Mac").font(.system(.caption2, weight: .light)).foregroundColor(.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(library.tracks.enumerated()), id: \.element.id) { index, track in
                    TrackRow(track: track, isCurrent: library.currentTrack?.id == track.id, isPlaying: library.isPlaying)
                        .onTapGesture { library.playTrack(at: index) }
                        .contextMenu {
                            Button(role: .destructive) {
                                if library.currentTrack?.id == track.id { library.togglePlayPause() }
                                library.removeTrack(track)
                            } label: { Label("Delete from Library", systemImage: "trash") }
                        }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        .frame(minWidth: 220)
        .background(VisualEffectView())
    }

    private var trackPlayer: some View {
        Group {
            if let track = library.currentTrack {
                MusicPlayerDetailView(track: track)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "music.note").font(.system(size: 36)).foregroundColor(.secondary.opacity(0.4))
                    Text("Select a track to play")
                        .font(.system(.caption, weight: .regular)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct TrackRow: View {
    let track: AudioTrack
    let isCurrent: Bool
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isCurrent && isPlaying ? "speaker.wave.2.fill" : "music.note")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(isCurrent ? .accentColor : .secondary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(track.title).font(.system(.caption, design: .rounded, weight: .regular)).lineLimit(1)
                Text(track.filename).font(.system(.caption2, weight: .light)).foregroundColor(.secondary).lineLimit(1)
            }
            Spacer()
            if isCurrent {
                Image(systemName: isPlaying ? "play.fill" : "pause.fill").font(.system(size: 8)).foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(isCurrent ? Color.accentColor.opacity(0.08) : Color.clear)
        .cornerRadius(4)
    }
}

struct MusicPlayerDetailView: View {
    let track: AudioTrack
    @ObservedObject private var library = AnimeAudioLibrary.shared
    @State private var showSpeedPicker = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "music.note.house.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text(track.title)
                .font(.system(.title2, design: .rounded, weight: .regular))
                .padding(.top, 16)

            Text(track.filename)
                .font(.system(.caption, weight: .light)).foregroundColor(.secondary)

            Spacer()

            VStack(spacing: 6) {
                Slider(value: Binding(get: { library.currentTime }, set: { library.seek(to: $0) }), in: 0...max(library.duration, 1))
                    .accentColor(.secondary)
                    .controlSize(.small)

                HStack {
                    Text(formatTime(library.currentTime)).font(.system(.caption2, design: .monospaced, weight: .light)).foregroundColor(.secondary).monospacedDigit()
                    Spacer()
                    Text(formatTime(library.duration)).font(.system(.caption2, design: .monospaced, weight: .light)).foregroundColor(.secondary).monospacedDigit()
                }
            }
            .padding(.horizontal, 32)

            HStack(spacing: 16) {
                Button(action: { library.previousTrack() }) { Image(systemName: "backward.fill").font(.system(size: 13)) }.buttonStyle(.plain)
                Button(action: { library.togglePlayPause() }) {
                    Image(systemName: library.isPlaying ? "pause.circle.fill" : "play.circle.fill").font(.system(size: 32))
                }.buttonStyle(.plain)
                Button(action: { library.nextTrack() }) { Image(systemName: "forward.fill").font(.system(size: 13)) }.buttonStyle(.plain)
            }
            .padding(.vertical, 14)

            HStack(spacing: 10) {
                if showSpeedPicker {
                    ForEach(musicSpeedOptions, id: \.label) { opt in
                        Button(action: { library.setRate(opt.rate) }) {
                            Text(opt.label)
                                .font(.system(.caption2, design: .monospaced, weight: library.playbackRate == opt.rate ? .semibold : .regular))
                                .foregroundColor(library.playbackRate == opt.rate ? .white : .secondary)
                                .padding(.horizontal, 6).padding(.vertical, 3)
                                .background(library.playbackRate == opt.rate ? Color.accentColor : Color(NSColor.separatorColor).opacity(0.15))
                                .cornerRadius(3)
                        }.buttonStyle(.plain)
                    }
                } else {
                    Button(action: { showSpeedPicker = true }) {
                        Text("Speed: \(library.playbackRate, specifier: "%.2f")x")
                            .font(.system(.caption2, design: .monospaced, weight: .light))
                            .foregroundColor(.secondary)
                    }.buttonStyle(.plain)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "speaker.fill").font(.system(size: 9)).foregroundColor(.secondary)
                    Slider(value: Binding(get: { library.volume }, set: { library.setVolume($0) }), in: 0...1).frame(width: 70).controlSize(.small)
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let m = Int(t) / 60; let s = Int(t) % 60
        return "\(m):\(String(format: "%02d", s))"
    }
}
