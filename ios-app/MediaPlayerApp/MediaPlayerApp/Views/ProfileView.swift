import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    headerSection
                    
                    // User Info Card
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                            .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3), radius: 15, y: 10)
                        
                        Text("Jane Doe")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("jane.doe@example.com")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    
                    Spacer()
                    
                    // Actions
                    VStack(spacing: 16) {
                        Button(action: {
                            // Edit profile action
                        }) {
                            Text("Edit Profile")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0.6, green: 0.4, blue: 1.0))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            // Logout action placeholder
                        }) {
                            Text("Log Out")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("ACCOUNT")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                Text("Profile")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.top, 20)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
