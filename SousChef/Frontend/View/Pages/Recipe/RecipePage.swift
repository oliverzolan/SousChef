import SwiftUI

struct RecipeDetailView: View {
    let recipe: EdamamRecipeModel

    @State private var isFavorite = false
    @State private var isAddedToShoppingList = false
    @State private var availableIngredients: Set<String> = []
    @StateObject private var recipeApiComponent = EdamamRecipeComponent()


    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        topImageSection()
                        ratingSection()
                        Divider()
                        ingredientsSection()
                        addToShoppingListButton()
                        Divider()
                        nutritionInfoSection()
                    }
                    .padding(.top)
                }
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .onAppear {
                loadPantryIngredients()
            }
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
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: 70)
                        .shadow(radius: 10)

                    HStack {
                        Text(recipe.label)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .minimumScaleFactor(0.5)
                    }
                }
                .padding(.top, 20)
            }
            .padding(.top, 40)
        }
        .padding(.top, -50)
    }

    // Rating Section
    private func ratingSection() -> some View {
        HStack {
            Text("Rating: ")
                .font(.headline)
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < 4 ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
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

    // Add to Shopping List Button
    private func addToShoppingListButton() -> some View {
        Button(action: {
            isAddedToShoppingList.toggle()
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
        VStack(alignment: .leading) {
            Text("Nutrition Info")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            HStack(spacing: 15) {
                nutritionCard(label: "2,036", subtitle: "Calories")
                nutritionCard(label: "94.1 g", subtitle: "Protein")
            }
            HStack(spacing: 15) {
                nutritionCard(label: "282.4 g", subtitle: "Carbs")
                nutritionCard(label: "58.8 g", subtitle: "Fat")
            }
        }
    }

    // Load Pantry Ingredients
    private func loadPantryIngredients() {
            print("🔄 Loading Pantry Ingredients...")

            var convertedIngredients: [EdamamIngredientModel] = []

            for ingredient in recipe.ingredients {
                let foodId = ingredient.foodId ?? ""
                let label = ingredient.food.lowercased()
                let category = ingredient.foodCategory
                let image = ingredient.image
                let nutrients = EdamamIngredientNutrients(energy: nil, protein: nil, fat: nil, carbs: nil, fiber: nil)

                print("📝 Processing Ingredient: \(label) with ID: \(foodId)")

                let convertedIngredient = EdamamIngredientModel(
                    foodId: foodId,
                    label: label,
                    category: category,
                    categoryLabel: nil,
                    image: image,
                    nutrients: nutrients
                )
                convertedIngredients.append(convertedIngredient)
            }

            print("✅ Converted Ingredients Ready: \(convertedIngredients.count) items")

            // Use the persistent recipeApiComponent for comparison
            recipeApiComponent.compareRecipeIngredientsWithPantry(recipeIngredients: convertedIngredients) { result in
                switch result {
                case .success(let matchedIngredients):
                    DispatchQueue.main.async {
                        print("✅ Matched Ingredients: \(matchedIngredients)")
                        self.availableIngredients = matchedIngredients
                    }
                case .failure(let error):
                    print("❌ Error comparing ingredients: \(error)")
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
        .background(Color.red.opacity(0.8))
        .cornerRadius(15)
    }
}
