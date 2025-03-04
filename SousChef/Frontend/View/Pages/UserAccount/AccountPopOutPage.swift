import SwiftUI

struct SideMenuView: View {
    let userName: String
    var closeMenu: () -> Void
    @State private var showSettings = false

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                Text("Hello, \(userName)!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Button("Saved Recipes") {
                    // Navigate to saved recipes
                }
                .foregroundColor(.white)

                Button("Settings") {
                    showSettings = true
                }
                .foregroundColor(.white)

                Button("Help") {
                    // Navigate to help
                }
                .foregroundColor(.white)

                Button("Report a Problem") {
                    // Navigate to report form
                }
                .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .frame(width: 250)
            .background(Color.black.opacity(0.3))
            .cornerRadius(20)
            .shadow(radius: 10)
            .sheet(isPresented: $showSettings) {
                SettingView()
            }
        }
        .padding(.top)
    }
}
