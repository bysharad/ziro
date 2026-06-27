import SwiftUI
import AVKit

struct AnimeDisplayView: View {
    @ObservedObject private var library = AnimeVideoLibrary.shared
    @State private var player = AVPlayer()
    @State private var isMuted = true
    @State private var loopObserver: Any?

    private var currentVideo: AnimeVideo? { library.dashboardVideo }

    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .overlay(RadialGradient(colors: [Color.clear, Color.black.opacity(0.1), Color.black.opacity(0.3)], center: .center, startRadius: 0, endRadius: 600))
                .cornerRadius(16).shadow(color: .black.opacity(0.3), radius: 20, y: 10)

            VStack {
                HStack {
                    Spacer()
                    Button(action: { isMuted.toggle(); player.isMuted = isMuted }) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(6)
                            .background(.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help(isMuted ? "Unmute video" : "Mute video")
                    .padding(12)
                }
                Spacer()
            }
        }
        .onAppear { library.loadVideos(); setupVideo() }
        .onDisappear { removeLoopObserver(); player.pause() }
        .onChange(of: library.dashboardVideoIndex) { _, _ in setupVideo() }
    }

    private func setupVideo() {
        guard let url = currentVideo?.url else { return }
        removeLoopObserver()
        let item = AVPlayerItem(asset: AVURLAsset(url: url))
        player.replaceCurrentItem(with: item)
        player.actionAtItemEnd = .none
        player.isMuted = isMuted
        loopObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak player] time in
            guard let player = player, let duration = player.currentItem?.duration, duration.isNumeric else { return }
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds(duration)
            if current >= total - 0.3 {
                player.seek(to: .zero)
            }
        }
        player.play()
    }

    private func removeLoopObserver() {
        if let observer = loopObserver { player.removeTimeObserver(observer); loopObserver = nil }
    }
}
