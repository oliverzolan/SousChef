import SwiftUI

struct CustomNavigationBar: View {
    var body: some View {
        ZStack {
            // Background Bar with White Color
            Rectangle()
                .fill(Color.white) // ✅ White background
                .frame(height: 80)
                .ignoresSafeArea(edges: .bottom)
            
            // Bottom Navigation Buttons
            HStack {
                Spacer()

                // Home
                NavigationLink(destination: HomePage()) {
                    VStack {
                        Image("home_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black) // Accent color
                        Text("Home")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()

                // Pantry
                NavigationLink(destination: PantryPage()) {
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

                // Scan
                NavigationLink(destination: ScanIngredientPage()) {
                    VStack {
                        Image("scan_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black) // Highlighted secondary color
                        Text("Scan")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()

                // Grocery List
                NavigationLink(destination: PantryPage()) {
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

                // Chef (Profile)
                NavigationLink(destination: ProfilePage()) {
                    VStack {
                        Image("chef_hat_icon")
                            .font(.system(size: 28))
                            .foregroundColor(Color.black) // Different secondary for emphasis
                        Text("Chef")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    }
                }

                Spacer()
            }
            .padding(.bottom, 10)
        }
    }
}
