import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                .font(.system(size: 20))
                .frame(width: 30)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                .font(.system(size: 20))
                .frame(width: 30)
            
            SecureField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 10)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 1.0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.8 : 1.0)
    }
}
