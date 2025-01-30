//
//  LoginView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/5/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit


struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var navigateToHome: Bool = false
    @EnvironmentObject var userSession: UserSession
    @StateObject private var appleAuth = AppleAuthViewModel() // Apple Sign-In ViewModel
    @State private var currentNonce: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        HomeButton()
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                    }

                    Spacer()

                    Text("Log In")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    // Login form
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(AppColors.cardColor), alignment: .bottom)

                        SecureField("Password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(AppColors.cardColor), alignment: .bottom)
                    }
                    .padding(.horizontal, 24)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Log In Button
                    Button(action: logIn) {
                        Text("LOG IN")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [AppColors.primary1]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                    }
                    .padding(.horizontal, 24)

                    // Google Sign-In Button
                    Button(action: signInWithGoogle) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.white)
                            Text("Sign in with Google")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
                    }
                    .padding(.horizontal, 24)

                    // Apple Sign-In Button
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = generateNonce()  // Generate a nonce
                            currentNonce = nonce          // Store it in state
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce) // Hash the nonce for security
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    if let nonce = currentNonce {  // Ensure nonce is available
                                        handleAppleSignIn(credential: appleIDCredential, nonce: nonce)
                                    } else {
                                        print("❌ Error: Missing nonce during Apple Sign-In")
                                    }
                                }
                            case .failure(let error):
                                print("Apple Sign-In failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .frame(height: 50)
                    .padding(.horizontal, 24)

                    // Guest Login Button
                    Button(action: {
                        userSession.loginAsGuest()
                        navigateToHome = true
                    }) {
                        Text("Continue as Guest")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(AppColors.primary2)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomePage()
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(userSession)
            }
        }
    }

    private func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                DispatchQueue.main.async {
                    userSession.token = Auth.auth().currentUser?.uid
                    navigateToHome = true
                }
            }
        }
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

    /// Generates a secure random nonce for Apple Sign-In authentication.
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

    /// Hashes a string using SHA256 for Apple Sign-In security.
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    private func signInWithGoogle() {
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

                DispatchQueue.main.async {
                    userSession.token = Auth.auth().currentUser?.uid
                    navigateToHome = true
                }
            }
        }
    }
}
