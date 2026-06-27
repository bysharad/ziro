import Foundation
import SwiftUI
import Combine
import AVFoundation

let supportedAudioExtensions: Set<String> = ["mp3", "wav", "aac", "m4a", "flac", "ogg", "wma", "aiff", "mp2", "alac"]

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

    private let player = AVPlayer()
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var statusObserver: NSKeyValueObservation?
    private var readyToPlay = false

    var currentTrack: AudioTrack? {
        guard tracks.indices.contains(currentTrackIndex) else { return nil }
        return tracks[currentTrackIndex]
    }

    func loadTracks() {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dir = documents.appendingPathComponent("ziro/Music")
        guard FileManager.default.fileExists(atPath: dir.path) else { return }
        let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        for file in files where supportedAudioExtensions.contains(file.pathExtension.lowercased()) {
            if tracks.contains(where: { $0.fileURL == file }) { continue }
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
        if currentTrack?.id == track.id { cleanUp(); resetState() }
        tracks.removeAll { $0.id == track.id }
    }

    func playTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        cleanUp()
        currentTrackIndex = index
        guard let url = tracks[index].fileURL else { return }
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        readyToPlay = false
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
        player.volume = volume
        player.actionAtItemEnd = .pause

        statusObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            guard let self = self else { return }
            switch item.status {
            case .readyToPlay:
                self.readyToPlay = true
                self.player.play()
                self.player.rate = self.playbackRate
                self.isPlaying = true
                if item.duration.isNumeric {
                    self.duration = CMTimeGetSeconds(item.duration)
                }
            case .failed:
                print("AVPlayerItem failed: \(item.error?.localizedDescription ?? "unknown")")
                self.isPlaying = false
            default:
                break
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.nextTrack()
        }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            if let dur = self.player.currentItem?.duration, dur.isNumeric {
                self.duration = CMTimeGetSeconds(dur)
            }
        }

        currentTime = 0
        duration = 0
    }

    func togglePlayPause() {
        if currentTrack != nil {
            if isPlaying {
                player.pause()
                isPlaying = false
            } else if readyToPlay || player.currentItem?.status == .readyToPlay {
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
        if isPlaying { player.rate = rate }
    }

    func setVolume(_ vol: Float) {
        volume = vol
        player.volume = vol
    }

    func seek(to time: TimeInterval) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
        currentTime = time
    }

    private func cleanUp() {
        statusObserver?.invalidate()
        statusObserver = nil
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }
    }

    private func resetState() {
        isPlaying = false
        currentTime = 0
        duration = 0
        readyToPlay = false
    }
}

struct AudioTrack: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let filename: String
    var fileURL: URL? = nil
}
