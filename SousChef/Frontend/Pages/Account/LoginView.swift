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
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Log In") {
                logIn()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

            // Conditional navigation for successful login
            NavigationStack {
                // Use a Button, Text, or other UI element to trigger the navigation by setting `isAuthenticated` to true
                Button("Go to Profile Activity") {
                    isAuthenticated = true
                }
                .navigationDestination(isPresented: $isAuthenticated) {
                    profile_activity()
                }
            }

        }
        .padding()
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
