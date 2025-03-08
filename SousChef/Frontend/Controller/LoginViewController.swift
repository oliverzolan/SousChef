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
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .wrongPassword, .invalidEmail, .userNotFound:
                    self?.errorMessage = "No account with that Email or Password Incorrect."
                default:
                    self?.errorMessage = "No account with that Email or Password Incorrect."
                }
                return
            }
            self?.errorMessage = nil
            self?.navigateToHome = true
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

            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    DispatchQueue.main.async {
                        self?.navigateToHome = true
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
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.errorMessage = "Apple Sign-In failed. Please try again."
                return
            }

            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )

            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.errorMessage = nil
                self?.navigateToHome = true
            }

        case .failure(let error):
            self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }

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
                fatalError("Unable to generate secure nonce")
            }
        }

        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
}
