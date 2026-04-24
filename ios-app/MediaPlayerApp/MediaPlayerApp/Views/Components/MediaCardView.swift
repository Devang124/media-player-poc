import SwiftUI

struct MediaCardView: View {
    let item: MediaItem
    var width: CGFloat = 160
    var height: CGFloat = 200
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
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
                
                // Type Icon Overlay
                ZStack {
                    Circle()
                        .fill(Color(red: 0.6, green: 0.4, blue: 1.0))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: item.type == .video ? "play.fill" : "music.note")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .padding(8)
            }
            .frame(width: width, height: height)
            .cornerRadius(20)
            .clipped()
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(item.type.rawValue.capitalized)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: width)
    }
    
    private var placeholderGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.6), Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
