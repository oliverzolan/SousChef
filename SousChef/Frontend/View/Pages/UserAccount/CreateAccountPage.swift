//
//  CreateAccountView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/8/24.
//

import SwiftUI
import FirebaseAuth

struct CreateAccountView: View {
    @State private var email: String = ""
    @State private var fullName: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = false // Navigation state

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all) // Ensures full background coverage

                VStack(spacing: 30) {
                    HStack {
                        Spacer()
                        HomeButton()
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                    }

                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.black) // Ensures visibility on white background
                        .padding(.top, 40)

                    VStack(spacing: 16) {
                        // Email TextField with bottom divider
                        TextField("Email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(Color.gray), alignment: .bottom)

                        // Username TextField
                        TextField("Username", text: $fullName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(Color.gray), alignment: .bottom)
                        
                        // Full Name TextField
                        TextField("Full Name", text: $name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(Color.gray), alignment: .bottom)

                        // Password SecureField
                        SecureField("Password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .overlay(Divider().background(Color.gray), alignment: .bottom)
                    }
                    .padding(.horizontal, 24)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Create Button with Gradient Background
                    Button(action: signUp) {
                        Text("CREATE")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [AppColors.primary1, AppColors.primary2]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer()

                    // Login Link
                    NavigationLink(destination: LoginView()) {
                        Text("LOGIN")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7)) // Adjusted for white background
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let user = result?.user {
                user.getIDToken { token, error in
                    if let token = token {
                        sendToServer(email: email, token: token)
                    } else {
                        errorMessage = "Failed to retrieve token."
                    }
                }
            }
        }
    }

    private func sendToServer(email: String, token: String) {
        guard let url = URL(string: "https://souschef.click/users/create") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue(email, forHTTPHeaderField: "Email")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending data to server: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Successfully sent data to server.")
                DispatchQueue.main.async {
                    isLoggedIn = true
                }
            } else {
                print("Server responded with an error.")
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Error: \(errorMessage)")
                }
            }
        }.resume()
    }
}

struct CreateAccount: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
            .previewDevice("iPhone 12")
    }
}
