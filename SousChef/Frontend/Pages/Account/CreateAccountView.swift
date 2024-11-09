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
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = false // Navigation state

    var body: some View {
        NavigationView {
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

                Button("Sign Up") {
                    signUp()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                NavigationLink(destination: LoginView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
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
