//
//  LoginView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/5/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewController()
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Welcome Back! 👋")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                            .padding(.vertical, 50)
                    }
                    
                    Spacer()
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        CustomTextField(label: "Email", placeholder: "Enter your email", text: $viewModel.email).padding(.horizontal, 24)
                        CustomSecureField(label: "Password", placeholder: "Enter your password", text: $viewModel.password).padding(.horizontal, 24)
                        
                        // Log In Button
                        Button(action: viewModel.logIn) {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(AppColors.primary2)
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        // Navigation to Create Account View
                        VStack(spacing: 8) {
                            NavigationLink(
                                destination: CreateAccountView()
                                    .navigationBarBackButtonHidden(true)
                            ) {
                                HStack {
                                    Text("Don't have an account?")
                                        .foregroundColor(.black)

                                    Text("Sign up")
                                        .foregroundColor(.blue)
                                        .fontWeight(.bold)
                                }
                            }

                            Button(action: viewModel.navigateToForgotPassword) {
                                Text("Forgot Password?")
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            }
                        }
                            
                        
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
                        
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Google Sign-In Button
                        Button(action: viewModel.signInWithGoogle) {
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
                                    .stroke(Color.black, lineWidth: 1) // ✅ Black border with 2px thickness
                            )
                        }
                        .padding(.horizontal, 24)
                        // Apple Sign-In Button
                        SignInWithAppleButton(
                            onRequest: viewModel.handleAppleRequest,
                            onCompletion: viewModel.handleAppleCompletion
                        )
                        .frame(height: 50)
                        .padding(.horizontal, 24)
                        
                        // Guest Login Button
                        Button(action: {
                            userSession.loginAsGuest()
                            viewModel.navigateToHome = true
                        }) {
                            Text("Continue as Guest")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 30).fill(.white)
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
                .navigationDestination(isPresented: $viewModel.navigateToHome) {
                    HomePage()
                        .navigationBarBackButtonHidden(true)
                        .environmentObject(userSession)
                }
            }
        }
    }
    
    
    
}

    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .environmentObject(UserSession()) // Ensure it has a UserSession instance
        }
    }

