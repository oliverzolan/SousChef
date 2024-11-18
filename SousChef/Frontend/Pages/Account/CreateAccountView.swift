//
//  CreateAccountView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/8/24.
//

import SwiftUI
import FirebaseAuth

struct CreateAccountView: View {
    @State private var email: String = ""
    @State private var fullName: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = false // Navigation state

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        // Email TextField with AppColors.cardColor underline
                        TextField("", text: $email)
                            .placeholder(when: email.isEmpty) {
                                Text("Email").foregroundColor(Color.white.opacity(0.7))
                            }
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(AppColors.cardColor), alignment: .bottom)
                        
                        // Full Name TextField with AppColors.cardColor underline
                        TextField("", text: $fullName)
                            .placeholder(when: fullName.isEmpty) {
                                Text("Username").foregroundColor(Color.white.opacity(0.7))
                            }
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(AppColors.cardColor), alignment: .bottom)
                        
                        // Password SecureField with AppColors.cardColor underline
                        SecureField("", text: $password)
                            .placeholder(when: password.isEmpty) {
                                Text("Password").foregroundColor(Color.white.opacity(0.7))
                            }
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(AppColors.cardColor), alignment: .bottom)
                    }
                    .padding(.horizontal, 24)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(Color.red)
                            .padding()
                    }
                    
                    // Create Button with Gradient Background
                    Button(action: signUp) {
                        Text("CREATE")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Login Link
                    NavigationLink(destination: LoginView()) {
                        Text("LOGIN")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true // Navigate to LoginView after signup
            }
        }
    }
}

// Custom placeholder view modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct CreateAccount: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
            .previewDevice("iPhone 12")
    }
}

