import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case uploadFailed(String)
}

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchVideos() async throws -> [MediaItem] {
        guard let url = URL(string: APIConstants.url(for: APIConstants.Endpoints.videoList)) else { throw NetworkError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([MediaItem].self, from: data)
    }
    
    func fetchMusic() async throws -> [MediaItem] {
        guard let url = URL(string: APIConstants.url(for: APIConstants.Endpoints.musicList)) else { throw NetworkError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([MediaItem].self, from: data)
    }
    
    func deleteMedia(id: String) async throws {
        guard let url = URL(string: APIConstants.url(for: APIConstants.Endpoints.deleteMedia(id: id))) else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.noData
        }
    }
    
    func uploadMedia(type: MediaType, title: String, fileURL: URL) async throws {
        let endpoint = type == .video ? APIConstants.Endpoints.uploadVideo : APIConstants.Endpoints.uploadMusic
        guard let url = URL(string: APIConstants.url(for: endpoint)) else { throw NetworkError.invalidURL }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Construct body
        var body = Data()
        
        // Title field (always use "title" as per simplified model)
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n")
        body.append("\(title)\r\n")
        
        // File field
        let fileName = fileURL.lastPathComponent
        let mimeType = type == .video ? "video/mp4" : "audio/mpeg"
        
        let isSecured = fileURL.startAccessingSecurityScopedResource()
        defer { if isSecured { fileURL.stopAccessingSecurityScopedResource() } }
        let fileData = try Data(contentsOf: fileURL)
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown upload error"
            throw NetworkError.uploadFailed(errorMsg)
        }
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
