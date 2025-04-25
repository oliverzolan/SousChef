import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    @StateObject private var viewModel = CreateAccountViewController()
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Create Account")
                            .font(.title).fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.top, 70)
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else if let success = viewModel.successMessage {
                            Text(success)
                                .foregroundColor(.green)
                                .padding()
                        }
                        

                        VStack(spacing: 16) {
                            CustomTextField(
                                label: "Display Name",
                                placeholder: "Enter your display name",
                                text: $viewModel.displayName
                            )
                            CustomTextField(
                                label: "Email",
                                placeholder: "Enter your email",
                                text: $viewModel.email
                            )
                            CustomSecureField(
                                label: "Password",
                                placeholder: "Enter your password",
                                text: $viewModel.password
                            )
                        }
                        .padding(.horizontal, 24)


                        Button(action: viewModel.signUp) {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Sign up")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.primary2)
                            )
                        }
                        .padding(.horizontal, 24)
                        .disabled(viewModel.isLoading)

                        HStack {
                            Divider().background(Color.gray.opacity(0.5))
                            Text("Or With")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                            Divider().background(Color.gray.opacity(0.5))
                        }
                        .frame(height: 20)
                        .padding(.horizontal, 40)

                        VStack(spacing: 10) {
                            SignInWithAppleButton(
                                onRequest: viewModel.handleAppleRequest,
                                onCompletion: viewModel.handleAppleCompletion
                            )
                            .frame(height: 50)
                            .padding(.horizontal, 24)

                            Button(action: viewModel.signUpWithGoogle) {
                                HStack {
                                    Image("google-logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    Text("Sign up with Google")
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
                        }

                        NavigationLink(
                            destination: LoginView()
                                .environmentObject(userSession)
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("LOGIN")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationDestination(isPresented: $viewModel.navigateToHome) {
                MainTabView()
                    .environmentObject(userSession)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
