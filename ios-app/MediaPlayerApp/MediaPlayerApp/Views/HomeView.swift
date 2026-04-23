import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MediaListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        headerSection
                        
                        mediaSection(title: "Featured Videos", items: viewModel.videos)
                        
                        mediaSection(title: "New Music", items: viewModel.music)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // Padding for tab bar
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.refresh()
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hi, Explorer")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            Text("Discover Media")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.top, 30)
    }
    
    private func mediaSection(title: String, items: [MediaItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button("See All") { }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            }
            
            if items.isEmpty {
                Text("No items found")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(items) { item in
                            NavigationLink(destination: PlayerView(mediaItem: item)) {
                                MediaCard(item: item)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

struct MediaCard: View {
    let item: MediaItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                // Background Thumbnail Image
                if let thumbUrl = item.thumbnailUrl, let url = URL(string: thumbUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 180, height: 240)
                                .clipped()
                                .cornerRadius(24)
                        case .failure(_), .empty:
                            placeholderGradient
                        @unknown default:
                            placeholderGradient
                        }
                    }
                } else {
                    placeholderGradient
                }
                
                Image(systemName: item.type == .video ? "play.fill" : "music.note")
                    .foregroundColor(.white)
                    .font(.system(size: 40))
                    .shadow(radius: 5)
            }
            .cornerRadius(24)
            .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3), radius: 15, y: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(item.type.rawValue.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 180)
    }

    private var placeholderGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.8), Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: 180, height: 240)
    }
}

