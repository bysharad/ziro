import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

let supportedVideoExtensions: Set<String> = ["mp4", "mov", "m4v", "mpg", "mpeg", "avi", "wmv", "flv", "webm", "mkv", "heic", "hevc", "gif", "3gp"]

class AnimeVideoLibrary: ObservableObject {
    static let shared = AnimeVideoLibrary(); private init() {}
    @Published var availableVideos: [AnimeVideo] = []
    @Published var currentPlaylist: [URL] = []
    @Published var dashboardVideoIndex: Int = 0

    private let defaultVideos: [AnimeVideo] = [
        AnimeVideo(title: "Rainy Cafe", filename: "rain", category: .ambient), AnimeVideo(title: "Coffee Shop", filename: "coffee_shop", category: .ambient),
        AnimeVideo(title: "Library Study", filename: "library", category: .study), AnimeVideo(title: "Cyberpunk City", filename: "cyberpunk", category: .cyberpunk),
        AnimeVideo(title: "Cherry Blossoms", filename: "cherry_blossoms", category: .nature), AnimeVideo(title: "Studio Apartment", filename: "studio_apartment", category: .living),
        AnimeVideo(title: "Late Night Coding", filename: "coding_night", category: .study), AnimeVideo(title: "Studying Girl", filename: "studying_girl", category: .study)
    ]

    var dashboardVideo: AnimeVideo? {
        guard availableVideos.indices.contains(dashboardVideoIndex) else { return availableVideos.first }
        return availableVideos[dashboardVideoIndex]
    }

    func loadVideos() {
        availableVideos = defaultVideos.filter {
            Bundle.main.url(forResource: $0.filename, withExtension: "mp4") != nil ||
            Bundle.main.url(forResource: $0.filename, withExtension: "gif") != nil
        }
        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            loadUserVideos(from: documents.appendingPathComponent("ziro/Videos"))
        }
    }

    private func loadUserVideos(from directory: URL) {
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        for file in files where supportedVideoExtensions.contains(file.pathExtension.lowercased()) {
            let title = file.deletingPathExtension().lastPathComponent
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
            availableVideos.append(AnimeVideo(title: title, filename: file.lastPathComponent, category: .custom, isUserAdded: true, fileURL: file))
        }
    }

    func addVideo(from url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer { if didStartAccessing { url.stopAccessingSecurityScopedResource() } }
        let destDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ziro/Videos")
        guard FileManager.default.fileExists(atPath: destDir.path) || (try? FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)) != nil else { return }
        let destURL = destDir.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: destURL.path) { return }
        guard (try? FileManager.default.copyItem(at: url, to: destURL)) != nil else { return }
        let title = url.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
        availableVideos.append(AnimeVideo(title: title, filename: url.lastPathComponent, category: .custom, isUserAdded: true, fileURL: destURL))
    }

    func removeVideo(_ video: AnimeVideo) {
        guard video.isUserAdded, let fileURL = video.fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
        availableVideos.removeAll { $0.id == video.id }
    }

    func setDashboardVideo(_ video: AnimeVideo) {
        guard let index = availableVideos.firstIndex(where: { $0.id == video.id }) else { return }
        dashboardVideoIndex = index
    }

    func getVideoURL(for video: AnimeVideo) -> URL? {
        video.fileURL ?? Bundle.main.url(forResource: video.filename, withExtension: "mp4")
    }
}

struct AnimeVideo: Identifiable, Hashable {
    let id = UUID(); let title: String; let filename: String; let category: VideoCategory
    var isUserAdded: Bool = false; var fileURL: URL? = nil
    var url: URL? { fileURL ?? Bundle.main.url(forResource: filename, withExtension: "mp4") }
}

enum VideoCategory: String, CaseIterable {
    case ambient, study, nature, cyberpunk, living, custom
    var displayName: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .ambient: return "cloud.rain.fill"; case .study: return "book.fill"
        case .nature: return "leaf.fill"; case .cyberpunk: return "bolt.fill"
        case .living: return "house.fill"; case .custom: return "folder.fill"
        }
    }
}
