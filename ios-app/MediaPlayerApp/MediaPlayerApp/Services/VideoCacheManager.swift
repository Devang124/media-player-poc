import Foundation
import AVFoundation

class VideoCacheManager {
    static let shared = VideoCacheManager()
    private var cache: [String: AVPlayer] = [:]
    
    private init() {}
    
    func getPlayer(for urlString: String) -> AVPlayer {
        if let cachedPlayer = cache[urlString] {
            return cachedPlayer
        }
        
        guard let url = URL(string: urlString) else {
            return AVPlayer()
        }
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        
        cache[urlString] = player
        return player
    }
    
    func clearCache() {
        cache.removeAll()
    }
}
