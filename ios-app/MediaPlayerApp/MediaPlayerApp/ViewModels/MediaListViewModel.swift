import Foundation
import Combine

@MainActor
class MediaListViewModel: ObservableObject {
    @Published var videos: [MediaItem] = []
    @Published var music: [MediaItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Run fetch in parallel
            async let fetchedVideos = NetworkService.shared.fetchVideos()
            async let fetchedMusic = NetworkService.shared.fetchMusic()
            
            self.music = try await fetchedMusic
            self.videos = try await fetchedVideos
        } catch {
            self.errorMessage = "Failed to load media: \(error.localizedDescription)"
            
            // For testing purposes if server is not running:
            // loadMockData()
        }
        
        isLoading = false
    }
    
    private func loadMockData() {
        self.videos = [
            // Mock items
        ]
    }
}
