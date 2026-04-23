import Foundation
import AVFoundation
import Combine
import MediaPlayer

class CustomPlayer: ObservableObject {
    private var asset: AVURLAsset?
    private let loaderDelegate = StreamingResourceLoader()
    private let queue = DispatchQueue(label: "com.mediaplayer.loader")
    
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    private var timeObserver: Any?
    
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
        
        setupTimeObserver()
        setupRemoteTransportControls()
        
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
        updateNowPlayingInfo()
    }
    
    func stop() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let item = self.player?.currentItem else { return }
            self.currentTime = time.seconds
            
            if self.duration == 0 {
                let dur = item.duration.seconds
                if !dur.isNaN {
                    self.duration = dur
                    self.updateNowPlayingInfo()
                }
            }
        }
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            if !self.isPlaying {
                self.togglePlay()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.togglePlay()
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "MediaVibe Stream"

        if duration > 0 {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate ?? 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
