import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var newName: String = ""
    @State private var showSuccessMessage: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            Spacer()

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
                    Text("Update check")
                        .font(.subheadline)
                        .foregroundColor(.white)
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
            .environmentObject(UserSession())
            .previewDevice("iPhone 12")
    }
}
