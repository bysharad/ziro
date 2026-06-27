import Foundation
import SwiftUI
import Combine
import AVFoundation

let supportedAudioExtensions: Set<String> = ["mp3", "wav", "aac", "m4a", "flac", "ogg", "wma", "aiff", "mp2", "alac", "caf"]

final class AnimeAudioLibrary: ObservableObject {
    static let shared = AnimeAudioLibrary()
    private init() { loadTracks() }

    @Published var tracks: [AudioTrack] = []
    @Published var currentTrackIndex: Int = 0
    @Published var isPlaying = false
    @Published var playbackRate: Float = 1.0
    @Published var volume: Float = 0.7
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var timeTimer: Timer?
    private var hasLoaded = false

    var currentTrack: AudioTrack? {
        guard tracks.indices.contains(currentTrackIndex) else { return nil }
        return tracks[currentTrackIndex]
    }

    func loadTracks() {
        if !hasLoaded { hasLoaded = true; scanTracksDirectory() }
    }

    func reloadTracks() { scanTracksDirectory() }

    private func scanTracksDirectory() {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dir = documents.appendingPathComponent("ziro/Music")
        guard FileManager.default.fileExists(atPath: dir.path) else { return }
        let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        for file in files where supportedAudioExtensions.contains(file.pathExtension.lowercased()) {
            if tracks.contains(where: { $0.fileURL?.path == file.path }) { continue }
            let title = file.deletingPathExtension().lastPathComponent
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
            tracks.append(AudioTrack(title: title, filename: file.lastPathComponent, fileURL: file))
        }
    }

    func addTrack(from url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer { if didStartAccessing { url.stopAccessingSecurityScopedResource() } }
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let destDir = documents.appendingPathComponent("ziro/Music")
        guard FileManager.default.fileExists(atPath: destDir.path) || (try? FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)) != nil else { return }
        let destURL = destDir.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: destURL.path) { return }
        guard (try? FileManager.default.copyItem(at: url, to: destURL)) != nil else { return }
        let title = url.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
        tracks.append(AudioTrack(title: title, filename: url.lastPathComponent, fileURL: destURL))
    }

    func removeTrack(_ track: AudioTrack) {
        guard let fileURL = track.fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
        if currentTrack?.id == track.id { stopAndReset() }
        tracks.removeAll { $0.id == track.id }
    }

    func playTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        stopAndReset()
        currentTrackIndex = index
        guard let url = tracks[index].fileURL else { return }
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player
            player.delegate = self
            player.volume = volume
            player.enableRate = true
            player.rate = playbackRate
            player.numberOfLoops = 0
            player.prepareToPlay()

            duration = player.duration
            currentTime = 0

            if player.play() {
                isPlaying = true
                startTimeTimer()
            } else {
                print("AVAudioPlayer.play() returned false for \(url.lastPathComponent)")
                isPlaying = false
            }
        } catch {
            print("AVAudioPlayer init failed for \(url.lastPathComponent): \(error)")
            fallbackPlay(url: url)
        }
    }

    private func fallbackPlay(url: URL) {
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        player.volume = volume
        player.actionAtItemEnd = .pause
        fallbackPlayer = player

        NotificationCenter.default.addObserver(
            self, selector: #selector(fallbackDidEnd),
            name: .AVPlayerItemDidPlayToEndTime, object: item
        )

        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            if let dur = self.fallbackPlayer?.currentItem?.duration, dur.isNumeric {
                self.duration = CMTimeGetSeconds(dur)
            }
        }

        player.play()
        player.rate = playbackRate
        isPlaying = true
    }

    private var fallbackPlayer: AVPlayer?

    @objc private func fallbackDidEnd() { nextTrack() }

    func togglePlayPause() {
        if let player = audioPlayer {
            if isPlaying {
                player.pause()
                isPlaying = false
                stopTimeTimer()
            } else {
                player.rate = playbackRate
                if player.play() {
                    isPlaying = true
                    startTimeTimer()
                }
            }
        } else if let player = fallbackPlayer {
            if isPlaying {
                player.pause()
                isPlaying = false
            } else {
                player.rate = playbackRate
                player.play()
                isPlaying = true
            }
        } else if !tracks.isEmpty {
            playTrack(at: 0)
        }
    }

    func nextTrack() {
        guard !tracks.isEmpty else { return }
        playTrack(at: (currentTrackIndex + 1) % tracks.count)
    }

    func previousTrack() {
        guard !tracks.isEmpty else { return }
        playTrack(at: (currentTrackIndex - 1 + tracks.count) % tracks.count)
    }

    func setRate(_ rate: Float) {
        playbackRate = rate
        if let player = audioPlayer, isPlaying {
            player.rate = rate
        } else if let player = fallbackPlayer, isPlaying {
            player.rate = rate
        }
    }

    func setVolume(_ vol: Float) {
        volume = vol
        audioPlayer?.volume = vol
        fallbackPlayer?.volume = vol
    }

    func seek(to time: TimeInterval) {
        if let player = audioPlayer {
            player.currentTime = time
            currentTime = time
        } else if let player = fallbackPlayer {
            player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
            currentTime = time
        }
    }

    private func startTimeTimer() {
        stopTimeTimer()
        timeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, player.isPlaying else { return }
            self.currentTime = player.currentTime
        }
    }

    private func stopTimeTimer() {
        timeTimer?.invalidate()
        timeTimer = nil
    }

    private func stopAndReset() {
        audioPlayer?.stop()
        audioPlayer = nil
        fallbackPlayer?.pause()
        fallbackPlayer = nil
        stopTimeTimer()
        isPlaying = false
        currentTime = 0
        duration = 0
    }
}

extension AnimeAudioLibrary: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { nextTrack() }
    }
}

struct AudioTrack: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let filename: String
    var fileURL: URL? = nil
}
