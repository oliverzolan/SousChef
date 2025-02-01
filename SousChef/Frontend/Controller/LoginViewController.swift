//
//  LoginViewModel.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 2/1/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class LoginViewController: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var navigateToHome: Bool = false
    private var currentNonce: String?

    func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            } else {
                DispatchQueue.main.async {
                    self.navigateToHome = true
                }
            }
        }
    }

    func signInWithGoogle() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            self.errorMessage = "Unable to get root view controller."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            guard let authentication = result?.user,
                  let idToken = authentication.idToken?.tokenString else {
                self.errorMessage = "Google authentication failed."
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    DispatchQueue.main.async {
                        self.navigateToHome = true
                    }
                }
            }
        }
    }

    func handleAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = generateNonce()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let error) = result {
            self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }

    // Function to generate a secure nonce for Apple Sign-In authentication
    func generateNonce(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = String()
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

            if status == errSecSuccess {
                randomBytes.forEach { byte in
                    if remainingLength == 0 {
                        return
                    }
                    if byte < charset.count {
                        result.append(charset[Int(byte)])
                        remainingLength -= 1
                    }
                }
            } else {
                fatalError("❌ Unable to generate secure nonce")
            }
        }

        return result
    }

    // Function to hash a nonce using SHA256 (required for Apple Sign-In security)
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    func navigateToSignUp() {
        // Handle navigation to sign-up page
    }

    func navigateToForgotPassword() {
        // Handle navigation to forgot password page
    }
}
