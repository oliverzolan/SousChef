import Foundation
import FirebaseAuth

class UserSession: ObservableObject {
    @Published var token: String?
    @Published var isGuest: Bool = false
    @Published var fullName: String?

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        self.token = KeychainHelper.shared.retrieve(for: "authToken")
        self.fullName = KeychainHelper.shared.retrieve(for: "userFullName")

        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self, let user = user else {
                self?.token = nil
                self?.fullName = nil
                return
            }

            user.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print("Error refreshing token: \(error.localizedDescription)")
                    self.token = nil
                    self.fullName = nil
                } else if let idToken = idToken {
                    self.token = idToken
                    KeychainHelper.shared.save(idToken, for: "authToken")

                    if let displayName = user.displayName {
                        self.fullName = displayName
                        KeychainHelper.shared.save(displayName, for: "userFullName")
                    }
                }
            }
        }
    }

    func updateFullName(_ name: String) {
        self.fullName = name
        KeychainHelper.shared.save(name, for: "userFullName")
    }

    func loginAsGuest() {
        isGuest = true
        fullName = "Guest"
    }

    func logout() {
        // Delete token and name from Keychain and reset state
        KeychainHelper.shared.delete(for: "authToken")
        KeychainHelper.shared.delete(for: "userFullName")
        self.token = nil
        self.fullName = nil
        self.isGuest = false
    }

    /// Manually refreshes the token, useful for handling network request failures
    func refreshToken(completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(nil)
            return
        }

        user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
            if let error = error {
                print("Error refreshing token: \(error.localizedDescription)")
                self?.token = nil
                completion(nil)
            } else if let idToken = idToken {
                self?.token = idToken
                KeychainHelper.shared.save(idToken, for: "authToken")
                completion(idToken)

                // Update full name if available
                if let displayName = user.displayName {
                    self?.fullName = displayName
                    KeychainHelper.shared.save(displayName, for: "userFullName")
                }
            }
        }
    }

    deinit {
        // Remove Firebase auth listener when UserSession is deallocated
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
}
