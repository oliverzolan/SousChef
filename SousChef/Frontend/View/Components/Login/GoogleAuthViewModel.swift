//
//  GoogleAuthViewModel.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 1/30/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

class GoogleAuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

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
                    return
                }

                self.isAuthenticated = true
            }
        }
    }
}
