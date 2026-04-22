import Foundation

struct APIConstants {
    static let baseURL = "http://10.0.61.111:3000/api/media"
    
    struct Endpoints {
        static let musicList = "/music-list"
        static let videoList = "/video-list"
        static let uploadVideo = "/upload-video"
        static let uploadMusic = "/upload-music"
        
        static func deleteMedia(id: String) -> String {
            return "/\(id)"
        }
    }
    
    static func url(for endpoint: String) -> String {
        return baseURL + endpoint
    }
}
