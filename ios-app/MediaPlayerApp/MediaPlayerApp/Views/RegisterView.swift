import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    Text("Create Account")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Join our community today")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        CustomTextField(icon: "person", placeholder: "Full Name", text: $viewModel.name)
                        
                        CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                        
                        CustomSecureField(icon: "lock", placeholder: "Password", text: $viewModel.password)
                        
                        CustomSecureField(icon: "lock.shield", placeholder: "Confirm Password", text: $viewModel.confirmPassword)
                        
                        if let error = viewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                }
                
                PrimaryButton(title: "Register", isLoading: viewModel.isLoading) {
                    Task {
                        await viewModel.register()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}
