import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    @StateObject private var emailViewModel = CreateAccountViewController()
    @StateObject private var googleViewModel = CreateAccountWithGoogleViewModel()
    @StateObject private var appleViewModel  = CreateAccountWithAppleViewModel()
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

                        if let error = emailViewModel.errorMessage ?? googleViewModel.errorMessage ?? appleViewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else if let success = emailViewModel.successMessage ?? googleViewModel.successMessage ?? appleViewModel.successMessage {
                            Text(success)
                                .foregroundColor(.green)
                                .padding()
                        }

                        VStack(spacing: 16) {
                            CustomTextField(
                                label: "Display Name",
                                placeholder: "Enter your display name",
                                text: $emailViewModel.displayName
                            )
                            CustomTextField(
                                label: "Email",
                                placeholder: "Enter your email",
                                text: $emailViewModel.email
                            )
                            CustomSecureField(
                                label: "Password",
                                placeholder: "Enter your password",
                                text: $emailViewModel.password
                            )
                        }
                        .padding(.horizontal, 24)

                        Button(action: emailViewModel.signUp) {
                            Group {
                                if emailViewModel.isLoading {
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
                        .disabled(emailViewModel.isLoading)

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
                            Button(action: {
                                appleViewModel.signUpWithApple()
                            }) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                    Text("Sign up with Apple")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 24)

                            Button(action: {
                                googleViewModel.displayName = emailViewModel.displayName
                                googleViewModel.signInWithGoogle()
                            }) {
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


            .navigationDestination(isPresented:
                Binding(
                    get: { emailViewModel.navigateToHome || googleViewModel.navigateToHome || appleViewModel.navigateToHome },
                    set: { _ in }
                )
            ) {
                MainTabView()
                    .environmentObject(userSession)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}


