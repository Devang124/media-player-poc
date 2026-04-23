import Foundation

enum MediaType: String, Codable {
    case video
    case music
}

struct MediaItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let fileUrl: String
    let thumbnailUrl: String?
    let type: MediaType
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case fileUrl
        case thumbnailUrl
        case type
    }
}
