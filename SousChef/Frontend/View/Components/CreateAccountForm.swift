//
//  CreateAccountForm.swift
//  SousChef
//
//  Created by Sutter Reynolds on 12/31/24.
//

import SwiftUI

struct CreateAccountForm: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(spacing: 16) {
            // Name Field
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Confirm Password Field
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Sign Up Button
            Button(action: {
                // Handle Sign Up logic
                print("Creating account for \(name)")
            }) {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty
                            ? Color.gray
                            : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            .padding(.horizontal)
        }
    }
}
