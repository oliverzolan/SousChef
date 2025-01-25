//
//  SignInViewModel.swift
//  SousChef
//
//  Created by Sutter Reynolds on 12/31/24.
//

import Foundation
import Combine

class SignInViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false

    func signIn() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password cannot be empty."
            return
        }

        // Simulated authentication (replace with real API logic)
        if username == "test" && password == "1234" {
            isAuthenticated = true
            errorMessage = ""
        } else {
            errorMessage = "Invalid credentials."
            isAuthenticated = false
        }
    }
}
