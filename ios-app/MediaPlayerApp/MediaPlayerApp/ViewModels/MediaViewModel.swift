import Foundation
import Combine

@MainActor
class MediaViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filteredMedia: [MediaItem] = []
    @Published var allMedia: [MediaItem] = []
    
    private let mediaService = MediaService.shared
    private let networkService = NetworkService.shared
    
    init() {
        // Initial load
        Task {
            await loadAllMedia()
        }
    }
    
    func loadAllMedia() async {
        do {
            async let videos = networkService.fetchVideos()
            async let music = networkService.fetchMusic()
            
            let all = try await (videos + music)
            self.allMedia = all
            self.filteredMedia = all
        } catch {
            print("Error loading media: \(error)")
        }
    }
    
    func searchMedia() {
        if searchText.isEmpty {
            filteredMedia = allMedia
            return
        }
        
        Task {
            do {
                self.filteredMedia = try await mediaService.searchMedia(query: searchText)
            } catch {
                print("Search error: \(error)")
                self.filteredMedia = []
            }
        }
    }
}
