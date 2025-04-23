import SwiftUI

struct SideMenuView: View {
    let userName: String
    var closeMenu: () -> Void
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Blur overlay for the background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    closeMenu()
                }
            
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text(userName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 70)

                    Button("Saved Recipes") {
                        // Navigate to saved recipes
                    }
                    .foregroundColor(.white)

                    Divider().background(Color.white)

                    Button("Settings") {
                        showSettings = true
                    }
                    .foregroundColor(.white)

                    Divider().background(Color.white)

                    Button("Help") {
                        // Navigate to help
                    }
                    .foregroundColor(.white)

                    Divider().background(Color.white)

                    Button("Report a Problem") {
                        // Navigate to report form
                    }
                    .foregroundColor(.white)
                    
                    Divider().background(Color.white)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: 250, maxHeight: .infinity)
                .background(Color.black.opacity(0.8))
                .edgesIgnoringSafeArea(.vertical)
                .sheet(isPresented: $showSettings) {
                    SettingView()
                }
            }
        }
    }
}
