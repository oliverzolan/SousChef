//
//  LoginView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/8/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isAuthenticated: Bool = false // Use to control navigation

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Log In")
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
                    
                    // Log In Button with Gradient Background
                    Button(action: logIn) {
                        Text("LOG IN")
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
                }
            }
            .navigationDestination(isPresented: $isAuthenticated) {
                profile_activity()
            }
        }
    }

    private func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isAuthenticated = true // Navigate to HomeView on successful login
            }
        }
    }
}

struct LoginViewScreen: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDevice("iPhone 12")
    }
}
