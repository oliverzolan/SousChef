import SwiftUI
import Firebase

struct SettingView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    HStack {
                        Text("Settings")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 40)

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
                            label: "New Password",
                            placeholder: "Enter new password (optional)",
                            text: $viewModel.newPassword
                        )
                    }
                    .padding(.horizontal, 24)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Button(action: { viewModel.updateUserInfo() }) {
                        Text("Save Changes")
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

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            viewModel.loadUserData()
        }
        .onChange(of: viewModel.updateSuccess) { success in
            if success {
                dismiss()
            }
        }
    }
}
