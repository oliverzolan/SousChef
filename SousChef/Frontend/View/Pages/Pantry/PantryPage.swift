import SwiftUI

struct PantryPage: View {
    @StateObject private var pantryController: PantryController
    @EnvironmentObject var userSession: UserSession

    init(userSession: UserSession) {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: userSession))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                HeaderComponent(title: "Pantry")
                SearchComponent(searchText: .constant(""))
                    .frame(maxWidth: .infinity, maxHeight: 55)

                // Display error message, if any.
                if let errorMessage = pantryController.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                // Loading indicator.
                if pantryController.isLoading {
                    ProgressView("Loading...")
                } else {
                    // Display your category grid.
                    HStack(spacing: 10) {
                        VStack(spacing: 13) {
                            NavigationLink(destination: VegetablesIngredientsPage()) {
                                CategoryButton(imageName: "vegetablesButton")
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)

                            NavigationLink(destination: GrainsIngredientsPage()) {
                                CategoryButton(imageName: "grainsButton")
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)

                            HStack(spacing: 10) {
                                NavigationLink(destination: SpicesIngredientsPage()) {
                                    CategoryButton(imageName: "spicesButton")
                                }
                                .frame(maxWidth: .infinity, maxHeight: 100)

                                NavigationLink(destination: CannedIngredientsPage()) {
                                    CategoryButton(imageName: "cannedButton")
                                }
                                .frame(maxWidth: .infinity, maxHeight: 100)
                            }

                            NavigationLink(destination: DrinksIngredientsPage()) {
                                CategoryButton(imageName: "drinksButton")
                            }
                            .frame(maxWidth: .infinity, maxHeight: 125)
                        }

                        VStack(spacing: 10) {
                            NavigationLink(destination: MeatsIngredientsPage()) {
                                CategoryButton(imageName: "meatsButton")
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            
                            NavigationLink(destination: FruitsIngredientsPage()) {
                                CategoryButton(imageName: "fruitButton")
                            }
                            .frame(maxWidth: .infinity, maxHeight: 240)

                            NavigationLink(destination: DairyIngredientsPage()) {
                                CategoryButton(imageName: "dairyButton")
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                        }
                    }
                    .padding(.horizontal, 15)

                    HStack(spacing: 10) {
                        NavigationLink(destination: CondimentsIngredientsPage()) {
                            CategoryButton(imageName: "condimentsButton")
                        }
                        .frame(maxWidth: .infinity, maxHeight: 200)

                        NavigationLink(destination: AllIngredientsPage()) {
                            CategoryButton(imageName: "allButton")
                        }
                        .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 39)
                }

                Spacer()

                // Plus button to show the add ingredient popup.
//                Button(action: {
//                    pantryController.showAddIngredientPopup.toggle()
//                }) {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.blue)
//                }
                .padding()
            }
            .background(Color(.systemBackground))
            .onAppear {
                pantryController.fetchPantryItems()
            }
            // add ingredient popup
            .sheet(isPresented: $pantryController.showAddIngredientPopup) {
                PantryPopupView(isVisible: $pantryController.showAddIngredientPopup, pantryItems: $pantryController.pantryItems)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct CategoryButton: View {
    var imageName: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    imageView
                }
            } else {
                imageView
            }
        }
    }
    
    private var imageView: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
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
