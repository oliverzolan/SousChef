//
//  SignInPage.swift
//  SousChef
//
//  Created by Sutter Reynolds on 12/31/24.
//

import SwiftUI

struct SignInPage: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)

            // Username Field
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Sign In Button
            Button(action: {
                // Handle Sign In logic
                print("Signing in with \(username)")
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(username.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(username.isEmpty || password.isEmpty)
            .padding(.horizontal)

        }
        .padding()
    }
}


