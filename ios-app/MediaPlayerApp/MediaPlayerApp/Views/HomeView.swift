import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        // Greeting Header
                        greetingHeader
                        
                        // Search Bar
                        searchBarSection
                        
                        if viewModel.isLoading && viewModel.videos.isEmpty {
                            loadingPlaceholder
                        } else if viewModel.videos.isEmpty && viewModel.music.isEmpty {
                            emptyStateView
                        } else {
                            // Featured Section
                            if let featured = viewModel.featuredMedia {
                                featuredSection(item: featured)
                            }
                            
                            // Music Section
                            mediaSection(title: "Music", items: viewModel.music, icon: "music.note")
                            
                            // Video Section
                            mediaSection(title: "Videos", items: viewModel.videos, icon: "video.fill")
                            
                            // Recently Added
                            recentlyAddedSection
                        }
                    }
                    .padding(.bottom, 100)
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
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hello 👋")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            
            Text("Discover your media")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search music or videos...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.searchMedia()
                }
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .padding(.horizontal, 24)
    }
    
    private func featuredSection(item: MediaItem) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Featured")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            NavigationLink(destination: PlayerView(mediaItem: item)) {
                ZStack(alignment: .bottomLeading) {
                    if let thumbUrl = item.thumbnailUrl, let url = URL(string: thumbUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Color.gray.opacity(0.2)
                            }
                        }
                    }
                    
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play Now")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.6, green: 0.4, blue: 1.0))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    }
                    .padding(24)
                }
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .padding(.horizontal, 24)
                .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3), radius: 15, x: 0, y: 10)
            }
        }
    }
    
    private func mediaSection(title: String, items: [MediaItem], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button("See All") { }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(items) { item in
                        NavigationLink(destination: PlayerView(mediaItem: item)) {
                            MediaCardView(item: item)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recently Added")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            VStack(spacing: 15) {
                ForEach(viewModel.recentlyAdded) { item in
                    NavigationLink(destination: PlayerView(mediaItem: item)) {
                        HStack(spacing: 15) {
                            if let thumbUrl = item.thumbnailUrl, let url = URL(string: thumbUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(12)
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(item.type.rawValue.capitalized)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var loadingPlaceholder: some View {
        VStack {
            ProgressView()
                .tint(Color(red: 0.6, green: 0.4, blue: 1.0))
                .scaleEffect(1.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("🎵 No Media Available")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
            Text("Pull to refresh to try again")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}
