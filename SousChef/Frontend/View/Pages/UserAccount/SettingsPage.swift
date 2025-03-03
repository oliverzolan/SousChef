import SwiftUI
import Firebase

struct SettingView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    // Header
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.top, 40)

                    // Input Fields
                    VStack(spacing: 16) {
                        CustomTextField(label: "Display Name", placeholder: "Enter your display name", text: $viewModel.displayName)
                        CustomTextField(label: "Email", placeholder: "Enter your email", text: $viewModel.email)
                        CustomTextField(label: "Full Name", placeholder: "Enter your full name", text: $viewModel.fullName)
                        CustomSecureField(label: "New Password", placeholder: "Enter new password (optional)", text: $viewModel.newPassword)
                    }
                    .padding(.horizontal, 24)

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Save Button
                    Button(action: viewModel.updateUserInfo) {
                        Text("Save Changes")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AppColors.primary2))
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
}
