import SwiftUI
import AVKit

struct PlayerView: View {
    let mediaItem: MediaItem
    @StateObject private var playerManager = CustomPlayer()
    @StateObject private var viewModel = PlayerViewModel()
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    @State private var editedTitle = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea() // Premium Deep Black
            
            VStack {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                    Text("Now Playing")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                        .textCase(.uppercase)
                    Spacer()
                    
                    Menu {
                        if let shareURL = URL(string: "http://10.0.61.110:3000\(mediaItem.fileUrl)") {
                            ShareLink(item: shareURL) {
                                Label("Share Media", systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        Button(action: { 
                            editedTitle = mediaItem.title
                            showEditSheet = true 
                        }) {
                            Label("Edit Title", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: { showDeleteAlert = true }) {
                            Label("Delete Media", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Visual Content / Video
                VStack {
                    ZStack {
                        // Thumbnail Placeholder
                        // Shown for videos until ready, or ALWAYS shown for music
                        if mediaItem.type == .music || !playerManager.isPlaying || playerManager.isLoading {
                            if let urlString = mediaItem.thumbnailUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(16/9, contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                    } else {
                                        AudioVisualizerPlaceholder()
                                    }
                                }
                            } else {
                                AudioVisualizerPlaceholder()
                            }
                        }
                        
                        // Actual Video Player
                        if mediaItem.type == .video {
                            if let player = playerManager.player {
                                VideoPlayer(player: player)
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .opacity(playerManager.isPlaying && !playerManager.isLoading ? 1 : 0)
                            }
                        }
                        
                        // Overlay States
                        if playerManager.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.4)))
                        }
                        
                        if playerManager.showRetry {
                            Button(action: { playerManager.setupPlayer(for: mediaItem.fileUrl) }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.system(size: 40))
                                    Text("Retry Loading")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.6)))
                            }
                        }
                        
                        // Play Button Overlay if not playing
                        if !playerManager.isPlaying && !playerManager.isLoading && !playerManager.showRetry {
                            Button(action: { playerManager.togglePlay() }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                            }
                        }
                    }
                    .shadow(color: Color.purple.opacity(0.4), radius: 12)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                Spacer()
                
                // Controls
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text(mediaItem.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Streaming in segments via AsyncSequence")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                    }
                    
                    // Progress Bar
                    VStack(spacing: 8) {
                        Slider(value: Binding(
                            get: { playerManager.currentTime },
                            set: { newValue in playerManager.seek(to: newValue) }
                        ), in: 0...(playerManager.duration > 0 ? playerManager.duration : 1))
                        .accentColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                        
                        HStack {
                            Text(formatTime(playerManager.currentTime))
                            Spacer()
                            Text(formatTime(playerManager.duration))
                        }
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 32)
                    
                    HStack(spacing: 50) {
                        Button(action: { playerManager.seek(to: max(0, playerManager.currentTime - 15)) }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: { playerManager.togglePlay() }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 0.4, blue: 1.0))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.5), radius: 15, y: 10)
                                
                                Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: { playerManager.seek(to: min(playerManager.duration, playerManager.currentTime + 15)) }) {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            playerManager.setupPlayer(for: mediaItem.fileUrl)
        }
        .onDisappear {
            playerManager.stop()
        }
        .alert("Delete Media", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteMedia(id: mediaItem.id)
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this media?")
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                VStack(spacing: 20) {
                    CustomTextField(icon: "pencil", placeholder: "Enter new title", text: $editedTitle)
                    
                    PrimaryButton(title: "Save Changes", isLoading: false) {
                        // Optional API call for update
                        showEditSheet = false
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea())
                .navigationTitle("Edit Title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { showEditSheet = false }
                    }
                }
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    private func formatTime(_ time: Double) -> String {
        if time.isNaN || time.isInfinite { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AudioVisualizerPlaceholder: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.1))
                .frame(width: 250, height: 250)
            
            Circle()
                .fill(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.15))
                .frame(width: 180, height: 180)
            
            HStack(spacing: 6) {
                ForEach(0..<6) { i in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 1.0)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 12, height: animate ? CGFloat.random(in: 40...160) : 40)
                        .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.1), value: animate)
                }
            }
        }
        .onAppear { animate = true }
    }
}

