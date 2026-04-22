import SwiftUI
import AVKit

struct PlayerView: View {
    let mediaItem: MediaItem
    @StateObject private var playerManager = CustomPlayer()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea() // Premium Deep Black
            
            VStack {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                    Text(mediaItem.type == .video ? "Now Playing" : "Now Playing")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                        .textCase(.uppercase)
                    Spacer()
                    Button(action: { }) {
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
                if mediaItem.type == .video {
                    if let player = playerManager.player {
                        VideoPlayer(player: player)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(24)
                            .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2), radius: 20, y: 10)
                            .padding(24)
                    } else {
                        ProgressView().tint(Color(red: 0.6, green: 0.4, blue: 1.0))
                    }
                } else {
                    AudioVisualizerPlaceholder()
                        .padding(.vertical, 40)
                }
                
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
                    
                    HStack(spacing: 50) {
                        Button(action: { }) {
                            Image(systemName: "backward.fill")
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
                        
                        Button(action: { }) {
                            Image(systemName: "forward.fill")
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

