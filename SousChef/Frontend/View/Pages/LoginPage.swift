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
                    
                    // Watermelon app icon
                    Image("watermelon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 20)
                    
                    Text("SousChef")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(Color.black)
                        .padding(.bottom, 100)
                    
                    //to login
                    NavigationLink(
                        destination: LoginView()
                            .environmentObject(userSession)
                            .navigationBarBackButtonHidden(true)
                    ) {
                        Text("Sign In")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(AppColors.primary1)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    // Navigation to Create Account View
                    NavigationLink(
                        destination: CreateAccountView()
                            .navigationBarBackButtonHidden(true) // Hide the back button
                    ) {
                        Text("Create Account")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(AppColors.primary2)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer() 
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    struct profile_activity_Previews: PreviewProvider {
        static var previews: some View {
            LoginPage()
                .environmentObject(UserSession())
                .previewDevice("iPhone 16 Pro")
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
