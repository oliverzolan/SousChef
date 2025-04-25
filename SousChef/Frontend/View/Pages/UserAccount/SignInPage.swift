import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewController()
    @EnvironmentObject var userSession: UserSession
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Welcome Back!")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.top, 50)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        

                        VStack(spacing: 16) {
                            CustomTextField(
                                label: "Email",
                                placeholder: "Enter your email",
                                text: $viewModel.email
                            )
                            .padding(.horizontal, 24)

                            CustomSecureField(
                                label: "Password",
                                placeholder: "Enter your password",
                                text: $viewModel.password
                            )
                            .padding(.horizontal, 24)

                            Button(action: viewModel.logIn) {
                                Text("Sign In")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppColors.primary2)
                                    )
                            }
                            .padding(.horizontal, 24)
                        }

                        VStack(spacing: 8) {
                            Button {
                                showSignUp = true
                            } label: {
                                HStack {
                                    Text("Don't have an account?")
                                    Text("Sign up")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.blue)
                            }

                            NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 24)

                        HStack {
                            Divider()
                            Text("Or With")
                            Divider()
                        }
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)


                        Button(action: viewModel.signInWithGoogle) {
                            HStack {
                                Image("google-logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Sign in with Google")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)

                        SignInWithAppleButton(
                            onRequest: viewModel.handleAppleRequest,
                            onCompletion: viewModel.handleAppleCompletion
                        )
                        .frame(height: 50)
                        .padding(.horizontal, 24)

                        Button {
                            userSession.loginAsGuest()
                            viewModel.navigateToHome = true
                        } label: {
                            Text("Continue as Guest")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(.white)
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding(.vertical, 40)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationDestination(isPresented: $showSignUp) {
                CreateAccountView()
                    .environmentObject(userSession)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $viewModel.navigateToHome) {
                MainTabView()
                    .environmentObject(userSession)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
