//
//  AppleAuthViewModel.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 1/30/25.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit


class AppleAuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    private var currentNonce: String?

    func signInWithApple() {
        let nonce = generateNonce()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to retrieve identity token."
                }
                return
            }

            guard let nonce = currentNonce else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid state: Missing nonce."
                }
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)

            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Nonce Generator for Secure Authentication
    private func generateNonce(length: Int = 32) -> String {
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
                fatalError("Unable to generate nonce")
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    private func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential, nonce: String) {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            print("❌ Error: Failed to retrieve identity token")
            return
        }

        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)

        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                print("🔥 Firebase Sign-In with Apple failed: \(error.localizedDescription)")
                return
            }

            guard let user = authResult?.user else {
                print("⚠️ Apple Sign-In succeeded but no user data was returned.")
                return
            }

            print("✅ Successfully signed in with Apple! User ID: \(user.uid)")

            // Optionally, update user display name
            if let fullName = credential.fullName {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = "\(fullName.givenName ?? "") \(fullName.familyName ?? "")".trimmingCharacters(in: .whitespaces)
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("⚠️ Failed to update display name: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

}
