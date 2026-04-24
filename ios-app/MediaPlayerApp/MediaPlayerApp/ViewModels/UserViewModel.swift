import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var users: [User] = []
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var myMedia: [MediaItem] = []
    
    private let userService = UserService.shared
    private let networkService = NetworkService.shared
    
    var musicCount: Int {
        myMedia.filter { $0.type == .music }.count
    }
    
    var videoCount: Int {
        myMedia.filter { $0.type == .video }.count
    }
    
    func register() async {
        guard validateRegister() else { return }
        
        isLoading = true
        errorMessage = nil
        do {
            let user = try await userService.registerUser(name: name, email: email, password: password)
            self.currentUser = user
            self.isLoggedIn = true
            clearFields()
        } catch {
            self.errorMessage = "Registration failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func login() async {
        guard validateLogin() else { return }
        
        isLoading = true
        errorMessage = nil
        do {
            let user = try await userService.loginUser(email: email, password: password)
            self.currentUser = user
            self.isLoggedIn = true
            clearFields()
        } catch {
            self.errorMessage = "Login failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func fetchMyMedia() async {
        isLoading = true
        do {
            async let videos = networkService.fetchVideos()
            async let music = networkService.fetchMusic()
            self.myMedia = try await (videos + music)
        } catch {
            self.errorMessage = "Failed to fetch uploads: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func fetchUsers() async {
        do {
            self.users = try await userService.fetchUsers()
        } catch {
            print("Failed to fetch users: \(error)")
        }
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
        myMedia = []
        clearFields()
    }
    
    private func validateLogin() -> Bool {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Email and password are required"
            return false
        }
        return true
    }
    
    private func validateRegister() -> Bool {
        if name.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "All fields are required"
            return false
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        return true
    }
    
    private func clearFields() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
}
