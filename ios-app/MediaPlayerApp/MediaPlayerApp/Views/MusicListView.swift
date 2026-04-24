import SwiftUI

struct MusicListView: View {
    @StateObject private var viewModel = MediaViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.filteredMedia) { item in
                NavigationLink(destination: PlayerView(mediaItem: item)) {
                    HStack(spacing: 12) {
                        if let thumbUrl = item.thumbnailUrl, let url = URL(string: thumbUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                case .failure(_), .empty:
                                    placeholderImage
                                @unknown default:
                                    placeholderImage
                                }
                            }
                        } else {
                            placeholderImage
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(item.type.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Music & Videos")
            .searchable(text: $viewModel.searchText, prompt: "Search media...")
            .onChange(of: viewModel.searchText) { _ in
                viewModel.searchMedia()
            }
            .refreshable {
                await viewModel.loadAllMedia()
            }
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: "music.note")
                    .foregroundColor(.gray)
            )
    }
}

struct MusicListView_Previews: PreviewProvider {
    static var previews: some View {
        MusicListView()
    }
}
