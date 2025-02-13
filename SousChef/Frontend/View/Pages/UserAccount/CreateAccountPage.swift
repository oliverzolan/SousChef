//
//  CreateAccountView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/8/24.
//

import SwiftUI
import AuthenticationServices


struct CreateAccountView: View {
    @StateObject private var viewModel = CreateAccountViewController()

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    // Header
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.top, 70)

                    // Input Fields
                    VStack(spacing: 16) {
                        CustomTextField(label: "Display Name", placeholder: "Enter your display name", text: $viewModel.displayName)
                        CustomTextField(label: "Email", placeholder: "Enter your email", text: $viewModel.email)
                        CustomTextField(label: "Full Name", placeholder: "Enter your full name", text: $viewModel.fullName)
                        CustomSecureField(label: "Password", placeholder: "Enter your password", text: $viewModel.password)
                    }
                    .padding(.horizontal, 24)

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Sign-Up Button
                    Button(action: viewModel.signUp) {
                        Text("Sign up")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AppColors.primary2))
                    }
                    .padding(.horizontal, 24)

                    // 📌 Separation Line between Sign-Up & Social Login with "Or With"
                    HStack {
                        Divider()
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .background(Color.gray.opacity(0.5))
                        
                        Text("Or With")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Divider()
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .background(Color.gray.opacity(0.5))
                    }
                    .frame(height: 20)
                    .padding(.horizontal, 40)

                    // Social Login Buttons (Apple & Google)
                    VStack(spacing: 10) {
                        SignInWithAppleButton(
                            onRequest: viewModel.handleAppleRequest,
                            onCompletion: viewModel.handleAppleCompletion
                        )
                        .frame(height: 50)
                        .padding(.horizontal, 24)

                        Button(action: viewModel.signUpWithGoogle) {
                            HStack {
                                Image("google-logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Sign in with Google")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear) // ✅ Transparent background
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1) // ✅ Black border
                            )
                        }
                        .padding(.horizontal, 24)
                    }

                    // Login Link
                    NavigationLink(destination: LoginView()) {
                        Text("LOGIN")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.bottom, 40)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// ✅ Preview
struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .environmentObject(UserSession()) // Ensuring UserSession is provided
    }
}
