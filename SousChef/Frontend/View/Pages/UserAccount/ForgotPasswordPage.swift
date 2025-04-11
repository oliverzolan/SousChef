//
//  ForgotPasswordView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 3/3/25.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var isResetSent = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Your Password")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Enter your email address and we'll send you instructions to reset your password.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            CustomTextField(label: "Email", placeholder: "Enter your email", text: $email)
                .padding(.horizontal, 24)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            Button(action: sendPasswordReset) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Send Reset Link")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .disabled(isLoading)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.primary2)
            )
            .padding(.horizontal, 24)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }

            if isResetSent {
                Text("If there is an email set up with an account, a password reset link has been sent to your email. (Check Junk/Spam folder)")
                    .foregroundColor(.green)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .background(AppColors.background.edgesIgnoringSafeArea(.all))
    }

    private func sendPasswordReset() {
        errorMessage = nil
        isResetSent = false
        isLoading = true
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email."
            isLoading = false
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isResetSent = true
                    self.errorMessage = nil
                    self.email = ""
                }
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 16 Pro"))
    }
}
