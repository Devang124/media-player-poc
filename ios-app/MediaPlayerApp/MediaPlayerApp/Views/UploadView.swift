import SwiftUI
import UniformTypeIdentifiers

struct UploadView: View {
    @StateObject private var viewModel = UploadViewModel()
    @State private var isMediaPickerPresented = false
    @State private var selectedMediaURL: URL?
    @State private var showThumbPicker = false
    @State private var animateUpload = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        headerSection
                        
                        // Media Type Selector (Segmented Control style)
                        typeSelector
                        
                        // Input Card
                        VStack(spacing: 20) {
                            // Title Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Media Title")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray)
                                
                                CustomTextField(icon: "pencil", placeholder: "Enter title", text: $viewModel.title)
                                
                                if viewModel.title.isEmpty {
                                    Text("Title is required")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red.opacity(0.8))
                                        .padding(.leading, 4)
                                }
                            }
                            
                            // File Selection Card
                            fileSelectionCard
                            
                            // Thumbnail Selection Card
                            thumbnailSelectionCard
                        }
                        .padding()
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(24)
                        .padding(.horizontal, 24)
                        
                        // Upload Button
                        uploadButton
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Media uploaded successfully")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("Retry") { }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Upload failed. Please try again.")
            }

        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Upload Content")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text("Share your music and videos with the world")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
    }
    
    private var typeSelector: some View {
        HStack(spacing: 0) {
            ForEach([MediaType.video, MediaType.music], id: \.self) { type in
                Button(action: { 
                    withAnimation(.spring()) { viewModel.mediaType = type }
                }) {
                    HStack {
                        Image(systemName: type == .video ? "video.fill" : "music.note")
                        Text(type.rawValue.capitalized)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            if viewModel.mediaType == type {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.3, blue: 0.9)], startPoint: .leading, endPoint: .trailing))
                                    .matchedGeometryEffect(id: "typeTab", in: typeAnimationNamespace)
                            }
                        }
                    )
                    .foregroundColor(viewModel.mediaType == type ? .white : .gray)
                }
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
    
    @Namespace private var typeAnimationNamespace
    
    private var fileSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select \(viewModel.mediaType.rawValue.capitalized) File")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)
            
            Button(action: { isMediaPickerPresented = true }) {
                HStack(spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: viewModel.mediaType == .video ? "video.badge.plus" : "music.note.list")
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                    }
                    
                    if let url = selectedMediaURL {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(url.lastPathComponent)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(viewModel.fileSizeString)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("Choose Media File...")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedMediaURL != nil ? Color.purple.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1))
            }
            .fileImporter(
                isPresented: $isMediaPickerPresented,
                allowedContentTypes: [.movie, .audio],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    selectedMediaURL = urls.first
                    viewModel.selectedFileURL = urls.first
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private var thumbnailSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cover Thumbnail")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)
            
            Button(action: { showThumbPicker = true }) {
                HStack(spacing: 15) {
                    if let thumbURL = viewModel.selectedThumbnailURL, 
                       let data = try? Data(contentsOf: thumbURL),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .clipped()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(viewModel.selectedThumbnailURL != nil ? "Change Thumbnail" : "Choose Thumbnail...")
                        .foregroundColor(viewModel.selectedThumbnailURL != nil ? .white : .gray)
                        .font(.system(size: 14, weight: viewModel.selectedThumbnailURL != nil ? .bold : .regular))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(viewModel.selectedThumbnailURL != nil ? Color.orange.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1))
            }
            .fileImporter(
                isPresented: $showThumbPicker,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    viewModel.selectedThumbnailURL = urls.first
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private var uploadButton: some View {
        Button(action: { 
            Task {
                await viewModel.upload()
            }
        }) {
            ZStack {
                if viewModel.isUploading {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                        Text("Uploading...")
                            .fontWeight(.bold)
                    }
                } else {
                    Text("Start Upload")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.isFormValid && !viewModel.isUploading ?
                LinearGradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.3, blue: 0.9)], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.white)
            .cornerRadius(18)
            .shadow(color: viewModel.isFormValid && !viewModel.isUploading ? Color.purple.opacity(0.4) : Color.clear, radius: 10, x: 0, y: 5)
        }
        .disabled(!viewModel.isFormValid || viewModel.isUploading)
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
