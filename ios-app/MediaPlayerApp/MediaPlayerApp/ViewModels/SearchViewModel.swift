import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [MediaItem] = []
    @Published var isLoading = false
    @Published var selectedFilter: SearchFilter = .all
    @Published var recentSearches: [String] = []
    
    enum SearchFilter: String, CaseIterable {
        case all = "All"
        case music = "Music"
        case video = "Video"
    }
    
    private let mediaService = MediaService.shared
    private var cancellables = Set<AnyCancellable>()
    private let recentSearchesKey = "RecentSearches"
    
    init() {
        loadRecentSearches()
        
        // Debounced search logic
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                if !text.isEmpty {
                    Task { [weak self] in
                        await self?.performSearch(query: text)
                    }
                } else {
                    self?.results = []
                }
            }
            .store(in: &cancellables)
    }
    
    var filteredResults: [MediaItem] {
        switch selectedFilter {
        case .all:
            return results
        case .music:
            return results.filter { $0.type == .music }
        case .video:
            return results.filter { $0.type == .video }
        }
    }
    
    func performSearch(query: String) async {
        guard !query.isEmpty else { return }
        
        isLoading = true
        addToRecentSearches(query)
        
        do {
            self.results = try await mediaService.searchMedia(query: query)
        } catch {
            print("Search failed: \(error)")
            self.results = []
        }
        
        isLoading = false
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    private func addToRecentSearches(_ query: String) {
        var searches = recentSearches
        if let index = searches.firstIndex(of: query) {
            searches.remove(at: index)
        }
        searches.insert(query, at: 0)
        recentSearches = Array(searches.prefix(5))
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
}
