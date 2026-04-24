import Combine
import Foundation

@MainActor
class PlayerViewModel: ObservableObject {
    @Published var isDeleting = false
    @Published var errorMessage: String?
    @Published var showDeleteSuccess = false
    
    private let networkService = NetworkService.shared
    
    func deleteMedia(id: String) async -> Bool {
        isDeleting = true
        errorMessage = nil
        
        do {
            try await networkService.deleteMedia(id: id)
            isDeleting = false
            showDeleteSuccess = true
            return true
        } catch {
            isDeleting = false
            errorMessage = "Failed to delete: \(error.localizedDescription)"
            return false
        }
    }
}
