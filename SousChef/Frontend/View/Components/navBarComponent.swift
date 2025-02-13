import SwiftUI

struct CustomNavigationBar: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(height: 80)
                .ignoresSafeArea(edges: .bottom)
            
            HStack {
                Spacer()

                NavigationLink(destination: HomePage()) {
                    VStack {
                        Image("home_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black)
                        Text("Home")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()

                NavigationLink(destination: PantryPage(userSession: userSession)) {
                    VStack {
                        Image("fridge_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black)
                        Text("Pantry")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()

                NavigationLink(destination: ScanIngredientPage()) {
                    VStack {
                        Image("scan_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black)
                        Text("Scan")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()

                NavigationLink(destination: PantryPage(userSession: userSession)) {
                    VStack {
                        Image("list_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black)
                        Text("Grocery")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()

                NavigationLink(destination: ProfilePage()) {
                    VStack {
                        Image("chef_hat_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black)
                        Text("Chef")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()
            }
            //.padding(.bottom, 10)
        }
    }
}
