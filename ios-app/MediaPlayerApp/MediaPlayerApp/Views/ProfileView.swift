import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.myMedia.isEmpty {
                    ProgressView()
                        .tint(Color(red: 0.6, green: 0.4, blue: 1.0))
                        .scaleEffect(1.5)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            // Header Section
                            ProfileHeaderView(
                                name: viewModel.currentUser?.name ?? "Guest User",
                                email: viewModel.currentUser?.email ?? "guest@example.com"
                            )
                            .padding(.top, 20)
                            
                            // User Info Card
                            VStack(alignment: .leading, spacing: 15) {
                                Text("ACCOUNT DETAILS")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .tracking(2)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                
                                VStack(spacing: 1) {
                                    ProfileMenuItemView(title: "Name", subtitle: viewModel.currentUser?.name, icon: "person.fill")
                                    ProfileMenuItemView(title: "Email", subtitle: viewModel.currentUser?.email, icon: "envelope.fill")
                                }
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 24)
                            
                            // Statistics Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("STATISTICS")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .tracking(2)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                
                                HStack(spacing: 16) {
                                    StatCardView(title: "Music", value: viewModel.musicCount, icon: "music.note")
                                    StatCardView(title: "Videos", value: viewModel.videoCount, icon: "video")
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // My Uploads Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("MY UPLOADS")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .tracking(2)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                
                                if viewModel.myMedia.isEmpty {
                                    VStack(spacing: 10) {
                                        Image(systemName: "tray.and.arrow.up")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.5))
                                        Text("No uploads yet")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .background(Color.white.opacity(0.02))
                                    .cornerRadius(20)
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.myMedia) { item in
                                            UploadRow(item: item)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Logout Button
                            Button(action: { showLogoutAlert = true }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.backward.circle")
                                    Text("Logout")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(16)
                                .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Logout", role: .destructive) {
                    viewModel.logout()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .onAppear {
                Task {
                    await viewModel.fetchMyMedia()
                }
            }
        }
    }
}

struct UploadRow: View {
    let item: MediaItem
    
    var body: some View {
        HStack(spacing: 15) {
            if let thumbUrl = item.thumbnailUrl, let url = URL(string: thumbUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    default:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 50, height: 50)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(item.type.rawValue.capitalized)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            }
            
            Spacer()
            
            Image(systemName: item.type == .video ? "play.circle.fill" : "music.note.list")
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}
