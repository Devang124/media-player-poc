import Foundation
import AVFoundation
import Combine
import MediaPlayer

class CustomPlayer: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isLoading = false
    @Published var showRetry = false
    
    private var timeObserver: Any?
    private var statusObserver: AnyCancellable?
    private var loadingTimer: Timer?
    
    func setupPlayer(for urlString: String) {
        isLoading = true
        showRetry = false
        
        // Use Cache Manager to get optimized player
        let player = VideoCacheManager.shared.getPlayer(for: urlString)
        self.player = player
        
        // Start timeout timer (5 seconds)
        startLoadingTimer()
        
        setupObservers(for: player)
        setupTimeObserver()
        setupRemoteTransportControls()
    }
    
    private func setupObservers(for player: AVPlayer) {
        // Observe buffer status
        statusObserver = player.currentItem?.publisher(for: \.status)
            .sink { [weak self] status in
                if status == .readyToPlay {
                    self?.isLoading = false
                    self?.cancelLoadingTimer()
                    self?.duration = player.currentItem?.duration.seconds ?? 0
                } else if status == .failed {
                    self?.isLoading = false
                    self?.showRetry = true
                    self?.cancelLoadingTimer()
                }
            }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.isPlaying = false
            self?.player?.seek(to: .zero)
        }
    }
    
    private func startLoadingTimer() {
        cancelLoadingTimer()
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            if self?.isLoading == true {
                self?.isLoading = false
                self?.showRetry = true
            }
        }
    }
    
    private func cancelLoadingTimer() {
        loadingTimer?.invalidate()
        loadingTimer = nil
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
        statusObserver?.cancel()
        cancelLoadingTimer()
        // We don't nullify player here if we want to keep it cached in VideoCacheManager
        isPlaying = false
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            
            if self.duration == 0 {
                let dur = self.player?.currentItem?.duration.seconds ?? 0
                if !dur.isNaN && dur > 0 {
                    self.duration = dur
                    self.updateNowPlayingInfo()
                }
            }
        }
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if !self.isPlaying {
                self.togglePlay()
                return .success
            }
            return .commandFailed
        }
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            if self.isPlaying {
                self.togglePlay()
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Media Player"
        if duration > 0 {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate ?? 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
