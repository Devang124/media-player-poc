import Foundation

class MediaService {
    static let shared = MediaService()
    
    private let baseURL = "http://localhost:3000/api/media/search"
    
    func searchMedia(query: String) async throws -> [MediaItem] {
        guard !query.isEmpty else {
            return []
        }
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?query=\(encodedQuery)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([MediaItem].self, from: data)
    }
}
