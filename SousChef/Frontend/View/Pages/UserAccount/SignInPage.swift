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
                            .padding(.vertical, 100)
                    }

                    Spacer()

                    // Input Fields
                    VStack(spacing: 16) {
                        CustomTextField(label: "Email", placeholder: "Enter your email", text: $viewModel.email)
                        CustomSecureField(label: "Password", placeholder: "Enter your password", text: $viewModel.password)
                        
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

                        // Links Section
                        VStack(spacing: 8) {
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.black)

                                Button(action: viewModel.navigateToSignUp) {
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

                        // Separation Line
                        Divider()
                            .background(Color.gray)
                            .padding(.horizontal, 24)
                    }
                    .padding(.horizontal, 24)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Google Sign-In Button
                    Button(action: viewModel.signInWithGoogle) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.white)
                            Text("Sign in with Google")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
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

// Custom Input Fields
struct CustomTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            TextField(placeholder, text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .foregroundColor(.black)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
        }
    }
}

struct CustomSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            SecureField(placeholder, text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .foregroundColor(.black)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
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
