import SwiftUI
import AVKit
import UniformTypeIdentifiers

let videoFileTypes: [UTType] = [
    .mpeg4Movie, .quickTimeMovie, .video, .mpeg,
    UTType(filenameExtension: "avi") ?? .data,
    UTType(filenameExtension: "mkv") ?? .data,
    UTType(filenameExtension: "webm") ?? .data,
    UTType(filenameExtension: "wmv") ?? .data,
    UTType(filenameExtension: "flv") ?? .data,
    UTType(filenameExtension: "3gp") ?? .data,
]

struct VideosView: View {
    @ObservedObject private var library = AnimeVideoLibrary.shared
    @State private var showingFilePicker = false
    @State private var selectedVideo: AnimeVideo?

    var body: some View {
        HSplitView {
            videoList
            videoPreview
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectView().ignoresSafeArea())
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: videoFileTypes, allowsMultipleSelection: true) { result in
            guard case .success(let urls) = result else { return }
            for url in urls { library.addVideo(from: url) }
        }
    }

    private var videoList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Library")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .tracking(0.5)
                Spacer()
                Button(action: { showingFilePicker = true }) {
                    Image(systemName: "plus").font(.system(size: 11, weight: .regular))
                }
                .buttonStyle(.plain)
                .help("Import video from Mac")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Rectangle().fill(Color(NSColor.separatorColor).opacity(0.15)).frame(height: 1)

            if library.availableVideos.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "video.slash").font(.system(size: 28)).foregroundColor(.secondary.opacity(0.5))
                    Text("No videos found").font(.system(.caption, weight: .regular)).foregroundColor(.secondary)
                    Text("Click + to import from your Mac").font(.system(.caption2, weight: .light)).foregroundColor(.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(library.availableVideos.enumerated()), id: \.element.id) { _, video in
                    VideoRow(
                        video: video,
                        isDashboardVideo: library.dashboardVideo?.id == video.id,
                        isSelected: selectedVideo?.id == video.id
                    )
                    .onTapGesture { selectedVideo = video }
                    .contextMenu {
                        if library.dashboardVideo?.id != video.id {
                            Button { library.setDashboardVideo(video) } label: {
                                Label("Set as Dashboard Background", systemImage: "tv")
                            }
                        }
                        if video.isUserAdded {
                            Button(role: .destructive) {
                                library.removeVideo(video)
                                if selectedVideo?.id == video.id { selectedVideo = nil }
                            } label: { Label("Delete from Library", systemImage: "trash") }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        .frame(minWidth: 240)
        .background(VisualEffectView())
    }

    private var videoPreview: some View {
        Group {
            if let video = selectedVideo, let url = video.url {
                VideoPlayerView(videoURL: url, title: video.title)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "video.fill").font(.system(size: 36)).foregroundColor(.secondary.opacity(0.4))
                    Text("Select a video to preview")
                        .font(.system(.caption, weight: .regular)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct VideoRow: View {
    let video: AnimeVideo
    let isDashboardVideo: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: video.category.icon)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.secondary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(video.title).font(.system(.caption, design: .rounded, weight: .regular)).lineLimit(1)
                HStack(spacing: 4) {
                    Text(video.category.displayName).font(.system(.caption2, weight: .light)).foregroundColor(.secondary)
                    if video.isUserAdded { Text("·").font(.caption2).foregroundColor(.secondary) }
                    if video.isUserAdded { Text("Imported").font(.system(.caption2, weight: .light)).foregroundColor(.blue.opacity(0.7)) }
                    if isDashboardVideo { Text("·").font(.caption2).foregroundColor(.secondary) }
                    if isDashboardVideo { Text("Dashboard").font(.system(.caption2, weight: .light)).foregroundColor(.green.opacity(0.7)) }
                }
            }
            Spacer()
            if isDashboardVideo {
                Image(systemName: "tv.fill").font(.system(size: 9)).foregroundColor(.green.opacity(0.7))
            } else if isSelected {
                Image(systemName: "play.fill").font(.system(size: 9)).foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
        .cornerRadius(4)
    }
}

let videoSpeedOptions: [(label: String, rate: Float)] = [("0.25x", 0.25), ("0.5x", 0.5), ("0.75x", 0.75), ("1x", 1.0), ("1.25x", 1.25), ("1.5x", 1.5), ("2x", 2.0), ("3x", 3.0), ("4x", 4.0)]

struct VideoPlayerView: View {
    let videoURL: URL
    let title: String
    @State private var player = AVPlayer()
    @State private var isPlaying = true
    @State private var playbackRate: Float = 1.0
    @State private var showSpeedPicker = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var showVolume = false
    @State private var volume: Float = 1.0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VideoPlayer(player: player)
                    .cornerRadius(10)
                VStack {
                    HStack {
                        Text(title).font(.system(.callout, design: .rounded, weight: .regular)).foregroundColor(.white).padding(12)
                        Spacer()
                        if showSpeedPicker {
                            HStack(spacing: 3) {
                                ForEach(videoSpeedOptions.prefix(7), id: \.label) { opt in
                                    Button(action: { setRate(opt.rate) }) {
                                        Text(opt.label)
                                            .font(.system(.caption2, design: .monospaced, weight: playbackRate == opt.rate ? .semibold : .regular))
                                            .foregroundColor(.white.opacity(playbackRate == opt.rate ? 1 : 0.5))
                                            .padding(.horizontal, 3).padding(.vertical, 1)
                                            .background(playbackRate == opt.rate ? Color.white.opacity(0.2) : Color.clear)
                                            .cornerRadius(2)
                                    }.buttonStyle(.plain)
                                }
                            }
                            .padding(4)
                            .background(.black.opacity(0.35))
                            .cornerRadius(4)
                        }
                    }
                    Spacer()
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(NSColor.separatorColor).opacity(0.2), lineWidth: 0.5))
            .padding(12)

            VStack(spacing: 4) {
                Slider(value: Binding(get: { currentTime }, set: { seek(to: $0) }), in: 0...max(duration, 1))
                    .frame(height: 3)
                    .accentColor(.secondary)
                    .controlSize(.small)

                HStack {
                    Text(formatTime(currentTime)).font(.system(.caption2, design: .monospaced, weight: .light)).foregroundColor(.secondary).monospacedDigit()
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: { seek(to: currentTime - 10) }) { Image(systemName: "gobackward.10").font(.system(size: 11)) }.buttonStyle(.plain)
                        Button(action: { player.seek(to: .zero); player.play() }) { Image(systemName: "backward.end.fill").font(.system(size: 11)) }.buttonStyle(.plain)
                        Button(action: { isPlaying ? player.pause() : player.play(); isPlaying.toggle() }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill").font(.system(size: 22))
                        }.buttonStyle(.plain)
                        Button(action: { player.seek(to: .zero) }) { Image(systemName: "forward.end.fill").font(.system(size: 11)) }.buttonStyle(.plain)
                        Button(action: { seek(to: currentTime + 10) }) { Image(systemName: "goforward.10").font(.system(size: 11)) }.buttonStyle(.plain)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Button(action: { showVolume.toggle() }) {
                            Image(systemName: volume == 0 ? "speaker.slash.fill" : volume < 0.5 ? "speaker.wave.1.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 9)).foregroundColor(.secondary)
                        }.buttonStyle(.plain)
                        if showVolume {
                            Slider(value: $volume, in: 0...1).frame(width: 50).controlSize(.small)
                                .onChange(of: volume) { _, _ in player.volume = volume }
                        }
                        Button(action: { showSpeedPicker.toggle() }) {
                            Text("\(playbackRate, specifier: "%.2f")x").font(.system(.caption2, design: .monospaced)).foregroundColor(showSpeedPicker ? .accentColor : .secondary)
                        }.buttonStyle(.plain)
                    }
                    Text(formatTime(duration)).font(.system(.caption2, design: .monospaced, weight: .light)).foregroundColor(.secondary).monospacedDigit()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .onAppear {
            let item = AVPlayerItem(asset: AVURLAsset(url: videoURL))
            player.replaceCurrentItem(with: item)
            player.actionAtItemEnd = .none
            player.isMuted = true
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
                player.seek(to: .zero); player.play()
            }
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main) { time in
                currentTime = CMTimeGetSeconds(time)
                duration = CMTimeGetSeconds(item.duration)
            }
            player.play()
        }
        .onDisappear { player.pause() }
    }

    private func setRate(_ rate: Float) { playbackRate = rate; player.rate = rate }
    private func seek(to time: TimeInterval) { player.seek(to: CMTime(seconds: time, preferredTimescale: 600)) }
    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let m = Int(t) / 60; let s = Int(t) % 60
        return "\(m):\(String(format: "%02d", s))"
    }
}
