import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class CreateAccountViewController: ObservableObject {
    @Published var email = ""
    @Published var displayName = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    @Published var navigateToHome = false

    private var currentNonce: String?

    func signUp() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        successMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let user = result?.user else { return }

                let changeReq = user.createProfileChangeRequest()
                changeReq.displayName = self.displayName
                changeReq.commitChanges { _ in }

                user.getIDToken { token, _ in
                    if let token = token {
                        self.sendToServer(email: self.email, token: token, displayName: self.displayName)
                    }
                }

                self.successMessage = "Account created successfully."
                self.navigateToHome = true
            }
        }
    }

    func signUpWithGoogle() {
        guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else {
            DispatchQueue.main.async { self.errorMessage = "Unable to get root view controller." }
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            guard
                let authUser = result?.user,
                let idToken = authUser.idToken?.tokenString
            else {
                DispatchQueue.main.async { self.errorMessage = "Google authentication failed." }
                return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authUser.accessToken.tokenString
            )
            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    if let user = authResult?.user {
                        let req = user.createProfileChangeRequest()
                        req.displayName = self.displayName
                        req.commitChanges { _ in }
                    }
                    self.successMessage = "Account created successfully."
                    self.navigateToHome = true
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
            guard
                let appleCred = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = appleCred.identityToken,
                let tokenString = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                DispatchQueue.main.async { self.errorMessage = "Apple Sign-In failed." }
                return
            }
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: tokenString,
                rawNonce: nonce
            )
            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    if let user = authResult?.user {
                        let name = appleCred.fullName
                        self.displayName = "\(name?.givenName ?? "") \(name?.familyName ?? "")".trimmingCharacters(in: .whitespaces)
                        let req = user.createProfileChangeRequest()
                        req.displayName = self.displayName
                        req.commitChanges { _ in }
                    }
                    self.successMessage = "Account created successfully."
                    self.navigateToHome = true
                }
            }
        case .failure(let error):
            DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
        }
    }

    func generateNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = "", remaining = length
        while remaining > 0 {
            var bytes = [UInt8](repeating: 0, count: 16)
            _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            for b in bytes where remaining > 0 {
                if b < charset.count {
                    result.append(charset[Int(b)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    func sha256(_ input: String) -> String {
        let hash = SHA256.hash(data: Data(input.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func sendToServer(email: String, token: String, displayName: String) {
        guard let url = URL(string: "https://souschef.click/users/create") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue(email, forHTTPHeaderField: "Email")
        request.setValue(displayName, forHTTPHeaderField: "Display-Name")
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
