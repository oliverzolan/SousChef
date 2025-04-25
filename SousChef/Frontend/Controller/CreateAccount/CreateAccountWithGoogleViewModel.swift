import SwiftUI
import FirebaseAuth
import GoogleSignIn

class CreateAccountWithGoogleViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var displayName: String = ""
    @Published var successMessage: String?
    @Published var navigateToHome: Bool = false

    func signInWithGoogle() {
        guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else {
            self.errorMessage = "Unable to get root view controller."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            guard let authUser = result?.user,
                  let idToken = authUser.idToken?.tokenString else {
                self.errorMessage = "Google authentication failed."
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authUser.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let user = authResult?.user else { return }

                // Optionally update displayName
                let changeReq = user.createProfileChangeRequest()
                changeReq.displayName = self.displayName
                changeReq.commitChanges { _ in }

                user.getIDToken { token, _ in
                    if let token = token {
                        self.sendToServer(email: user.email ?? "", token: token, displayName: self.displayName)
                    }
                }

                self.successMessage = "Account created successfully."
                self.isAuthenticated = true
                self.navigateToHome = true
            }
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

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error sending user info to server: \(error.localizedDescription)")
            }
        }.resume()
    }
}
