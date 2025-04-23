import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var showLogin = false
    @State private var showSignUp = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    Spacer()

                    Text("SousChef")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.vertical, 200)

                    Button("Sign In") {
                        showLogin = true
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(AppColors.primary1))
                    .padding(.horizontal, 24)

                    Button("Create Account") {
                        showSignUp = true
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(AppColors.primary2))
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .navigationBarBackButtonHidden(true)

                NavigationLink(
                    destination: LoginView()
                        .environmentObject(userSession)
                        .navigationBarBackButtonHidden(true),
                    isActive: $showLogin
                ) {
                    EmptyView()
                }

                NavigationLink(
                    destination: CreateAccountView()
                        .environmentObject(userSession)
                        .navigationBarBackButtonHidden(true),
                    isActive: $showSignUp
                ) {
                    EmptyView()
                }
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
            .environmentObject(UserSession())
            .previewDevice("iPhone 16 Pro")
    }
}
