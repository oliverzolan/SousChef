import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class CreateAccountWithAppleViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var navigateToHome: Bool = false
    private var currentNonce: String?

    func signUpWithApple() {
        let nonce = generateNonce()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8),
              let nonce = currentNonce else {
            DispatchQueue.main.async { self.errorMessage = "Apple Sign-In failed." }
            return
        }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nonce
        )

        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let user = authResult?.user else { return }

                let name = credential.fullName
                let displayName = "\(name?.givenName ?? "") \(name?.familyName ?? "")".trimmingCharacters(in: .whitespaces)

                let changeReq = user.createProfileChangeRequest()
                changeReq.displayName = displayName
                changeReq.commitChanges { _ in }

                user.getIDToken { token, _ in
                    if let token = token {
                        self.sendToServer(email: user.email ?? "", token: token, displayName: displayName)
                    }
                }

                self.successMessage = "Account created successfully."
                self.isAuthenticated = true
                self.navigateToHome = true
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }

    private func sendToServer(email: String, token: String, displayName: String) {
        guard let url = URL(string: "https://souschef.click/users/create") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue(email, forHTTPHeaderField: "Email")
        request.setValue(displayName, forHTTPHeaderField: "Display-Name")

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Server error: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func generateNonce(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = String()
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            if SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes) == errSecSuccess {
                for byte in randomBytes {
                    if remainingLength == 0 { break }
                    if byte < charset.count {
                        result.append(charset[Int(byte)])
                        remainingLength -= 1
                    }
                }
            } else {
                fatalError("Unable to generate nonce.")
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let hash = SHA256.hash(data: Data(input.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
