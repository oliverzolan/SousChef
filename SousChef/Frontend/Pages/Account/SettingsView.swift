import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSession: UserSession // Access shared user session
    @State private var newName: String = "" // Temporary name for the input field
    @State private var showSuccessMessage: Bool = false // Flag to show success message

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Spacer()

            // User Profile Name Update
            VStack(alignment: .leading, spacing: 10) {
                Text("Update Your Name")
                    .font(.headline)
                    .foregroundColor(.white)

                TextField("Enter your name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(10)

                Button(action: {
                    userSession.fullName = newName
                    showSuccessMessage = true
                    dismissKeyboard() 
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                if showSuccessMessage {
                    Text("Name updated successfully!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(AppColors.background)
        .edgesIgnoringSafeArea(.all)
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSession()) // Provide a default UserSession object
            .previewDevice("iPhone 12")
    }
}
