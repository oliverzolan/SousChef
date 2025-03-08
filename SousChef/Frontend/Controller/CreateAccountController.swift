//
//  CreateAccountViewController.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 2/1/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class CreateAccountViewController: ObservableObject {
    @Published var email: String = ""
    @Published var fullName: String = ""
    @Published var displayName: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    private var currentNonce: String?

    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            } else if let user = result?.user {
                self.updateUserDisplayName(user: user)

                user.getIDToken { token, error in
                    if let token = token {
                        self.sendToServer(email: self.email, token: token, displayName: self.displayName)
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to retrieve token."
                        }
                    }
                }
            }
        }
    }

    private func updateUserDisplayName(user: User) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = self.displayName // Set Display Name
        changeRequest.commitChanges { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to update display name: \(error.localizedDescription)"
                }
            }
        }
    }

    
    func signUpWithGoogle() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            self.errorMessage = "Unable to get root view controller."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let authentication = result?.user,
                  let idToken = authentication.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self.errorMessage = "Google authentication failed."
                }
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

               
                if let user = authResult?.user {
                    self.updateUserDisplayName(user: user)
                }

                DispatchQueue.main.async {
                    self.isLoggedIn = true
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
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                
                guard let nonce = currentNonce else {
                    self.errorMessage = "Nonce is missing."
                    return
                }

                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = error.localizedDescription
                        }
                        return
                    }

                    
                    if let user = authResult?.user, let fullName = appleIDCredential.fullName {
                        let displayName = "\(fullName.givenName ?? "") \(fullName.familyName ?? "")".trimmingCharacters(in: .whitespaces)
                        self.displayName = displayName
                        self.updateUserDisplayName(user: user)
                    }

                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            }
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
                    if remainingLength == 0 { return }
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

    
    private func sendToServer(email: String, token: String, displayName: String) {
        guard let url = URL(string: "https://souschef.click/users/create") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue(email, forHTTPHeaderField: "Email")
        request.addValue(displayName, forHTTPHeaderField: "Display-Name")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending data to server: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Successfully sent data to server.")
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            } else {
                print("Server responded with an error.")
            }
        }.resume()
    }
}
