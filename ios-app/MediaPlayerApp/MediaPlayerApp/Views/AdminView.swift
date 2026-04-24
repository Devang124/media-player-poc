import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

struct AdminView: View {
    @StateObject private var viewModel = UploadViewModel()
    @State private var showFilePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea() // Premium Deep Black
                
                VStack(spacing: 30) {
                    headerSection
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Input
                        AdminTextField(label: "MEDIA TITLE", text: $viewModel.title, placeholder: "e.g. My Awesome Video")
                        
                        // Media Type Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MEDIA TYPE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                            
                            HStack {
                                SelectionButton(title: "Video", isSelected: viewModel.mediaType == .video) {
                                    viewModel.mediaType = .video
                                }
                                SelectionButton(title: "Music", isSelected: viewModel.mediaType == .music) {
                                    viewModel.mediaType = .music
                                }
                            }
                        }
                        
                        // File Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MEDIA FILE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                            
                            Button(action: { showFilePicker = true }) {
                                HStack {
                                    Image(systemName: viewModel.selectedFileURL == nil ? "plus.circle.fill" : "doc.fill")
                                    Text(viewModel.selectedFileURL?.lastPathComponent ?? "Choose Media File")
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            }
                            .fileImporter(
                                isPresented: $showFilePicker,
                                allowedContentTypes: viewModel.mediaType == .video ? [.audiovisualContent, .movie] : [.audio, .mp3],
                                allowsMultipleSelection: false
                            ) { result in
                                switch result {
                                case .success(let urls):
                                    if let selectedFile = urls.first {
                                        viewModel.selectedFileURL = selectedFile
                                    }
                                case .failure(let error):
                                    viewModel.errorMessage = "Failed to select file: \(error.localizedDescription)"
                                }
                            }
                        }

                        // Thumbnail Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("THUMBNAIL IMAGE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                            
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                HStack {
                                    Image(systemName: viewModel.selectedThumbnailURL == nil ? "photo.fill" : "photo.on.rectangle.angled")
                                    Text(viewModel.selectedThumbnailURL?.lastPathComponent ?? "Choose Thumbnail Image")
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            }
                            .onChange(of: selectedPhotoItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        // Save to a temporary file URL to match the current logic
                                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                                        try? data.write(to: tempURL)
                                        DispatchQueue.main.async {
                                            viewModel.selectedThumbnailURL = tempURL
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    
                    Spacer()
                    
                    // Upload Button
                    Button(action: { Task { await viewModel.upload() } }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.isUploading ? Color.gray.opacity(0.5) : Color(red: 0.6, green: 0.4, blue: 1.0))
                                .frame(height: 56)
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(viewModel.isUploading ? 0 : 0.4), radius: 10, y: 5)
                            
                            if viewModel.isUploading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Upload Media")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(viewModel.isUploading)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationBarHidden(true)
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("Your media has been uploaded successfully!")
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("ADMIN PANEL")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                Text("Upload Content")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 32))
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
        }
        .padding(.top, 20)
    }
}

struct AdminTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .foregroundColor(.white)
                .accentColor(Color(red: 0.6, green: 0.4, blue: 1.0))
        }
    }
}

struct SelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color(red: 0.6, green: 0.4, blue: 1.0) : Color.white.opacity(0.05))
                .cornerRadius(12)
                .foregroundColor(isSelected ? .white : .gray)
        }
    }
}

