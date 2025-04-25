import SwiftUI

struct SideMenuView: View {
    let userName: String
    var closeMenu: () -> Void

    @EnvironmentObject var userSession: UserSession

    @State private var showSavedRecipes = false
    @State private var showSettings     = false
    @State private var showHelp         = false
    @State private var showReport       = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { closeMenu() }

            HStack(alignment: .top, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 20) {
                    Text(userName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 70)

                    Divider().background(Color.white)

                    Button("Settings") {
                        showSettings = true
                    }
                    .foregroundColor(.white)
                    Divider().background(Color.white)

                    Button("Help") {
                        showHelp = true
                    }
                    .foregroundColor(.white)
                    Divider().background(Color.white)

                    Button("Report a Problem") {
                        showReport = true
                    }
                    .foregroundColor(.white)
                    Divider().background(Color.white)


                    Button("Log Out") {
                        userSession.logout()
                        closeMenu()
                    }
                    .foregroundColor(.red)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: 250, maxHeight: .infinity)
                .background(Color.black.opacity(0.8))
                .edgesIgnoringSafeArea(.vertical)
            }
        }
        .sheet(isPresented: $showSavedRecipes, onDismiss: closeMenu) {
            SavedRecipesView()
        }
        .sheet(isPresented: $showSettings, onDismiss: closeMenu) {
            SettingView()
        }
        .sheet(isPresented: $showHelp, onDismiss: closeMenu) {
            HelpListView()
        }
        .sheet(isPresented: $showReport, onDismiss: closeMenu) {
            ReportProblemView()
        }
    }
}
