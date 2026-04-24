import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var videos: [MediaItem] = []
    @Published var music: [MediaItem] = []
    @Published var recentlyAdded: [MediaItem] = []
    @Published var searchText: String = ""
    @Published var filteredMedia: [MediaItem] = []
    @Published var featuredMedia: MediaItem?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    private let mediaService = MediaService.shared
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let fetchedVideos = networkService.fetchVideos()
            async let fetchedMusic = networkService.fetchMusic()
            
            let v = try await fetchedVideos
            let m = try await fetchedMusic
            
            self.videos = v
            self.music = m
            
            // Combine and find featured (prioritize "Sajni")
            let all = v + m
            self.featuredMedia = all.first(where: { $0.title.contains("Sajni") }) ?? v.first
            
            self.recentlyAdded = Array(all.prefix(5)) // Simple mock for recently added
            
        } catch {
            self.errorMessage = "Failed to load media: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func searchMedia() {
        if searchText.isEmpty {
            filteredMedia = []
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
