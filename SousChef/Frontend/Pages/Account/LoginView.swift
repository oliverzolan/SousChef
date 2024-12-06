//
//  UserSession.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/5/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var navigateToHome: Bool = false // State for navigation
    @EnvironmentObject var userSession: UserSession // Access shared session

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Log In")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        .padding(.top, 40)
                    
                    // Login form
                    VStack(spacing: 16) {
                        TextField("", text: $email)
                            .placeholder(when: email.isEmpty) {
                                Text("Email").foregroundColor(Color.white.opacity(0.7))
                            }
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(AppColors.cardColor), alignment: .bottom)
                        
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
                    
                    // Log In Button
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
                    
                    // Guest Login Button
                    Button(action: {
                        userSession.loginAsGuest()
                        navigateToHome = true // Redirect to homepage as guest
                    }) {
                        Text("Continue as Guest")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(AppColors.cardColor)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            // Redirect to homepage_activity
            .navigationDestination(isPresented: $navigateToHome) {
                homepage_activity()
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(userSession)
            }
        }
    }

    private func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let result = result {
                if let token = result.user.refreshToken {
                    KeychainHelper.shared.save(token, for: "authToken")
                    userSession.token = token // Update global session
                    navigateToHome = true // Trigger navigation to homepage
                } else {
                    errorMessage = "Failed to retrieve token. Please try again."
                }
            }
        }
    }
}
