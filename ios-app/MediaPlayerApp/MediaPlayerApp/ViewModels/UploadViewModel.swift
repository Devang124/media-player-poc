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
    
    var isFormValid: Bool {
        !title.isEmpty && selectedFileURL != nil && selectedThumbnailURL != nil
    }
    
    var fileName: String {
        selectedFileURL?.lastPathComponent ?? "No file selected"
    }
    
    var fileSizeString: String {
        guard let url = selectedFileURL,
              let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? Int64 else {
            return ""
        }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    func upload() async {
        guard isFormValid else {
            errorMessage = "Please enter a title, select a file, and choose a thumbnail image."
            return
        }
        
        isUploading = true
        errorMessage = nil
        
        do {
            try await NetworkService.shared.uploadMedia(
                type: mediaType,
                title: title,
                fileURL: selectedFileURL!,
                thumbnailURL: selectedThumbnailURL!
            )
            showSuccessAlert = true
            resetForm()
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
        }
        
        isUploading = false
    }
    
    func resetForm() {
        title = ""
        selectedFileURL = nil
        selectedThumbnailURL = nil
    }
}
