import Foundation

class UserService {
    static let shared = UserService()
    private let baseURL = "http://localhost:3000/api/users"
    
    private init() {}
    
    func registerUser(name: String, email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/register") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["name": name, "email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.noData
        }
        
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func loginUser(email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/login") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.noData
        }
        
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/users") else { throw NetworkError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.noData
        }
        
        return try JSONDecoder().decode([User].self, from: data)
    }
}
