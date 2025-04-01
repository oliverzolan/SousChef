import SwiftUI

struct RecipeDetailView: View {
    let recipe: EdamamRecipeModel

    @State private var isFavorite = false
    @State private var isAddedToShoppingList = false
    @State private var availableIngredients: Set<String> = []

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {

                        // Top Rounded Background with Recipe Image
                        ZStack(alignment: .topLeading) {
                            // Rounded Rectangle Background with Static Color
                            RoundedRectangle(cornerRadius: 30)
                                .fill(AppColors.secondary2)
                                .frame(width: UIScreen.main.bounds.width, height: 370)
                                .offset(y: -70)
                                .ignoresSafeArea(edges: .top)

                            // Recipe Image 
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

                                // Title Card with Center-Aligned Text and Overflow Handling
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

                        // Rating and Servings
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

                        Divider()

                        // Ingredients Section
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
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
                        }
                        .padding(.horizontal)

                        // Add to Shopping List Button
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

                        Divider()

                        // Nutrition Info
                        Text("Nutrition Info")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        // Nutrition Cards
                        HStack(spacing: 15) {
                            nutritionCard(label: "2,036", subtitle: "Calories")
                            nutritionCard(label: "94.1 g", subtitle: "Protein")
                        }
                        HStack(spacing: 15) {
                            nutritionCard(label: "282.4 g", subtitle: "Carbs")
                            nutritionCard(label: "58.8 g", subtitle: "Fat")
                        }
                    }
                    .padding(.top)
                }

                // Bottom Button Bar
                HStack(spacing: 10) {
                    if let url = URL(string: recipe.url) {
                        Link(destination: url) {
                            Text("Take Me to Recipe")
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.6, minHeight: 35)
                                .padding(.vertical, 5)
                                .background(AppColors.primary2)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }

                    Button(action: {
                        print("Ask AI tapped")
                    }) {
                        Text("Ask AI")
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.35, minHeight: 35)
                            .padding(.vertical, 5)
                            .foregroundColor(AppColors.primary2)
                            .background(Color.clear)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AppColors.primary2, lineWidth: 2)
                            )
                    }
                }
                .padding()
                .background(Color.white)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .onAppear {
                loadPantryIngredients()
            }
        }
    }

    private func loadPantryIngredients() {
        let recipeApiComponent = EdamamRecipeComponent()
        
        let convertedIngredients = recipe.ingredients.map { ingredient in
            EdamamIngredientModel(
                foodId: ingredient.foodId ?? "",
                label: ingredient.food,
                category: ingredient.foodCategory,
                categoryLabel: nil,
                image: ingredient.image,
                nutrients: EdamamIngredientNutrients(energy: nil, protein: nil, fat: nil, carbs: nil, fiber: nil)
            )
        }
        
        recipeApiComponent.compareRecipeIngredientsWithPantry(recipeIngredients: convertedIngredients) { result in
            switch result {
            case .success(let matchedIngredients):
                DispatchQueue.main.async {
                    print("Matched Ingredients: \(matchedIngredients)")
                    self.availableIngredients = matchedIngredients
                }
            case .failure(let error):
                print("Error comparing ingredients: \(error)")
            }
        }
    }

    // Nutrition Card Function
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
