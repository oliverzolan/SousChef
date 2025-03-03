import SwiftUI

struct PantryPage: View {
    @StateObject private var pantryController: PantryController
    @EnvironmentObject var userSession: UserSession

    init(userSession: UserSession) {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: userSession))
    }

    var body: some View {
        VStack(spacing: 10) {
            HeaderComponent(title: "Pantry")
            SearchComponent(searchText: .constant(""))
                .frame(maxWidth: .infinity, maxHeight: 55)

//                if let errorMessage = pantryController.errorMessage {
//                    Text("Error: \(errorMessage)")
//                        .foregroundColor(.red)
//                        .padding()
//                }

            if pantryController.isLoading {
                ProgressView("Loading...")
            } else {
                // Pantry categories
                HStack(spacing: 10) {
                    VStack(spacing: 13) {
                        CategoryButton(imageName: "vegetablesButton") { fetchCategoryItems("vegetables") }
                            .frame(maxWidth: .infinity, maxHeight: 150)

                        CategoryButton(imageName: "grainsButton") { fetchCategoryItems("grains") }
                            .frame(maxWidth: .infinity, maxHeight: 150)

                        HStack(spacing: 10) {
                            CategoryButton(imageName: "spicesButton") { fetchCategoryItems("spices") }
                                .frame(maxWidth: .infinity, maxHeight: 100)

                            CategoryButton(imageName: "cannedButton") { fetchCategoryItems("canned") }
                                .frame(maxWidth: .infinity, maxHeight: 100)
                        }

                        CategoryButton(imageName: "drinksButton") { fetchCategoryItems("drinks") }
                            .frame(maxWidth: .infinity, maxHeight: 125)
                    }

                    VStack(spacing: 10) {
                        CategoryButton(imageName: "meatsButton") { fetchCategoryItems("meats") }
                            .frame(maxWidth: .infinity, maxHeight: 150)

                        CategoryButton(imageName: "fruitButton") { fetchCategoryItems("fruit") }
                            .frame(maxWidth: .infinity, maxHeight: 240)

                        CategoryButton(imageName: "dairyButton") { fetchCategoryItems("dairy") }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                    }
                }
                .padding(.horizontal, 15)

                HStack(spacing: 10) {
                    CategoryButton(imageName: "condimentsButton") { fetchCategoryItems("condiments") }
                        .frame(maxWidth: .infinity, maxHeight: 200)

                    CategoryButton(imageName: "allButton") { fetchCategoryItems("all") }
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 39)
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            pantryController.fetchPantryItems()
        }
    }
}

private func fetchCategoryItems(_ category: String) {
    print("Fetching items for category: \(category)")
    // Implement category-specific item fetching
}

struct CategoryButton: View {
    var imageName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
        }
    }
}

struct PantryPage_Previews: PreviewProvider {
    static var previews: some View {
        let mockSession = UserSession()
        mockSession.token = "mock_token"

        return PantryPage(userSession: mockSession)
            .environmentObject(mockSession)
            .previewDevice("iPhone 16 Pro")
    }
}
