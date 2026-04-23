import Foundation
import SwiftUI
import Combine

@MainActor
class UploadViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var selectedFileURL: URL?
    @Published var selectedThumbnailURL: URL?
    @Published var mediaType: MediaType = .video
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0
    @Published var showSuccessAlert = false
    @Published var errorMessage: String?
    
    func upload() async {
        guard let fileURL = selectedFileURL, let thumbnailURL = selectedThumbnailURL, !title.isEmpty else {
            errorMessage = "Please enter a title, select a file, and choose a thumbnail image."
            return
        }
        
        isUploading = true
        errorMessage = nil
        uploadProgress = 0.5 
        
        do {
            try await NetworkService.shared.uploadMedia(
                type: mediaType,
                title: title,
                fileURL: fileURL,
                thumbnailURL: thumbnailURL
            )
            showSuccessAlert = true
            resetForm()
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
        }
        
        isUploading = false
    }
    
    private func resetForm() {
        title = ""
        selectedFileURL = nil
        selectedThumbnailURL = nil
    }
}
