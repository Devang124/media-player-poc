import SwiftUI

struct ProfileHeaderView: View {
    let name: String
    let email: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 1.0)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .opacity(0.9)
            }
            .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.4), radius: 12, x: 0, y: 8)
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(email)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: Int
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct ProfileMenuItemView: View {
    let title: String
    let subtitle: String?
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                .font(.system(size: 20))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
}
