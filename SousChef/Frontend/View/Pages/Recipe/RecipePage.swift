import SwiftUI

struct RecipeDetailView: View {
    let recipe: EdamamRecipeModel

    @EnvironmentObject var userSession: UserSession
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite = false
    @State private var isAddedToShoppingList = false
    @State private var availableIngredients: Set<String> = []
    @StateObject private var recipeApiComponent = EdamamRecipeComponent()
    
    @State private var showCartSelection = false
    @State private var selectedCartName: String? = nil
    @State private var showSuccessNotification = false
    @State private var navigateToChat = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Top image and header
                    ZStack(alignment: .bottom) {
                        // Image background
                        if let imageUrl = URL(string: recipe.image) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width, height: 200)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .fill(AppColors.secondary2.opacity(0.5))
                                    .frame(width: UIScreen.main.bounds.width, height: 200)
                            }
                        } else {
                            Rectangle()
                                .fill(AppColors.secondary2.opacity(0.5))
                                .frame(width: UIScreen.main.bounds.width, height: 200)
                        }
                        
                        // Recipe info card
                        recipeInfoCard()
                            .padding(.horizontal)
                            .padding(.bottom, -50) // Half the card extends below the image
                    }
                    .frame(height: 200)
                    
                    VStack(spacing: 24) {
                        Spacer().frame(height: 50)
                        
                        ingredientsSection()
                            .padding(.horizontal)
                        
                        addToShoppingListButton()
                            .padding(.horizontal)
                        
                        nutritionInfoSection()
                            .padding(.horizontal)
                        
                        additionalInfoSection()
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 80)
                }
            }
            
            // Custom back button overlay
            VStack {
                HStack {
                    Button(action: {
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.top, 40)
            
            VStack {
                Spacer()
                bottomFixedButtons()
            }
            
            NavigationLink(
                destination: ChatbotPage(recipeURL: recipe.url),
                isActive: $navigateToChat
            ) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            loadPantryIngredients()
        }
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

    // Recipe info card
    private func recipeInfoCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.label)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Recipe info
            HStack(spacing: 16) {
                if let cuisineType = recipe.cuisineType?.first {
                    metaInfoItem(icon: "globe", text: cuisineType.capitalized)
                }
                
                // Use calories
                metaInfoItem(icon: "flame", text: "\(Int(recipe.calories)) cal")
                
                // Use totalWeight for servings
                let servings = max(1, Int(recipe.totalWeight / 250))
                metaInfoItem(icon: "person.2", text: "\(servings) servings")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // Meta info item
    private func metaInfoItem(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(AppColors.primary2)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }

    // Ingredients Section
    private func ingredientsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingredients")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(recipe.ingredients, id: \.foodId) { ingredient in
                    HStack(spacing: 12) {
                        if let foodId = ingredient.foodId, availableIngredients.contains(foodId) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        
                        Text(ingredient.text)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }

    // Add to Shopping List Button
    private func addToShoppingListButton() -> some View {
        Button(action: {
            showCartSelection = true
        }) {
            HStack {
                Image(systemName: "cart")
                    .foregroundColor(.white)
                Text("Add missing ingredients to cart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.primary2)
            )
        }
    }

    // Nutrition Info Section
    private func nutritionInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrition")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .center, spacing: 24) {
                // Pie chart
                RecipeNutritionPieChart(
                    calories: getCaloriesValue(),
                    protein: getProteinValue(),
                    carbs: getCarbsValue(),
                    fat: getFatValue()
                )
                .frame(height: 220)
                .padding(.top, 8)
                
                // Nutrition details
                HStack(spacing: 16) {
                    nutritionInfoCard(value: formattedCalories(recipe.totalNutrients.energy), label: "Calories", color: Color.orange)
                    nutritionInfoCard(value: formattedNutrient(recipe.totalNutrients.protein), label: "Protein", color: Color(hex: "#FF6B6B"))
                }
                
                HStack(spacing: 16) {
                    nutritionInfoCard(value: formattedNutrient(recipe.totalNutrients.carbs), label: "Carbs", color: Color(hex: "#4ECDC4"))
                    nutritionInfoCard(value: formattedNutrient(recipe.totalNutrients.fat), label: "Fat", color: Color(hex: "#FFE66D"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // Nutrition info card
    private func nutritionInfoCard(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
    }
    
    // Helper functions to get nutritional values
    private func getCaloriesValue() -> Double {
        if let nutrient = recipe.totalNutrients.energy {
            return nutrient.quantity
        }
        return 0
    }
    
    private func getProteinValue() -> Double {
        if let nutrient = recipe.totalNutrients.protein {
            return nutrient.quantity
        }
        return 0
    }
    
    private func getCarbsValue() -> Double {
        if let nutrient = recipe.totalNutrients.carbs {
            return nutrient.quantity
        }
        return 0
    }
    
    private func getFatValue() -> Double {
        if let nutrient = recipe.totalNutrients.fat {
            return nutrient.quantity
        }
        return 0
    }

    // Helper to format calorie values (no unit)
    private func formattedCalories(_ nutrient: EdamamRecipeNutrient?) -> String {
        if let nutrient = nutrient {
            return String(format: "%.0f", nutrient.quantity)
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

    private func addMissingIngredients(to shoppingList: ShoppingList) {
        for ingredient in recipe.ingredients {
            if let foodId = ingredient.foodId, !availableIngredients.contains(foodId) {
                // Use the generic name from the parsed ingredient if available; fallback to ingredient.food
                let genericName = ingredient.parsed?.first?.food ?? ingredient.food
                let cartItem = CartItem(name: genericName, price: 0.0, quantity: 1)
                shoppingList.items.append(cartItem)
            }
        }
    }
    
    private func additionalInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recipe Information")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                if let dietLabels = recipe.dietLabels, !dietLabels.isEmpty {
                    infoRow(title: "Diet Labels", value: dietLabels.joined(separator: ", "))
                }
                
                if let healthLabels = recipe.healthLabels, !healthLabels.isEmpty {
                    infoRow(title: "Health Labels", value: healthLabels.joined(separator: ", "))
                }
                
                if let cuisineType = recipe.cuisineType, !cuisineType.isEmpty {
                    infoRow(title: "Cuisine Type", value: cuisineType.joined(separator: ", "))
                }
                
                if let mealType = recipe.mealType, !mealType.isEmpty {
                    infoRow(title: "Meal Type", value: mealType.joined(separator: ", "))
                }
                
                if let dishType = recipe.dishType, !dishType.isEmpty {
                    infoRow(title: "Dish Type", value: dishType.joined(separator: ", "))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }

    // Bottom Buttons Section
    private func bottomFixedButtons() -> some View {
        HStack(spacing: 12) {
            Button(action: {
                if let url = URL(string: recipe.url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("View Full Recipe")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.primary2)
                    )
            }
            .frame(width: UIScreen.main.bounds.width * 0.65)
            
            Button(action: {
                navigateToChat = true
            }) {
                Text("Ask AI")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primary2, lineWidth: 2)
                    )
            }
            .frame(width: UIScreen.main.bounds.width * 0.25)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -4)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}

// Nutrition Pie Chart
struct RecipeNutritionPieChart: View {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    // Chart colors
    private let proteinColor = Color(hex: "#FF6B6B")
    private let carbsColor = Color(hex: "#4ECDC4")
    private let fatColor = Color(hex: "#FFE66D")
    
    private var totalMacros: Double {
        max(protein + carbs + fat, 1.0)
    }
    
    private var proteinAngle: Double {
        360.0 * (protein / totalMacros)
    }
    
    private var carbsAngle: Double {
        360.0 * (carbs / totalMacros)
    }
    
    private var fatAngle: Double {
        360.0 * (fat / totalMacros)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Empty circle with border if no data
                if totalMacros <= 1.0 {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 170, height: 170)
                } else {
                    // Chart background
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 20)
                        .frame(width: 170, height: 170)
                    
                    // Carbs slice
                    PieSliceArc(startAngle: 0, endAngle: carbsAngle, innerRadiusFraction: 0.65)
                        .fill(carbsColor)
                        .frame(width: 170, height: 170)
                    
                    // Protein slice
                    PieSliceArc(startAngle: carbsAngle, endAngle: carbsAngle + proteinAngle, innerRadiusFraction: 0.65)
                        .fill(proteinColor)
                        .frame(width: 170, height: 170)
                    
                    // Fat slice
                    PieSliceArc(startAngle: carbsAngle + proteinAngle, endAngle: 360, innerRadiusFraction: 0.65)
                        .fill(fatColor)
                        .frame(width: 170, height: 170)
                }
                
                // Calories in center
                VStack(spacing: 4) {
                    Text("\(Int(calories))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("calories")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                macroLegendItem(color: carbsColor, name: "Carbs", value: "\(Int(carbs))g", percent: Int(round(carbs / totalMacros * 100)))
                macroLegendItem(color: proteinColor, name: "Protein", value: "\(Int(protein))g", percent: Int(round(protein / totalMacros * 100)))
                macroLegendItem(color: fatColor, name: "Fat", value: "\(Int(fat))g", percent: Int(round(fat / totalMacros * 100)))
            }
        }
    }
    
    private func macroLegendItem(color: Color, name: String, value: String, percent: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        
                    Text("(\(percent)%)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// Arc-style pie slice shape
struct PieSliceArc: Shape {
    var startAngle: Double
    var endAngle: Double
    var innerRadiusFraction: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * innerRadiusFraction
        
        let startAngleRadians = startAngle * Double.pi / 180 - Double.pi / 2
        let endAngleRadians = endAngle * Double.pi / 180 - Double.pi / 2
        
        var path = Path()
        
        // Outer arc
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .radians(startAngleRadians),
            endAngle: .radians(endAngleRadians),
            clockwise: false
        )
        
        // Line to inner arc
        path.addLine(to: CGPoint(
            x: center.x + innerRadius * Foundation.cos(endAngleRadians),
            y: center.y + innerRadius * Foundation.sin(endAngleRadians)
        ))
        
        // Inner arc
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: .radians(endAngleRadians),
            endAngle: .radians(startAngleRadians),
            clockwise: true
        )
        
        // Close path
        path.closeSubpath()
        return path
    }
}
