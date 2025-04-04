import SwiftUI

struct RecipeDetailView: View {
    let recipe: EdamamRecipeModel

    @EnvironmentObject var userSession: UserSession
    @State private var isFavorite = false
    @State private var isAddedToShoppingList = false
    @State private var availableIngredients: Set<String> = []
    @StateObject private var recipeApiComponent = EdamamRecipeComponent()
    
    // New state variables for cart selection and success notification
    @State private var showCartSelection = false
    @State private var selectedCartName: String? = nil
    @State private var showSuccessNotification = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        topImageSection()
                        Divider()
                        ingredientsSection()
                        addToShoppingListButton()
                        Divider()
                        nutritionInfoSection()
                        Divider()
                        additionalInfoSection()
                    }
                    .padding(.top)
                }
                bottomFixedButtons()
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .onAppear {
                loadPantryIngredients()
            }
            // Present the shopping cart selection sheet
            .sheet(isPresented: $showCartSelection) {
                ShoppingCartSelectionView { selectedList in
                    addMissingIngredients(to: selectedList)
                    self.selectedCartName = selectedList.name
                    self.isAddedToShoppingList = true
                    
                    
                    withAnimation {
                        showSuccessNotification = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccessNotification = false
                        }
                    }
                }
                .environmentObject(userSession)
            }
            // Overlay for success notification
            .overlay(
                Group {
                    if showSuccessNotification {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Ingredients added successfully!")
                                    .padding()
                                    .background(AppColors.primary2.opacity(0.9))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                                Spacer()
                            }
                            .padding(.bottom, 40)
                        }
                        .transition(.opacity)
                    }
                }
            )
        }
    }

    // Top Image Section
    private func topImageSection() -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(AppColors.secondary2)
                .frame(width: UIScreen.main.bounds.width, height: 370)
                .offset(y: -70)
                .ignoresSafeArea(edges: .top)
            
            VStack {
                if let imageUrl = URL(string: recipe.image) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 3)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Text(recipe.label)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(10)
                }
                .padding(.top, 20)
            }
            .padding(.top, 40)
        }
        .padding(.top, -50)
    }

    // Ingredients Section
    private func ingredientsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredients")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ForEach(recipe.ingredients, id: \.foodId) { ingredient in
                HStack {
                    Text("• \(ingredient.text)")
                    Spacer()
                    if let foodId = ingredient.foodId, availableIngredients.contains(foodId) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // Updated Add to Shopping List Button
    private func addToShoppingListButton() -> some View {
        Button(action: {
            showCartSelection = true
        }) {
            HStack {
                Image(systemName: "cart")
                    .foregroundColor(AppColors.primary2)
                Text("Add missing ingredients to cart")
                    .foregroundColor(AppColors.primary2)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(AppColors.primary2, lineWidth: 2)
            )
        }
        .padding(.horizontal)
    }

    // Nutrition Info Section
    private func nutritionInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Nutrition Info")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading, 1)
            
            HStack(spacing: 15) {
                nutritionCard(label: formattedCalories(recipe.totalNutrients.energy), subtitle: "Calories")
                nutritionCard(label: formattedNutrient(recipe.totalNutrients.protein), subtitle: "Protein")
            }
            HStack(spacing: 15) {
                nutritionCard(label: formattedNutrient(recipe.totalNutrients.carbs), subtitle: "Carbs")
                nutritionCard(label: formattedNutrient(recipe.totalNutrients.fat), subtitle: "Fat")
            }
        }
    }

    // Helper to format calorie values (no unit)
    private func formattedCalories(_ nutrient: EdamamRecipeNutrient?) -> String {
        if let nutrient = nutrient {
            return String(format: "%.1f", nutrient.quantity)
        } else {
            return "N/A"
        }
    }

    // Helper to format other nutritional values (with unit)
    private func formattedNutrient(_ nutrient: EdamamRecipeNutrient?) -> String {
        if let nutrient = nutrient {
            return String(format: "%.1f %@", nutrient.quantity, nutrient.unit)
        } else {
            return "N/A"
        }
    }

    // Load Pantry Ingredients
    private func loadPantryIngredients() {
        var convertedIngredients: [EdamamIngredientModel] = []
        
        for ingredient in recipe.ingredients {
            let foodId = ingredient.foodId ?? ""
            let label = ingredient.parsed?.first?.food.lowercased() ?? ingredient.food.lowercased()
            let category = ingredient.foodCategory
            let image = ingredient.image
            let nutrients = EdamamIngredientNutrients(energy: nil, protein: nil, fat: nil, carbs: nil, fiber: nil)
            let parsed = ingredient.parsed
            
            let convertedIngredient = EdamamIngredientModel(
                foodId: foodId,
                label: label,
                category: category,
                categoryLabel: nil,
                image: image,
                nutrients: nutrients,
                parsed: parsed
            )
            convertedIngredients.append(convertedIngredient)
        }
        
        recipeApiComponent.compareRecipeIngredientsWithPantry(recipeIngredients: convertedIngredients) { result in
            switch result {
            case .success(let matchedIngredients):
                DispatchQueue.main.async {
                    self.availableIngredients = matchedIngredients
                }
            case .failure(let error):
                print("Error comparing ingredients: \(error)")
            }
        }
    }

    // Helper to add missing ingredients to a shopping list
    private func addMissingIngredients(to shoppingList: ShoppingList) {
        for ingredient in recipe.ingredients {
            if let foodId = ingredient.foodId, !availableIngredients.contains(foodId) {
                // Create a CartItem with default values (update as needed)
                let cartItem = CartItem(name: ingredient.text, price: 0.0, quantity: 1)
                shoppingList.items.append(cartItem)
            }
        }
    }

    // Nutrition Card
    private func nutritionCard(label: String, subtitle: String) -> some View {
        VStack {
            Text(label)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(width: 160, height: 80)
        .background(AppColors.secondary2)
        .cornerRadius(15)
    }
    
    private func additionalInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recipe Information")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if let dietLabels = recipe.dietLabels, !dietLabels.isEmpty {
                infoRow(title: "Diet Labels:", value: dietLabels.joined(separator: ", "))
            }
            
            if let healthLabels = recipe.healthLabels, !healthLabels.isEmpty {
                infoRow(title: "Health Labels:", value: healthLabels.joined(separator: ", "))
            }
            
            if let cuisineType = recipe.cuisineType, !cuisineType.isEmpty {
                infoRow(title: "Cuisine Type:", value: cuisineType.joined(separator: ", "))
            }
            
            if let mealType = recipe.mealType, !mealType.isEmpty {
                infoRow(title: "Meal Type:", value: mealType.joined(separator: ", "))
            }
            
            if let dishType = recipe.dishType, !dishType.isEmpty {
                infoRow(title: "Dish Type:", value: dishType.joined(separator: ", "))
            }
        }
        .padding(.horizontal)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
            Text(value)
            Spacer()
        }
    }

    // Bottom Buttons Section
    private func bottomFixedButtons() -> some View {
        HStack(spacing: 10) {
            Button(action: {
                if let url = URL(string: recipe.url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("View Full Recipe")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.primary2)
                    .cornerRadius(30)
            }
            .frame(width: UIScreen.main.bounds.width * 0.65)
            
            Button(action: {
                print("Ask AI tapped")
            }) {
                Text("Ask AI")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(AppColors.primary2, lineWidth: 2)
                    )
            }
            .frame(width: UIScreen.main.bounds.width * 0.3)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.bottom))
    }
}
