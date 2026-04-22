import Foundation
import AVFoundation
import Combine

class CustomPlayer: ObservableObject {
    private var asset: AVURLAsset?
    private let loaderDelegate = StreamingResourceLoader()
    private let queue = DispatchQueue(label: "com.mediaplayer.loader")
    
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    
    func setupPlayer(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Use a custom scheme to trigger the resource loader delegate
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = "streaming" 
        
        guard let streamingURL = components?.url else { return }
        
        let asset = AVURLAsset(url: streamingURL)
        asset.resourceLoader.setDelegate(loaderDelegate, queue: queue)
        
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        self.isPlaying = false
        
        // Add observers for playback state
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
            self.isPlaying = false
            self.player?.seek(to: .zero)
        }
    }
    
    func togglePlay() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
    }
}
