import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @State private var navigateToRegister = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Welcome Back")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Login to continue")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 20) {
                        CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                        
                        CustomSecureField(icon: "lock", placeholder: "Password", text: $viewModel.password)
                        
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
                    
                    PrimaryButton(title: "Login", isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.login()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    Button(action: { navigateToRegister = true }) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            Text("Register")
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    NavigationLink(destination: RegisterView().environmentObject(viewModel), isActive: $navigateToRegister) {
                        EmptyView()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
