//
//  UserSession.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/5/24.
//

import Foundation
import FirebaseAuth

class UserSession: ObservableObject {
    @Published var token: String? // For authenticated users
    @Published var isGuest: Bool = false // For guest users

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        // Retrieve token from Keychain on initialization
        self.token = KeychainHelper.shared.retrieve(for: "authToken")
        
        // Add Firebase auth state listener to handle token refresh automatically
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self, let user = user else {
                self?.token = nil
                return
            }

            user.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print("Error refreshing token: \(error.localizedDescription)")
                    self.token = nil
                } else if let idToken = idToken {
                    self.token = idToken
                    KeychainHelper.shared.save(idToken, for: "authToken")
                }
            }
        }
    }

    func loginAsGuest() {
        isGuest = true
    }

    func logout() {
        // Delete token from Keychain and reset state
        KeychainHelper.shared.delete(for: "authToken")
        self.token = nil
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
