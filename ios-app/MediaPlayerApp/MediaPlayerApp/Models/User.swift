import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: String { _id }
    let _id: String
    let name: String
    let email: String
    let password: String? // Optional in case we don't want to store it locally
    
    enum CodingKeys: String, CodingKey {
        case _id
        case name
        case email
        case password
    }
}
