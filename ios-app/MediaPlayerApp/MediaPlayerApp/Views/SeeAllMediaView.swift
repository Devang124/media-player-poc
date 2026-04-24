import SwiftUI

struct SeeAllMediaView: View {
    let title: String
    let items: [MediaItem]
    
    // Grid layout for 2 columns
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(items) { item in
                        NavigationLink(destination: PlayerView(mediaItem: item)) {
                            MediaGridCard(item: item)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MediaGridCard: View {
    let item: MediaItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                // Background Thumbnail Image
                if let thumbUrl = item.thumbnailUrl, let url = URL(string: thumbUrl) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            placeholderGradient
                        }
                    }
                } else {
                    placeholderGradient
                }
                
                Image(systemName: item.type == .video ? "play.fill" : "music.note")
                    .foregroundColor(.white)
                    .font(.system(size: 32))
                    .shadow(radius: 5)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 180)
            .cornerRadius(16)
            .clipped()
            .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2), radius: 10, y: 5)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(item.type.rawValue.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var placeholderGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.8), Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 180)
    }
}
